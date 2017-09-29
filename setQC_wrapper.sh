#!/bin/bash
# Prepare the files and etc for runSetQCreport.sh
LIB_IDS=$1 #;(`seq 48 57`) # array
LIB_ARRAY=($LIB_IDS)
LIB_LEN=${#LIB_ARRAY[@]}

BASE_OUTPUT_DIR="/projects/ps-epigen/outputs/"
SET_NO=$2; #"4_1"

SETQC_DIR="${BASE_OUTPUT_DIR}setQCs/Set_${SET_NO}/"
LOG_FILE="${SETQC_DIR}log.txt"

# 1. runMultiQC
echo -e "(`date`): running mutliQC" | tee -a $LOG_FILE

if [ -n "$3" ];
then
    LIB_RUN=${3};
    cmd="runMultiQC.sh  -s $SET_NO -n $LIB_RUN ${LIB_IDS[@]} " # trim;
else
    cmd="runMultiQC.sh  -s $SET_NO ${LIB_IDS[@]}" # no trim;
fi; #"_2"

echo $cmd 
eval $cmd



# 4. prepare tracks
if [ -n "$3" ]
then
    cmd="transferTracks.sh -d $SETQC_DIR -r $LIB_RUN ${LIB_IDS[@]}"
else
    cmd="transferTracks.sh -d $SETQC_DIR  ${LIB_IDS[@]}"
fi

echo -e "(`date`): copy track files" | tee -a $LOG_FILE
echo $cmd | tee -a $LOG_FILE
eval $cmd

cd $SETQC_DIR"/data"
find . -name 'JYH*.json' | sort -n  | xargs -I '{}' cat '{}'|awk '{print}' >tracks_merged.json
Rscript $(which genWashUtracks.R) "Set_${SET_NO}"


# 3. genSetQCreport
# use envrionment bds_atac_py3 (installed R-3.4.1)
echo -e "(`date`): running comple setQC html" | tee -a $LOG_FILE
cd $SETQC_DIR


#LIB_IDS=("${LIB_IDS[@]/%/${LIB_RUN}}")
source activate bds_atac_py3

echo "preparing setQC: get merged peaks..."
#calcOverlapAvgFC.sh 

echo "Rscript $(which compile_setQC_report.R)  $SET_NO ${LIB_IDS[@]} "
Rscript $(which compile_setQC_report.R)  $SET_NO ${LIB_IDS[@]} ; ##"48 49 50 51 52 53 54 55 56 57 58" "4_1"



# 5. Final: set up the sharing web site
echo -e "(`date`): uploading to website" | tee -a $LOG_FILE
rsync -v -r -u $SETQC_DIR zhc268@epigenomics.sdsc.edu:/home/zhc268/setQC_reports/Set_${SET_NO}


# 6. prepare shiny apps
cd $SETQC_DIR
mkdir -p $SETQC_DIR"/app"
cp $(which app.R) ./app/;
cp including_libs.txt ./app;
cp ./data/avgOverlapFC.tab ./app;
cd $SETQC_DIR"/app"
rsync -v -r -u ./  zhc268@epigenomics.sdsc.edu:/home/zhc268/shiny-server/setQCs/Set_${SET_NO}
rm -r ../app


#EXAMPLES:
# setQC_wrapper.sh "42 43 44 45 46 47" 6 

