#!/bin/sh
#
# GNU/Linux does not really require something like RelativeLink.c
# However, we do want to have the same look and feel with similiar features.
# In the future, we may want this to be a C binary with a custom icon but at the moment
# it's quite simple to just use a shell script
#
# To run in debug mode simply pass --debug
#
# Copyright 2010 Erinn Clark <erinn@torproject.org>

if [ $1 ]; then 
	debug=$1
	printf "\nDebug enabled.\n\n"
fi

# If ${PWD} results in a zero length HOME, we can try something else...
HOME="${0%%Contents/MacOS/TorBrowserBundle}"
export HOME

DYLD_LIBRARY_PATH=${HOME}/Contents/Frameworks
export LDPATH
export DYLD_LIBRARY_PATH
DYLD_PRINT_LIBRARIES=1
export DYLD_PRINT_LIBRARIES

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
		./Contents/MacOS/Vidalia --loglevel debug --logfile vidalia-debug-log \
		--datadir ./Contents/Resources/Data/Vidalia/
		printf "\nVidalia exited with the following return code: $?\n"
	exit
fi

# not in debug mode, run proceed normally
printf "\nLaunching Tor Browser Bundle for Linux in ${HOME}\n"
cd "${HOME}"
$HOME/Contents/MacOS/Vidalia --datadir $HOME/Contents/Resources/Data/Vidalia/
