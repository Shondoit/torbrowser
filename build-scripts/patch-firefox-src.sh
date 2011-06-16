#!/bin/sh

# Cycle through available patches for Firefox and apply them in order. Fail if
# any of them don't apply cleanly.

for i in *patch; do patch -tp1 <$i || exit 1; done
