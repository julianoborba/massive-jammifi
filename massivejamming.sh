#!/bin/bash

SCRIPT=wifijammer_1.0.sh
MONIFACE=wlp2s0mon

if [ x"`which id 2> /dev/null`" != "x" ]; then
	USERID="`id -u 2> /dev/null`"
fi
if [ x$USERID = "x" -a x$UID != "x" ]; then
	USERID=$UID
fi
if [ x$USERID != "x" -a x$USERID != "x0" ]; then
	echo "Run it as root" ; exit ;
fi

for d in [1-9]
do
    ( cd $d && gnome-terminal -e "sh $SCRIPT -i $MONIFACE -c $d" )
done

for d in [1][0-1]
do
    ( cd $d && gnome-terminal -e "sh $SCRIPT -i $MONIFACE -c $d" )
done