#!/bin/bash

args=("$@")
DIRS=()
FILTER=".*@[0-9a-z\.\-]*${args[0]}[0-9a-z\.\-]*$" #Use first paramet to create regex filter
ROOT_DIRECTORY="."
if [[ -v QB_HOME ]]; then
    ROOT_DIRECTORY=$QB_HOME
fi
LAST_DIRECTORY=""
LAST_FILTER=""
DEPTH=false

function setArgumentDepth() {
	if [[ ${args[$1]} =~ ^[0-9]+$ ]]
	then 
		DEPTH=${args[$1]}
	fi
}

setArgumentDepth 1
setArgumentDepth 2

function likeAncestry () {
	DIR=$1
	PARENT_DIRECTORY=`dirname $DIR`
	if [[ $PARENT_DIRECTORY != $DIR ]]
	then
		likeAncestry $PARENT_DIRECTORY
	fi

	#Only add ancestors if it, minus it's parent directoy, passes criteria
	if [[ "$1#${LAST_DIRECTORY}" =~ ${FILTER} ]]
	then
		LAST_DIRECTORY=$1
		DIRS+=($1)
	fi
}

function likeDescendants() {
	#Unset space as a delimiter, so that find returns paths with
	# spaces in full.  Then reset that control after execution
	IFS=$'\t\n'
	DIR_COUNT=${#DIRS[@]}
	if [[ ! ${DEPTH} == false ]]
	then
		DIRS+=(`find ${ROOT_DIRECTORY} -maxdepth $DEPTH -type d -regextype posix-extended -iregex "${FILTER}"|sort`) 	
	else
		DIRS+=(`find ${ROOT_DIRECTORY} -type d -regextype posix-extended -iregex "${FILTER}"|sort`) 	
	fi
	unset $IFS #or IFS=$' \t\n'
}

#if second parameter exists, use that as root directory to start search
#else, default to current directory and also and path ancestry
if [[ ! -z ${args[1]} ]] 
then
	if [[ ${DEPTH} == false ]]
	then
		ROOT_DIRECTORY=${args[1]}
	fi
else
	likeAncestry `pwd` #Search up current path
fi

likeDescendants

DIR_COUNT=${#DIRS[@]}
if (( $DIR_COUNT  == 0 ))
then
	echo "No results please try again with another query."
else
	if [ $DIR_COUNT -lt 10 ]
	then
		ZERO_PADDING="%01d"
	else
		ZERO_PADDING="%02d"
	fi
	while true; do
		let i=0
		FILTERED_DIRS=()
		let current_directory_list_count=0
		for DIR in ${DIRS[@]}
		do
			#Compare directory minus last recorded directory against
			# filter to add only uniquely rooted file paths
			(( current_directory_list_count++ ))
			shopt -s nocasematch
			if [[ "`printf $ZERO_PADDING ${current_directory_list_count}`: ${DIR#${LAST_DIRECTORY}}" =~ ${FILTER} ]]
				then
				(( i++ ))
				echo `printf $ZERO_PADDING $i`: ${DIR}
				FILTERED_DIRS+=(${DIR})
				
				#Don't record files, only directories
				if [[ -d ${DIR} ]]
				then
					LAST_DIRECTORY=${DIR}
				fi
			fi
		done

		if [[ $i == 1 ]]
			then
				#Check if lone path is a directory or file
				if [[ -d ${FILTERED_DIRS[0]} ]]
					then
						cd -P ${FILTERED_DIRS[0]}
					else
						#If file, change to parent directory
						cd -P `dirname ${FILTERED_DIRS[0]}`
				fi
				break	
		fi

		if [[ $i == 0 ]]
			then
				FILTER=${LAST_FILTER}
				echo "No results.  Try again with previous query."
			else
				DIRS=( "${FILTERED_DIRS[@]}" )
				LAST_FILTER=${FILTER}
				read FILTER

				if [[ $FILTER =~ ^[0-9]+:$ ]]
				then
					FILTER="^$FILTER"
				fi
		fi
	done
fi
