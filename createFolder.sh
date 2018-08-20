#!/bin/bash
# Author: José Manuel C. Noronha
# Date: 16/06/2018
# Create folder if this folder not exist
# Full path to folder separete by space
# Example: folder1 folder2 folder3
# Output folder1/folder2/folder3

# Global var #
declare -a myArrayFolder=("$@")
declare fullPathFolder
declare message

# Functions #
# Check if folder exist
function isFolderExist(){
	local folder="$1"
	local -i response=0	# 0 = false / 1 = true

	if [ -d $folder ]; then
		response=1
	fi

	# Return response
	echo $response
}

# Create folder
function createFolder(){
	local folderToCreate="$1"
	local -i success
	mkdir "$folderToCreate"
}

# Main #
declare -i firstArgInserted=0
declare -i success=1

for arg in "${myArrayFolder[@]}";
do
	if [ $firstArgInserted -eq 0 ]; then
		fullPathFolder="$arg"
		firstArgInserted=1
	else
		# If last character of string is / insert fullPathFolder without /
		if [ "${fullPathFolder: -1}" == "/" ]; then
			fullPathFolder="$fullPathFolder$arg"
		else
			fullPathFolder="$fullPathFolder/$arg"
		fi
	fi

	# If folder not exist, create
	if [ $(isFolderExist "$fullPathFolder") -eq 0 ]; then
		$(createFolder "$fullPathFolder")
		if [ $(isFolderExist "$fullPathFolder") -eq 0 ]; then
			success=0
			break
		fi
	fi
done

# Print message
if [ $success -eq 0 ]; then
	message="### Error on create: $fullPathFolder ###"
else
	message="### Folder created: $fullPathFolder ###"
fi
echo "$message"