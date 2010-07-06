#!/bin/sh

###
### Set language code in Pidgin config file
###
### Copyright 2008 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### See LICENSE for licensing information
###
### $Id: patch-vidalia-language.sh 13521 2008-02-15 12:37:49Z sjm217 $
###

## Parse command line
FILENAME=$1
MOZLANG=$2
PIDGINLOCALEDIR=$3
GTKLOCALEDIR=$4

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
sed -c "s/PIDGINLOCALE/$LANGCODE/" "$ORIGFILENAME" > "$FILENAME"

## Remove backup
rm -f "$ORIGFILENAME"

## Remove languages we don't need
find "$PIDGINLOCALEDIR" -mindepth 1 -maxdepth 1 -not -iname $LANGCODE -exec rm -rf {} \;
find "$GTKLOCALEDIR" -mindepth 1 -maxdepth 1 -not -iname $LANGCODE -exec rm -rf {} \;
