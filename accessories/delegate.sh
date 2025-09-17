#!/bin/bash
COUNTER=0
for d in ./*/
do 
	let COUNTER+=1
	(cd $d && eval $1)
done
