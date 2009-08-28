#!/bin/sh
## This is a little sanity providing app that when run in a loop it will:
## 1) Setup the environment properly
## 2) Change to the proper $HOME directory
## 3) Install a single .xpi or Firefox extension
## 4) Profit!
##

STARTDIR="`pwd`";
BUNDLE=$1
EXTENSION=$2;
HOME="`pwd`"/$BUNDLE;
export $HOME;

FIREFOX=./App/firefox/firefox
FIREFOX_ARGS=-install-global-extension
cd $HOME;
echo "We're now in $PWD"
echo "Attempting to run: $FIREFOX $FIREFOX_ARGS";
echo
