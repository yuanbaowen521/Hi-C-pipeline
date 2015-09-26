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

This script is used to call significant interactions between distal
genomic loci, based on the bioconductor package GOTHiC.

${txtbld}OPTIONS${txtrst}:
	-f	File containing the pair-end mapped reads.
	        (usually the BAM format)${bldred}[NECESSARY]${txtrst}
	-s	The name of the Sample. 
	-D	An integer specifying the maximum amount of duplicated
		paired-end reads allowed, over that value it is
		expected to be PCR bias.[${bldred}Default 1${txtrst}]
    	-B	A character string of the BSgenome package required
		to make the restriction fragment file containing information
		for both the organism the experiment was made in, and
		the genome version the reads were mapped to.
		[${bldred}Default
		'BSgenome.Hsapiens.UCSC.hg19'${txtrst}]
	-g	The BSgenome package required to make the restriction
		fragment file containing information for both the
		organism the experiment was made in, and the genome
		version the reads were mapped to. [${bldred}Default
		'BSgenome.Hsapiens.UCSC.hg19'${txtrst}] 
    	-e	A character string containing the name of the enzyme
		used during the Hi-C experiment (i.e. "HindIII",
		"NcoI").[${bldred}Default 'HindIII'${txtrst}]
	-r      A character string that specifies the enzymes 
		recognition site, ^ indicating where the enzyme
		actually cuts. [${bldred}Default HindIII restriction
		site:'A^AGCTT'${txtrst}]
	-R	An integer that gives the required bin size or
		resolution of the contact map. [${bldred}Default
		1000000${txtrst}]
	-c	A character string with three possibilities. "all"
		runs the binomial test on all interactions, "cis" runs
		the binomial test only on intrachromosomal/cis
		interactions, "trans" runs the binomial test only on
		interchromosomal/trans interactions. [${bldred}Default
		all${txtrst}]
	-p	The path of the directory that will save the
		interaction results of each chromosome.
EOF
}

file=
sample=
DUPLICATETHRESHOLD=1
BSgenomeName='BSgenome.Hsapiens.UCSC.hg19'
genome='BSgenome.Hsapiens.UCSC.hg19'
restrictionSite='A^AGCTT'
enzyme='HindIII'
resolution=1000000
cistrans='all'
outpath=

while getopts "hf:s:D:B:g:r:e:R:c:p:" OPTION
do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		f)
			file=$OPTARG
			;;
		s)
			sample=$OPTARG
			;;
		D) 
			DUPLICATETHRESHOLD=$OPTARG
			;;
		B)
			BSgenomeName=$OPTARG
			;;
		g)
			genome=$OPTARG
			;;
		r)
			restrictionSite=$OPTARG
			;;
		e)
			enzyme=$OPTARG
			;;
		R)
			resolution=$OPTARG
			;;
		c)
			cistrans=$OPTARG
			;;
		p)
			outpath=$OPTARG
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
    samtools view -b -f 0x40 - > ${sample}_chr${i}_read1.bam 

    samtools view -bh -f 0x80 ${file} > ${sample}_read2.bam
###This will find all the intra- and inter-interactions by chromosomes

#    samtools view -h ${file} | awk -v i=$i \
#    'BEGIN{FS=OFS="\t";}{if($3=="chr"i||$1~/^@/) print $0;}' - | \
#    samtools view -b -f 0x80 - > ${sample}_chr${i}_read2.bam

    echo "Begin to call interactions of chr${i}."

    GOTHiC_call_loops.sh -F ${sample}_chr${i}_read1.bam -S \
    ${sample}_read2.bam -n chr${i} -D ${DUPLICATETHRESHOLD} \
    -B ${BSgenomeName} -g ${genome} -e "${enzyme}" -r \
    ${restrictionSite} -R ${resolution} -c ${cistrans} -o \
    ${outpath}/chr${i}_in_situ_${resolution}_interactions.txt
done 
