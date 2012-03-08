#!/bin/sh
#Patch the start file for the specified version.

MSVC_VER=$1

patch start-msvc$MSVC_VER.bat -t -N < start-msvc.patch || exit 1
