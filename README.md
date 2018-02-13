# orthologcollector

**Dependencies**  
ncbi-blast+, bedtools  

**Simple run:**  
1: `python GetGeneIDs.py <gene>`  
2: `bash logcollector.sh <reference genome fasta> <protein fasta of gene used in step 1>`

**Batch run:**  
Functionality to run in batch mode on a collection of reference genomes and protein fastas  
Load all reference genomes into ref/   
Load all target proteins into prot/  
*important:* all fastas must be in .fa format  
`bash automate.sh`  
Resulted will be placed in a directory beginning with `results` followed by a timestamp. e.g. `results_2018-02-13-11:00:42`
