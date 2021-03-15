#!/bin/bash

set -a

TRACKFILE="tracks.txt"

HISTSIZE=0
HISTFILE=/dev/null


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

logwarning() {
    printf '%-100s: %s\n' "${RED}[!] $1${NC}" ""
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

process_carefull() {
    read -p "Process $1 (y|*)? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        process "$1"
    fi
}



# check if root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root" 
   exit 1
fi


# process tracks file
logmsg "Processing files from ${TRACKSFILE}"
while read f; do
    # skip if blank or startswith #
    if [[ -n "$f" && "$f" != [[:blank:]#]* ]]; then
        process "$f"
    fi
done < "${TRACKFILE}"

# process all _history files
logmsg "Processing history files"
find / -type f -name "*_history" -not \( -path /run -prune \) -exec bash -c 'process_carefull "$0"' {} \;

# process all .log , in case we missed something
logmsg "Processing all .log files"
find / -type f -name "*.log" -exec bash -c 'process_carefull "$0"' {} \;


# warnings
logwarning "DO NOT FORGET to clear history: history -c"