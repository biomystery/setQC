
# load library ------------------------------------------------------------
require(knitr)
#require(kableExtra)
require(RColorBrewer)
require(googlesheets)
require(DT)
# devtools::install_github("jennybc/googlesheets")
require(htmltools)
require(highcharter)
require(tidyverse)
require(ggplot2)

# load sample info from msTracking --------------------------------------

getSampleTable <- function(lib_ids){
    sample_file <- paste0(setQC_dir,"/sample_table.csv")
  if(file.exists(sample_file)){
    if (system(paste0("wc -l ",sample_file,"|awk  '{print $1}'"),intern = T)!="1")
      return(read.csv(file = sample_file,
                      stringsAsFactors = F,check.names = F))
  }else{
    #print("get Sample info from gs")
    require(googlesheets)
      suppressPackageStartupMessages(require(dplyr))
      gs_auth(token="/home/zhc268/software/google/googlesheets_token.rds")
    gs_ls() # for the auth
    gs_mseqts <- gs_key("1DqQQ0e5s2Ia6yAkwgRyhfokQzNPfDJ6S-efWkAk292Y")
    sample_table <- gs_mseqts%>% gs_read(range=cell_limits(c(3,1),c(NA,15)))
    sample_table <- subset(sample_table, `Sequencing ID` %in% lib_ids)[,-c(5,6,7)] #member initial, date, lib ID
    write.csv(file=sample_file,sample_table,row.names = F)
    sample_table
  }
}


updateSetQC_gs <- function(){
  gs_auth(token="/home/zhc268/software/google/googlesheets_token.rds")
    gs_mseqts <- gs_key("1ZD223K4A7SJ0_uw4OvhUOm9BecqDAposRflE9i1Ocms")
    sample_table <- gs_mseqts%>% gs_read(range=cell_limits(c(1,1),c(NA,7)))
    rid <- which(sample_table$`Set QC index`==paste0("Set_",set_no))
    ## edit: https://rawgit.com/jennybc/googlesheets/master/vignettes/basic-usage.html
    
    # 1. updated - time 
    sample_table$Updated[rid] <- date()
    gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample_table$Updated,  anchor="F2")
    
    # 2. version 
    sample_table$version[rid] <- system("git rev-parse --short HEAD", intern = TRUE)
    gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample_table$version,  anchor="G2")
}

# contamination plot  --------------------------------------

parseFastqScreen<- function(fn="JYH_109_R1_screen.txt"){
  pd <- read.delim(paste0(libQC_dir,sub("_R[1-2]_screen.txt","",fn),"/",fn),
                   skip = 1,check.names=F,stringsAsFactors = F)
  pd <- pd[,c(1,grep("\\%",colnames(pd)))]
  pd <- pd[,-2] # drop unmapped 
  um <- as.numeric(unlist(strsplit(pd$Genome[7],split = ":"))[2])
  pd$Genome[7] <- "No hits"; pd$`%One_hit_one_genome`[7] <- um
  pd[is.na(pd)] <- 0 
  #pd$`%total_alignment` <- apply(pd[,2:ncol(pd)],1,sum)
  pd %>% gather("type","Percentage_Aligned",-1) %>% mutate(sample=sub("_screen.txt","",fn)) 
  #pd %>% mutate(sample=sub("_screen.txt","",fn))
}

parseFastqScreen_perLib <- function(lib)
  rbind(parseFastqScreen(fn=paste0(lib,"_R1_screen.txt")),
        parseFastqScreen(fn=paste0(lib,"_R2_screen.txt")))

plotSource <- function(pd=do.call(rbind,lapply(libs, parseFastqScreen_perLib))){
  pd.new <-pd %>% group_by(name=type,
                           stack=sample)%>% do(data = .$Percentage_Aligned,
                                               categories= .$Genome)
  pd.new$color = rep(brewer.pal(4,"Set3"),each=nrow(pd.new)/4)
  pd.new$linkedTo = rep(":previous",nrow(pd.new))
  pd.new.list <- list_parse(pd.new)
  for(i in seq(1,nrow(pd.new),by = nrow(pd.new)/4)) pd.new.list[[i]]$linkedTo =NULL 
  
  # ref = https://stackoverflow.com/questions/38093229/multiple-series-in-highcharter-r-stacked-barchart
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
  # ref: https://github.com/jbkunst/highcharter/issues/54 
  # ref: https://github.com/ewels/MultiQC/blob/master/multiqc/modules/fastq_screen/fastq_screen.py
  
  }



# re plot MultiQC file  -----------------------------------------------
plotMultiQC <- function(data.file="../Set_6/multiqc_data/mqc_picard_gcbias_plot_1.txt",ylab="Normalized Coverage",xlab="GC%"){

  r2.list <- lapply(readLines(data.file),function(x) as.numeric((unlist(strsplit(x,split = "\t")))[-1]))

  if(length(r2.list) > 2* no_libs){
    df <- lapply(1:no_libs,function(i) data.frame(x=r2.list[[2*i-1]],y=r2.list[[2*i]],libs_=libs[i]))
  }else{
    df <- lapply(1:no_libs,function(i) data.frame(x=r2.list[[1]],y=r2.list[[i+1]],libs_=libs[i]))
  }

  df <- do.call(rbind,c(df,row.name=NULL))

  hchart(df,"spline",hcaes(x=x,y=y,group=libs_)) %>%
    hc_plotOptions(series=list(
      marker = list(enabled =FALSE)
    )) %>%
    hc_yAxis(title=list(text=ylab))%>%
    hc_xAxis(title=list(text=xlab))
}

# ref: https://github.com/jbkunst/highcharter/issues/302 ; remove marker


# parse libQC results -----------------------------------------------------
getLibQCtable <- function(lib_ids,trim=T){
  #print("getting libQC table")
  parseLibQC <- function(lib=libs[1]){
    ### Parse one libQC result
    libQC_report_dir <- paste0(libQC_dir,lib,"/")
    if(trim){
      libQC_report_file <- paste0(libQC_report_dir,list.files(libQC_report_dir,pattern = "trim.PE2SE_qc.txt"))
    }else{
      libQC_report_file <- paste0(libQC_report_dir,list.files(libQC_report_dir,pattern = "_qc.txt"))
    }

    qc <- read.table(libQC_report_file,sep = "\t",header = F,fill = T,col.names = paste0("v",seq(3)),
                     stringsAsFactors = F)
    qc$v3 <- signif(qc$v3,digits = 3)
    qc.2 <- data.frame(sapply(1:nrow(qc),function(x) sub(" \\| NA","",paste(qc$v2[x],qc$v3[x],sep = " | "))),
                       stringsAsFactors = F)
    rownames(qc.2)<- qc$v1
    colnames(qc.2)<- lib
    qc.2
  }
  qc_table <- do.call(what = cbind,args = lapply(lib_ids,parseLibQC))
  qc_table<-qc_table[-c(1:2,16:24,26:27,35,37),]

  if(all.equal(sample_table$`Sequencing ID`, colnames(qc_table))){
    qc_table<-rbind(sample_table$`sample ID (from MSTS)`,qc_table)
    rownames(qc_table)[1] <- "sampleId"
  }
  qc_table
}


getReadsTable <- function(qc_table=libQC_table){
  rtable <- data.matrix(subset(qc_table,grepl("Read count",rownames(qc_table))))
  list(reads_count =rtable,
       reads_yield = apply(rtable,2,function(x) sapply(1:length(x),function(i) x[i]/x[1])))
}

percent <- function(x, digits = 2, format = "f", ...) {
  paste0(formatC(100 * x, format = format, digits = digits, ...), "%")
}

# TSS plots --------------------------------------------
#  gether all the tss plots
getherTSSplot <- function(lib_ids,trim=T){
    image_dir <- paste0(setQC_dir,"/images/")
  system(paste0("mkdir -p ",image_dir))
  if(system(paste0("ls -l ",image_dir," | wc -l")) == "0"){
    sapply(lib_ids, function(x) {
      cmd <- paste0("find ",libQC_dir,x," -name '*large_tss*' -exec cp -n {} ",image_dir," \\;")
      system(cmd)
      cmd <- paste0("find ",libQC_dir,x," -name '*tss-enrich.txt' -exec cp -n {} ",image_dir," \\;")
      system(cmd)
    })}

  if(trim){
    paste0("./images/",list.files(path = image_dir,pattern = "trim.PE2SE_large_tss-enrich.png"))}else{
    paste0("./images/",list.files(path = image_dir,pattern = "*.png"))}
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
