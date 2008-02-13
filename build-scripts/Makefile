###
### Makefile for building Tor USB bundle
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### See LICENSE for licensing information
###
### $Id$
###

#####################
### Configuration ###
#####################

## Location of required libraries
MING=/c/MinGW/bin
QT=/c/Qt/4.3.2/bin

## Location of bundle components
VIDALIA=/c/build/vidalia
TOR=/c/build/tor-0.2.0.19-alpha
POLIPO=/c/build/polipo-1.0.4
FIREFOX_SRC=/c/build/FirefoxPortable

## Location of utility applications
SEVENZIP="/c/Program Files/7-Zip/7z.exe"
WGET:=/c/Python25/python.exe $(shell pwd)/pyget.py

## Location of config files
CONFIG_SRC=config

## Destination for the generic bundle
DEST="Generic Bundle"

## Name of the bundle"
NAME="Tor Browser"

## Extensions to install by default
DEFAULT_EXTENSIONS=torbutton.xpi

## Where to download Torbutton from
TORBUTTON=http://torbutton.torproject.org/dev/torbutton-current-alpha.xpi

## Put more extensions here
EXTENSIONS_DIR=extensions

#############
### Rules ###
#############

##
## Default rule
##

bundle: bundle_en

all-bundles: bundle_en bundle_de bundle_es-ES bundle_fr bundle_nl \
             bundle_pt-PT bundle_ru bundle zh-CN

##
## Cleanup
##

clean:
	rm -fr $(DEST)
	rm -f *~
	rm -fr $(DEST) $(BINARIES) $(DOCS)
	rm -f "Tor Browser.exe"

##
## Generate a non-localized bundle and put in $(DEST)
##

## Install binaries, documentation, FirefoxPortable and launcher into $(DEST)
$(DEST): directory-structure install-binaries install-docs install-firefoxportable configure-apps launcher

APPDIR=$(DEST)/App
DOCSDIR=$(DEST)/Docs
DATADIR=$(DEST)/Data

## Build directory structure
directory-structure: 
	rm -fr $(DEST)
	mkdir -p $(APPDIR)
	mkdir -p $(DATADIR)/Tor
	mkdir -p $(DATADIR)/Vidalia
	mkdir -p $(DATADIR)/Polipo
	mkdir -p $(DOCSDIR)

## Package up all the Vidalia and Tor pre-requisites
## Filenames extracted using Dependency Walker <http://www.dependencywalker.com/>
install-binaries: 
	cp $(MING)/mingwm10.dll $(APPDIR)
	cp $(QT)/QtCore4.dll $(QT)/QtGui4.dll \
           $(QT)/QtNetwork4.dll $(QT)/QtXml4.dll $(APPDIR) 
	cp $(VIDALIA)/src/vidalia/vidalia.exe $(APPDIR)
	cp $(POLIPO)/polipo.exe $(APPDIR)
	cp $(TOR)/src/or/tor.exe $(TOR)/src/tools/tor-resolve.exe $(APPDIR)

## Collect up license files
install-docs:
	mkdir -p $(DOCSDIR)/Vidalia
	mkdir -p $(DOCSDIR)/Tor
	mkdir -p $(DOCSDIR)/Qt
	mkdir -p $(DOCSDIR)/MinGW
	mkdir -p $(DOCSDIR)/Polipo
	cp $(VIDALIA)/LICENSE $(VIDALIA)/COPYING $(VIDALIA)/AUTHORS $(QT)/../LICENSE.GPL $(DOCSDIR)/Vidalia
	cp $(TOR)/LICENSE $(TOR)/AUTHORS $(TOR)/README $(DOCSDIR)/Tor
	cp $(QT)/../LICENSE.GPL $(DOCSDIR)/Qt
	cp $(MING)/../COPYING $(DOCSDIR)/MinGW
	cp $(POLIPO)/COPYING  $(POLIPO)/README $(DOCSDIR)/Polipo

## Copy over FirefoxPortable
install-firefoxportable:
	cp -R $(FIREFOX_SRC) $(DEST)/FirefoxPortable

## Configure Firefox, FirefoxPortable, Vidalia, Polipo and Tor
configure-apps:
	## Configure Firefox preferences
	cp $(CONFIG_SRC)/prefs.js $(DEST)/FirefoxPortable/App/DefaultData/profile/
	cp $(CONFIG_SRC)/user.js $(DEST)/FirefoxPortable/App/DefaultData/profile/
	cp $(CONFIG_SRC)/bookmarks.html $(DEST)/FirefoxPortable/App/DefaultData/profile/
	## Configure FirefoxPortable
	cp $(CONFIG_SRC)/FirefoxPortable.ini $(DEST)/FirefoxPortable
	## Configure Vidalia
	cp $(CONFIG_SRC)/vidalia.conf $(DEST)/Data/Vidalia
	## Configure Polipo
	cp $(CONFIG_SRC)/polipo.conf $(DEST)/Data/Polipo
	## Configure Tor
	cp $(CONFIG_SRC)/torrc $(DEST)/Data/Tor

launcher:
	echo 'start /b .\\App\\vidalia.exe --datadir .\\Data\\Vidalia\\' > $(DEST)/"Start Tor Browser.bat"

##
## How to create required extensions
##

## Torbutton development version
torbutton.xpi:
	$(WGET) -O $@ $(TORBUTTON)

## Generic language pack rule
langpack_%.xpi:
	$(WGET) -O $@ http://releases.mozilla.org/pub/mozilla.org/firefox/releases/2.0.0.11/win32/xpi/%.xpi
## Persian isn't a supported language by Firefox yet
langpack_fa.xpi:
	$(WGET) -O $@ https://addons.mozilla.org/en-US/firefox/downloads/file/18157/persian_language_pack-2.0.0.6-fx.xpi
## English comes as default
langpack_en.xpi:
	touch $@

## Download Quick Locale Switcher
quick_locale_switcher.xpi:
	$(WGET) -O $@ https://addons.mozilla.org/en-US/firefox/downloads/file/20672/quick_locale_switcher-1.6.3.7-fx+mz+tb+sb+nvu+ns+sm+fl.xpi

##
## Customize the bundle
##

bundle_%:
	LANGCODE=$* make bundle

bundle: copy-base install-extensions patch-vidalia-language patch-firefox-config

compress-bundle:
	cd $(NAME)_$(LANGCODE); $(SEVENZIP) a -sfx7z.sfx $(NAME)_$(LANGCODE).exe $(NAME)

copy-base:
	mkdir $(NAME)_$(LANGCODE)
	cp -R $(DEST) $(NAME)_$(LANGCODE)/$(NAME)

BUNDLE=$(NAME)_$(LANGCODE)/$(NAME)
DUMMYPROFILE=$(BUNDLE)/FirefoxPortable/App/DummyProfile
install-extensions:
	## Make a dummy profile to stop Firefox creating some large files
	cp -R $(BUNDLE)/FirefoxPortable/App/DefaultData $(DUMMYPROFILE)
	for extension in $(DEFAULT_EXTENSIONS) $(EXTENSIONS_DIR)/*; \
	  do $(BUNDLE)/FirefoxPortable/App/firefox/firefox.exe \
             -profile $(DUMMYPROFILE) \
             -install-global-extension $$extension; \
          done
	## Delete the dummy profile
	rm -fr $(DUMMYPROFILE)

## Set the language for Vidalia
patch-vidalia-language:
	## Patch Vidalia
	./patch-language.sh $(DEST)/Data/Vidalia/vidalia.conf $(LANGCODE)

patch-firefox-config:
	## TODO

###
### Utilities
###

## Copy Firefox preferences from a run of FirefoxPortable to be the default
apply-prefs:
	cp $(DEST)/FirefoxPortable/Data/profile/prefs.js $(CONFIG_SRC)

## Export the source code of the bundle
SRCVERSION=0.0.6
SRCNAME=tor-browser-$(SRCVERSION)
SRCDEST=/tmp
SRCDESTPATH=$(SRCDEST)/$(SRCNAME)
srcdist:
	rm -fr $(SRCDESTPATH)
	svn export https://tor-svn.freehaven.net/svn/torbrowser/trunk/ \
                   $(SRCDESTPATH)
	cd $(SRCDEST); tar --exclude www --exclude src -czvf \
                       $(SRCNAME)-src.tar.gz $(SRCNAME) 
