#!/bin/bash
# Prepare the files and etc for runSetQCreport.sh


LIB_IDS=$1 #;(`seq 48 57`) # array
LIB_ARRAY=($LIB_IDS)
LIB_LEN=${#LIB_ARRAY[@]}
# echo $LIB_IDS; echo $LIB_LEN

BASE_OUTPUT_DIR="/projects/ps-epigen/outputs/"
SET_NO=$2; #"4_1"
if [ -n $4 ]; then LIB_RUN=$4;fi; #"_2"
PORT=$3; # 8083


SETQC_DIR="${BASE_OUTPUT_DIR}setQCs/Set_${SET_NO}/"

# 1. runMultiQC
# TODO - fix the input here 
#runMultiQC.sh -l "${LIB_IDS[@]}" -s $SET_NO -n $LIB_RUN  #for the second set
cmd="runMultiQC.sh  -s $SET_NO ${LIB_IDS[@]}" # no trim;
echo $cmd 
eval $cmd


# 3. genSetQCreport
# use envrionment bds_atac_py3 (installed R-3.4.1)
source activate bds_atac_py3
cd $SETQC_DIR

Rscript $(which compile_setQC_report.R) $PORT $SET_NO ${LIB_IDS[@]} ; ##"48 49 50 51 52 53 54 55 56 57 58" "4_1"


# 4. prepare tracks
cmd="transferTracks.sh -d $SETQC_DIR  ${LIB_IDS[@]}"
echo $cmd
eval $cmd
#exit 1

cd $SETQC_DIR"/data"
find . -name '*.json' | sort -n  | xargs -I '{}' cat '{}'|awk '{print}' >tracks_merged.json
Rscript $(which genWashUtracks.R) $PORT 

# 5. Final: set up the sharing web site 
rsync -v -r -u $SETQC_DIR zhc268@epigenomics.sdsc.edu:/home/zhc268/setQC_reports/Set_${SET_NO}
ssh zhc268@epigenomics.sdsc.edu "screen -d -m http-server -p $PORT ./setQC_reports/Set_${SET_NO}"




# setQC_wrapper.sh "71 72 73 74 75 76 77 78 79 80" 5 8084 
