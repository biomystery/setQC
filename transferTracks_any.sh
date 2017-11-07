#!/bin/bash 

usage() { echo "Usage: $0 [-d destination_dir] [-t trim] [-r run_no]>" 1>&2; exit 1; }

while getopts "d:l:t:" o; do
    case $o in
        d) d="${OPTARG}";;
        l) l="${OPTARG}";;
        t) t="$OPTARG" ;;
        *) usage;;
    esac
done
shift $((OPTIND-1))
echo $d
echo $l 
echo $t
echo $@

# cp the files to the output folder 

libs=$@; #`seq 48 57` - the remaining argvs 
output_dir=$l 
desti_dir=$d"/data/" #"${HOME}/set4_2_Reports/data/" 
mkdir -p $desti_dir

for sample in ${libs[@]}
do 

    echo "transfering $sample ${sample}${t}*.fc.signal.bigwig..." 

    cat ${output_dir}"/$sample/${sample}_tracks.json" | \
	sed "s/\/.\/signal\/macs2\/rep1/http:\/\/epigenomics.sdsc.edu\/share/g" | \
	sed "s/\/.\/peak\/macs2\/rep1/http:\/\/epigenomics.sdsc.edu\/share/g" > \
	$desti_dir"/${sample}.json"
    find  $output_dir"/${sample}/peak/" -name "${sample}${t}*hammock*"  -exec cp -u {} $desti_dir \;
    find  $output_dir"/${sample}/signal/" -name "${sample}${t}*.fc.signal.bigwig" -exec cp -u {} $desti_dir \;
done 

