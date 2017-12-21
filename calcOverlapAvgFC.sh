#!/bin/sh
usage() { echo "Usage: $0 [-g <human|mouse> -d <string,directory>] >" 1>&2; exit 1; }

while getopts "g:d:" o; do
    case $o in
        g) genome="${OPTARG}";; # set
        d) setQC_dir="${OPTARG}";;         
        *) usage;;
    esac
done

shift $((OPTIND-1))

# created merged peak files
including_libs=($@)

#bedIntersect -aHitAny $oldBed $cosmicBed stdout | wc -l
cd $setQC_dir
echo "merging peaks"
find ./data -name "*.ham*.gz" -exec zcat {} \; | awk -v OFS='\t' '{print $1,$2,$3}'| sort -k1,1 -k2,2n | uniq > ./merged.tmp.bed
bedtools merge -i merged.tmp.bed > merged.bed
if [[ $genome = "human" ]]
then
    bedClip merged.bed ~/data/GENOME/hg38/hg38.chrom.sizes merged.clip.bed
else
    bedClip merged.bed ~/data/GENOME/mm10/mm10.chrom.sizes  merged.clip.bed
fi

cat merged.clip.bed | sort -k1,1 -k2,2n | uniq | awk -v OFS='\t' '{print $0,NR-1}' > merged_peak.srt.clip.named.bed

# created avgOverlapFC.tab
for w in ${including_libs[@]};
do
    echo "for lib:$w  - calculating avarage fc overlap in merged peaks";
    a=`find ./data \( -name "${w}_*.bigwig" -o -name "${w}*.bigwig" \) `
    bigWigAverageOverBed $a merged_peak.srt.clip.named.bed ${w}.tab 
    awk '{print $6}' ${w}.tab > ${w}_avg.tab &&  rm ${w}.tab
done


echo "paste ${including_libs[@]/%/_avg.tab} > ./data/avgOverlapFC.tab ... "
paste "${including_libs[@]/%/_avg.tab}" > ./data/avgOverlapFC.tab


rm *_avg.tab;
rm merged.tmp.bed; rm merged.clip.bed;
mv merged_peak.srt.clip.named.bed ./data


