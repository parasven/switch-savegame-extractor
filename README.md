## Description
Mounts a raw nand dump from nintendo switch and extracts the savegames to the output folder.
Uses the following tools to do so:
- ninfs
- hactool

jq, wget, mount, unzip

Uses a gamelist from https://www.eliboa.com/switch/nsw_titles.php?export=csv ins csv format to identify the games via ID so we can have nice names in the output folder to better identify the games later on.


## Usage
# Extract saves
./extract_saves.sh ./rawnand.bin


# If you pass a second paramter --info nothing will be extracted but only information from the savegames will be show.
./extract_saves.sh ./rawnand.bin --info


## CSV for gamelist with serials
https://www.eliboa.com/switch/nsw_titles.php?export=csv

## ninfs Repo
https://github.com/ihaveamac/ninfs

## hactool Repo
https://github.com/Thealexbarney/LibHac
