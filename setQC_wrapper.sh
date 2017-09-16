#!/bin/bash
# Prepare the files and etc for runSetQCreport.sh


LIB_IDS=$1 #;(`seq 48 57`) # array
LIB_ARRAY=($LIB_IDS)
LIB_LEN=${#LIB_ARRAY[@]}


BASE_OUTPUT_DIR="/projects/ps-epigen/outputs/"
SET_NO=$2; #"4_1"
if [ -n $3 ]; then LIB_RUN=$3;fi; #"_2"
SETQC_DIR="${BASE_OUTPUT_DIR}setQCs/Set_${SET_NO}/"
LOG_FILE="${SETQC_DIR}log.txt"

# 1. runMultiQC
# TODO - fix the input here 
#runMultiQC.sh -l "${LIB_IDS[@]}" -s $SET_NO -n $LIB_RUN  #for the second set
echo -e "(`date`): running mutliQC" | tee -a $LOG_FILE
cmd="runMultiQC.sh  -s $SET_NO ${LIB_IDS[@]}" # no trim;
echo $cmd 
#eval $cmd


# 3. genSetQCreport
# use envrionment bds_atac_py3 (installed R-3.4.1)
echo -e "(`date`): running comple setQC html" | tee -a $LOG_FILE
source activate bds_atac_py3
cd $SETQC_DIR

Rscript $(which compile_setQC_report.R) $PORT $SET_NO ${LIB_IDS[@]} ; ##"48 49 50 51 52 53 54 55 56 57 58" "4_1"


# 4. prepare tracks
cmd="transferTracks.sh -d $SETQC_DIR  ${LIB_IDS[@]}"
echo -e "(`date`): copy track files" | tee -a $LOG_FILE
echo $cmd | tee -a $LOG_FILE
eval $cmd
#exit 1
cd $SETQC_DIR"/data"
find . -name 'JYH*.json' | sort -n  | xargs -I '{}' cat '{}'|awk '{print}' >tracks_merged.json
Rscript $(which genWashUtracks.R) "Set_${SET_NO}"

# 5. Final: set up the sharing web site
echo -e "(`date`): uploading to website" | tee -a $LOG_FILE
rsync -v -r -u $SETQC_DIR zhc268@epigenomics.sdsc.edu:/home/zhc268/setQC_reports/Set_${SET_NO}
#ssh zhc268@epigenomics.sdsc.edu "screen -d -m http-server -s -d false -p $PORT ./setQC_reports/Set_${SET_NO}"




# setQC_wrapper.sh "42 43 44 45 46 47" 6 

