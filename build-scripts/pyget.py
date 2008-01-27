#!/usr/bin/python

###
### Simple HTTP download utility for platforms without wget
###
### Copyright 2008 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### See LICENSE for licensing information
###
### $Id$
###

import sys
import os
import urllib
import urlparse
from optparse import OptionParser

## Destination filename when no sensible default can be guessed
DEFAULT_DEST = "index.html"

## Create a URL opener which throws an exception on error
class DebugURLopener(urllib.FancyURLopener):
    def http_error_default(self, url, fp, errcode, errmsg, headers):
        _ = fp.read()
        fp.close()
        raise IOError, ('http error', errcode, errmsg, headers)

## Set this as the default URL opener
urllib._urlopener = DebugURLopener()

def main():
    ## Parse command line
    usage = "Usage: %prog [options] URL\n\nDownload URL to file."
    parser = OptionParser(usage)
    parser.set_defaults(verbose=True)
    parser.add_option("-O", "--output-document", dest="dest",
                      help="write document to DEST")
    parser.add_option("-q", "--quiet", action="store_false", dest="verbose",
                      help="don't show debugging information")

    (options, args) = parser.parse_args()
    if len(args) != 1:
        parser.error("Missing URL")

    ## Get URL
    url = args[0]

    ## Get destination filename
    if options.dest:
        dest = options.dest
    else:
        url_components = urlparse.urlsplit(url)
        dest = os.path.basename(url_components.path).strip()
        if dest == "":
            dest = DEFAULT_DEST

    ## Download URL
    if options.verbose:
        print "Downloading %s to %s..."%(url, dest)

    urllib.urlretrieve(url, dest)

    if options.verbose:
        print "Download was successful."

if __name__ == "__main__":
    main()
