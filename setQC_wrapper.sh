#!/usr/bin/env bash
#Time-stamp: "2018-10-12 08:52:14"
source activate bds_atac_py3

############################################################
# PART I dependency check
############################################################


############################################################
# PART II usage info
############################################################


usage(){
    echo "usage: setQC_wrapper.sh -n <Set_xx> -c <true|false> -p <true|false> -t <atac|chip|atac_chip> -m <true|false>"
}


[[ $# -eq 0 ]] && { echo "ERROR: need input" ;usage; exit $ERRCODE; } 



############################################################
# PART III  params
############################################################
# default 
BASE_OUTPUT_DIR="/projects/ps-epigen/outputs/setQCs/"
track_source_dir="/projects/ps-epigen/outputs/"

# receiving arguments
while getopts ":s:b:n:p:m:c:l:t:" opt;
do
	case "$opt" in
	    s) SAMPLE_FILE=$OPTARG;;  # txt file including all  sample files
            b) B_NAME=$OPTARG;; # a higher level base name on top of set name 
	    n) SET_NAME=$OPTARG;;
	    p) PADV=$OPTARG;;
            m) MULTIQC=$OPTARG;; # do multiqc
            c) CHIP_SNAP=$OPTARG;; # if SNAP
            l) LIBQC_DIR=$OPTARG;; # proessed lib dir
            t) EXP_TYPE=$OPTARG;; # experimental type
	    \?) usage
		echo "input error"
		exit 1
		;;
	esac
done

# check if input sample name file exists


if [  -z "$PADV" ]; then
    PADV="true"
fi

if [  -z "$MULTIQC" ]; then
    MULTIQC="true"
fi

if [  -z "$CHIP_SNAP" ]; then
    CHIP_SNAP="false"
fi

if [ -z "$SET_NAME" ]; then
    echo "set name file not found!"
    exit 1
fi

if [ ! -f "$SAMPLE_FILE" ]; then
    SAMPLE_FILE=$BASE_OUTPUT_DIR${SET_NAME}.txt
fi

if [ ! -d "$LIBQC_DIR" ]; then
    LIBQC_DIR="/projects/ps-epigen/outputs/libQCs/"
fi

if [ -z "$EXP_TYPE" ]; then
    EXP_TYPE="atac" # atac by default 
fi


## Prepare the files and etc for runSetQCreport.sh
LIB_ARRAY=(`awk '{print $1}'  $SAMPLE_FILE`) # assume all the single libs in the same dir


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

############################################################
# PART III: Main 
############################################################


echo -e "############################################################"
echo -e "# Step 1. runMultiQC" 
echo -e "(`date`): running mutliQC" | tee -a $LOG_FILE
echo -e "############################################################"

# cp s all libqc files to one folder
# prefered trim
rm -rf $SETQC_DIR"/libQCs/" || true ; rm -rf $SETQC_DIR"/data/" || true ;
mkdir -p $SETQC_DIR"/libQCs/";mkdir -p $SETQC_DIR"/data/";

for l in ${LIB_ARRAY[@]}
do
    echo "cp $l libqc files..."
    find $LIBQC_DIR$l -type f -exec cp -Psu '{}' $SETQC_DIR"/libQCs/" \; 2> /dev/null
    echo "cp $l peaks files"
    find  $track_source_dir"peaks" \( -name "${l}_R*hammock*" -o -name "${l}.*hammock*" \)  -exec cp -Prfs {} $SETQC_DIR"/data/" \;
    find  $track_source_dir"signals" \( -name "${l}_R*.signal.bigwig" -o -name "${l}.*.signal.bigwig" \)  -exec cp -Prfs {} $SETQC_DIR"/data/" \;
    find  $track_source_dir"signals" \( -name "${l}_R*.signal.bw" -o -name "${l}.*.signal.bw" \)  -exec cp -Prfs {} $SETQC_DIR"/data/" \;    
done

cmd="multiqc -k tsv -f -p $SETQC_DIR/libQCs  -o $SETQC_DIR"
echo $cmd

[[ $MULTIQC == "true" ]] && eval $cmd

## deal with snap chip option 
if [ $CHIP_SNAP == 'true' ]; then
    echo -e "############################################################"
    echo -e "# Step 1b. parse snap-chip spikin" 
    echo -e "(`date`): running parsing snap-chip" | tee -a $LOG_FILE
    echo -e "############################################################"
    
    snapcnt=${SETQC_DIR}/snap.cnt
    find  $SETQC_DIR"libQCs" -name "*snap*tab" | while read f
    do
        grep -q sequences $f
        if [ $? -eq 0 ]; then
            awk '(NR>9){a=FILENAME; sub(".*/","",a);split(a,b,".");print  $0,b[1]}' $f
        else
            awk '{a=FILENAME; sub(".*/","",a);split(a,b,".");print  $0,b[1]}' $f
        fi
        
    done> $snapcnt
fi

echo -e "############################################################"
echo -e "Step 2. genSetQCreport" 
echo -e "############################################################"

cmd="Rscript $(which compile_setQC_report.R) $SET_NAME $SETQC_DIR ${SETQC_DIR}/libQCs/ $PADV $CHIP_SNAP $EXP_TYPE $SAMPLE_FILE $(whoami)" #LIR_arry sorted by name already
echo $cmd
eval $cmd

echo -e "############################################################"
echo -e "# Step 3. prepare tracks"
echo -e "############################################################"

# get the libnames
> $SETQC_DIR/including_libs.txt
for s in ${LIB_ARRAY[@]}
do
    ss=`echo $s | sed -E "s/_S[0-9]+_L[0-9]+//g"`;
    ln=`grep -n "${ss}," $SETQC_DIR/sample_table.csv | cut -f1 -d:`;
    sn=`sed "${ln}q;d" $SETQC_DIR/sample_table.csv| awk -F"," '{print $3}'| sed "s/\ /\_/g"`;
    echo -e "$s\t$sn">> $SETQC_DIR/including_libs.txt ;
done

cmd="transferTracks.sh -d $SETQC_DIR -s $track_source_dir  -l $SETQC_DIR/including_libs.txt"
[[ $EXP_TYPE == "chip" ]] && cmd=${cmd/transferTracks/transferTracks_chip} # handle chipseq 

echo -e "(`date`): copy track files" | tee -a $LOG_FILE
echo $cmd | tee -a $LOG_FILE
eval $cmd 

cd $SETQC_DIR"/data"
Rscript $(which genWashUtracks.R) "$RELATIVE_DIR"

echo -e "############################################################"
echo -e "# (`date`) Step 4. Final: set up the sharing web site & make app " | tee -a $LOG_FILE
echo -e "############################################################"

mkdir -p $SETQC_DIR"/app"
cd $SETQC_DIR"/app"
cp -ufs /projects/ps-epigen/software/setQC/peakApp/app.R ./;
cp -Pfs $SETQC_DIR/data/avgOverlapFC.tab ./
cp -Pfs $SETQC_DIR/sample_table.csv ./

ssh zhc268@epigenomics.sdsc.edu "mkdir -p /home/zhc268/shiny-server/setQCs/$RELATIVE_DIR;cp -rPfs /projects/ps-epigen/outputs/setQCs/$RELATIVE_DIR/app/* /home/zhc268/shiny-server/setQCs/$RELATIVE_DIR/"

echo -e "############################################################"
echo -e "# Step 5. Final: prepare downloading files "
echo -e "############################################################"


rm -rf $SETQC_DIR"/download" || true ;mkdir $SETQC_DIR"/download"
cd $SETQC_DIR"/download"

# script 
data_dir="/projects/ps-epigen/"



libs_name_dic=(`cat $SETQC_DIR/including_libs.txt`)
for i in `seq 1 $LIB_LEN`
do 
    
    a=${libs_name_dic[2*$i-2]};b=${libs_name_dic[2*$i-1]};

    echo "tranfering $a to $b"
    find $data_dir"/seqdata" \( -name $a"_R*.bz2" -o -name $a"*.gz" \) -exec ln -s {} ./  \; 
    find $data_dir"/outputs/bams" \( -name $a"_R*.bam" -o -name $a".*bam" \)  -type f -exec ln -s {} ./  \; 
    find $data_dir"/outputs/peaks/"$a -name "*.filt.narrowPeak.gz"  -type f -exec ln -s {} ./  \; 
    find $data_dir"/outputs/signals/" \( -name $a"_R*fc*" -o -name $a".nodup*fc*" \) -type f -exec ln -s {} ./  \; 
    find $data_dir"/outputs/signals/" \( -name $a"_R*pval*" -o -name $a".nodup*pval*" \)  -type f -exec ln -s {} ./  \;
    find $data_dir"/outputs/signals/" \( -name $a"_R*pileup*" -o -name $a".nodup*pileup*" \)  -type f -exec ln -s {} ./  \;    

    # rename 
    
    find . \( -name $a"_R*.fastq.gz" -o -name $a"_R*.fastq.bz2" -o -name $a".*fastq.gz" -o -name $a".*fastq.bz2" \) | xargs -n1 -I '{}' echo mv {} {} | sed "s/$a/$b/2" | bash  2> /dev/null
    find . -name $a"_R*.PE2SE.bam" | xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE/$b\.raw/2;s/${a}_R1\.trim\.PE2SE/${b}\.raw/2" | bash 2> /dev/null #atac
    find . -name $a"_R*.PE2SE.bam" | xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.PE2SE/$b\.raw/2" | bash 2> /dev/null #PE chip
    find . -name $a".bam" | xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}/${b}\.raw/2" | bash 2> /dev/null    # SE chip 
    find . -name $a"_R*.nodup.bam" | xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE\.nodup/$b\.final/2;s/${a}_R1\.trim\.PE2SE\.nodup/${b}\.final/2"  | bash 2> /dev/null #atac
    find . -name $a"_R*.nodup.bam" | xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.PE2SE\.nodup/$b\.final/2"  | bash 2> /dev/null #PE chip
    
    find . -name $a".nodup.bam" | xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}\.nodup/${b}\.final/2"  | bash 2> /dev/null    #se chip 
    find . -name $a"_R*narrowPeak.gz" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE\.nodup\.tn5\.pf\.filt/$b/2;s/${a}_R1\.trim\.PE2SE\.nodup\.tn5\.pf\.filt/$b/2" | bash 2> /dev/null
    find . -name "*${a}.*narrowPeak.gz" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}\.nodup\.tagAlign/$b/2" | bash 2> /dev/null # se chip
    find . -name "*${a}_R*narrowPeak.gz" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.PE2SE\.nodup\.tagAlign/$b/2"  | bash 2> /dev/null # pe chip
    
    find . -name $a"_R*bigwig" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE\.nodup\.tn5\.pf/$b/2;s/${a}_R1\.trim\.PE2SE\.nodup\.tn5\.pf/$b/2" | bash 2> /dev/null
    find . -name "*${a}.*bw" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}\.nodup\.tagAlign/$b/2" | bash 2> /dev/null #se chip
    find . -name "*${a}_R*bw" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.PE2SE\.nodup\.tagAlign/$b/2" | bash 2> /dev/null #pe chip
    
    find . -name $a".*bigwig" |xargs -n1 -I '{}' echo mv {} {} | sed "s/${a}_R1\.fastq\.bz2\.PE2SE\.nodup\.pf/$b/2;s/${a}_R1\.trim\.PE2SE\.nodup\.pf/$b/2" | bash 2> /dev/null
done

# delete meta
rm -f *.meta

## generate files.txt
urlbase="http://epigenomics.sdsc.edu:8088/$RELATIVE_DIR/download/"
cd  $SETQC_DIR/download; ls -1 | while read f; do echo ${urlbase}${f};done >files.txt
## generate index for files 
tree -C -I '*.html' -D -H '.' -L 1 --noreport --charset utf-8 -T '' > index.html #--timefmt '%F %T'


## final output msg
echo "link: http://epigenomics.sdsc.edu:8088/$RELATIVE_DIR/setQC_report.html"

# END 

#EXAMPLES:

# setQC_wrapper.sh -n Set_96 -c true
# setQC_wrapper.sh -n Set_96 -c true -p false
# setQC_wrapper.sh -n Set_70 -c true -p false -t chip
# setQC_wrapper.sh -n Set_70_test -p false -t chip -m false
# setQC_wrapper.sh -n Set_113 -t atac_chip -c true -m false 
