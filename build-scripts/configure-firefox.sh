#!/bin/sh
## This is a little sanity providing app that when run in a loop it will:
## 1) Setup the environment properly
## 2) Change to the proper $HOME directory
## 3) Install a single .xpi or Firefox extension
## 4) Profit!
##

STARTDIR="`pwd`";
BUNDLE="$1";
echo "BUNDLE is: $BUNDLE"
EXTENSION=$2;

FIREFOX="./App/firefox/firefox";
FIREFOX_ARGS="-profile firefox -install-global-extension $EXTENSION";
cd "$BUNDLE";
export HOME=$PWD;
echo "We're now in $PWD"
echo "Attempting to run: $FIREFOX $FIREFOX_ARGS";
$FIREFOX $FIREFOX_ARGS;
echo "Firefox said: $?";
echo
