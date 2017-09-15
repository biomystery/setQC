#!/bin/bash 

usage() { echo "Usage: $0 [-d destination_dir] [-t trim] [-r run_no]>" 1>&2; exit 1; }

while getopts "d:t:r:" o; do
    case $o in
        d) d="${OPTARG}";;
        t) t="$OPTARG" ;;
        r) r="$OPTARG" ;;  
        *) usage;;
    esac
done

shift $((OPTIND-1))
echo $d
echo $t
echo $r
echo $@

# cp the files to the output folder 

libs=$@; #`seq 48 57` - the remaining argvs 
output_dir="/projects/ps-epigen/outputs/"
desti_dir=$d"/data/" #"${HOME}/set4_2_Reports/data/" 
#if [ -n $t ]; then t="*trim";echo $t; fi # -t tim
mkdir -p $desti_dir

for i in ${libs[@]}
do 
    if [ -n $r ]; then sample="JYH_${i}${r}"; else sample="JYH_${i}";fi
    echo "transfering $sample ${sample}${t}*.fc.signal.bigwig..." 

    cat ${output_dir}"signals/${sample}_tracks.json" | \
	sed "s/\/.\/signal\/macs2\/rep1/http:\/\/epigenomics.sdsc.edu\/share/g" | \
	sed "s/\/.\/peak\/macs2\/rep1/http:\/\/epigenomics.sdsc.edu\/share/g" > \
	$desti_dir"${sample}.json"
    find  $output_dir"peaks/${sample}/" -name "${sample}${t}*hammock*"  -exec cp -u {} $desti_dir \;
    find  $output_dir"signals/" -name "${sample}${t}*.fc.signal.bigwig" -exec cp -u {} $desti_dir \;

done 

