#!/bin/sh
#
# GNU/Linux does not really require something like RelativeLink.c
# However, we do want to have the same look and feel with similiar features.
#
# To run in debug mode simply pass --debug
#
# Copyright 2010 The Tor Project.  See LICENSE for licensing information.

# First, make sure DISPLAY is set.  If it isn't, we're hosed; scream
# at stderr and die.
if [ "x$DISPLAY" = "x" ]; then
	echo "The Tor Browser Bundle for Linux must be run within the X Window System." >&2
	echo "Exiting." >&2
	exit 1
fi

# Determine whether we are running in a terminal.  If we are, we
# should send our error messages to stderr...
ARE_WE_RUNNING_IN_A_TERMINAL=0
if [ -t 1 -o -t 2 ]; then
	ARE_WE_RUNNING_IN_A_TERMINAL=1
fi

# ...unless we're running in the same terminal as startx or xinit.  In
# that case, the user is probably running us from a GUI file manager
# in an X session started by typing startx at the console.
#
# Hopefully, the local ps command supports BSD-style options.  (The ps
# commands usually used on Linux and FreeBSD do; do any other OSes
# support running Linux binaries?)
ps T 2>/dev/null |grep startx 2>/dev/null |grep -v grep 2>&1 >/dev/null
not_running_in_same_terminal_as_startx="$?"
ps T 2>/dev/null |grep xinit 2>/dev/null |grep -v grep 2>&1 >/dev/null
not_running_in_same_terminal_as_xinit="$?"

# not_running_in_same_terminal_as_foo has the value 1 if we are *not*
# running in the same terminal as foo.
if [ "$not_running_in_same_terminal_as_startx" -eq 0 -o \
     "$not_running_in_same_terminal_as_xinit" -eq 0 ]; then
	ARE_WE_RUNNING_IN_A_TERMINAL=0
fi

# Complain about an error, by any means necessary.
# Usage: complain message
# message must not begin with a dash.
complain () {
	# If we're being run in a terminal, complain there.
	if [ "$ARE_WE_RUNNING_IN_A_TERMINAL" -ne 0 ]; then
		echo "$1" >&2
		return
	fi

	# Otherwise, we're being run by a GUI program of some sort;
	# try to pop up a message in the GUI in the nicest way
	# possible.
	#
	# In mksh, non-existent commands return 127; I'll assume all
	# other shells set the same exit code if they can't run a
	# command.  (xmessage returns 1 if the user clicks the WM
	# close button, so we do need to look at the exact exit code,
	# not just assume the command failed to display a message if
	# it returns non-zero.)

	# First, try zenity.
	zenity --error --text="$1"
	if [ "$?" -ne 127 ]; then
		return
	fi

	# Try xmessage.
	xmessage "$1"
	if [ "$?" -ne 127 ]; then
		return
	fi

	# Try gxmessage.  This one isn't installed by default on
	# Debian with the default GNOME installation, so it seems to
	# be the least likely program to have available, but it might
	# be used by one of the 'lightweight' Gtk-based desktop
	# environments.
	gxmessage "$1"
	if [ "$?" -ne 127 ]; then
		return
	fi
}

if [ "`id -u`" -eq 0 ]; then
	complain "The Tor Browser Bundle should not be run as root.  Exiting."
	exit 1
fi

if [ "$1" ]; then
	debug="$1"
	printf "\nDebug enabled.\n\n"
fi

# If XAUTHORITY is unset, set it to its default value of $HOME/.Xauthority
# before we change HOME below.  (See xauth(1) and #1945.)  XDM and KDM rely
# on applications using this default value.
if [ -z "$XAUTHORITY" ]; then
	XAUTHORITY=~/.Xauthority
	export XAUTHORITY
fi

# If this script is being run through a symlink, we need to know where
# in the filesystem the script itself is, not where the symlink is.
myname="$0"
while [ -L "$myname" ]; do
	# XXX readlink is not POSIX, but is present in GNU coreutils
	# and on FreeBSD.  Unfortunately, the -f option (which follows
	# a whole chain of symlinks until it reaches a non-symlink
	# path name) is a GNUism, so we can't safely use it.  (Using
	# it would be rude to FreeBSD users who currently have no
	# other officially supported choice than TBB for Linux, and
	# might even break compatibility with older versions of the
	# GNU utility.)
	myname="`readlink -n "$myname"`"
done

# Try to be agnostic to where we're being started from, chdir to where
# the script is.
mydir="$(dirname "$myname")"
test -d "$mydir" && cd "$mydir"

# If ${PWD} results in a zero length HOME, we can try something else...
if [ ! "${PWD}" ]; then
	# "hacking around some braindamage"
	HOME="`pwd`"
	export HOME
	surveysays="This system has a messed up shell.\n"
else
	HOME="${PWD}"
	export HOME
fi

if ldd ./App/Firefox/firefox-bin | grep -q "libz\.so\.1.*not found"; then
	LD_LIBRARY_PATH="${HOME}/Lib:${HOME}/Lib/libz"
else
	LD_LIBRARY_PATH="${HOME}/Lib"
fi

LDPATH="${HOME}/Lib/"
export LDPATH
export LD_LIBRARY_PATH
DYLD_PRINT_LIBRARIES=1
export DYLD_PRINT_LIBRARIES

# if any relevant processes are running, inform the user and exit cleanly
RUNNING=0
RUNNING_MESSAGE=""
for process in tor vidalia
        # FIXME pidof isn't POSIX
        do pid="`pidof $process`"
        if [ -n "$pid" ]; then
		RUNNING_MESSAGE="`printf "%s\n%s is already running as PID %s." "$RUNNING_MESSAGE" "$process" "$pid"`"
		RUNNING=1
	fi
	done

if [ "$RUNNING" -eq 1 ]; then
	complain "`printf "%s\n\nPlease shut down the above process(es) before running Tor Browser Bundle." "$RUNNING_MESSAGE"`"
	exit 1
fi


if [ "${debug}" ]; then
	if [ -n "${surveysays}" ]; then 
		printf "\nSurvey says: $surveysays\n\n"
	fi
  	
		# this is likely unportable to Mac OS X or other netstat binaries
  		for port in "8118" "9050"
  			do
			BOUND="`netstat -tan 2>&1|grep 127.0.0.1":${port}[^:]"|grep -v TIME_WAIT`"
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
exitcode="$?"
if [ "$exitcode" -ne 0 ]; then
	complain "Vidalia exited abnormally.  Exit code: $exitcode"
	exit "$exitcode"
fi
