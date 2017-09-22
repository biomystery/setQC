#!/bin/sh

while read line
do
    for w in $line
    do
        echo $w;
        bigWigAverageOverBed ./data/${w}_R1.fastq.bz2.PE2SE.nodup.tn5.pf.fc.signal.bigwig merged_peak.srt.clip.named.bed ${w}.tab 
        awk '{print $6}' ${w}.tab > ${w}_avg.tab; rm ${w}.tab
    done;
    line=($line) # convert to array     
    echo "paste ${line[@]/%/_avg.tab} > avgOverlapFC.tab ... "
    paste "${line[@]/%/_avg.tab}" > avgOverlapFC.tab
    
done < including_libs.txt 
