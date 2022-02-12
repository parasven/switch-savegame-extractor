#!/bin/bash

## Executing directory of the script
script_home="$(dirname $(readlink -f "$BASH_SOURCE"))"
output_folder="$script_home/output"
conf_folder="$script_home/conf"
tools_folder="$script_home/tools"
NANDFS_mount="$script_home/NANDFS_mount"
SYSTEM_mount="$script_home/SYSTEM_mount"
USER_mount="$script_home/USER_mount"
mount_nandhac="$HOME/.local/bin/mount_nandhac"


## Check if hactoolnet is present, if not get the lattest release
if [[ ! -e "$tools_folder/hactoolnet" ]] 
then
	echo "hactoolnet is missing. Trying to download the latest release from github https://github.com/Thealexbarney/LibHac/releases/latest"
	echo "Rerun the script after this download"
	wget --quiet --content-disposition  $(curl -q -s https://api.github.com/repos/Thealexbarney/LibHac/releases/latest | jq -r '.["assets"][]|select(.name | endswith("-linux.zip"))["browser_download_url"]') -O "$tools_folder/hactool.zip"
	unzip "$tools_folder/hactool.zip" -d "$tools_folder"
	chmod +x "$tools_folder/hactoolnet"
fi

## Check if nxgamelist.csv is present, if not get it from https://www.eliboa.com/switch/nsw_titles.php?export=csv
if [[ ! -e "$conf_folder/nxgamelist.csv" ]]
then
	echo "nxgamelist.csv is missing. Trying to download the csv from https://www.eliboa.com/switch/nsw_titles.php?export=csv"
        echo "Rerun the script  after this download"
	wget --quiet --content-disposition https://www.eliboa.com/switch/nsw_titles.php?export=csv -O "$conf_folder/nxgamelist.csv"
fi

if [[ ! -e "$mount_nandhac" ]]
then
        echo "Tool mount_nandhac is missing. Trying to install it from https://github.com/ihaveamac/ninfs/archive/2.0.zip"
	echo "Rerun the script  after this download"
	python3 -m pip install --upgrade --user https://github.com/ihaveamac/ninfs/archive/2.0.zip
fi




## Catch non entered parameter
if [[ ! "$1" ]] 
then
	echo
        echo "Missing Parameter. Usage: $0 <\"Fullpath to rawnand.bin\">"
        echo "$0 \"/path/to/rawnand.bin\""
        exit
fi



## Mount NANDFS to "working directory/NANDFS_mount"
$mount_nandhac -o nonempty --keys "$conf_folder/prod.keys" "$1" "$NANDFS_mount"

if [[ $? == 0 ]]
then
	## Mount USER partion to "working directory/USER_mount"
	mount "$NANDFS_mount/USER.img" "$USER_mount"
	mount "$NANDFS_mount/SYSTEM.img" "$SYSTEM_mount"

else
	echo "There was an error of some sort. Aborting"
	exit 1
fi

## Iterate through savefaile found in Userpartition
while read savefile
do
	title_id=""
	title_name=""
	save_type=""
	echo "Processing file: $savefile"
	if [[ "$2" == "--info" ]]
	then
		"$tools_folder/hactoolnet" --listtitles -t save "$savefile"
	else
		title_id=$("$tools_folder/hactoolnet" --listtitles -t save "$savefile" | grep "Title ID:" | cut -d ":" -f2 | xargs | tr a-z A-Z)
		save_type=$("$tools_folder/hactoolnet" --listtitles -t save "$savefile" | grep "Save Type:" | cut -d ":" -f2 | xargs)
		title_name=$(cat "$conf_folder/nxgamelist.csv" | grep -i "$title_id" | cut -d";" -f2 | sed 's/[:,®,™,.,/,>,<,\",\\,|,?,*]//g')
		echo "$title_id"
		echo "$save_type"
		echo
		if [[ ! -e "$output_folder/$save_type/$title_name/$title_id/" ]]
		then
			mkdir -p "$output_folder/$save_type/$title_name/$title_id/"
		fi
		"$tools_folder/hactoolnet" -t save "$savefile" --outdir "$output_folder/$save_type/$title_name/$title_id/"


	fi
done <<<"$(find "$USER_mount/save/" -type f)"



echo -e "\n\nUnmouting $USER_mount..."
umount "$USER_mount"
echo "Unmouting $SYSTEM_mount..."
umount "$SYSTEM_mount"
echo "Unmouting $NANDFS_mount..."
umount "$NANDFS_mount"
