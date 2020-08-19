#'---
#'always_allow_html: yes
#'params:
#'  set_name: "Pfizer_2017-11-30"
#'  libs_file: ""
#'  setQC_dir: "./"
#'  libQC_dir: "./"
#'  update_gs: F
#'  has_sample_table: T
#'  padv: T
#'title: "`r params$set_name`"
#'output:
#'  html_document:
#'    theme: united
#'    number_sections: no
#'    highlight: tango
#'    smart: TRUE
#'    toc: true
#'    toc_depth: 2
#'    toc_float: true
#'author: "Zhang (Frank) Cheng (zhangc518@gmail.com), UCSD Center for Epigenomics"
#'date: "`r date()`"
#'---
#'<hr style="border: 1px dashed grey;" />
#+ init, echo=F,warning=F,message=F
# load the candidate files
attach(params)
source('./libs.R')

#htmltools::img(src = "http://epigenomics.sdsc.edu:8000/static/images/CFE_Brandmark-01.png",
#               alt = 'logo', style = 'position:absolute;height:100px; width:auto; top:0; right:0; padding:0px;')


#' # Sample information
#+ check_sample_info,echo=F,warning=F,cache=F,message=F
if(has_sample_table) {
    sample_table<- getSampleTable(libs_file)
    libs.showname <- sample_table[,"Label"]
    kable(sample_table)
}

libs <- sample_table[,"Internal Library ID"]
no_libs <- length(libs)
libs.showname.dic <- libs.showname;names(libs.showname.dic)<-libs



#' # Sequencing metrics
#+ fastq_module,echo=F,message=F,warning=F
# need runMutliQC and move the figures to here first
fastqcfils <- list.files(path = paste0(setQC_dir,"/multiqc_plots/png/"),pattern = "fastqc*")
img_f<- as.character(sapply(fastqcfils,function(x) paste0("./multiqc_plots/png/",x)))
thumbnail("Per base N Content", grep("per_base_n_content",img_f,value=T))
thumbnail("Mean Quality Scores", grep("base_sequence",img_f,value=T))
thumbnail("Per Sequence Quality Scores",  grep("per_sequence_quality",img_f,value=T))
div(class="row")
a(href="./multiqc_report.html",class="btn btn-success btn-sm","View full MultiQC report (in new window)")



#' # Alignment metrics {.tabset .tabset-fade .tabset-pills}
#' ## Alignment statistics (by count)
#+ reads_counts_table, echo=F
libQC_table <- getLibQCtable(libs) # need determined by the input
reads_list <- getReadsTable(libQC_table)

reads_list$reads_count <- updateCounts(reads_list$reads_count)
datatable(reads_list$reads_count,colnames=libs.showname,
          extensions = 'Buttons',
          options =list(
              dom = 'Bfrtip',
              buttons = c('copy', 'csv')
          ))%>% formatCurrency(1:length(libs),currency="",digits=0)

#' ## Alignment statistics (by %)
#+ reads_yeild,echo=F
datatable(reads_list$reads_yield,colnames=libs.showname,
          extensions = 'Buttons',
          options =list(
              dom = 'Bfrtip',
              buttons = c('copy', 'csv')
          ))%>% formatPercentage(1:length(libs),digits=0)

#' ##  Mitochondrial read fraction
#+ mito_frac,echo=F,warning=F

pd <- libQC_table[grep('(Mitochondrial reads)|( peak regions)|(Fraction of reads in promoter regions)',rownames(libQC_table)),]
pd.2 <- t(pd)
for(i in 1:nrow(pd))
  for(j in 1:ncol(pd))
    pd.2[j,i] <-parse_func(pd[i,j])
pd.3<- data.frame(apply(pd.2,2,function(x) as.numeric(x)),
                  libs=libs.showname)
tlist <- list()
tlist[[1]]<- hchart(pd.3, "column", hcaes(x = libs, y = Mitochondrial.reads..out.of.total. ))
tagList(tlist)

#' ## FastQ Screen
#+ fastq_screen,echo=F,message=F,warning=F
tlist <- list()
tlist[[1]]<- plotSource()
tagList(tlist)


#' ## Fragment size distribution
#+ insert_size,echo =F,warning=F
div(class="alert alert-info","ATAC-seq fragments show a characteristic multimodal size distribution reflecting sub-nucleosomal fragments (<100bp), mono-nucleosomal (~200bp), and sometimes multi-nucleosomal fragments at ~150bp intervals beyond that.")
tlist[[1]]<- plotMultiQC(data.file=paste0(setQC_dir,"/multiqc_data/mqc_picard_insert_size_Percentages.txt"),
                         xlab="Insert Size (bp)",ylab="Percentage of Counts")
tagList(tlist)

#' ## GC content after alignment
#+ gc,echo =F,warning=F
div(class="alert alert-info","ATAC-seq alignments tend to have high GC content due to enrichment in promoters and other regulatory sequencing.")
tlist[[1]]<- plotMultiQC(data.file=paste0(setQC_dir,"/multiqc_data/mqc_picard_gcbias_plot_1.txt"))
tagList(tlist)

#' #  Signal-to-noise metrics {.tabset .tabset-fade .tabset-pills}
#' ## TSS enrichement (TSSe)
#+ tss_enrich_plot,echo =F, warning=F
#require(evaluate)
tss_plots <- getherTSSplot()
tss_enrich <- libQC_table[grep('TSS',rownames(libQC_table)),]
show_tss <- function(i) paste(libs.showname[i],signif(as.numeric(tss_enrich[i]),4),sep = ' : ')

tmp <- sapply( 1:length(libs), function(i){
    ii <- grep(libs[i],tss_plots)
    thumbnail(show_tss(i),tss_plots[ii],colsize ='col-sm-3' )})
tagList(tmp)
div(class='row')

#' ## TSSe average profile
#+ avg_tss,echo=F,warning=F,message=F
# read data
l.tmp <- NULL;rd <- list()
if(length(list.files(libQC_dir,paste0(libs[1],".*enrich.txt")))>0){
    for(l in libs){
        f=list.files(libQC_dir,paste0(l,".*enrich.txt"))
        if(length(f)>0) {
            if(length(f)>1) f=grep(paste0(l,"_R"),f,value=T)
            rd[[l]] <- (read.delim(paste0(libQC_dir,f),header = F))
            l.tmp <- c(l.tmp,which(libs==l))
    }}

    rd <- do.call(cbind,rd);names(rd) <- libs.showname[l.tmp]
    rd$TSS <- seq(-2000,2000,length.out = nrow(rd));

    # hchart function: https://cran.r-project.org/web/packages/highcharter/vignettes/charting-data-frames.html
    tlist <- list()
    tlist[[1]]<-hchart(rd %>% gather(key = "libs",value = "avg_tss_enrichment",l.tmp),
                       "line",hcaes(x=TSS,y=avg_tss_enrichment,group=libs))
    tagList(tlist)
}


#' ## TSSe barplot
#+ max_tss,echo=F,warning=F,message=F
# bargraph for the
tss_enrich.pd <- data.frame(libs=libs.showname,
                            TSS_enrichment = as.numeric(tss_enrich))
#plt <- ggplot(tss_enrich.pd,aes(libs,tss_enrich)) + geom_bar(stat = 'identity')
#ggplotly(plt)
# ref: http://rpubs.com/jbkunst/highcharter-129
# ref: https://stackoverflow.com/questions/30509866/for-loop-over-dygraph-does-not-work-in-r

tlist <- list()
tlist[[1]]<- hchart(tss_enrich.pd, "column", hcaes(x = libs, y = TSS_enrichment))

#insert_thumbnail(libs[13],col.size="col-sm-3")
tagList(tlist)



#' ## Fraction of Reads that Overlap TSS (FROT)
#+ FRoT, echo=F

tlist[[1]]<- hchart(pd.3, "column", hcaes(x = libs, y =  Fraction.of.reads.in.promoter.regions ))
tagList(tlist)


#' # Peaks metrics {.tabset .tabset-fade .tabset-pills}
#' ## Peak counts
#+ raw_peak_num,echo =F
div(class="alert alert-info","The number of peaks called per sample. Usually ~100K-200K.")
raw_peak_number <- libQC_table[grep("Raw peaks",rownames(libQC_table)),]
raw_peak_number<- sapply(raw_peak_number,function(x)
    as.numeric(unlist(strsplit(as.character(x),split = " [-] "))[1]))
pd.raw_peak_number <- data.frame(raw_peak_number=raw_peak_number,
                                 libs=libs.showname)
idx.control <- (grepl("control",libs.showname,ignore.case=T))&(grepl("atac",libs.showname,ignore.case=T))
is.all.control <- sum(idx.control)== no_libs

if(is.all.control){ # all controls
    tlist[[1]]<- hchart(pd.raw_peak_number, "column", hcaes(x = libs, y =  raw_peak_number ))
} else{
    tlist[[1]]<- hchart(pd.raw_peak_number[!idx.control,], "column", hcaes(x = libs, y =  raw_peak_number ))
}

tagList(tlist)

#' ## Fraction of Reads in Peaks (FRiP)
#+ FRip,echo=F
div(class="alert alert-info","A metric of signal-to-noise ratio. We generally prefer TSSe or FROT, because these metrics are independent of peak calls which vary between libraries.")
if(is.all.control){
    tlist[[1]]<-    hchart(pd.3, "column", hcaes(x = libs, y =  Fraction.of.reads.in.called.peak.regions ))
}else{
    tlist[[1]]<-    hchart(pd.3[!idx.control,], "column", hcaes(x = libs, y =  Fraction.of.reads.in.called.peak.regions ))
}
tagList(tlist)


#' ## PCA
#+ pca,echo=F,message=F,warning=F
div(class="alert alert-info","Principal Component Analysis of samples based on peak intensity (fold enrichment of calculated background from MACS2).")
padv <- as.logical(padv)
if(padv){
    if(length(system(paste0("find ",setQC_dir,"/data -mtime +1 -name 'avgOverlapFC.tab'"),intern=T))>0 | !file.exists(paste0(setQC_dir,"/data/avgOverlapFC.tab"))){
        if (is.all.control){
            system(paste("calcOverlapAvgFC.sh -g",libQC_table["Genome",1],"-d",setQC_dir,paste(libs,collapse=" ")))
        }else{
            system(paste("calcOverlapAvgFC.sh -g",libQC_table["Genome",1],"-d",setQC_dir,paste(libs[!idx.control],collapse=" ")))
        }
    }

    if(length(libs.showname[!idx.control])>2){
        require(scatterD3)
        pd <- fread(paste0(setQC_dir,"/data/avgOverlapFC.tab"))
        pd.log2 <- log2(subset(pd,apply(pd,1,max)>2)+1)
        pd.log2 <- pd.log2[apply(pd.log2,1,var)!=0,]
        pd.pca <- prcomp(t(pd.log2),center =T,scale. = T )
        perct <- as.numeric(round(summary(pd.pca)$importance[2,1:2]*100))

        tlist[[1]]<-scatterD3(pd.pca$x[,1],pd.pca$x[,2],lab = as.character(libs.showname[!idx.control]),point_size = 100,
                              xlab = paste0("PC1: ",perct[1],"%"),
                              ylab = paste0("PC2: ",perct[2],"%"),
                              point_opacity = 0.5,hover_size = 4, hover_opacity = 1,lasso = T,
                              width = "500px",height = "500px")
        tagList(tlist)
    }else{
        tags$p('Lib number in this set is <=2 ')
    }
}else{
    print("Module disabled")
}

#' ## Correlation matrix
#+ app,echo=F,message=F,warning=F
div(class="alert alert-info","Spearman's correlation matrix based on peak intensity (fold enrichment of calculated background from MACS2).")
relative_dir <- sub("/projects/ps-epigen/outputs/setQCs(/)+","",setQC_dir)
if(padv && no_libs<=10 ){
    tags$iframe(class="embed-responsive-item",
            width="90%",
            height="750px",
            src= paste0("http://epigenomics.sdsc.edu:3838/setQCs/",relative_dir))
}else if(padv && no_libs>10){
    rm(pd);gc()
    colnames(pd.log2)<-libs.showname[!idx.control]
    plotCorrelation(pd.log2)
}else{
    print("Module disabled")
}

#' # Genome browser
#+ track,echo=F

json_src=paste0("http://epigenomegateway.wustl.edu/browser/?genome=",
                libQC_table["Genome",1],
                "&tknamewidth=275&datahub=http://epigenomics.sdsc.edu:8088/",
                relative_dir,
                "/data/tracks_merged_pf.json")

a(href=json_src,class="btn btn-success btn-sm","Open WashU Genome Browser in a new window")
div(class="row")

tags$iframe(class="embed-responsive-item",
            width="1340px",
            height="750px",
            src= json_src)

#' # Download {.tabset .tabset-fade .tabset-pills}
#' ## Batch download
#+ batch_download, echo=F
file_list <- paste0("http://epigenomics.sdsc.edu:8088/",relative_dir,"/download/files.txt")
div(class="alert alert-info","Click",a(href=file_list,'Download file list'), "to download a",
    code("files.txt"), "that contains the list of urls to files in this report. Then run the script bellow on the terminal:")
pre("xargs -n 1 curl -0 -L < files.txt" )

#' ## Individual download links
#+ track_download, echo=F
tags$iframe(class="embed-responsive-item",
            width="1340px",
            height="750px",
            src= "./download/")

#' ## Metadata table
#+ Metadata_table,echo=F,message=F
div(class="alert alert-info","This table contains a variety of QC metrics for each library. For more information about ATAC-seq QC metrics please see:",
            a(href="https://www.encodeproject.org/atac-seq/","https://www.encodeproject.org/atac-seq/"))
idx <- ! rownames(libQC_table) %in% c("`Naive overlap peaks`","`IDR peaks`","`Fraction of reads in enhancer regions`","`Duplicates that are mitochondrial (out of all dups)`")
libQC_table <- libQC_table[idx,]

datatable(libQC_table,colnames=libs.showname,
          extensions = 'Buttons',
          options =list(
              dom = 'Bfrtlip',
              buttons = c('copy', 'csv')
          ))
write.table(libQC_table,file=paste0(setQC_dir,"/libQC.txt"),row.names = T,quote=F,sep="\t",col.names=T)

