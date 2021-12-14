#!/bin/bash
if [ "$1" != "reboot" ]
then
	sleep 2
	echo "small Snooze"
	sleep 2
	echo "Snooze"
	sleep 2
	echo "large Snooze"
	sleep 2
	echo "super Snooze"
	sleep 2
	echo "hyper Snooze"
	sleep 2
	echo "mega Snooze"
	sleep 2
	echo "giga Snooze"
	sleep 2
	echo "tera Snooze"
	sleep 2
	echo "peta Snooze"
else
	echo "Reboot time. I do nothing"
fi
