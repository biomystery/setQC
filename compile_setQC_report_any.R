args <- commandArgs(trailingOnly = TRUE)
(set_name_ <- args[1])
(setQC_dir_ <- args[2])
(libQC_dir_ <-  args[3])
(libs_<- args[4:length(args)]) # the last



rmarkdown::render("/projects/ps-epigen/software/setQC/setQC_report_any.R",
                  params = list(
                    set_name = set_name_,
                    libs = libs_,
                    setQC_dir = setQC_dir_,
                    libQC_dir = libQC_dir_
                  ),
                  output_dir=setQC_dir_)

#source activate bds_atac_py3;  Rscript $(which compile_setQC_report.R) 8085 6 42 43 44 45 46 47
