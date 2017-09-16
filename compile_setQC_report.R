args <- commandArgs(trailingOnly = TRUE)      
set <- args[1]#4_1
libs <- args[2:length(args)]
set
libs
#libs <- seq(48,57)
#set <- "4_1"


setQC_dir <- paste0("/projects/ps-epigen/outputs/setQCs/Set_",set)

rmarkdown::render("/projects/ps-epigen/software/setQC/setQC_report.R", 
                  params = list(
                    libs_no = libs,
                    set_no = set
                  ),
                  output_dir=setQC_dir)

#source activate bds_atac_py3;  Rscript $(which compile_setQC_report.R) 8085 6 42 43 44 45 46 47
