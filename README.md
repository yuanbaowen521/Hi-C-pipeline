# Hi-C-pipeline
This repository contains a total workflow for Hi-C data analysis.

Workflow includes four steps:
1: raw data to mapped and filtered bam files
2: bam files to contact matrices and contact maps 
3: from bam files to list of significant interacctions 
4: from bam files to TADs

Step one:
From raw data to mapped and filtered bam files, this will employ
HiCUP (http://www.bioinformatics.babraham.ac.uk/projects/hicup/). 
Raw sequencing reads were processed, which maps the positions of
di-tags against the genomes, filters out experimental artifacts, 
such as circularized reads and re-ligations, and removes all 
duplicate reads.

A detailed document of HiCUP can be found at:
http://www.bioinformatics.babraham.ac.uk/projects/hicup/overview/

Step two:
From the mapped reads to contact matrices and maps, this step utilize
the software of ,,,

Step three:
From the mapped reads to list of significant interactions, which
utilize GOTHiC. GOTHiC assumes that biases occurring in HiC and
HiC-derived experiments are captured in the coverage (total number of
reads mapping to a given fragment or larger bin), including the bias
emanating from capturing one end of a ligation fragment, as the
capturing step will result in higher coverage of the captured
digestion fragment. Therefore significantly interacting regions or
true interactions can be separated from background noise using a
one-sided cumulative binomial test followed by Benjamini-Hochberg
correction for multiple testing. Interactions were further filtered by
removing those where the interacting fragment’s coverage was more
than 3 times or less than 0.2 times the median coverage and
those without a significant neighboring interaction (owing to the DNA’s 
polymer property those are likely to be artifacts). 

Step four:
From 



Prerequisite:
To conduct the workflow, several softwares should be installed.
1: HiCUP (http://www.bioinformatics.babraham.ac.uk/projects/download.html#hicup)
2: A bioconductor package GOTHiC 
3:
4:
















