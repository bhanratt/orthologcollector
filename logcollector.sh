#!/bin/bash
#Brian Hanratty -- bhanratt@asu.edu
#ASU Bioinformatics Core Lab -- asubioinformatics.org
#Parses a reference genome for orthologs of a protein
#Produces Orthlogs.fa, a fasta of all hits
#FIRST run `Python GetGeneIDs.py <gene>` to generate a necessary input file
#Created -- 9/12/2017
#Dependencies: blat, blastx, pslToBed, bedtools
#Includes: split.pl

if [ $# -lt 3 ]; then
	echo "Usage: $0 <genome fasta> <protein fasta> <y/n for length filter>"
	exit 1
fi

genome=$1
peptide=$2
lengthfilter=$3
peplength=`cat $peptide | awk '$0 ~ ">" {print c; c=0; } $0 !~ ">" {c+=length($0);} END { print c; }' | tail -n 1`
p=$((3*peplength))
genomename=`echo ${1%.fa} | sed 's,^[^/]*/,,'`
peptidename=`echo ${2%.fa} | sed 's,^[^/]*/,,'`
grepline=`cat grepline.txt`

echo 'Ortholog detector by ASU Bioinformatics Core Lab (asubioinformatics.org) - Last Updated: 2/26/2018'
echo 'using genome ' $genomename;
echo 'using peptide ' $peptidename;
echo 'peptide length: ' $peplength;
if [ "$lengthfilter" = "y" ]; then
	echo 'Length filter ON. Will remove any sequences smaller than: '$p;
else
	echo 'Length filter OFF.';
fi

date
echo 'Running Step 1: blat';

#can set -minScore=65 for more specific results
tools/blat $1 $2 -t=dnax -q=prot -minIdentity=65 -minScore=55 $genomename.$peptidename.blat.psl;
date
echo 'Running Step 2: pslToBed';
tools/pslToBed $genomename.$peptidename.blat.psl $genomename.$peptidename.blat.psl.bed;
date
echo 'Running Step 3: bedtools';
bedtools getfasta -s -split -fi $genome -bed $genomename.$peptidename.blat.psl.bed -fo Copies.$peptidename;

#split fasta by IDs
perl tools/split.pl --input_file Copies.$peptidename --output_dir ./;
date
echo 'Running Step 4: blastx and parse for protein';

#logic to filter out sequences that are smaller than 3X peptide length
if [ "$lengthfilter" = "y" ]; then
	for i in *.split
		do
		size=`cat $i | awk '$0 ~ ">" {print c; c=0; } $0 !~ ">" {c+=length($0);} END { print c; }' | tail -n 1`
		if [ "$size" -ge "$p" ]; then
			echo 'Passed the length filter: '$i;
		else
			echo 'Failed the length filter: '$i;
			rm $i;
		fi
		done
fi
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
