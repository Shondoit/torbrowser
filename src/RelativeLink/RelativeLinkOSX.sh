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

if [ "$1" == "--debug" ]; then 
	printf "\nDebug enabled.\n\n"
fi

HOME="${0%%Contents/MacOS/TorBrowserBundle}"
export HOME

DYLD_LIBRARY_PATH=${HOME}/Contents/Frameworks
export LDPATH
export DYLD_LIBRARY_PATH
DYLD_PRINT_LIBRARIES=1
export DYLD_PRINT_LIBRARIES

if [ "${debug}" ]; then
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
