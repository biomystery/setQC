#!/usr/bin/env bash
#Time-stamp: "2018-02-24 14:28:49"
source activate bds_atac_py3


# PART I dependency check 

# PART II usage info
usage(){
    exit 1
} 

# PART III  params
# default 
BASE_OUTPUT_DIR="/home/zhc268/data/outputs/setQCs/"
track_source_dir="/home/zhc268/data/outputs/"

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

echo -e "############################################################"
echo -e "# Step 1. runMultiQC" 
echo -e "(`date`): running mutliQC" | tee -a $LOG_FILE

# cp s all libqc files to one folder
# prefered trim
rm -rf $SETQC_DIR"/libQCs/" || true ; rm -rf $SETQC_DIR"/data/" || true ;
mkdir -p $SETQC_DIR"/libQCs/";mkdir -p $SETQC_DIR"/data/";

for l in ${LIB_ARRAY[@]}
do
    echo "cp $l libqc files..."
    find $LIBQC_DIR$l -type f -exec cp -Psu '{}' $SETQC_DIR"/libQCs/" \; 2> /dev/null
    echo "cp $l peaks files"
    find  $track_source_dir"peaks" \( -name "${l}_R*hammock*" -o -name "${l}.fastq*hammock*" \)  -exec cp -Prfs {} $SETQC_DIR"/data/" \;
    find  $track_source_dir"signals" \( -name "${l}_R*.signal.bigwig" -o -name "${l}.fastq*.signal.bigwig" \)  -exec cp -Prfs {} $SETQC_DIR"/data/" \;
done

cmd="multiqc -k tsv -f -p $SETQC_DIR/libQCs  -o $SETQC_DIR"
echo $cmd
eval $cmd


echo -e "############################################################"
echo -e "Step 2. genSetQCreport" 

cmd="Rscript $(which compile_setQC_report.R) $SET_NAME $SETQC_DIR ${SETQC_DIR}/libQCs/ ${LIB_ARRAY[@]}" #LIR_arry sorted by name already
echo $cmd
eval $cmd

echo -e "############################################################"
echo -e "# Step 3. prepare tracks"

# get the libnames
> $SETQC_DIR/including_libs.txt
for s in ${LIB_ARRAY[@]}
do
    ss=`echo $s | sed -E "s/_S[0-9]+_L[0-9]+//g"`;
    ln=`grep -n "${ss}," $SETQC_DIR/sample_table.csv | cut -f1 -d:`;
    sn=`sed "${ln}q;d" $SETQC_DIR/sample_table.csv| awk -F"," '{print $3}'| sed "s/\ /\_/g"`;
    echo -e "$s\t$sn">> $SETQC_DIR/including_libs.txt ;done
cmd="transferTracks.sh -d $SETQC_DIR -s $track_source_dir  -l $SETQC_DIR/including_libs.txt" 
echo -e "(`date`): copy track files" | tee -a $LOG_FILE
echo $cmd | tee -a $LOG_FILE
eval $cmd 

cd $SETQC_DIR"/data"
Rscript $(which genWashUtracks.R) "$RELATIVE_DIR"

echo -e "############################################################"
echo -e "# (`date`) Step 4. Final: set up the sharing web site & make app " | tee -a $LOG_FILE

mkdir -p $SETQC_DIR"/app"
cd $SETQC_DIR"/app"
cp -ufs /home/zhc268/data/software/setQC/peakApp/app.R ./;
cp -Pfs $SETQC_DIR/data/avgOverlapFC.tab ./
cp -Pfs $SETQC_DIR/sample_table.csv ./

ssh zhc268@epigenomics.sdsc.edu "mkdir -p /home/zhc268/shiny-server/setQCs/$RELATIVE_DIR;cp -rPfs /home/zhc268/data/outputs/setQCs/$RELATIVE_DIR/app/* /home/zhc268/shiny-server/setQCs/$RELATIVE_DIR/"

echo -e "############################################################"
echo -e "# Step 5. Final: prepare downloading files "

rm -rf $SETQC_DIR"/download" || true ;mkdir $SETQC_DIR"/download"
cd $SETQC_DIR"/download"

# script 
data_dir="/home/zhc268/data/"



libs_name_dic=(`cat $SETQC_DIR/including_libs.txt`)
for i in `seq 1 $LIB_LEN`
do 
    
    a=${libs_name_dic[2*$i-2]};b=${libs_name_dic[2*$i-1]};

    echo "tranfering $a to $b"
    find $data_dir"/seqdata" \( -name $a"_R*.bz2" -o -name $a"*.gz" \)  -type f -exec ln -s {} ./  \; 
    find $data_dir"/outputs/bams" -name $a"_R*.bam"  -type f -exec ln -s {} ./  \; 
    find $data_dir"/outputs/peaks/"$a -name "*.filt.narrowPeak.gz"  -type f -exec ln -s {} ./  \; 
    find $data_dir"/outputs/signals/" -name $a"_R*fc*.bigwig"  -type f -exec ln -s {} ./  \; 
    find $data_dir"/outputs/signals/" -name $a"_R*pval*.bigwig"  -type f -exec ln -s {} ./  \;
    find $data_dir"/outputs/signals/" -name $a"_R*pileup*.bigwig"  -type f -exec ln -s {} ./  \;    

    # rename 
    
    find . \( -name $a"_R*.fastq.gz" -o -name $a"_R*.fastq.bz2" -name $a".*.fastq.gz" -o -name $a".*.fastq.bz2" \) | xargs -n1 -I '{}' echo mv {} {} | sed "s/$a/$b/2" | bash  2> /dev/null
    find . -name $a"_R*.PE2SE.bam" | xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE/$b\.raw/2;s/${a}_R1\.trim\.PE2SE/${b}\.raw/2" | bash 2> /dev/null
    find . -name $a"_R*.nodup.bam" | xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE\.nodup/$b\.final/2;s/${a}_R1\.trim\.PE2SE\.nodup/${b}\.final/2"  | bash 2> /dev/null
    find . -name $a"_R*narrowPeak.gz" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE\.nodup\.tn5\.pf\.filt/$b/2;s/${a}_R1\.trim\.PE2SE\.nodup\.tn5\.pf\.filt/$b/2" | bash 2> /dev/null
    find . -name $a"_R*bigwig" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE\.nodup\.tn5\.pf/$b/2;s/${a}_R1\.trim\.PE2SE\.nodup\.tn5\.pf/$b/2" | bash 2> /dev/null
    find . -name $a"_R*bigwig" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE\.nodup\.pf/$b/2;s/${a}_R1\.trim\.PE2SE\.nodup\.pf/$b/2" | bash 2> /dev/null
done


ssh zhc268@epigenomics.sdsc.edu "tree -I '*.html' --timefmt '%F %T'  -H '.' -L 1 --noreport --charset utf-8 -T ''  /home/zhc268/data/outputs/setQCs/$RELATIVE_DIR/download > /home/zhc268/data/outputs/setQCs/$RELATIVE_DIR/download/index.html"

echo "link: http://epigenomics.sdsc.edu:8088/$RELATIVE_DIR/setQC_report.html"

# END 

#EXAMPLES:

# setQC_wrapper.sh -s /home/zhc268/scratch/others/2017-10-25-sswangson_morgridge/chu_mmus/uniq_samples_rev.txt \

