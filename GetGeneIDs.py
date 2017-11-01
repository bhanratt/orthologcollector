#Brian Hanratty
#bhanratt@asu.edu
#Accepts a Gene Symbol from user input and produces a file to be read by logcollector.sh

import sys
data_table = {}

#Import Gene Dictionary
try:
	f1=open('AllGeneIDs.txt')
	for line in f1:
	    geneid = str.strip(line.split('|')[0])
	    genesymbol = str.strip(line.split('|')[1])
	    data_table.setdefault(genesymbol, set( )).add(geneid)

#Missing dictionary handling
except FileNotFoundError:
	print("Missing dependency: AllGeneIDs.txt")
	sys.exit(1)

gene=raw_input('Enter a gene symbol: ').upper()

#Do the thing
if gene in data_table:
	matchedids=list(data_table[gene])
	resultline= ' -e '.join(matchedids)
	fw=open('grepline.txt', 'w')
	fw.write('grep -e '+resultline+' $i.blr > $i.blr.tp53')
else:
	print("Gene not found in dictionary. Maybe a typo?")
	sys.exit(1)

print('All done!')
f1.close()
fw.close()
