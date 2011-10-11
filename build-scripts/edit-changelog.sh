#!/bin/sh

# Create a consistent template for adding changelog entries
#
# To use this script, simply run ./edit-changelog.sh osx (or linux, or windows)
#
# Copyright Erinn Clark 2011 <erinn@torproject.org>
# See LICENSE for licensing information


VERSION=$(make -f "$PWD"/$1.mk print-version)
TORNAME="Erinn Clark"
TOREMAIL="erinn@torproject.org"

cat > $PWD/../tmp.changelog.$1 <<EOF
Tor Browser Bundle ($VERSION); suite=$1

  *
  *
  *

 -- $TORNAME <$TOREMAIL>  $(date)

EOF

mv ../changelog.$1-2.2 ../changelog.$1-2.2-old
cat ../tmp.changelog.$1 ../changelog.$1-2.2-old >> ../changelog.$1-2.2

