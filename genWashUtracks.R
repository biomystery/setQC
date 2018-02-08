args <- commandArgs(trailingOnly = TRUE)

set_dir<- args[1];
track.json.simple <- readLines("./tracks_merged.json")
track.json.simple <- gsub("\\{ \"type\":\"native_track\", \"list\":\\[ \\{ \"name\":\"gencodeV23\", \"mode\":\"full\", \\} \\] \\}, \\]\\[","",track.json.simple)
track.json.simple <- gsub("\\{ \"type\":\"native_track\", \"list\":\\[ \\{ \"name\":\"ensGene\", \"mode\":\"full\", \\} \\] \\}, \\]\\[","",track.json.simple)
track.json.simple <- gsub("\\{ \"type\":\"native_track\", \"list\":\\[ \\{ \"name\":\"refGene\", \"mode\":\"full\", \\} \\] \\}, \\]\\[","",track.json.simple)


track.json.simple <- gsub("\\/share\\/",paste0("\\:8088/",set_dir,"\\/data\\/"),track.json.simple)

# to check if pileup track existed
if(length(list.files(paste0(set_dir,"data"),"pileup"))>0){
    track.json.simple <- gsub(" pval"," FPMR",track.json.simple)
    track.json.simple <- gsub("pval","pileup",track.json.simple)
    track.json.simple <- gsub("\"thmax\":40","\"thmax\":3",track.json.simple)# scale to 0 and 25
}else{
    track.json.simple <- gsub("pval","fc",track.json.simple)
    track.json.simple <- gsub("\"thmax\":40","\"thmax\":25",track.json.simple)# scale to 0 and 25

}
track.json.simple <- gsub("\"thmin\":2","\"thmin\":0",track.json.simple)# scale to 0 and 25
writeLines(track.json.simple,"./tracks_merged_pf.json")
