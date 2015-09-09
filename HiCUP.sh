#!/bin/bash

#set -x

usage()
{
cat <<EOF
${txtcyn}

****** Created by Bao-Wen Yuan (yuanbaowen521@126.com) ******

Usage:

$0 options${txtrst}

${bldblu}Function${txtrst}:

This script is used to call the function of HiCUP.

${txtbld}OPTIONS${txtrst}:
	-f	FASTQ files to be analysed, placing paired files
		adjacent ${bldred}[NECESSARY]${txtrst}
    	-o	Directory to which output files should be
		written ${bldred}[Default current directory]${txtrst}
	-p	Number of threads to use ${bldred}[Default
		8]${txtrst}
	-s	Suppress progress updates (0: off, 1:on) ${bldred}
		[Default 0]${txtrst}
	-r	Retain intermediate pipeline files (0: off, 1:on)
		${bldred}[Default 1]${txtrst}
	-c	Compress outputfiles (0: off, 1: on) ${bldred} 
		[Default 0]${txtrst}
	-b	Path to the alignment program Bowtie (include the
		executable Bowtie filename) ${bldred}[Default
		/home/baowen/softwares/bowtie2-2.2.5/bowtie2]${txtrst}
	-i	Path to the reference genome indices, including the
		basename of the genome indices ${bldred}[Default
		/home/baowen/baowen/Genomes/Homo_sapiens/UCSC/hg19/Seq
		uence/Bowtie2Index/genome]${txtrst} 	
	-d	Path to the genome digest file produced by hicup_digester
		${bldred}[NECESSARY]${txtrst}
	-F	FASTQ format (valid formats: 'Sanger',
		'Solexa_Illumina_1.0', 'Illumina_1.3' or 'Illumina_1.5')
		${bldred}[Default Sanger]${txtrst}
	-m	Maximum di-tag length ${bldred}[Default 800]${txtrst}
	-n	Minimum di-tag length ${bldred}[Default 150]${txtrst}
EOF
}

#file="a_1.fastq,a_2.fastq b_1.fastq,b_2.fastq c_1.fastq,c_2.fastq"
file=""
output=
threads=8
supress=0
retain=0
compress=0
bowtie= "/home/baowen/softwares/bowtie2-2.2.5/bowtie2"
index= "/home/baowen/baowen/Genomes/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome"
digest=
format="Sanger"
max=800
min=150

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
		o)
			output=$OPTARG
			;;
		p)	
			threads=$OPTARG
			;;
		s)
			supress=$OPTARG
			;;
		r)
			retain=$OPTARG
			;;
		c)
			compress=$OPTARG
			;;
		b)	
			bowtie=$OPTARG
			;;
		i)
			index=$OPTARG
			;;
		d)
			digest=$OPTARG
			;;
		-F)
			format=$OPTARG
			;;
		-m)
			max=$OPTARG
			;;
		-n)
			min=$OPTARG
			;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -z "$file" ]; then
	usage
	exit 1
fi

fileL=`echo ${file} | sed -e 's/,/\n/g' -e 's/ /\n\n/g'`

cat <<END > hicup.conf

#Example configuration file for the hicup Perl script - edit as required
########################################################################

#Directory to which output files should be written (optional parameter)
#Set to current working directory by default
Outdir: ${output}

#Number of threads to use
Threads: ${threads}

#Suppress progress updates (0: off, 1: on)
Quiet: ${supress}

#Retain intermediate pipeline files (0: off, 1: on)
Keep: ${retain}

#Compress outputfiles (0: off, 1: on)
Zip: ${compress}

#Path to the alignment program Bowtie (include the executable Bowtie filename)
Bowtie: ${bowtie}

#Path to the reference genome indices
#Remember to include the basename of the genome indices
Index: ${index}

#Path to the genome digest file produced by hicup_digester
Digest: ${digest}

#FASTQ format (valid formats: 'Sanger', 'Solexa_Illumina_1.0', 'Illumina_1.3' or 'Illumina_1.5')
#If not specified, HiCUP will try to determine the format automatically by analysing
#one of the FASTQ files. All input FASTQ will assumed to be in this format
Format: ${format}

#Maximum di-tag length (optional parameter)
Longest: ${max}

#Minimum di-tag length (optional parameter)
Shortest: ${min}  

#FASTQ files to be analysed, placing paired files on adjacent lines
${fileL}

END

hicup --config hicup.conf
if [ "$?" == "0" ]; then /bin/rm -f hicup.conf; fi
