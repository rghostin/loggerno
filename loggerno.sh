#!/bin/bash

# todo
# clear all history files in homes for all users

set -e
set -a

TRACKFILE="tracks.txt"


RED=$(tput setaf 1) GREEN=$(tput setaf 2) YELLOW=$(tput setaf 3) CYAN=$(tput setaf 6) NC=$(tput sgr0) 
PROCESSED="${GREEN}[PROCESSED]${NC}"
FAILED="${RED}[FAILED]${NC}"
NOT_FOUND="${YELLOW}[NOT_FOUND]${NC}"

logstatus() {
    printf '%-100s: %s\n' "* $1" "$2"
}

logmsg() {
    printf '%-100s: %s\n' "${CYAN}[*] $1${NC}" ""
}


clean() {
  shred -z -n3 -v "$1"
}


process() {
    if [ -d "$1" ]; then
        process_dir "$1"
    elif [ -f "$1" ]; then
        clean "$1"
        if [ $? -eq 0 ]; then
           logstatus "$1" "$PROCESSED"
        else
           logstatus "$1" "$FAILED"
        fi
    else
        logstatus "$1" "$NOT_FOUND"
    fi
}

process_dir() {
    if [ ! -d "$1" ]; then
        echo "Error: $1 is not a directory"
        exit 1
    fi
    find "$1" -type f -exec bash -c 'process "$0"' {} \;
}

# check if root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root" 
   exit 1
fi


# process track file
logmsg "Processing files from ${TRACKSFILE}"
while read f; do
    # skip if blank or startswith #
    if [[ -n "$f" && "$f" != [[:blank:]#]* ]]; then
        process "$f"
    fi
done < "${TRACKFILE}"

process all .log , in case we missed something
logmsg "Processing all .log files"
find / -type f -name "*.log" -exec bash -c 'process "$0"' {} \;

