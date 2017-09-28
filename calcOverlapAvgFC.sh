#!/bin/sh
# created merged peak files 
find . -name *.ham*.gz -exec zcat {} \; | awk -v OFS='\t' '{print $1,$2,$3}'| sort -k1,1 -k2,2n | uniq > merged.tmp.bed
bedtools merge -i merged.tmp.bed > merged.bed 
bedClip merged.bed ~/data/GENOME/hg38/hg38.chrom.sizes merged.clip.bed
cat merged.clip.bed | sort -k1,1 -k2,2n | uniq | awk -v OFS='\t' '{print $0,NR-1}' > merged_peak.srt.clip.named.bed



# created avgOverlapFC.tab

while read line
do
    for w in $line
    do
        echo "for lib:$w  - calculating avarage fc overlap in merged peaks";
        bigWigAverageOverBed ./data/${w}_R1.fastq.bz2.PE2SE.nodup.tn5.pf.fc.signal.bigwig merged_peak.srt.clip.named.bed ${w}.tab 
        awk '{print $6}' ${w}.tab > ${w}_avg.tab; rm ${w}.tab
    done;
    line=($line) # convert to array     
    echo "paste ${line[@]/%/_avg.tab} > ./data/avgOverlapFC.tab ... "
    paste "${line[@]/%/_avg.tab}" > ./data/avgOverlapFC.tab
    
done < including_libs.txt 

rm *_avg.tab; rm merged.tmp.bed; rm merged.clip.bed;
mv merged_peak.srt.clip.named.bed ./data


