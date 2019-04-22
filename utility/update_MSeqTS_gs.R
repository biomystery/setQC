# scan the whole libQC folder to get the values
require(googlesheets)
require(tidyverse)


libQC.dir <-  "/home/zhc268/data/outputs/libQCs/"
libQC.files <- list.files(libQC.dir,pattern="*_qc.txt",recursive=T)
libs <-  sub(pattern="/.*$","",libQC.files)

# parse the results
parseLibQC <- function(i= 1,libs_=libs,libQC.files_=libQC.files){

    libQC_report_file <- paste0(libQC.dir,libQC.files_[i])
    qc <- read.table(libQC_report_file,sep = "\t",header = F,fill = T,col.names = paste0("v",seq(3)),
                     stringsAsFactors = F)
    qc$v3 <- signif(qc$v3,digits = 3)
    qc.2 <- (sapply(1:nrow(qc),function(x) sub(" \\| NA","",paste(qc$v2[x],qc$v3[x],sep = " | "))))

    names(qc.2)<- qc$v1

    #output
    pd <- data.frame(
        lib=libs[i],
                     Genome=qc.2["Genome"],
                     PE=qc.2["Paired/Single-ended"],
                     Total_reads=qc.2["Read count from sequencer"],
                     Final_reads=parseFraction(qc.2["Final reads (after all filters)"])[1],
                     Final_yield=parseFraction(qc.2["Final reads (after all filters)"])[2],
                     Mito_frac=parseFraction(qc.2["Mitochondrial reads (out of total)"])[2],
                     TSS_enrichment=signif(as.numeric(qc.2["TSS_enrichment"]),4),
                     FRoP=parseFraction(qc.2["Fraction of reads in promoter regions"])[2],
                     stringsAsFactors=F)
    pd
}

parseFraction <- function(val=qc.2["Mitochondrial reads (out of total)"]){
    as.numeric(unlist(strsplit(val,split=" | "))[-2])
}

qc.all <- do.call(rbind, lapply(1:length(libs),parseLibQC))


# upload to mseqts gs

gs_auth(token="/home/zhc268/software/google/googlesheets_token.rds")
gs_mseqts <- gs_key("1DqQQ0e5s2Ia6yAkwgRyhfokQzNPfDJ6S-efWkAk292Y")

sample.table <- gs_mseqts%>% gs_read(range=cell_limits(c(3,9),c(NA,28))) # 9th col: Sequencing ID
colnames(sample.table)

all(libs %in% sample.table$`Sequencing ID`)
libs <- libs[(libs %in% sample.table$`Sequencing ID`)]
#sample.table <- sample_table[,c(2,14:20)]

colnames(sample.table)[14:20]
colnames(qc.all)
for( l in libs){
    qc <- qc.all[l,]
    ridx <- which(sample.table$`Sequencing ID`==l)
    sample.table[ridx,14:20] <- qc
}



## edit: https://rawgit.com/jennybc/googlesheets/master/vignettes/basic-usage.html


gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample.table[,14],  anchor="V3") # Genome
gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample.table[,15],  anchor="W3")
gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample.table[,16],  anchor="X3")
gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample.table[,17],  anchor="Y3")
gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample.table[,18],  anchor="Z3")
gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample.table[,19],  anchor="AA3")
gs_mseqts<- gs_mseqts %>% gs_edit_cells(input=sample.table[,20],  anchor="AB3")
