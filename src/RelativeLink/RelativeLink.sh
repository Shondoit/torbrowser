#!/bin/sh
#
# Gnu/Linux does not really require something like RelativeLink.c
# However, we do want to have the same look and feel with similiar features.
# In the future, we may want this to be a C binary with a custom icon but at the moment
# it's quite simple to just use a shell script
#

echo "Attemping to properly configure HOME..."
export HOME=$PWD
echo $HOME
export LDPATH=$HOME/Lib/
echo "Attemping to properly configure LDPATH..."
echo $LDPATH
export LD_LIBRARY_PATH=$HOME/Lib/
echo "Attemping to properly configure LD_LIBRARY_PATH..."
echo $LD_LIBRARY_PATH
export DYLD_PRINT_LIBRARIES=1
echo "Attemping to properly configure DYLD_PRINT_LIBRARIES..."
echo $DYLD_PRINT_LIBRARIES
# You may want to try this for debugging:
# exec $HOME/bin/vidalia --loglevel debug --logfile vidalia-log \
# --datadir .config/
echo "Now attempting to launch the TBB for Linux..."
exec ./App/vidalia --datadir Data/Vidalia/
echo "Everything should be gone!"
