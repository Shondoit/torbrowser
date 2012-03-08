#!/bin/sh

###
### Set language code in Firefox config file
###
### Copyright 2007-2008 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### See LICENSE for licensing information
###

## Parse command line
FILENAME=$1
LANGCODE=$2
SEDARG=$3

# For linux, we tell this to be silent by passing "-n"
# On other platforms, we pass "-c" when they do nothing
if [ -z $SEDARG ];
then
	SEDARG="-e";
fi

## Backup original file
ORIGFILENAME=$FILENAME.orig
mv "$FILENAME" "$ORIGFILENAME"

## Replace LanguageCode value with $LANGCODE
#sed -c "s/BUNDLELOCALE/$LANGCODE/" "$ORIGFILENAME" > "$FILENAME"
sed $SEDARG "s/BUNDLELOCALE/$LANGCODE/" "$ORIGFILENAME" > "$FILENAME"

## Remove backup
rm -f "$ORIGFILENAME"
