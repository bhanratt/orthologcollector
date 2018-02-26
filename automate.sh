#!/bin/bash
#Brian Hanratty -- bhanratt@asu.edu
#ASU Bioinformatics Core Lab -- asubioinformatics.org
#Automation script for looping through all reference genomes in ref/ and all proteins in prot/
#Important: All reference genomes and proteins must be in .fa format and loaded into ref/ and prot/ respectively
#Created: 11/2/2017
#Modified: 2/26/2018

#Prompts user to choose if they want to apply the length filter, which will remove any results that are smaller than 3X the length of the protein.
read -p "Apply length filter? (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  lengthchoice="y";
else
  lengthchoice="n";
fi

#creates results directory and protein specific subdirectories
mkdir results
for proteindir in prot/*.fa
	do
		protdir=`echo ${proteindir%.fa} | sed 's,^[^/]*/,,'`
		mkdir results/$protdir
	done
#nested loop for looping through species and target proteins
for reference in ref/*.fa
	do
		for protein in prot/*.fa
			do
			prot=`echo ${protein%.fa} | sed 's,^[^/]*/,,'`
			ref=`echo ${reference%.fa} | sed 's,^[^/]*/,,'`
			python GetGeneIDs.py $prot
			bash logcollector.sh $reference $protein $lengthchoice
			mv Results.fa results/$prot/Results.$prot.$ref.fa
			mv Results.blr results/$prot/Results.$prot.$ref.blr
		done
	done
cd results
#combines results from multiple species into single per-protein files
for dir in *
	do
		cd $dir
		cat *.fa > Results.$dir.all.fa
		cat *.blr > Results.$dir.all.blr
		cd ..
	done
cd ..
#renames results directory with a timestamp
mv results results_$(date +%T-%F)
