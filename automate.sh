#!/bin/bash
#Brian Hanratty -- bhanratt@asu.edu
#ASU Bioinformatics Core Lab -- asubioinformatics.org
#Automation script for looping through all reference genomes in ref/ and all proteins in prot/
#Important: All reference genomes and proteins must be in .fa format and loaded into ref/ and prot/ respectively
#Created: 11/2/2017
#Modified: 2/13/2018

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
			bash logcollector.sh $reference $protein
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
