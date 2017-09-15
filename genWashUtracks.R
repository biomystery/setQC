args <- commandArgs(trailingOnly = TRUE)

port <- args[1]; #8083; #need define
track.json.simple <- readLines("./tracks_merged.json")
track.json.simple <- gsub("\\{ \"type\":\"native_track\", \"list\":\\[ \\{ \"name\":\"gencodeV23\", \"mode\":\"full\", \\} \\] \\}, \\]\\[","",track.json.simple)

track.json.simple <- gsub("\\/share\\/",paste0("\\:",port,"\\/data\\/"),track.json.simple)
track.json.simple <- gsub("pval","fc",track.json.simple)
track.json.simple <- gsub("hammock","hammock.2",track.json.simple)# disable hammock peak track
track.json.simple <- gsub("\"thmax\":40","\"thmax\":25",track.json.simple)# scale to 0 and 25
track.json.simple <- gsub("\"thmin\":2","\"thmin\":0",track.json.simple)# scale to 0 and 25
writeLines(track.json.simple,"./tracks_merged_pf.json")
