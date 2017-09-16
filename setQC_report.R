#'---
#'params:
#'  libs_no: "48 49 50 51 52 53 54 55 56 57"
#'  set_no: "4_1"
#'title: "Report for Set`r params$set_no `: JYH_`r paste(params$libs_no,collapse=' ')`"
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

#+ echo=F,warning=F,message=F
# load the candidate files 
attach(params)
setQC_dir <- paste0("/projects/ps-epigen/outputs/setQCs/Set_",set_no)
#ibs_no <- unlist(strsplit(libs_no,split = " "))
libs <- sapply(libs_no, function(x) paste0("JYH_",x) )# will replaced by inputs ; ,"_2" for second run
source('./libs.R') # libQC_dir environment 



#' # Sample info. 
#+ echo=F,warning=F,cache=F,message=F


sample_table<- getSampleTable(libs)
kable(sample_table)

#' # QC of Fastq files
#+ echo=F,message=F,warning=F
# need runMutliQC and move the figures to here first 
fastqcfils <- list.files(path = paste0(setQC_dir,"/multiqc_plots/png/"),pattern = "fastqc*")
img_f<- sapply(fastqcfils,function(x){
  paste0("./multiqc_plots/png/",x)
})
thumbnail("", img_f[1])
thumbnail("", img_f[2])
thumbnail("", img_f[5])
div(class="row")
thumbnail("", img_f[4])
thumbnail("", img_f[6])
thumbnail("", img_f[7])
div(class="row")


#' # QC of mappability

#' ## Reads yeild table {.tabset .tabset-fade .tabset-pills}

#' ### Read yield (%) after each step
#+ echo=F
libQC_table <- getLibQCtable(libs,trim = F) # need determined by the input 
reads_list <- getReadsTable(libQC_table)
kable(apply(reads_list$reads_yield,2, function(x) sapply(1:length(x), function(i) round(x[i]*100))),caption = "")



#' ### Read counts after each step
#+ echo=F
kable(reads_list$reads_count,caption = "")


#' ##  Mitochondrial reads fraction 
#+ echo=F,warning=F

pd <- libQC_table[grep('(Mitochondrial reads)|( peak regions)|(Fraction of reads in promoter regions)',rownames(libQC_table)),]
pd.2 <- t(pd)
for(i in 1:nrow(pd))
  for(j in 1:ncol(pd))
    pd.2[j,i] <-parse_func(pd[i,j])
pd.3<- data.frame(apply(pd.2,2,function(x) as.numeric(x)),
                  libs=rownames(pd.2))
tlist <- list()
tlist[[1]]<- hchart(pd.3, "column", hcaes(x = libs, y = Mitochondrial.reads..out.of.total. ))
tagList(tlist)


#' ## TSS enrichement plots

#+ echo =F, warning=F
#require(evaluate)
tss_plots <- getherTSSplot(libs,trim = F)
tss_enrich <- libQC_table[grep('TSS',rownames(libQC_table)),]
show_tss <- function(i) paste(i,signif(as.numeric(tss_enrich[i]),4),sep = ' : ')

tmp <- sapply( 1:length(libs), function(i)
  thumbnail((libs[i]),tss_plots[i],colsize ='col-sm-3' ))
tagList(tmp)
div(class='row')    

#' ## Peak TSS enrichment and FRiT {.tabset .tabset-fade .tabset-pills}

#' ### Max TSS enrichement compare
#+ echo=F,warning=F,message=F
# bargraph for the 

tss_enrich.pd <- data.frame(libs=colnames(tss_enrich),
                            TSS_enrichment = as.numeric(tss_enrich))
#plt <- ggplot(tss_enrich.pd,aes(libs,tss_enrich)) + geom_bar(stat = 'identity')
#ggplotly(plt)
# ref: http://rpubs.com/jbkunst/highcharter-129
# ref: https://stackoverflow.com/questions/30509866/for-loop-over-dygraph-does-not-work-in-r

tlist <- list()
tlist[[1]]<- hchart(tss_enrich.pd, "column", hcaes(x = libs, y = TSS_enrichment))

#insert_thumbnail(libs[13],col.size="col-sm-3")
tagList(tlist)
div(class="row")



#' ### FRiT (Fraction of reads in TSS) 

#+ echo=F
tlist[[1]]<- hchart(pd.3, "column", hcaes(x = libs, y =  Fraction.of.reads.in.promoter.regions ))
tagList(tlist)


#' ## Insert size distribution 

#+ echo =F
thumbnail(img = "./multiqc_plots/png/mqc_picard_insert_size_Percentages.png",colsize = "col-sm-12")


#' ## GC bias in final bam 
#+ echo =F
thumbnail(img = "./multiqc_plots/png/mqc_picard_gcbias_plot_1.png",colsize = "col-sm-12")


#' # QC of peaks {.tabset .tabset-fade .tabset-pills}
#' ## Raw peak numbers 
#+ echo =F
raw_peak_number <- libQC_table[grep("Raw peaks",rownames(libQC_table)),]
raw_peak_number<- sapply(raw_peak_number,function(x)
  as.numeric(unlist(strsplit(as.character(x),split = " [-] "))[1]))
pd.raw_peak_number <- data.frame(raw_peak_number=raw_peak_number,
                                 lib=names(raw_peak_number))
tlist[[1]]<- hchart(pd.raw_peak_number, "column", hcaes(x = libs, y =  raw_peak_number ))
tagList(tlist)



#' ## FRiP (Fraction of reads in Peak region)

#+ echo=F
tlist[[1]]<- hchart(pd.3, "column", hcaes(x = libs, y =  Fraction.of.reads.in.called.peak.regions ))
tagList(tlist)



#' # LibQC table 
#+ echo=F,message=F
datatable(libQC_table)



#' # Tracks
#+ echo=F 

json_src=paste0("http://epigenomegateway.wustl.edu/browser/?genome=",
                libQC_table["Genome",1],
                "&tknamewidth=275&datahub=http://epigenomics.sdsc.edu:8084/Set_",
                set_no,
                "/data/tracks_merged_pf.json")
a(href=json_src,class="btn btn-primary","Open WashU Genome Browser")

tags$iframe(class="embed-responsive-item", 
            width="1340px",
            height="750px",
            src= json_src)


  
  
