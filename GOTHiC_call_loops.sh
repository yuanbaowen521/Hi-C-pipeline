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
	-F	File containing the mapped reads of the first fragment
	        ends (usually the BAM format)${bldred}[NECESSARY]${txtrst}
	-S	File containing the mapped reads of the second fragment
	        ends (usually the BAM format)${bldred}[NECESSARY]${txtrst}
	-n	A character string that will be used to name the
		exported BedGraph file containing the coverage, R
		object files with paired and mapped reads, and the
		final data frame with the results from the binomial
		test. They will be saved in the current directory.
	-D	An integer specifying the maximum amount of duplicated
		paired-end reads allowed, over that value it is
		expected to be PCR bias.[${bldred}Default 1${txtrst}]
	-f	A character string specifying the format of the
		aligned reads. [${bldred}Default BAM, accepted
		'Bowtie'${txtrst}]
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
    	-p	Logical argument. If TRUE the mapping and the binomial
		test will be performed faster using multiple cores.
		[${bldred}Default FALSE ${txtrst}]
	-t	An integer specifying the number of cores used in the
		parallel processing if parellel=TRUE.
		[${bldred}Default 1${txtrst}]
	-R	An integer that gives the required bin size or
		resolution of the contact map. [${bldred}Default
		1000000${txtrst}]
	-c	A character string with three possibilities. "all"
		runs the binomial test on all interactions, "cis" runs
		the binomial test only on intrachromosomal/cis
		interactions, "trans" runs the binomial test only on
		interchromosomal/trans interactions. [${bldred}Default
		all${txtrst}]
	-d	An integer specifying the distance between the
		midpoint of fragments under which interactions are
		filtered out in order to filter for those read-pairs
		where the digestion was incomplete. [${bldred}Default
		10000${txtrst}]
	-o	The path and file name to save the results.
EOF
}

file1=
file2=
name=
DUPLICATETHRESHOLD=1
filetype='BAM'
BSgenomeName='BSgenome.Hsapiens.UCSC.hg19'
genome='BSgenome.Hsapiens.UCSC.hg19'
restrictionSite='A^AGCTT'
enzyme='HindIII'
parallel='FALSE'
cores=1
resolution=1000000
cistrans='all'
filterdist=10000
outfile=

while getopts "hF:S:n:D:f:B:g:r:e:p:t:R:c:d:o:" OPTION
do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		F)
			file1=$OPTARG
			;;
		S)
			file2=$OPTARG
			;;
		n)
			name=$OPTARG
			;;
		D) 
			DUPLICATETHRESHOLD=$OPTARG
			;;
		f)     
			filetype=$OPTARG
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
		p)
			parallel=$OPTARG
			;;
		t)
			cores=$OPTARG
			;;
		R)
			resolution=$OPTARG
			;;
		c)
			cistrans=$OPTARG
			;;
		d) 
			filterdist=$OPTARG
			;;
		o)
			outfile=$OPTARG
			;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -z $file1 ] || [ -z ${file2} ]; then
	usage
	exit 1
fi

cat <<END >${name}.r

library(GOTHiC)

paired <- pairReads("${file1}", "${file2}", sampleName='${name}',
	  DUPLICATETHRESHOLD = ${DUPLICATETHRESHOLD},
	  fileType='${filetype}')

mapped <- mapReadsToRestrictionSites(paired, sampleName='${name}',
	  BSgenomeName='${BSgenomeName}', genome=${genome},
	  restrictionSite='${restrictionSite}', enzyme='${enzyme}',
	  parallel=${parallel}, cores=${cores})   

#pdf(file="${name}.pvalue.pdf", width=600, height=800)

binom <- GOTHiC(mapped, sampleName='${name}', res=${resolution},
	 cistrans='${cistrans}', filterdist=${filterdist})

#pdf(file="${name}.pvalue.pdf", width=600, height=800, res=120)
dev.off()

write.table(binom, file="${outfile}", row.names=F, col.names=T, 
sep="\t", quote=FALSE)

END

Rscript ${name}.r
/bin/rm -f ${name}.r
#if [ "$?" == "0" ]; then /bin/rm -f ${name}.r; fi

