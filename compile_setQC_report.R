require(googlesheets)
require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
(set_name_id <- args[1])
(setQC_dir_ <- args[2])
(libQC_dir_ <-  args[3]) # used to pull out libqc files in libs.R
(libs_<- args[4:length(args)]) # the last


## loading tracking sheet 5 here to update the name
# better construct a data base here

getSetName <- function(setID=set_name_id){
  gs_auth(token="/home/zhc268/software/google/googlesheets_token.rds")
    gs_mseqts <- gs_key("1ZD223K4A7SJ0_uw4OvhUOm9BecqDAposRflE9i1Ocms")
    sample_table <- gs_mseqts%>% gs_read(range=cell_limits(c(3,1),c(NA,7)))
    rid <- which(sample_table$SetID==setID)
   paste(sample_table$`Set name (for title of report)`[rid],sample_table$`Date requested`[rid],sep="_")
}


rmarkdown::render("/projects/ps-epigen/software/setQC/setQC_report_any.R",
                  params = list(
                    set_name = _name_ <- getSetName(),
                    libs = libs_,
                    setQC_dir = setQC_dir_,
                    libQC_dir = libQC_dir_
                  ),
                  output_dir=setQC_dir_)

#source activate bds_atac_py3;  Rscript $(which compile_setQC_report.R) 8085 6 42 43 44 45 46 47


