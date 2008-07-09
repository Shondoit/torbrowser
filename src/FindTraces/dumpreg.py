###
### Extract list of registry keys created from a Process Monitor CSV log and
### dump values. The result can be compared using diff to see if the keys
### have actually been created or changed.
### Process Monitor can be downloaded from http://technet.microsoft.com/en-us/sysinternals/
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### See LICENSE for licensing information
###
### $Id$
###

import win32con
from registrydict import RegistryDict
import csv
import sys

def parse_key(key):
	'''Take a registry path, in ProcessMonitor format and split.
	Returns (top, rest) where top is the appropriate win32con HKEY_* variable
	and rest is a list of path components'''
	
	## Separate into components
	path = key.split("\\")
	
	## Split into first element, and the rest
	top = path[0]
	rest = path[1:]
	
	## The Windows API expects an integer for the first path component,
	## so convert it
	if top=='HKLM':
		top = win32con.HKEY_LOCAL_MACHINE
	elif top=='HKCU':
		top = win32con.HKEY_CURRENT_USER
	elif top=='HKCR':
		top = win32con.HKEY_CLASSES_ROOT
	elif top=='HKU':
		top = win32con.HKEY_USERS
	else:
		raise Exception("Unknown top-level registry key", top)
	
	return top, rest

def main():
	## Check usage
	if len(sys.argv) != 3:
		print "Usage: dumpreg.py LOGFILE OUTFILE"
		sys.exit()
	
	## Open input and output files
	ifn = sys.argv[1]
	ofn = sys.argv[2]
	
	logfile = csv.reader(file(ifn, "rb"))
	fh=file(ofn, "w")
		
	## Skip header
	logfile.next()

	keys = {}
	for row in logfile:
		## Parse the line
		seq, time, proc, pid, op, key, result, detail = row
		## We only handle RegCreateKey operations
		assert(op.startswith('Reg'))

		if keys.has_key(key):
			continue
		keys[key] = None
		
		## Parse the registry key		
		handle, path = parse_key(key)
		try:
			## Get the contents
			r = RegistryDict(handle, path, win32con.KEY_READ)
			## Key exists
			fh.write(str((1, key, proc, r))+"\n")
		except:
			## Key doesn't exist
			fh.write(str((2, key, proc, None))+"\n")
			
if __name__=="__main__":
	main()
