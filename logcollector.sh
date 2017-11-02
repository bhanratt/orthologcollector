#!/bin/bash
#Brian Hanratty -- bhanratt@asu.edu
#ASU Bioinformatics Core Lab -- asubioinformatics.org
#Parses a reference genome for orthologs of a protein
#Produces Orthlogs.fa, a fasta of all hits
#FIRST run `Python GetGeneIDs.py <gene>` to generate a necessary input file
#Created -- 9/12/2017
#Dependencies: blat, blastx, pslToBed, bedtools
#Includes: split.pl

if [ $# -lt 2 ]; then
	echo "Usage: $0 <genome fasta> <protein fasta>"
	exit 1
fi

genome=$1
peptide=$2
grepline=`cat grepline.txt`

echo 'Ortholog detector by ASU Bioinformatics Core Lab (asubioinformatics.org) - Last Updated: 10/31/2017'
echo 'using genome ' $genome;
echo 'using peptide ' $peptide;
date
echo 'Running Step 1: blat';
#can set -minScore=65 for more specific results
#maybe implement pblat to speed up the blat step https://github.com/icebert/pblat
tools/blat $1 $2 -t=dnax -q=prot -minIdentity=65 -minScore=55 $2.blat.psl;
date
echo 'Running Step 2: pslToBed';
tools/pslToBed $2.blat.psl $2.blat.psl.bed;
date
echo 'Running Step 3: bedtools';
bedtools getfasta -s -split -fi $genome -bed $2.blat.psl.bed -fo Copies.$peptide;
#split fasta by IDs
perl tools/split.pl --input_file Copies.$peptide --output_dir ./;
date
echo 'Running Step 4: blastx and parse for protein';
#parse split protein fastas for occurences of TP53 IDs and filter by identity >=65%
for i in *.split
do
	blastx -outfmt 6 -query $i -subject tools/humanprotein.fa > $i.blr;
	eval $grepline
	awk '$3 >= 65.00' $i.blr.tp53 > $i.blr.tp53.passed;
done
#remove non-matches
find . -name '*.passed' -size 0 -delete
#save potential hits
for i in $(ls *.blr.tp53.passed)
do
	mv $i ${i%.split.blr.tp53.passed}.orth;
done
#save fasta sequences
for i in $(ls *.orth)
do
	mv ${i%.orth}.split ${i%.orth}.orth.fa;
done

echo 'All done before cleanup!';
date
#concatenate results
cat *.orth.fa > Results.fa
cat *.orth > Results.blr
#cleanup temp files
rm *.orth.fa
rm *.orth
rm *.split
rm Copies.*
rm *.split.*
rm *.bed
rm *.psl
rm grepline.txt
echo 'All done!';
