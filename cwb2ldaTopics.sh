#!/bin/sh

# Argumente: 
# - Anzahl Topics
# - Zu bearbeitende Datei
# - "long" für lange Stopwortliste, nichts für normale Liste

malletpath="/path/to/mallet-2.0.7/bin/" # set here the path to mallet

mkdir Resultate

for file in $2
	do
	
	
	filename=`basename $file`
	echo "Bearbeite Datei $file ($filename) und finde $1 Topics..."
	echo "Mallet liegt in: $malletpath"
	
	if [ -z "$3" ] # testen, ob Variable $3 leer ist
		then stopwordfile="stopwords.txt"
		else stopwordfile="stopwords_longlist.txt"
	fi
	
	echo "Verwende $stopwordfile..."


	cp $file $file.csv
	perl -pi -e "s/^ *?(\d+): <text_(date|year|decade) (.+?)>: +(.+)/\1\t\3\t\4/" $file.csv
	perl -pi -e "s/\t(\d+)-(\d+)-(\d+)\t/\t\1-\2-\3\t\1\t/" $file.csv
	perl -pi -e "s/^(\d+)\t(\d+)\t/\1\t\2-00-00\t\2\t/" $file.csv
	perl -pi -e "s/ <.+?> / /" $file.csv
	
	echo "Sende $file.csv an mallet..."
	
	$malletpath/mallet import-file --input $file.csv --line-regex "^(.+?)\t(.+?)\t(.+)$" --output $file.mallet --preserve-case --token-regex "[\p{L}\p{N}]+|[\p{P}]+" --keep-sequence --remove-stopwords --stoplist-file $stopwordfile
	
	echo "Rechne LDA mit $file.mallet.."
	
	$malletpath/mallet train-topics --input $file.mallet --num-topics $1 --output-state $file.topic-state.gz --output-topic-keys $file.keys.txt --output-doc-topics $file.composition.txt --optimize-interval $1

	sed 1d $file.composition.txt > composition.tmp

	cut -f1,2,3 $file.csv > fields.tmp

	paste fields.tmp composition.tmp > $file.tab.tmp
	
	paste fields.tmp composition.tmp $file.csv > $file.fulldata.tab.tmp

	echo "ID\tDate\tYear\tCase\tID2\tTopic\tProbability" > header.tmp
	cat header.tmp $file.tab.tmp > $file.tab.txt
	cat header.tmp $file.fulldata.tab.tmp > $file.fulldata.tab.txt
	
	cut -f1,2,3,4,6,7 $file.tab.txt > $file.tab.simple.txt
	
	# Anführungszeichen aus keys-File löschen:
	perl -pi -e "s/\"//g" $file.keys.txt
	
	rm $file.*.tmp
	
	echo "Verschiebe Dateien..."
	
	mkdir Resultate/$filename/
	mv $file.* Resultate/$filename/
	
	echo "Visualisiere Ergebnisse mit R..."
	lemma=`echo $filename | cut -f2 -d _ | cut -f1 -d .`
	echo "R CMD BATCH --no-save --no-restore --verbose \"--args Resultate/$filename/$filename $lemma\" generateLDAGraphs.r"
	
	R CMD BATCH --no-save --no-restore "--args Resultate/$filename/$filename $lemma" generateLDAGraphs.r

done

rm *.tmp

echo "Arbeiten abgeschlossen."