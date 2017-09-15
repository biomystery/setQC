args <- commandArgs(trailingOnly = TRUE)

port <- args[1]; #8083; #need define
track.json.simple <- readLines("./tracks_merged.json")
track.json.simple <- gsub("\\{ \"type\":\"native_track\", \"list\":\\[ \\{ \"name\":\"gencodeV23\", \"mode\":\"full\", \\} \\] \\}, \\]\\[","",track.json.simple)

track.json.simple <- gsub("\\/share\\/",paste0("\\:",port,"\\/data\\/"),track.json.simple)
track.json.simple <- gsub("pval","fc",track.json.simple)
track.json.simple <- gsub("hammock","hammock.2",track.json.simple)# disable hammock peak track
writeLines(track.json.simple,"./tracks_merged_pf.json")
