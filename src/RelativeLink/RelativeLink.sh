#!/bin/sh
#
# GNU/Linux does not really require something like RelativeLink.c
# However, we do want to have the same look and feel with similiar features.
# In the future, we may want this to be a C binary with a custom icon but at the moment
# it's quite simple to just use a shell script
#
# To run in debug mode simply pass --debug
#
# Copyright 2010 The Tor Project.  See LICENSE for licensing information.

if [ $1 ]; then 
	debug=$1
	printf "\nDebug enabled.\n\n"
fi

# If ${PWD} results in a zero length HOME, we can try something else...
if [ ! "${PWD}" ]; then
	# "hacking around some braindamage"
	HOME=`pwd`
	export HOME
	surveysays="This system has a messed up shell.\n"
else
	HOME="${PWD}"
	export HOME
fi

if ldd ./App/Firefox/firefox-bin | grep -q "libz\.so\.1.*not found"; then
	LD_LIBRARY_PATH=${HOME}/Lib:${HOME}/Lib/libz
else
	LD_LIBRARY_PATH=${HOME}/Lib
fi

LDPATH=${HOME}/Lib/
export LDPATH
export LD_LIBRARY_PATH
DYLD_PRINT_LIBRARIES=1
export DYLD_PRINT_LIBRARIES

# if any relevant processes are running, inform the user and exit cleanly
RUNNING=0
for process in tor vidalia polipo privoxy
        do pid=`pidof $process`
        if [ -n "$pid" ]; then
		printf "\n$process is already running as PID $pid\n\n"
		RUNNING=1
	fi
	done

if [ $RUNNING -eq 1 ]; then
	printf "Please shut down the above process(es) before running Tor Browser Bundle.\n\n"
	exit 0
fi


if [ "${debug}" ]; then
	if [ -n "${surveysays}" ]; then 
		printf "\nSurvey says: $surveysays\n\n"
	fi
  	
		# this is likely unportable to Mac OS X or other netstat binaries
  		for port in "8118" "9050"
  			do
			BOUND=`netstat -tan 2>&1|grep 127.0.0.1":${port}[^:]"|grep -v TIME_WAIT`
			if [ "${BOUND}" ]; then
			printf "\nLikely problem detected: It appears that you have something listening on ${port}\n"
			printf "\nWe think this because of the following: ${BOUND}\n"
			fi
		done

		printf "\nStarting Vidalia now\n"
		cd "${HOME}"
		printf "\nLaunching Vidalia from: `pwd`\n"
		./App/vidalia --loglevel debug --logfile vidalia-debug-log \
		--datadir Data/Vidalia/
		printf "\nVidalia exited with the following return code: $?\n"
	exit
fi

# not in debug mode, run proceed normally
printf "\nLaunching Tor Browser Bundle for Linux in ${HOME}\n"
cd "${HOME}"
./App/vidalia --datadir Data/Vidalia/
printf "\nExited cleanly. Goodbye.\n"
