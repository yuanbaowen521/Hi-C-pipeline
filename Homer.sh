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

This script is used to get contact matrix from homer.
{txtbld}OPTIONS${txtrst}:

        -f	Data file ${bldred}[NECESSARY]${txtrst}
	-z	Is there a header[${bldred}Default TRUE${txtrst}]
EOF
}

file=
header='TRUE'

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
		z)
			header=$OPTARG
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

echo "Begin to merge all the paired end reads into an initial tag directory"
#since the HiCUP has already filtered and removed reads, so these steps are
#skipped in this procedure.
makeTagDirectory ${sample}_filtered ${sample}_read1.sam,${sample}_read2.sam   

echo "Begin to create background models for Hi-C data, to save 
important parameters from normalization so that the background model 
only has to be computed once for a given resolution."
analyzeHiC ${sample}_filtered/ -res ${resolution} -bgonly -cpu ${cpu}

echo "Begin to create and normalize contact matrices"
if (${norm}) {
    analyzeHiC ${sample}_filtered/ -res ${resolution} -superRes \
    ${superRes} ${norm} > \
    ${sample}.${resolution}by${superRes}Resolution_${norm}.txt
} else if (${norm} && ${corr}) {
    analyzeHiC ${sample}_filtered/ -res ${resolution} -superRes \
    ${superRes} ${norm} ${corr} > \
    ${sample}.${resolution}by${superRes}Resolution_${norm}_${corr}.txt
} else if (${logp}) {
    analyzeHiC ${sample}_filtered/ -res ${resolution} -superRes \
    ${superRes} ${logp} > \
    ${sample}.${resolution}by${superRes}Resolution_${logp}.txt
} else if (${logp} && ${corr}) {
    analyzeHiC ${sample}_filtered/ -res ${resolution} -superRes \
    ${superRes} ${logp} ${corr} > \
    ${sample}.${resolution}by${superRes}Resolution_${logp}_${corr}.txt
