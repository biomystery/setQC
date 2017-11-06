args <- commandArgs(trailingOnly = TRUE)
set <- args[1]#4_1
libs <- args[2:length(args)]
didTrim_  <- F
set
libs
#libs <- seq(48,57)
#set <- "4_1"

if (grepl("_",set)){# contain _
    suf <- as.numeric(unlist(strsplit(set,"_")))[2]
    if(suf >1){
        libs <- paste0(libs,"_",suf)
        didTrim_ <- T
        }
}

libs

setQC_dir <- paste0("/projects/ps-epigen/outputs/setQCs/Set_",set)

rmarkdown::render("/projects/ps-epigen/software/setQC/setQC_report_any.R",
                  params = list(
                    libs_no = libs,
                    set_no = set,
                    didTrim = didTrim_
                  ),
                  output_dir=setQC_dir)

#source activate bds_atac_py3;  Rscript $(which compile_setQC_report.R) 8085 6 42 43 44 45 46 47
