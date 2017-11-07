#!/usr/bin/env bash
#Time-stamp: "2017-11-07 10:07:54"

# PART I dependency check 

# PART II usage info
usage(){
    exit 1
} 

# PART III  params
# default 
BASE_OUTPUT_DIR="/projects/ps-epigen/outputs/setQCs/"



# receiving arguments
while getopts ":s:b:n:l:" opt;
do
	case "$opt" in
	    s) SAMPLE_FILE=$OPTARG;;  #;(`xx xx`) any prefix name
            b) B_NAME=$OPTARG;; # a higher level base name on top of set name 
	    n) SET_NAME=$OPTARG;;
            l: LIBQC_DIR=$OPTARG;; # proessed lib dir 
	    \?) usage
		echo "input error"
		exit 1
		;;
	esac
done

# check if input sample name file exists

if [ ! -f "$SAMPLE_FILE" ]; then
       echo "sample file not found!"
       exit 1
fi
     
# Prepare the files and etc for runSetQCreport.sh
LIB_ARRAY=(`cat $SAMPLE_FILE | sort -n`) # assume all the single libs in the same dir 
LIB_LEN=${#LIB_ARRAY[@]}
BASE_OUTPUT_DIR="${BASE_OUTPUT_DIR}/${B_NAME}/"

# check if there is $BASE_OUTPUT_DIR/$B_NAME/$SET_NAME.txt
rand_d_string=$BASE_OUTPUT_DIR/$B_NAME/$SET_NAME.txt 
if [ ! -f $rand_d_string ];then
    RAND_D=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32`
else
    RAND_D=`cat $rand_d_string`
fi

SETQC_DIR="${BASE_OUTPUT_DIR}/${RAND_D}/${SET_NAME}/"
LOG_FILE="${SETQC_DIR}log.txt"

mkdir -p $SETQC_DIR

# PART III: Main 

# 1. runMultiQC
echo -e "(`date`): running mutliQC" | tee -a $LOG_FILE
source activate bds_atac_py3
cmd="multiqc -k tsv -f -p $LIBQC_DIR -o $SETQC_DIR"
echo $cmd 
eval $cmd
wait
source deactivate bds_atac_py3


# 2. prepare tracks
cmd="transferTracks_any.sh -d $SETQC_DIR -l $LIBQC_DIR  ${LIB_ARRAY[@]}"

echo -e "(`date`): copy track files" | tee -a $LOG_FILE
echo $cmd | tee -a $LOG_FILE
eval $cmd

cd $SETQC_DIR"/data"
find . -name '*.json' | sort -n  | xargs -I '{}' cat '{}'|awk '{print}' >tracks_merged.json
Rscript $(which genWashUtracks.R) "${B_NAME}/${RAND_D}/${SET_NAME}"
LIBQC_DIR="/home/zhc268/scratch/others/2017-10-25-sswangson_morgridge/chu_mmus"
# delete the individual tracks
find . ! \( -name "*pf.json" -o -name "*.gz" -o -name "*.bigwig" -o -name "*.tbi" \) -delete


# 3. genSetQCreport
# use envrionment bds_atac_py3 (installed R-3.4.1)
echo -e "(`date`):  compiling setQC html" | tee -a $LOG_FILE
cd $SETQC_DIR


#LIB_IDS=("${LIB_IDS[@]/%/${LIB_RUN}}")
source activate bds_atac_py3

echo "preparing setQC: get merged peaks..."
calcOverlapAvgFC.sh $SAMPLE_FILE


cmd="Rscript $(which compile_setQC_report_any.R) $SET_NAME $SETQC_DIR $LIBQC_DIR ${LIB_ARRAY[@]}"
echo $cmd
eval $cmd 

# 5. Final: set up the sharing web site
echo -e "(`date`): uploading to website" | tee -a $LOG_FILE
rsync -v -r -u $SETQC_DIR zhc268@epigenomics.sdsc.edu:/home/zhc268/setQC_reports/Set_${SET_NAME}


# 6. prepare shiny apps
cd $SETQC_DIR
mkdir -p $SETQC_DIR"/app"
cp $(which app.R) ./app/;
cp including_libs.txt ./app;
cp ./data/avgOverlapFC.tab ./app;
cd $SETQC_DIR"/app"
rsync -v -r -u ./  zhc268@epigenomics.sdsc.edu:/home/zhc268/shiny-server/setQCs/Set_${SET_NAME}
rm -r ../app


#EXAMPLES:

# setQC_wrapper_any.sh -s /home/zhc268/scratch/others/2017-10-25-sswangson_morgridge/chu_mmus/uniq_samples_rev.txt \
# 
