#!/bin/bash 

usage() { echo "Usage: $0 [-d destination_dir]  [-s source_dir] [-l lib_files]>" 1>&2; exit 1; }

while getopts "d:s:l:" o; do
    case $o in
        d) d="${OPTARG}";;
        s) source_dir="${OPTARG}";;
        l) libs_txt="${OPTARG}";;         
        *) usage;;
    esac
done
shift $((OPTIND-1))
echo "destination folder: $d"
echo "source folder:  $source_dir"
echo "lib files:  $source_dir"


# cp the files to the output folder 
libs=(`cat $libs_txt`);
libs_len=`cat $libs_txt| wc -l`

desti_dir=$d"/data/" #"${HOME}/set4_2_Reports/data/" 
mkdir -p $desti_dir
> $desti_dir/tracks_merged.json # new file

all_control=false
[[ $(echo ${libs[@]} | tr -s " " "\n" | grep -i -c -E 'atac.*control') -eq $libs_len ]] && all_control=true  #atac & control 

for i in `seq 1 $libs_len`
do
    sample=${libs[2*$i-2]};sample_name=${libs[2*$i-1]};
    if [ $(echo $sample_name | grep -i -c 'atac.*control') -eq 0 ] || [ "$all_control" = true ]
    then
        echo "transfering $sample ${sample}*.pileup.signal.bigwig..." 

        # default is pval, mannually changed to fc
        cat ${source_dir}"/signals/${sample}_tracks.json" | \
	    sed "s/\/.\/signal\/macs2\/rep1/http:\/\/epigenomics.sdsc.edu\/share/g" | \
	    sed "s/\/.\/peak\/macs2\/rep1/http:\/\/epigenomics.sdsc.edu\/share/g" | \
            sed "s/${sample}\ /${sample_name}\ /g" | sed "s/\ (rep1)//g" | sed "s/ff0000/0000ff/g" >>  $desti_dir/tracks_merged.json 
    fi
done 

echo >>  $desti_dir/tracks_merged.json 
