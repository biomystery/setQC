libs<-c( "AVD_143","AVD_144","AVD_145","AVD_146","AVD_147","AVD_148","AVD_149","AVD_150","AVD_151","AVD_152","AVD_153","AVD_154","AVD_155","AVD_156")
setQC_dir <- "../../data/outputs/setQCs//Set_101/2a85d6d99eb8c5f59e73d0b6a17226dd/"
libQC_dir <-"../../data/outputs/setQCs/Set_101/2a85d6d99eb8c5f59e73d0b6a17226dd//libQCs/"

no_libs <- length(libs)
source('./libs.R')

sample_table<- getSampleTable(libs)
libs.showname <- sample_table$`Label (for QC report)`
libs.showname.dic <- libs.showname;names(libs.showname.dic)<-libs
input.idx <- grep(pattern = "input",libs.showname,ignore.case = T)
libQC_table <- getLibQCtable(libs) # need determined by the input
reads_list <- getReadsTable(libQC_table)
