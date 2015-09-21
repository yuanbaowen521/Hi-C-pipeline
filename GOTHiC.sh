#!/bin/bash

#set -x
#set -e
#set -u

usage()
{
cat <<EOF
${txtcyn}

******Created by Bao-Wen Yuan (yuanbaowen521@126.com)******

Usage:

$0 options${txtrst}

${bldblu}Function${txtrst}:

This script is used to call the function of GOTHiC_call_loops.sh to
find chromatin interactions by chromosomes. This script is used when
the large data set are beyond the momery of server.

${txtbld}OPTIONS${txtrst}:
	-f	File containing the mapped paired end reads
		(usually the BAM format)${bldred}[NECESSARY]${txtrst}
	-n	A character string that will be used to name the
		exported BedGraph file containing the coverage, R
		object files with paired and mapped reads, and the
		final data frame with the results from the binomial
		test. They will be saved in the current directory.
	-R	An integer that gives the required bin size or
		resolution of the contact map. [${bldred}Default
		5000${txtrst}]
	-o	The directory that the results should be placed. 
EOF
}

file=
name=
resolution=5000
outpath=

while getopts "hf:n:R:o:" OPTION
do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		f)
			file=$OPTARG
			;;
		n)
			name=$OPTARG
			;;
		R)
			resolution=$OPTARG
			;;
		o)	outpath=$OPTARG
			;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -z $file ]; then
	usage
	exit 1
fi

for i in $(echo `seq 1 1 22` X Y)
do 
    samtools view -h ${file} | awk -v i=$i \
    'BEGIN{FS=OFS="\t";}{if($3=="chr"i||$1~/^@/) print $0;}' - | \
    samtools view -b -f 0x40 - > ${name}_chr${i}_read1.bam 
    
    samtools view -h ${file} | awk -v i=$i \
    'BEGIN{FS=OFS="\t";}{if($3=="chr"i||$1~/^@/) print $0;}' - | \
    samtools view -b -f 0x80 - > ${name}_chr${i}_read2.bam

    echo "Begin to call interactions of chr${i}.

    GOTHiC_call_loops.sh -F ${name}_chr${i}_read1.bam -S \
    ${name}_chr${i}_read2.bam -n chr${i} -e "MboI" -r ^GATC -R \
    ${resolution} -o ${outpath}/chr${i}_in_situ_${resolution}_interactions.txt
done


