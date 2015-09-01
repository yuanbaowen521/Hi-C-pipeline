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

Prerequisite:
To conduct the workflow, several softwares should be installed.
1: HiCUP (http://www.bioinformatics.babraham.ac.uk/projects/download.html#hicup)
2:  
3:
4:
















