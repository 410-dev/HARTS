#!/bin/bash
touch "/tmp/TESTDONE.harts"
while [[ ! -z $(ps -ax | grep "[l]ockvf") ]] || [[ ! -z $(ps -ax | grep "[l]ocker") ]]; do
	touch "/tmp/TESTDONE.harts"
	sleep 1
fi
sleep 3
#if [[ -z $(ps -ax | grep "/System/Library/CoreServices/[F]inder") ]]; then

	# ADD force finder start if finder is not started 

rm "/tmp/TESTDONE.harts"