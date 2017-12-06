#'---
#'params:
#'  set_name: "Pfizer_2017-11-30"
#'  libs: "48 49 50 51 52 53 54 55 56 57"
#'  setQC_dir: "./"
#'  libQC_dir: "./"
#'  update_gs: F
#'  has_sample_table: T
#'title: "Report for `r params$set_name`"
#'output:
#'  html_document:
#'    theme: united
#'    number_sections: no
#'    highlight: tango
#'    smart: TRUE
#'    toc: true
#'    toc_depth: 2
#'    toc_float: true
#'author: "Frank (zhangc518@gmail.com) @ UCSD Center for Epigenomics"
#'date: "`r date()`"
#'---
#'<hr style="border: 1px dashed grey;" />
#+ init, echo=F,warning=F,message=F
# load the candidate files
attach(params)
no_libs <- length(libs)
source('./libs.R')
if(update_gs)
    updateSetQC_gs()

libs.showname <- sub("_S[0-9]+_L[0-9]+","",libs)

#' # Sample info.
#+ check_sample_info,echo=F,warning=F,cache=F,message=F
if(has_sample_table) {
    sample_table<- getSampleTable(libs.showname)
    libs.showname <- sample_table$`Label (for QC report)`
    kable(sample_table)
}



#' # Fastq files {.tabset .tabset-fade .tabset-pills}

#' ## Sequence sources (potential contamination)
#+ fastq_screen,echo=F,message=F,warning=F
tlist <- list()
tlist[[1]]<- plotSource()
tagList(tlist)

#' ## Sequencing Quality
#+ fastq_module,echo=F,message=F,warning=F
# need runMutliQC and move the figures to here first
fastqcfils <- list.files(path = paste0(setQC_dir,"/multiqc_plots/png/"),pattern = "fastqc*")
img_f<- as.character(sapply(fastqcfils,function(x) paste0("./multiqc_plots/png/",x)))
thumbnail("Per base N Content", grep("per_base_n_content",img_f,value=T))
thumbnail("Mean Quality Scores", grep("base_sequence",img_f,value=T))
thumbnail("Per Sequence Quality Scores",  grep("per_sequence_quality",img_f,value=T))
div(class="row")
thumbnail("Per Sequence GC content",  grep("gc.*Percentage",img_f,value=T))
thumbnail("Sequence Duplication Levels",  grep("duplication",img_f,value=T))
thumbnail("Sequence Length Distribution",  grep("length",img_f,value=T))
div(class="row")
a(href="./multiqc_report.html",class="btn btn-link","see  details (leave setQC)")


#' # Mappability

#' ## Reads yeild table {.tabset .tabset-fade .tabset-pills}

#' ### Read yield (%) after each step
#+ reads_yeild,echo=F
libQC_table <- getLibQCtable(libs) # need determined by the input
reads_list <- getReadsTable(libQC_table)
datatable(reads_list$reads_yield,colnames=libs.showname)%>%
    formatPercentage(1:length(libs),digits=0)


#' ### Read counts after each step
#+ reads_counts_table, echo=F
datatable(reads_list$reads_count,colnames=libs.showname)%>%
    formatCurrency(1:length(libs),currency="",digits=0)

#' ##  Mitochondrial reads fraction
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

#' ##  TSS enrichment {.tabset .tabset-fade .tabset-pills}
#' ### TSS enrichement plots

#+ tss_enrich_plot,echo =F, warning=F
#require(evaluate)
tss_plots <- getherTSSplot(libs)
tss_enrich <- libQC_table[grep('TSS',rownames(libQC_table)),]
show_tss <- function(i) paste(libs.showname[i],signif(as.numeric(tss_enrich[i]),4),sep = ' : ')

tmp <- sapply( 1:length(libs), function(i)
  thumbnail(show_tss(i),tss_plots[i],colsize ='col-sm-3' ))
tagList(tmp)
div(class='row')

#' ### Average TSS enrichement compare
#+ avg_tss,echo=F,warning=F,message=F
# read data

 rd<-lapply(list.files(paste0(setQC_dir,"/images/"),"*.txt"),
           function(f)
    read.delim(paste0(setQC_dir,"/images/",f),header = F))

rd <- do.call(cbind,rd); names(rd) <- libs.showname
rd$TSS <- seq(-2000,2000,length.out = nrow(rd));

# hchart function: https://cran.r-project.org/web/packages/highcharter/vignettes/charting-data-frames.html
tlist <- list()
tlist[[1]]<-hchart(rd %>% gather(key = "libs",value = "avg_tss_enrichment",1:no_libs),
       "line",hcaes(x=TSS,y=avg_tss_enrichment,group=libs))
tagList(tlist)

#' ### Max TSS enrichement compare
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



#' ### FROT (Fraction of reads overlap TSS)

#+ FRoT, echo=F
tlist[[1]]<- hchart(pd.3, "column", hcaes(x = libs, y =  Fraction.of.reads.in.promoter.regions ))
tagList(tlist)


#' ## Insert size & GC bias {.tabset .tabset-fade .tabset-pills}
#' ### Insert size distribution

#+ insert_size,echo =F,warning=F
tlist[[1]]<- plotMultiQC(data.file=paste0(setQC_dir,"/multiqc_data/mqc_picard_insert_size_Percentages.txt"),
                         xlab="Insert Size (bp)",ylab="Percentage of Counts")
tagList(tlist)

#' ### GC bias in final bam
#+ gc,echo =F,warning=F

tlist[[1]]<- plotMultiQC(data.file=paste0(setQC_dir,"/multiqc_data/mqc_picard_gcbias_plot_1.txt"))
tagList(tlist)



#' # Peaks
#' ## Peak basics {.tabset .tabset-fade .tabset-pills}

#' ### Raw peak numbers
#+ raw_peak_num,echo =F
raw_peak_number <- libQC_table[grep("Raw peaks",rownames(libQC_table)),]
raw_peak_number<- sapply(raw_peak_number,function(x)
  as.numeric(unlist(strsplit(as.character(x),split = " [-] "))[1]))
pd.raw_peak_number <- data.frame(raw_peak_number=raw_peak_number,
                                 libs=libs.showname)
tlist[[1]]<- hchart(pd.raw_peak_number, "column", hcaes(x = libs, y =  raw_peak_number ))
tagList(tlist)



#' ### FRiP (Fraction of reads in Peak region)

#+ FRip,echo=F
tlist[[1]]<- hchart(pd.3, "column", hcaes(x = libs, y =  Fraction.of.reads.in.called.peak.regions ))
tagList(tlist)

#' ## Peak advanced {.tabset .tabset-fade .tabset-pills}

#' ### Correlation matrix & Peak Intensity Scatter
#+ app,echo=F,message=F,warning=F
relative_dir <- sub("/home/zhc268/data/outputs/setQCs(/)+","",setQC_dir)
tags$iframe(class="embed-responsive-item",
            width="90%",
            height="750px",
            src= paste0("http://epigenomics.sdsc.edu:3838/setQCs/",relative_dir))


#' ### PCA
#+ pca,echo=F,message=F,warning=F
if(length(libs)>2){
    require(scatterD3)
    if(!file.exists(paste0(setQC_dir,"/data/avgOverlapFC.tab"))){
        system(paste("calcOverlapAvgFC.sh -g",tolower(sample_table$species[1]),"-d",setQC_dir,"-l including_libs.txt")
    }
    pd <- read.table(paste0(setQC_dir,"/data/avgOverlapFC.tab"))
    pd.log2 <- log2(subset(pd,apply(pd,1,max)>2)+1)
    pd.pca <- prcomp(t(pd.log2),center =T,scale. = T )
    perct <- as.numeric(round(summary(pd.pca)$importance[2,1:2]*100))

    tlist[[1]]<-scatterD3(pd.pca$x[,1],pd.pca$x[,2],lab = as.character(libs.showname),point_size = 100,
                          xlab = paste0("PC1: ",perct[1],"%"),
                          ylab = paste0("PC2: ",perct[2],"%"),
                          point_opacity = 0.5,hover_size = 4, hover_opacity = 1,lasso = T,
                          width = "500px",height = "500px")
    tagList(tlist)}else{
                      tags$p('Lib number in this set is <=2 ')
}

#' # LibQC table
#+ libqc_table,echo=F,message=F
datatable(libQC_table,colnames=libs.showname)



#' # Tracks & Download {.tabset .tabset-fade .tabset-pills}
#' ## Browser
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

#' ## Download Links
#+ track_download, echo=F

tags$iframe(class="embed-responsive-item",
            width="1340px",
            height="750px",
            src= "./download/")


