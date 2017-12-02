#!/usr/bin/env bash
#Time-stamp: "2017-12-01 16:46:37"

# PART I dependency check 

# PART II usage info
usage(){
    exit 1
} 

# PART III  params
# default 
BASE_OUTPUT_DIR="/home/zhc268/data/outputs/setQCs/"


# receiving arguments
while getopts ":s:b:n:l:" opt;
do
	case "$opt" in
	    s) SAMPLE_FILE=$OPTARG;;  # txt file including all  sample files
            b) B_NAME=$OPTARG;; # a higher level base name on top of set name 
	    n) SET_NAME=$OPTARG;;
            l) LIBQC_DIR=$OPTARG;; # proessed lib dir 
	    \?) usage
		echo "input error"
		exit 1
		;;
	esac
done

# check if input sample name file exists


#if [  -z "$B_NAME" ]; then
#    echo $B_NAME
#    echo "Base name not set!"
#    exit 1
#fi

if [ -z "$SET_NAME" ]; then
    echo "set name file not found!"
    exit 1
fi

if [ ! -f "$SAMPLE_FILE" ]; then
    SAMPLE_FILE=$BASE_OUTPUT_DIR${SET_NAME}.txt
fi

if [ ! -d "$LIBQC_DIR" ]; then
    LIBQC_DIR="/home/zhc268/data/outputs/libQCs/"
fi
     
# Prepare the files and etc for runSetQCreport.sh
LIB_ARRAY=(`cat $SAMPLE_FILE | sort -n`) # assume all the single libs in the same dir 
LIB_LEN=${#LIB_ARRAY[@]}
BASE_OUTPUT_DIR="${BASE_OUTPUT_DIR}/${B_NAME}/"

# check if there is $BASE_OUTPUT_DIR/$B_NAME/$SET_NAME.txt
rand_d_string=$BASE_OUTPUT_DIR/$SET_NAME.rstr.txt 
if [ ! -f $rand_d_string ];then
    RAND_D=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32`
    echo $RAND_D > $BASE_OUTPUT_DIR/$B_NAME/$SET_NAME.rstr.txt 
else
    RAND_D=`cat $rand_d_string`

fi

SETQC_DIR="${BASE_OUTPUT_DIR}/${SET_NAME}/${RAND_D}/"
RELATIVE_DIR="${B_NAME}/${SET_NAME}/${RAND_D}"
LOG_FILE="${SETQC_DIR}log.txt"

mkdir -p $SETQC_DIR

# PART III: Main 

############################################################
# 1. runMultiQC
echo -e "(`date`): running mutliQC" | tee -a $LOG_FILE
source activate bds_atac_py3
# cp s all libqc files to one folder
mkdir -p $SETQC_DIR"/tmp/"
for l in ${LIB_ARRAY[@]}
do
    echo "cp $l libqc files..."
    find $LIBQC_DIR$l -type f -exec cp -rsu '{}' $SETQC_DIR"/tmp/" \; 2> /dev/null 
done

#####
cmd="multiqc -k tsv -f -p $SETQC_DIR/tmp  -o $SETQC_DIR"
echo $cmd 
eval $cmd
wait
rm -r $SETQC_DIR"/tmp/"

source deactivate bds_atac_py3

############################################################
# 2. prepare tracks
track_source_dir="/home/zhc268/data/outputs/"
cmd="transferTracks_any.sh -d $SETQC_DIR -s $track_source_dir  ${LIB_ARRAY[@]}"

echo -e "(`date`): copy track files" | tee -a $LOG_FILE
echo $cmd | tee -a $LOG_FILE
eval $cmd

#####
cd $SETQC_DIR"/data"
find . -name '*.json' | sort -n  | xargs -I '{}' cat '{}'|awk '{print}' >tracks_merged.json
Rscript $(which genWashUtracks.R) "$RELATIVE_DIR"

# delete the individual tracks
#find . ! \( -name "*pf.json" -o -name "*.gz" -o -name "*.bigwig" -o -name "*.tbi" \) -delete

############################################################
# 3. genSetQCreport
# use envrionment bds_atac_py3 (installed R-3.4.1)
echo -e "(`date`):  compiling setQC html" | tee -a $LOG_FILE
cd $SETQC_DIR

source activate bds_atac_py3
echo "preparing setQC: get merged peaks..."
calcOverlapAvgFC_any.sh ${LIB_ARRAY[@]}

### 
cmd="Rscript $(which compile_setQC_report_any.R) $SET_NAME $SETQC_DIR $LIBQC_DIR ${LIB_ARRAY[@]}"
echo $cmd
eval $cmd 


############################################################
# 5. Final: set up the sharing web site & make app 
echo -e "(`date`): uploading to website" | tee -a $LOG_FILE

mkdir -p $SETQC_DIR"/app"
cd $SETQC_DIR"/app"

cp -us /home/zhc268/data/software/setQC/app.R ./;
echo ${LIB_ARRAY[@]} > ./including_libs.txt;
cp -Prs $SETQC_DIR/data/avgOverlapFC.tab ./;

ssh zhc268@epigenomics.sdsc.edu "mkdir -p /home/zhc268/shiny-server/setQCs/$RELATIVE_DIR"
ssh zhc268@epigenomics.sdsc.edu "cp -Prs  /home/zhc268/data/outputs/setQCs/$RELATIVE_DIR/app/* /home/zhc268/shiny-server/setQCs/$RELATIVE_DIR"

echo "link: http://epigenomics.sdsc.edu:8088/$RELATIVE_DIR/setQC_report_any.html"

# END 

#EXAMPLES:

# setQC_wrapper_any.sh -s /home/zhc268/scratch/others/2017-10-25-sswangson_morgridge/chu_mmus/uniq_samples_rev.txt \

