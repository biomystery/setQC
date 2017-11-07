#!/bin/sh
# created merged peak files
including_libs=$1


find . -name "*.ham*.gz" -exec zcat {} \; | awk -v OFS='\t' '{print $1,$2,$3}'| sort -k1,1 -k2,2n | uniq > merged.tmp.bed
bedtools merge -i merged.tmp.bed > merged.bed
if [ $(grep -c gencodeV23 ./data/tracks_merged_pf.json) -ne 0 ]
then
    bedClip merged.bed ~/data/GENOME/hg38/hg38.chrom.sizes merged.clip.bed
else
    bedClip merged.bed ~/data/GENOME/mm10/mm10.chrom.sizes  merged.clip.bed
fi

cat merged.clip.bed | sort -k1,1 -k2,2n | uniq | awk -v OFS='\t' '{print $0,NR-1}' > merged_peak.srt.clip.named.bed



# created avgOverlapFC.tab
while read line
do
    for w in $line
    do
        echo "for lib:$w  - calculating avarage fc overlap in merged peaks";
        bigWigAverageOverBed ./data/${w}_*.bigwig merged_peak.srt.clip.named.bed ${w}.tab 
        awk '{print $6}' ${w}.tab > ${w}_avg.tab; rm ${w}.tab
    done;
    line=($line) # convert to array     
    echo "paste ${line[@]/%/_avg.tab} > ./data/avgOverlapFC.tab ... "
    paste "${line[@]/%/_avg.tab}" > ./data/avgOverlapFC.tab
    
done < $including_libs

rm *_avg.tab; rm merged.tmp.bed; rm merged.clip.bed;
mv merged_peak.srt.clip.named.bed ./data


