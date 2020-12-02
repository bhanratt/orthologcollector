# orthologcollector

**Dependencies**  
ncbi-blast+, bedtools  

**Simple run:**  
1: `python GetGeneIDs.py <gene>`  
2: `bash logcollector.sh <reference genome fasta> <protein fasta of gene used in step 1> <y or n for apply length filter> <multiplier for filter>`

**Batch run:**  
Functionality to run in batch mode on a collection of reference genomes and protein fastas  
Load all reference genomes into ref/   
Load all target proteins into prot/  
*important:* all fastas must be in .fa format  
`bash automate.sh`  
Results will be placed in a directory beginning with `results` followed by a timestamp. e.g. `results_2018-02-13-11:00:42`

# License  
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  
  
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  
  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
