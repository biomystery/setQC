
# load library ------------------------------------------------------------
require(knitr)
#require(kableExtra)
require(googlesheets)
require(DT)
# devtools::install_github("jennybc/googlesheets")
require(htmltools)
require(highcharter)
require(dplyr)
require(tidyr)
#require(evaluate)

#libQC_dir <- "~/mnt/tscc_home/data/outputs/libQCs/"
libQC_dir <- "/projects/ps-epigen/outputs/libQCs/"
# load sample info from msTracking --------------------------------------

getSampleTable <- function(lib_ids){
    sample_file <- paste0(setQC_dir,"/sample_table.csv")
  if(file.exists(sample_file)){
    if (system(paste0("wc -l ",sample_file,"|grep -o '[0-9]\\+'"),intern = T)!="1")
      return(read.csv(file = sample_file,
                      stringsAsFactors = F,check.names = F))
  }else{
    #print("get Sample info from gs")
    require(googlesheets)
    suppressPackageStartupMessages(require(dplyr))
    gs_ls() # for the auth
    gs_mseqts <- gs_key("1DqQQ0e5s2Ia6yAkwgRyhfokQzNPfDJ6S-efWkAk292Y")
    sample_table <- gs_mseqts%>% gs_read(range=cell_limits(c(3,1),c(NA,15)))
    sample_table <- subset(sample_table, `Sequencing ID` %in% lib_ids)[,-c(5,6,7)] #member initial, date, lib ID 
    write.csv(file=sample_file,sample_table,row.names = F)
    sample_table
  }
}




# load enrionment varialbes -----------------------------------------------



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
  sample_table$`Sequencing ID`
  colnames(qc_table)
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

require(htmltools)
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
