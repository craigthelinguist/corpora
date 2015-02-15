#!/bin/sh

# check input file has been specified
if [ $# -eq 0 ]
	then
		echo "Error: no arguments supplied."
		echo "Usage: make-corpora.sh input.txt"
		echo "Where input.txt is your corpus."
		exit
fi

# input is the location of your corpus
input=$1

# do n-gram counts for degree 1,2,3
for degree in {1..3}
do

	# fname is where the output for this will be
	# delete $fname if it already exists
	fname="output"$degree".txt"
	if [ -f $fname ]
		then
			rm $fname	
	fi

	# make output, run program
	touch $fname
	echo "=============="
	echo "Making "$degree"-gram corpus."
	ruby environments.rb $input $fname -$degree

done

# print exit msg
echo "*** FINISHED COUNTING N-GRAMS ***"
