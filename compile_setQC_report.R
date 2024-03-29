require(googlesheets)
require(tidyverse)
require(data.table)

args <- commandArgs(trailingOnly = TRUE)
(set_name_id <- args[1])
(setQC_dir_ <- args[2])
(libQC_dir_ <-  args[3]) # used to pull out libqc files in libs.R
(padv_<- args[4]) # peak advanced toggle
(chipsnap_<- args[5]) # peak advanced toggle
(exptype <-  args[6])
(libs_file_<- args[7]) # use lib_file
(uid_<- args[8]) # uid
##(set_name_<- args[9]) # set name (real, name_date)
(set_name_<- fread(paste0("~/data/outputs/setQCs/.",set_name_id,".txt"),sep="\t",header=T,stringsAsFactors=F)$Set.Name[1])

(" Deciding which type of experiments")
if (exptype=="chip"){
        message("run chips seq test")
        rmarkdown::render("/home/zhc268/software/setQC/setQC_report_chip.R",
                      params = list(
                          set_name = set_name_,
                          libs_file= libs_file_,
                          setQC_dir = setQC_dir_,
                          libQC_dir = libQC_dir_,
                          padv =padv_,
                          chipsnap =chipsnap_
                      ),
                      intermediates_dir=tempdir(),
                      output_dir=setQC_dir_)
} else if (exptype=="atac_chip"){
        message("run chips seq test")
        rmarkdown::render("/home/zhc268/software/setQC/setQC_report_atac_chip.R",
                      params = list(
                          set_name = set_name_,
                          libs_file= libs_file_,
                          setQC_dir = setQC_dir_,
                          libQC_dir = libQC_dir_,
                          padv =padv_,
                          chipsnap =chipsnap_
                      ),
                      intermediates_dir=tempdir(),
                      output_dir=setQC_dir_)
} else{
    message("run atac")
    rmarkdown::render("/home/zhc268/software/setQC/setQC_report.R",
                      c("html_document"),
                      params = list(
                          set_name = set_name_,
                          libs_file= libs_file_,
                          setQC_dir = setQC_dir_,
                          libQC_dir = libQC_dir_,
                          padv =padv_
                      ),
                      intermediates_dir=tempdir(),
                      output_dir=setQC_dir_)
}



#source activate bds_atac_py3;  Rscript $(which compile_setQC_report.R) 8085 6 42 43 44 45 46 47


