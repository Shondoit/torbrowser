#!/bin/sh
## This is a little sanity providing app that when run in a loop it will:
## 1) Setup the environment properly
## 2) Change to the proper $HOME directory
## 3) Install a single .xpi or Firefox extension
## 4) Profit!
##

# Here's where Make puts us
STARTDIR="`pwd`";
# This is the bundle we want to tamper with
BUNDLE="$1";
echo "BUNDLE is: $BUNDLE"

# This is the full path to the extension we want to install
EXTENSION="$STARTDIR/$2";

# Here's a relative path to our custom Firefox
FIREFOX="./App/firefox/firefox";
# Here's what we think should properly install a plugin
#FIREFOX_ARGS="-profile default -install-global-extension ";
FIREFOX_ARGS=" -install-global-extension ";

# Now we'll switch into the bundle we wish to tamper with
cd "$BUNDLE";
# Now if we were running the bundle, we'd have our CWD as HOME
export HOME=$PWD;
echo "We're now in (HOME): $PWD"
export LDPATH=$HOME/Lib/
echo "Attemping to properly configure LDPATH..."
echo $LDPATH
export LD_LIBRARY_PATH=$HOME/Lib/
echo "Attemping to properly configure LD_LIBRARY_PATH..."

# Here's where we actually tell firefox to install this extension
echo "Attempting to run: $FIREFOX $FIREFOX_ARGS $EXTENSION";
$FIREFOX $FIREFOX_ARGS $EXTENSION;
echo "Firefox said: $?";
echo
