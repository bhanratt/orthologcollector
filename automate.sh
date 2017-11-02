#!/bin/bash
#Brian Hanratty -- bhanratt@asu.edu
#ASU Bioinformatics Core Lab -- asubioinformatics.org
#Automation script for looping through all reference genomes in ref/ and all proteins in prot/
#Important: All reference genomes and proteins must be in .fa format and loaded into ref/ and prot/ respectively
#Created: 11/2/2017
#Modified: 11/2/2017
for reference in ref/*.fa
	do
		for protein in prot/*.fa
			do
			prot=`echo ${protein%.fa} | sed 's,^[^/]*/,,'`
			ref=`echo ${reference%.fa} | sed 's,^[^/]*/,,'`
			python GetGeneIDs.py $prot
			bash logcollector.sh $reference $protein
			mv Results.fa $ref.$prot.fa
			mv Results.blr $ref.$prot.blr
		done
	done