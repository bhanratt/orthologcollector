#!/bin/bash
#Brian Hanratty -- bhanratt@asu.edu
#ASU Bioinformatics Core Lab -- asubioinformatics.org
#Automation script for looping through all reference genomes in ref/ and all proteins in prot/
#Important: All reference genomes and proteins must be in .fa format and loaded into ref/ and prot/ respectively
#Created: 11/2/2017
#Modified: 2/9/2018
mkdir results
for reference in ref/*.fa
	do
		for protein in prot/*.fa
			do
			prot=`echo ${protein%.fa} | sed 's,^[^/]*/,,'`
			ref=`echo ${reference%.fa} | sed 's,^[^/]*/,,'`
			mkdir results/$prot
			python GetGeneIDs.py $prot
			bash logcollector.sh $reference $protein
			mv Results.fa results/$prot/Results.$prot.$ref.fa
			mv Results.blr results/$prot/Results.$prot.$ref.blr
		done
	done
cd results
for dir in *
	do
		cd $dir
		cat *.fa > Results.$dir.all.fa
		cat *.blr > Results.$dir.all.blr
		cd ..
	done
cd ..
