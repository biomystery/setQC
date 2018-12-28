## load library ------------------------------------------------------------
require(knitr)
##require(kableExtra)
require(RColorBrewer)
require(googlesheets)
require(DT)
## devtools::install_github("jennybc/googlesheets")
require(htmltools)
require(highcharter)
require(tidyverse)
require(ggplot2)
require(data.table)

## load sample info from msTracking --------------------------------------

getSampleTable <- function(lib_ids){
    sample_file <- paste0(setQC_dir,"/sample_table.csv")

    if(length(system(paste0("find ",setQC_dir," -mtime -1 -name 'sample_table.csv'"),intern=T))>0){
        if (system(paste0("wc -l ",sample_file,"|awk  '{print $1}'"),intern = T)!="1")
            return(read.csv(file = sample_file,
                            stringsAsFactors = F,check.names = F))
    }else{

        require(googlesheets)
        suppressPackageStartupMessages(require(dplyr))
        gs_auth(token="/projects/ps-epigen/software/google/googlesheets_token.rds")##/home/zhc268
        gs_ls() ## for the auth
        gs_mseqts <- gs_key("1DqQQ0e5s2Ia6yAkwgRyhfokQzNPfDJ6S-efWkAk292Y")
        sample_table <- gs_mseqts%>% gs_read(range=cell_limits(c(3,1),c(NA,19)))

        q1 <- sample_table$`Sequencing ID` %in% lib_ids
        sample_table <- subset(sample_table, q1)[,c(1,2,3,4,9,10,12)] ##member initial, date, lib ID

        na.id <- is.na(sample_table[,3]); sample_table[na.id,3] <- sample_table[na.id,2]
        sample_table[,3] <- make.names(sample_table$`Label (for QC report)`,unique =T)
        sample_table <- as.data.frame(sample_table)
        rownames(sample_table)<- as.character(sample_table$`Sequencing ID`)
        sample_table <- sample_table[lib_ids,] ## keep same order as libs
        write.csv(file=sample_file,sample_table,row.names = F,quote=F)
        sample_table

    }

}

updateCounts <- function(df){
    frow=df[1,]
    lrow=df[5,]
    fac=ifelse(libQC_table["Paired/Single-ended",] == "Paired-ended",2,1)
    frow=frow/fac;lrow=lrow/fac
    rownames(frow) <- "Total number of molecules sequenced"
    rownames(lrow) <- "Final number of fragments"
    rbind(frow,          df, lrow)
}

updateSetQC_gs <- function(){
    gs_auth(token="/projects/ps-epigen/software/google/googlesheets_token.rds")
    gs_mseqts <- gs_key("1ZD223K4A7SJ0_uw4OvhUOm9BecqDAposRflE9i1Ocms")
    sample_table <- gs_mseqts%>% gs_read(range=cell_limits(c(1,1),c(NA,7)))
    rid <- which(sample_table$`Set QC index`==paste0("Set_",set_no))
#### edit: https://rawgit.com/jennybc/googlesheets/master/vignettes/basic-usage.html

    ## 1. updated - time
    sample_table$Updated[rid] <- Sys.time()
    gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample_table$Updated,  anchor="F2")

    ## 2. version
    sample_table$version[rid] <- system("git rev-parse --short HEAD", intern = TRUE)
    gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample_table$version,  anchor="G2")
}

## contamination plot  --------------------------------------

parseFastqScreen<- function(fn="JYH_109_R1_screen.txt"){
    df <- list.files(path=libQC_dir,pattern=fn,recursive=T,full.names=T)
    if(length(df)==0) return("")

    pd <- read.delim(df,skip = 1,check.names=F,stringsAsFactors = F)
    pd <- pd[,c(1,grep("\\%",colnames(pd)))]
    pd <- pd[,-2] ## drop unmapped

    um <- as.numeric(unlist(strsplit(pd$Genome[nrow(pd)],split = ":"))[2])
    pd$Genome[nrow(pd)] <- "No hits"; pd$`%One_hit_one_genome`[nrow(pd)] <- um
    pd[is.na(pd)] <- 0
    ##pd$`%total_alignment` <- apply(pd[,2:ncol(pd)],1,sum)
    pd %>% gather("type","Percentage_Aligned",-1) %>% mutate(sample=sub("_screen.txt","",fn))
    ##pd %>% mutate(sample=sub("_screen.txt","",fn))
}

parseFastqScreen_perLib <- function(lib){
    out= rbind(parseFastqScreen(fn=paste0(lib,"_R1.*_screen.txt")), ## . is required here to search for multiple chr
               parseFastqScreen(fn=paste0(lib,"_R2.*_screen.txt")))
    if(ncol(out)== 4){
        return(out)
    } else{
        return(parseFastqScreen(fn=paste0(lib,".*_screen.txt"))) ## for SE
    }
}

plotSource <- function(pd=do.call(rbind,lapply(libs, parseFastqScreen_perLib))){
    pd.new <-pd %>% group_by(name=type,
                             stack=sample)%>% do(data = .$Percentage_Aligned,
                                                 categories= .$Genome)
    pd.new <- pd.new %>% filter(name!="")
    pd.new$color = rep(brewer.pal(4,"Set3"),each=nrow(pd.new)/4)
    pd.new$linkedTo = rep(":previous",nrow(pd.new))
    pd.new.list <- list_parse(pd.new)
    for(i in seq(1,nrow(pd.new),by = nrow(pd.new)/4)) pd.new.list[[i]]$linkedTo =NULL

    ## ref = https://stackoverflow.com/questions/38093229/multiple-series-in-highcharter-r-stacked-barchart
    highchart() %>%
        hc_chart(type = "column") %>%
        hc_xAxis(categories= pd.new$categories[[1]]
                 )%>%
        hc_yAxis(title = list(text = "Percentage Aligned"),
                 min=0,
                 max=100) %>%
        hc_plotOptions(column = list(
                           dataLabels = list(enabled = FALSE),
                           groupPadding = .02,
                           pointPadding = 0,
                           stacking = "normal")
                       ) %>%
        hc_add_series_list(pd.new.list) %>%
        hc_tooltip(formatter=JS("function (){
                            return '<b>' + this.series.stackKey.replace('column','') + ' - ' + this.x + '</b><br/>' + \n\
                            this.series.name + ': ' + this.y + '%<br/>' + \n\
                            'Total Alignment: ' + this.point.stackTotal + '%';}"))
    ## ref: https://github.com/jbkunst/highcharter/issues/54
    ## ref: https://github.com/ewels/MultiQC/blob/master/multiqc/modules/fastq_screen/fastq_screen.py

}



## re plot MultiQC file  -----------------------------------------------
plotMultiQC <- function(data.file="../Set_6/multiqc_data/mqc_picard_gcbias_plot_1.txt",ylab="Normalized Coverage",xlab="GC%"){

    if(!file.exists(data.file))    return("")
    r2.list <- lapply(readLines(data.file),function(x) as.numeric((unlist(strsplit(x,split = "\t")))[-1]))

    if(length(r2.list) > 2* no_libs){
        df <- lapply(1:no_libs,function(i) data.frame(x=r2.list[[2*i-1]],y=r2.list[[2*i]],libs_=libs.showname[i]))
    }else{
        df <- lapply(1:no_libs,function(i) data.frame(x=r2.list[[1]],y=r2.list[[i+1]],libs_=libs.showname[i]))
    }

    df <- do.call(rbind,c(df,row.name=NULL))

    hchart(df,"spline",hcaes(x=x,y=y,group=libs_)) %>%
        hc_plotOptions(series=list(
                           marker = list(enabled =FALSE)
                       )) %>%
        hc_yAxis(title=list(text=ylab))%>%
        hc_xAxis(title=list(text=xlab))
}

## ref: https://github.com/jbkunst/highcharter/issues/302 ; remove marker


## parse libQC results -----------------------------------------------------
getLibQCtable <- function(lib_ids){
    ##print("getting libQC table")
    parseLibQC <- function(lib=libs[1]){
###### Parse one libQC result
        libQC_report_file <- system(paste("find",libQC_dir, "-name",paste0(lib,"_R*_qc.txt")),intern=T)
        if(length(libQC_report_file)==0)  libQC_report_file <- system(paste("find",libQC_dir, "-name",paste0(lib,".*_qc.txt")),intern=T)
        if(length(libQC_report_file)==0)  libQC_report_file <- system(paste("find",libQC_dir, "-name",paste0(lib,"_qc.txt")),intern=T)
        if(length(libQC_report_file)>1) libQC_report_file <- grep("trim",libQC_report_file,value=T)

        qc <- read.table(libQC_report_file,sep = "\t",header = F,fill = T,col.names = paste0("v",seq(3)),
                         stringsAsFactors = F)
        qc$v3 <- signif(qc$v3,digits = 3)
        qc.2 <- data.frame(sapply(1:nrow(qc),function(x) sub(" \\| NA","",paste(qc$v2[x],qc$v3[x],sep = " | "))),
                           stringsAsFactors = F)
        rownames(qc.2)<- qc$v1
        colnames(qc.2)<- lib
        qc.2
    }
    qcs <- lapply(lib_ids,parseLibQC)
    idx <-  Reduce(intersect, lapply(qcs,rownames))
    qc_table<- t(do.call(rbind, lapply(qcs, "[", idx, )))
    rownames(qc_table) <- idx
    colnames(qc_table) <- lib_ids

    ##qc_table <- do.call(what = cbind,args = lapply(lib_ids,parseLibQC))
    ##qc_table<-qc_table[-c(1:2,16:24,26:27,35,37),]

    if(exists("sample_table")){
        if(all.equal(sample_table$`Sequencing ID`, colnames(qc_table))){
            qc_table<-rbind(sample_table$`sample ID (from MSTS)`,qc_table)
            rownames(qc_table)[1] <- "sampleId"
        }
    }
    qc_table
}

getReadsTable <- function(qc_table=libQC_table){
    a1 <- subset(qc_table,grepl("Read count",rownames(qc_table)))
    rtable<- a1%>%  as.tibble %>% mutate_all(as.character) %>% mutate_all(as.numeric)%>%as.data.frame
    rownames(rtable) <- rownames(a1)

    ryield = apply(rtable,2,function(x) sapply(1:length(x),function(i) (x[i])/(x[1])))
    rownames(ryield) <- rownames(rtable)
    list(reads_count =rtable,
         reads_yield = ryield)
}

percent <- function(x, digits = 2, format = "f", ...) {
    paste0(formatC(100 * x, format = format, digits = digits, ...), "%")
}

## TSS plots --------------------------------------------
##  gether all the tss plots
getherTSSplot <- function(){
    paste0("./libQCs/",list.files(path = libQC_dir,pattern = "*_large_tss-enrich.png"))
}


thumbnail <- function(title="", img, caption = TRUE,colsize="col-sm-4") {
    tagList(div(class =colsize ,
                a(class = "thumbnail", title = title, href = img,
                  img(src = img),
                  div(class = ifelse(caption, "caption", ""),
                      ifelse(caption, title, "")
                      )
                  )
                ))
}

parse_func <- function (x="10844795 | 0.21")
    unlist(strsplit(x,split = " [|] "))[2]
## Chip seq plots --------------------------------------------
showDF<- function(df){
    brks <- seq(min(df),max(df),length.out = 50)
    clrs <- round(seq(255, 40, length.out = length(brks) + 1), 0) %>%
        {paste0("rgb(255,", ., ",", ., ")")}
    datatable(df,options = list(pageLength=nrow(df))) %>%
        formatStyle(names(df),
                    backgroundColor = styleInterval(brks, clrs))
}

plotJSD <- function(){
    fs <- list.files(path = libQC_dir,pattern = "*jsd.dat",full.names = F)

    ## filter ophan input group
    ophan.input <- libs.info %>%
        rownames_to_column("libs")%>%
        filter(!group %in% libs.info.input$group)

    if(nrow(ophan.input)>0)
        fs <- fs[-sapply(ophan.inputx$libs,
                         function(x) grep(x,fs)) ]
    pd.jsd <- sapply(fs, plotJSD_getDat)
    colnames(pd.jsd) <- sub("_jsd.dat.*","",colnames(pd.jsd))
    pd.jsd <- rbind(pd.jsd,group=libs.info[colnames(pd.jsd),'group'])
    pd.jsd.2 <- do.call(rbind,pd.jsd[1,]) ## merge all treatment libs
    pd.jsd.2 <- pd.jsd.2 %>% rownames_to_column(var = "lib")%>%
        mutate(lib=sub("\\..*","",lib))

    ## first libs in each group
    flibs <-  unique((t(as.data.frame(pd.jsd['group',]))))

    for (l in rownames(flibs)){
        pd.jsd.2 <- rbind(pd.jsd.2,
                          cbind(pd.jsd[[2,l]], ## input
                                lib=libs.info.input$libs[libs.info.input$group==flibs[l,]]))
    }

    pd.jsd.2$lib <- libs.showname.dic[pd.jsd.2$lib]
    hchart(pd.jsd.2,
           "line",hcaes(x=rank,y=frac_reads,group=lib))
}

plotJSD_genDF <- function(dv){
    dv.c <- cumsum(dv[order(dv)])
    dv.c.r <- rank(dv.c,ties.method = "min")-1
    df <- round(data.frame(rank=dv.c.r/(max(dv.c.r)),frac_reads=dv.c/max(dv.c)),3)
    idx <- sample(1:nrow(df),size = 1000)
    df <- rbind(df[idx[order(idx)],],c(rank=1,frac_reads=1))
}

plotJSD_getDat <- function(f){
    dt <-fread(paste0(libQC_dir,f));setDF(dt);
    names(dt) <- c("treat","input")
    pd.jdf <- lapply(dt,plotJSD_genDF)
}
