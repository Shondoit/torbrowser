#!/bin/sh

###
### Set language code in Vidalia config file
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### See LICENSE for licensing information
###

## Parse command line
FILENAME=$1
MOZLANG=$2
SEDARG=$3

# For linux, we tell this to be silent by passing "-n"
# On other platforms, we pass "-c" when they do nothing
if [ -z $SEDARG ];
then
	SEDARG="-e";
fi

## Handle exceptions where Mozilla language definition doesn't equal Vidalia's
case "$MOZLANG" in
    'en-US') LANGCODE='en'
    ;;
    'es-ES') LANGCODE='es'
    ;;
    'fa-IR') LANGCODE='fa'
    ;;
    'pt-PT') LANGCODE='pt'
    ;;
    'zh-CN') LANGCODE='zh_CN'
    ;;
    *) LANGCODE="$MOZLANG"
    ;;
esac

## Backup original file
ORIGFILENAME=$FILENAME.orig
mv "$FILENAME" "$ORIGFILENAME"

## Replace LanguageCode value with $LANGCODE
#sed -c "s/\\(LanguageCode=\\).*/\\1$LANGCODE/" "$ORIGFILENAME" > "$FILENAME"
sed $SEDARG "s/\\(LanguageCode=\\).*/\\1$LANGCODE/" "$ORIGFILENAME" > "$FILENAME"

## Remove backup
rm -f "$ORIGFILENAME"
