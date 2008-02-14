#!/bin/sh

###
### Set language code in Firefox config file
###
### Copyright 2007-2008 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### See LICENSE for licensing information
###
### $Id$
###

## Parse command line
FILENAME=$1
LANGCODE=$2

## Backup original file
ORIGFILENAME=$FILENAME.orig
mv "$FILENAME" "$ORIGFILENAME"

## Replace LanguageCode value with $LANGCODE
sed -c "s/BUNDLELOCALE/$LANGCODE/" "$ORIGFILENAME" > "$FILENAME"
