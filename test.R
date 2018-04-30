libs<-c("AVD_108","AVD_109","AVD_110","AVD_111")
setQC_dir <- "../../data/outputs/setQCs/Set_70_test/69ec5ea434b42b06f29bebc97d063ca7/"
libQC_dir <-"../../data/outputs/setQCs/Set_70_test/69ec5ea434b42b06f29bebc97d063ca7/libQCs/"

no_libs <- length(libs)
source('./libs.R')

sample_table<- getSampleTable(libs)
libs.showname <- sample_table$`Label (for QC report)`
libs.showname.dic <- libs.showname;names(libs.showname.dic)<-libs
input.idx <- grep(pattern = "input",libs.showname,ignore.case = T)
libQC_table <- getLibQCtable(libs) # need determined by the input
