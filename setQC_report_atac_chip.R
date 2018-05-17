#'---
#'params:
#'  set_name: "Pfizer_2017-11-30"
#'  libs: "48 49 50 51 52 53 54 55 56 57"
#'  setQC_dir: "./"
#'  libQC_dir: "./"
#'  update_gs: F
#'  has_sample_table: T
#'  padv: T
#'  chipsnap: F
#'title: "Report for `r params$set_name`"
#'output:
#'  html_document:
#'    theme: yeti
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


#' # Sample info.
#+ check_sample_info,echo=F,warning=F,cache=F,message=F
if(has_sample_table) {
    sample_table<- getSampleTable(libs)
    libs.showname <- sample_table$`Label (for QC report)`
    kable(sample_table)
}
libs.showname.dic <- libs.showname;names(libs.showname.dic)<-libs


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

#' ###  Mitochondrial reads fraction
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
tss_plots <- getherTSSplot()
tss_enrich <- libQC_table[grep('TSS',rownames(libQC_table)),]
show_tss <- function(i) paste(libs.showname[i],signif(as.numeric(tss_enrich[i]),4),sep = ' : ')

tmp <- sapply( 1:length(libs), function(i){
    ii <- grep(libs[i],tss_plots)
    thumbnail(show_tss(i),tss_plots[ii],colsize ='col-sm-3' )})
tagList(tmp)
div(class='row')

#' ### Average TSS enrichement compare
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


#' ### Max TSS enrichement compare
#+ max_tss,echo=F,warning=F,message=F
# bargraph for the

tss_enrich.pd <- data.frame(libs=libs.showname,
                            TSS_enrichment = as.numeric(tss_enrich))
tlist <- list()
tlist[[1]]<- hchart(tss_enrich.pd, "column", hcaes(x = libs, y = TSS_enrichment))
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


#' # ChIP-seq specific
#' ## SNAP-ChIP spikein {.tabset .tabset-fade .tabset-pills}
#' ### Specificty ( %,#hits/#total_hits)
#+ snap_chip_prt,echo =F
if(chipsnap){
    snap.cnt <-read.table(paste0(setQC_dir,"snap.cnt"),
                          col.names = c("barcodes","cnt","sample"))
    snap.cnt.wd <- snap.cnt %>%
        separate(barcodes,c("b_id","b_target","b_rep")) %>%
        select(b_target,cnt,sample) %>%
        group_by(b_target,sample) %>%
        summarise(b_cnt = sum(cnt)) %>%
        spread(sample,b_cnt,fill=as.integer(0))

    df.cnt <- as.data.frame(snap.cnt.wd); rownames(df.cnt) <- df.cnt$b_target;df.cnt$b_target <-NULL
    id.nm <- colnames(df.cnt)
    colnames(df.cnt) <- as.character(libs.showname.dic[id.nm])
    id.nm.me <- grep("me",colnames(df.cnt))
    df.cnt <- df.cnt[,id.nm.me];
    df.prt <- as.data.frame(apply(df.cnt,2,function(x) signif(x/sum(x)*100,2)))
    df.cpm <-as.data.frame(signif(t(t(df.cnt)/as.numeric(reads_list$reads_count[1,id.nm[id.nm.me]])*1000000),2))

    showDF(df.prt)

}else{p('This module is disabled')}

#' ### Spikein count (raw)
#+ snap_chip_cnt,echo =F
if(chipsnap){
    showDF(df.cnt)
}else{
    p('This module is disabled')
}


#' ### Spikein count (cpm)
#+ snap_chip_prt_lib,echo =F
if(chipsnap){
    showDF(df.cpm)
}else{
    p('This module is disabled')
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

#' ## Batch download
#+ batch_download, echo=F
p("click 'Download file list' link bellow to download a 'files.txt' that contains the list of urls to files in this report. Then run the script bellow on the terminal")
file_list <- paste0("http://epigenomics.sdsc.edu:8088/",relative_dir,"/download/files.txt")
a(href=file_list,class="btn btn-outline-info",role="button","Download file list")
pre("xargs -n 1 curl -0 -L < files.txt" )

#' ## Download links
#+ track_download, echo=F
tags$iframe(class="embed-responsive-item",
            width="1340px",
            height="750px",
            src= "./download/")

