require(googlesheets)
require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
(set_name_id <- args[1])
(setQC_dir_ <- args[2])
(libQC_dir_ <-  args[3]) # used to pull out libqc files in libs.R
(padv_<- args[4]) # peak advanced toggle
(chipsnap_<- args[5]) # peak advanced toggle
(exptype <-  args[6])
(libs_<- args[7:length(args)]) # the last, sorted by name


relative_dir <- sub("/home/zhc268/data/outputs/setQCs(/)+","",setQC_dir_)

## loading tracking sheet 5 here to update the name
# 1. better construct a data base here
# 2. try reduce the gspreadsheet reading times

getSetName <- function(setID=set_name_id){
  gs_auth(token="/home/zhc268/software/google/googlesheets_token.rds")
    gs_mseqts <- gs_key("1ZD223K4A7SJ0_uw4OvhUOm9BecqDAposRflE9i1Ocms")
    sample_table <- gs_mseqts%>% gs_read(range=cell_limits(c(3,1),c(NA,11)))
  rid <- which(sample_table$SetID==setID)


  # update time,version
  surl<- "";#https://github.com/biomystery/setQC/tree/"
  sdir<- "/home/zhc268/software/setQC/"


  gs_mseqts<- gs_mseqts %>% gs_edit_cells(input="ZC",  anchor=paste0("I",3+rid))
  gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=Sys.time(),  anchor=paste0("J",3+rid))
  gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=paste0(surl,system(paste("cd",sdir,";git rev-parse --short HEAD"), intern = TRUE)),
                                          anchor=paste0("K",3+rid))
  url <- ifelse(chipsnap_,paste0("http://epigenomics.sdsc.edu:8088/",relative_dir,"/setQC_report_chip.html"),
         ifelse(exptype=="chip",
                paste0("http://epigenomics.sdsc.edu:8088/",relative_dir,"/setQC_report_chip_test.html"),
                paste0("http://epigenomics.sdsc.edu:8088/",relative_dir,"/setQC_report.html")))
  gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=url,  anchor=paste0("G",3+rid))

  # return set_name
  paste(sample_table$`Set name (for title of report)`[rid],sample_table$`Date requested`[rid],sep="_")
}

(set_name_= getSetName())

print(" before run chip")
if (exptype=="chip"){
        print("run chips seq test")
        rmarkdown::render("/home/zhc268/software/setQC/setQC_report_chip.R",
                      params = list(
                          set_name = set_name_,
                          libs = libs_,
                          setQC_dir = setQC_dir_,
                          libQC_dir = libQC_dir_,
                          padv =padv_,
                          chipsnap =chipsnap_
                      ),
                      output_dir=setQC_dir_)
}else{
    print("run atac")
    rmarkdown::render("/home/zhc268/software/setQC/setQC_report.R",
                      params = list(
                          set_name = set_name_,
                          libs = libs_,
                          setQC_dir = setQC_dir_,
                          libQC_dir = libQC_dir_,
                          padv =padv_
                      ),
                      output_dir=setQC_dir_)}



#source activate bds_atac_py3;  Rscript $(which compile_setQC_report.R) 8085 6 42 43 44 45 46 47


