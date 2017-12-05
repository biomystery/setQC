#!/bin/bash 

usage() { echo "Usage: $0 [-d destination_dir]  [-s source_dir]>" 1>&2; exit 1; }

while getopts "d:s:" o; do
    case $o in
        d) d="${OPTARG}";;
        s) source_dir="${OPTARG}";; 
        *) usage;;
    esac
done
shift $((OPTIND-1))
echo "destination folder: $d"
echo "source folder:  $source_dir"
echo $@

# cp the files to the output folder 
libs=$@; #`seq 48 57` - the remaining argvs 
desti_dir=$d"/data/" #"${HOME}/set4_2_Reports/data/" 
mkdir -p $desti_dir
> $desti_dir/tracks_merged.json # new file

for sample in ${libs[@]}
do 
    echo "transfering $sample ${sample}*.fc.signal.bigwig..." 

    cat ${source_dir}"/signals/${sample}_tracks.json" | \
	sed "s/\/.\/signal\/macs2\/rep1/http:\/\/epigenomics.sdsc.edu\/share/g" | \
	sed "s/\/.\/peak\/macs2\/rep1/http:\/\/epigenomics.sdsc.edu\/share/g" >> \
            $desti_dir/tracks_merged.json 
    find  $source_dir"peaks"  -name "${sample}*hammock*"  -exec cp -Prfs {} $desti_dir \;
    find  $source_dir"signals" -name "${sample}*.fc.signal.bigwig" -exec cp -Prfs {} $desti_dir \;
done 

echo >>  $desti_dir/tracks_merged.json 
