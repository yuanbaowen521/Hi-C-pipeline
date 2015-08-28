# Hi-C-pipeline
This repository will contain a total workflow of Hi-C data analysis.
From raw data to the called TADs and significant interactions.
For the whole workflow, several steps will be taken:
Step one: from raw data to the filterd mapped reads
In this step, we will employee HiCUP(http://www.bioinformatics.babraham.ac.uk/projects/hicup/):
Raw sequencing reads were processed, which maps the positions of
di-tags against the human genome (hg19), filters out experimental
artifacts, such as circularized reads and re-ligations, and removes 
all duplicate reads.
A detailed document of HiCUP can be found at: 
http://www.bioinformatics.babraham.ac.uk/projects/hicup/overview/


