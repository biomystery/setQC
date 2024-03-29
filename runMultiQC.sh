#!/bin/bash
# setQC1: get the multiQC reports for the input libs

usage() { echo "Usage: $0 [-l <ints>] [-s <int>] [-n <_2|_3|etc.>] [-t <strings|blank(no trim step)>" 1>&2; exit 1; }

while getopts "s:n:" o; do
    case $o in
        s) s="${OPTARG}";; # set 
        n) n="$OPTARG" ;; # _2 (no of seq of the lib)
        *) usage;;
    esac
done

shift $((OPTIND-1))

#if [ -z "${l}" ] || [ -z "${s}" ]; then
#    usage
#fi

echo "input lib number: $@"
echo "input lib run number = ${n} /blank for the first lib"
echo "output set number = ${s}"
echo

# take the input as array
libs_array=($@)
libs_array=("${libs_array[@]/#/JYH_}") #add prefix

echo "copying files:...."

libs_array=("${libs_array[@]/%/${n}}") #add postfix, seqlib Number

libQC_dir="/projects/ps-epigen/outputs/"
out_dir="/projects/ps-epigen/outputs/setQCs/Set_${s}/"
mkdir -p $out_dir

echo ${libs_array[@]} > ${out_dir}including_libs.txt

# paste the command 
#cmd="multiqc -k tsv -f -p ${libs_array[@]/#/${libQC_dir}libQCs/}  ${libs_array[@]/#/${libQC_dir}peaks/} -o $out_dir --tag  "
if [ -n "$n" ] ; then suffix="/*trim*"; else suffix="/*";fi #-n also means trimmed for IGM core 
file1=("${libs_array[@]/#/${libQC_dir}libQCs/}")
file1=("${file1[@]/%/${suffix}}")


file2=("${libs_array[@]/#/${libQC_dir}libQCs/}")
file2=("${file2[@]/%/${suffix}}")


logs_dir=$out_dir"logs/"
mkdir -p $logs_dir

for f in ${file1[@]}; do  cp -u $f $logs_dir;done
for f in ${file2[@]}; do  cp -u $f $logs_dir; done 

# load the multiQC environment
source activate bds_atac_py3
multiqc -k tsv -f -p $logs_dir -o $out_dir

rm -rf $logs_dir


# eg:
# runMultiQC.sh -l "48 49 50 51 52 53 54 55 56 57" -s 4_2 -n _2
