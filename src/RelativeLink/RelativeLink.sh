#!/bin/sh
#
# Gnu/Linux does not really require something like RelativeLink.c
# However, we do want to have the same look and feel with similiar features.
# In the future, we may want this to be a C binary with a custom icon but at the moment
# it's quite simple to just use a shell script
#
# To run in debug mode simply pass --debug
if [ $1 ]; then debug=$1; echo "Debug enabled!"; fi

# If ${PWD} results in a zero length HOME, we can try something else...
if [ ! "${PWD}" ]; then
  echo "We're hacking around some braindamage...";
  HOME=`pwd`;
  export HOME
  surveysays="This system has a messed up shell!";
else
  HOME="${PWD}";
  export HOME
fi

LDPATH=${HOME}/Lib/
export LDPATH
LD_LIBRARY_PATH=${HOME}/Lib/
export LD_LIBRARY_PATH
DYLD_PRINT_LIBRARIES=1
export DYLD_PRINT_LIBRARIES

if [ "${debug}" ]; then
  if [ -n "${surveysays}" ]; then echo "Survey says: $surveysays"; fi
  echo "We're running as PID: $$";
  echo "Attemping to properly configure HOME...";
  echo $HOME;
  echo "Attemping to properly configure LDPATH...";
  echo $LDPATH;
  echo "Attemping to properly configure LD_LIBRARY_PATH...";
  echo $LD_LIBRARY_PATH;
  echo "Attemping to properly configure DYLD_PRINT_LIBRARIES...";
  echo $DYLD_PRINT_LIBRARIES;
  # This is where we want to look for:
  # firefox, tor, vidalia, privoxy/polipo and other programs like pidgin
  # If they're already running, we should find them and warn the user
  echo "Attempting to find problem programs with pidof...";
  echo "We have the followid pidof binary: `which pidof`";
  FIREFOX=`pidof firefox-bin`
  TOR=`pidof tor`
  VIDALIA=`pidof vidalia`
  PRIVOXY=`pidof privoxy`
  POLIPO=`pidof polipo`

  for problem in $FIREFOX $TOR $VIDALIA $PRIVOXY $POLIPO
  do
    echo "You appear to be running a problematic program with a PID of: $problem"
  done

  # This is likely unportable to Mac OS X or other non gnu netstat binaries
  for port in "8118" "9050";
  do
    BOUND=`netstat -tan 2>&1|grep 127.0.0.1:${port}|grep -v TIME_WAIT`;
    if [ "${BOUND}" ]; then
      if [ "${port}" == $$ ]; then
        break;
      else
        echo "Likely problem detected: It appears that you have something listening on ${port}";
        echo "We think this because of the following: ${BOUND}"
      fi
    fi
  done

  echo "Starting Vidalia now...";
  cd "${HOME}";
  echo "Running Vidalia from: `pwd`";
  exec ./App/vidalia --loglevel debug --logfile vidalia-debug-log \
  --datadir Data/Vidalia/
  echo "Vidalia exited with the following return code: $?";
  exit;
fi
# If we're not in debug mode, we'll jump right here:
echo "Now attempting to launch the TBB for Linux in ${HOME}..."
cd "${HOME}";
exec ./App/vidalia --datadir Data/Vidalia/
echo "Everything should be gone!"
