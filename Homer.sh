#!/bin/bash

#set -x
set -e
set -u

usage()
{
cat <<EOF
${txtcyn}
Usage:

$0 options${txtrst}

${bldblu}Function${txtrst}:

This script is used to create and normalize contact matrix by homer.
{txtbld}OPTIONS${txtrst}:

        -f	File containing the mapped paired end reads 
		(SAM or BAM format)${bldred}[NECESSARY]${txtrst}
	-n	Name of the sample.
	-R	Resolution. Represents how frequent the genome is
		divided up into regions, namely the binned size.
		[${bldred}Default 1 Mb${txtrst}]
	-S	Superresolution. represents how large the region is
		expanded when counting reads.[${bldred}Default 2
		Mb${txtrst}]
	-c	Use multiple processors, because the process is very
		slow, so better to use multiple processors.
		[${bldred}Default 8${txtrst}]
	-N	Outputs the ratio of observed to expected interactions
	        by assuming each region has an equal chance of
		interacting with every other region in the genome AND
		that regions are expected to interact depending
		on their linear distance along the chromosome. This
		attempts to take into account the "proximity ligation"
		effect, where adjact regions are expected to
		have interactions regardless of the specific 3D
		genomic structure. [${bldred}Default TRUE${txtrst}]
	-P	Outputs the natural log of the p-value describing the
		likelihood of observeing the actual number of
		interactions relative to the expected number of
		interactions between to two loci. This is calculated 
		conservatively as a cumulative binomial distribution.
		[${bldred}this parameter is conflict with -N${txtrst}]	
	-C	Instead of outputing the matrix as is, the value of
		each cell is replaced with the Peason's Correlation
		Coefficient between the row and column. [${bldred}this
		parameter can be used together with -N or -P${txtrst}]
EOF
}

file=
name=
resolution=1000000
superRes=2000000
cpu=8
norm=TRUE
logp=
corr=

while getopts "hf:z:" OPTION
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
		S)
			superRes=$OPTARG
			;;
		c)	
			cpu=$OPTARG
			;;
		N)
			norm=$OPTARG
			;;
		P)
			logp=$OPTARG
			;;
		C)
			corr=$OPTARG
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

samtools view -bh -f 0x40 ${file} > ${name}_read1.bam
samtools view -bh -f 0x80 ${file} > ${name}_read2.bam

echo "Begin to merge all the paired end reads into an initial tag directory"
#since the HiCUP has already filtered and removed reads, so these steps are
#skipped in this procedure.
makeTagDirectory ${sample}_filtered ${name}_read1.bam,${name}_read2.bam   

echo "Begin to create background models for Hi-C data, to save 
important parameters from normalization so that the background model 
only has to be computed once for a given resolution."
analyzeHiC ${sample}_filtered/ -res ${resolution} -bgonly -cpu ${cpu}

echo "Begin to create and normalize contact matrices"
if (${norm}) {
    if (${corr}) {
	analyzeHiC ${sample}_filtered/ -res ${resolution} -superRes \
	${superRes} ${norm} ${corr} > \
	${sample}.${resolution}by${superRes}Resolution_${norm}_${corr}.txt
    } else {
	analyzeHiC ${sample}_filtered/ -res ${resolution} -superRes \
	${superRes} ${norm} > \
	${sample}.${resolution}by${superRes}Resolution_${norm}.txt
    } 
} 

if (${logp}) {
    if (${corr}) {
	analyzeHiC ${sample}_filtered/ -res ${resolution} -superRes \
	${superRes} ${logp} ${corr} > \
	${sample}.${resolution}by${superRes}Resolution_${logp}_${corr}.txt
    } else {
    analyzeHiC ${sample}_filtered/ -res ${resolution} -superRes \
    ${superRes} ${logp} > \
    ${sample}.${resolution}by${superRes}Resolution_${logp}.txt
    }
}
