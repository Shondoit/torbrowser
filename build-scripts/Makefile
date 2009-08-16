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
QT=/c/Qt/4.5.1/bin
OPENSSL=/c/build/openssl-0.9.8k/bin

## Location of bundle components
VIDALIA=/c/build/vidalia-0.2.2
TOR=/c/build/tor-0.2.1.19
POLIPO=/c/build/polipo-1.0.4
FIREFOX_SRC=/c/build/FirefoxPortable-3.0.13
PIDGIN_SRC=/c/build/PidginPortable-2.5.8

## Location of utility applications
SEVENZIP="/c/Program Files/7-Zip/7z.exe"
WGET:=/c/Python25/python.exe $(shell pwd)/pyget.py
WINRAR="/c/Program Files/WinRAR/WinRAR.exe"

## Size of split archive volumes for WinRAR
SPLITSIZE=1440k

## Location of config files
CONFIG_SRC=config

## Destination for the generic bundle
DEST="Generic Bundle"

## Name of the bundle"
NAME="Tor Browser"

## Version and name of the compressed bundle (also used for source)
VERSION=1.2.7-dev
DEFAULT_COMPRESSED_BASENAME=tor-browser-
IM_COMPRESSED_BASENAME=tor-im-browser-
DEFAULT_COMPRESSED_NAME=$(DEFAULT_COMPRESSED_BASENAME)$(VERSION)
IM_COMPRESSED_NAME=$(IM_COMPRESSED_BASENAME)$(VERSION)

ifeq ($(USE_PIDGIN),1)
COMPRESSED_NAME=$(IM_COMPRESSED_NAME)
else
COMPRESSED_NAME=$(DEFAULT_COMPRESSED_NAME)
endif

## Extensions to install by default
DEFAULT_EXTENSIONS=torbutton.xpi

## Where to download Torbutton from
#TORBUTTON=https://addons.mozilla.org/en-US/firefox/downloads/file/49457/torbutton-1.2.1-fx.xpi
TORBUTTON=https://addons.mozilla.org/en-US/firefox/downloads/latest/2275/addon-2275-latest.xpi?src=addondetail

## Where to download Mozilla language packs
MOZILLA_LANGUAGE=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/3.0.13/win32/xpi

## Where Farsi Language Pack can be downloaded from
FA_LANGPACK=https://addons.mozilla.org/en-US/firefox/downloads/latest/3667/addon-3667-latest.xpi

## Put more extensions here
EXTENSIONS_DIR=extensions

## Local overrides
-include local.makefile

#############
### Rules ###
#############

##
## Default rule
##

bundle: bundle_en-US

all-bundles-both:
	USE_PIDGIN=1 make all-bundles
	make clean
	USE_PIDGIN=0 make all-bundles
	make clean

all-bundles: all-compressed-bundles all-split-bundles

all-compressed-bundles: compressed-bundle_ar \
	compressed-bundle_en-US \
	compressed-bundle_de \
	compressed-bundle_es-ES \
	compressed-bundle_fa-IR \
	compressed-bundle_fr \
	compressed-bundle_nl \
    compressed-bundle_pl \
	compressed-bundle_pt-PT \
	compressed-bundle_ru \
	compressed-bundle_zh-CN \
	compressed-bundle_it

all-split-bundles: split-bundle_ar \
	split-bundle_en-US \
	split-bundle_de \
	split-bundle_es-ES \
	split-bundle_fa-IR \
	split-bundle_fr \
	split-bundle_nl \
    split-bundle_pl \
	split-bundle_pt-PT \
	split-bundle_ru \
	split-bundle_zh-CN \
	split-bundle_it

##
## Cleanup
##

clean:
	rm -fr $(DEST) *.stamp
	rm -f *~
	rm -fr *.xpi *.jar
	rm -fr $(NAME)_*
	cd ../src/RelativeLink/ && $(MAKE) clean

## Also remove the output files
reallyclean: clean
	rm -fr $(IM_COMPRESSED_BASENAME)*_*.exe
	rm -fr $(IM_COMPRESSED_BASENAME)*_*.rar	
	rm -fr $(IM_COMPRESSED_BASENAME)*_*_split
	rm -fr $(DEFAULT_COMPRESSED_BASENAME)*_*.exe
	rm -fr $(DEFAULT_COMPRESSED_BASENAME)*_*.rar
	rm -fr $(DEFAULT_COMPRESSED_BASENAME)*_*_split

##
## Generate a non-localized bundle and put in $(DEST)
##

## Install binaries, documentation, FirefoxPortable, PidginPortable, and launcher into $(DEST)
generic-bundle.stamp:
	make generic-bundle
generic-bundle: directory-structure install-binaries install-docs install-firefoxportable install-pidginportable configure-apps launcher
	touch generic-bundle.stamp

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
	cp $(MING)/libgnurx-0.dll $(APPDIR)
	cp $(QT)/QtCore4.dll $(QT)/QtGui4.dll \
           $(QT)/QtNetwork4.dll $(QT)/QtXml4.dll $(APPDIR) 
	cp $(OPENSSL)/ssleay32.dll $(APPDIR)
	cp $(OPENSSL)/libeay32.dll $(APPDIR)
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
	cp $(VIDALIA)/LICENSE* $(VIDALIA)/CREDITS $(DOCSDIR)/Vidalia
	cp $(TOR)/LICENSE $(TOR)/AUTHORS $(TOR)/README $(DOCSDIR)/Tor
	cp $(QT)/../LICENSE.GPL* $(QT)/../LICENSE.LGPL $(DOCSDIR)/Qt
	cp $(MING)/../COPYING $(DOCSDIR)/MinGW
	cp $(POLIPO)/COPYING  $(POLIPO)/README $(DOCSDIR)/Polipo
	cp ../README $(DOCSDIR)/README-TorBrowserBundle

## Copy over FirefoxPortable
install-firefoxportable:
	cp -R $(FIREFOX_SRC) $(DEST)/FirefoxPortable

## Copy over PidginPortable
install-pidginportable:
ifeq ($(USE_PIDGIN),1)
	cp -R $(PIDGIN_SRC) $(DEST)/PidginPortable
endif

## Configure Firefox, FirefoxPortable, Vidalia, Polipo and Tor
configure-apps:
	## Configure Firefox preferences
	cp $(CONFIG_SRC)/prefs.js $(DEST)/FirefoxPortable/App/DefaultData/profile/
	cp $(CONFIG_SRC)/bookmarks.html $(DEST)/FirefoxPortable/App/DefaultData/profile/
	## Set up alternate launcher
	mv $(DEST)/FirefoxPortable/App/Firefox/firefox.exe $(DEST)/FirefoxPortable/App/Firefox/tbb-firefox.exe
	#rm $(DEST)/FirefoxPortable/FirefoxPortable.exe
	## Configure FirefoxPortable
	cp $(CONFIG_SRC)/FirefoxPortable.ini $(DEST)/FirefoxPortable
	cp $(CONFIG_SRC)/FirefoxPortableSettings.ini $(DEST)/FirefoxPortable/Data/settings
	## Configure PidginPortable
ifeq ($(USE_PIDGIN),1)
	cp $(CONFIG_SRC)/PidginPortable.ini $(DEST)/PidginPortable
	mkdir -p $(DEST)/PidginPortable/Data/settings/.purple
	cp $(CONFIG_SRC)/prefs.xml $(DEST)/PidginPortable/Data/settings/.purple
	cp $(CONFIG_SRC)/PidginPortableSettings.ini $(DEST)/PidginPortable/Data/settings
endif
	## Configure Vidalia
ifeq ($(USE_PIDGIN),1)
	cp $(CONFIG_SRC)/vidalia.conf.ff+pidgin $(DEST)/Data/Vidalia/vidalia.conf
else
	cp $(CONFIG_SRC)/vidalia.conf.ff $(DEST)/Data/Vidalia/vidalia.conf
endif
	## Configure Polipo
	cp $(CONFIG_SRC)/polipo.conf $(DEST)/Data/Polipo
	## Configure Tor
	cp $(CONFIG_SRC)/torrc $(DEST)/Data/Tor
	cp $(TOR)/src/config/geoip $(DEST)/Data/Tor

launcher:
	#echo 'start /b .\\App\\vidalia.exe --datadir .\\Data\\Vidalia\\' > $(DEST)/"Start Tor Browser.bat"
	cd ../src/RelativeLink/ && $(MAKE)
	cp ../src/RelativeLink/StartTorBrowserBundle.exe $(DEST)/"Start Tor Browser.exe"

##
## How to create required extensions
##

## Torbutton development version
torbutton.xpi:
	$(WGET) -O $@ $(TORBUTTON)

## Generic language pack rule
langpack_%.xpi:
	$(WGET) -O $@ $(MOZILLA_LANGUAGE)/$*.xpi
## Persian isn't a supported language by Firefox yet
langpack_fa-IR.xpi:
	$(WGET) -O $@ $(FA_LANGPACK)
## English comes as default
langpack_en-US.xpi:
	touch $@

##
## Customize the bundle
##

bundle_%:
	LANGCODE=$* make bundle-localized
compressed-bundle_%:
	LANGCODE=$* make compressed-bundle-localized
split-bundle_%:
	LANGCODE=$* make split-bundle-localized

bundle-localized_%.stamp:
	make copy-files_$* install-extensions patch-vidalia-language patch-firefox-language patch-pidgin-language
	touch bundle-localized_$*.stamp

bundle-localized: bundle-localized_$(LANGCODE).stamp

compressed-bundle-localized: bundle-localized_$(LANGCODE).stamp
	rm -f $(COMPRESSED_NAME)_$(LANGCODE).exe
	cd $(NAME)_$(LANGCODE); $(SEVENZIP) a -sfx7z.sfx ../$(COMPRESSED_NAME)_$(LANGCODE).exe $(NAME)

split-bundle-localized: bundle-localized_$(LANGCODE).stamp
	rm -fr $(COMPRESSED_NAME)_$(LANGCODE)_split; mkdir $(COMPRESSED_NAME)_$(LANGCODE)_split
	cd $(NAME)_$(LANGCODE); $(WINRAR) a -r -s -ibck -sfx -v$(SPLITSIZE) \
            ../$(COMPRESSED_NAME)_$(LANGCODE)_split/$(COMPRESSED_NAME)_$(LANGCODE)_split.exe $(NAME)

copy-files_%: generic-bundle.stamp
	rm -fr $(NAME)_$*
	mkdir $(NAME)_$*
	cp -R $(DEST) $(NAME)_$*/$(NAME)

BUNDLE=$(NAME)_$(LANGCODE)/$(NAME)
DUMMYPROFILE=$(BUNDLE)/FirefoxPortable/App/DummyProfile
install-extensions: $(DEFAULT_EXTENSIONS) langpack_$(LANGCODE).xpi
	## Make a dummy profile to stop Firefox creating some large files
	cp -R $(BUNDLE)/FirefoxPortable/App/DefaultData $(DUMMYPROFILE)
	## Install default extensions and everything from extensions directory
	for extension in langpack_$(LANGCODE).xpi $(DEFAULT_EXTENSIONS) $(EXTENSIONS_DIR)/*.xpi $(EXTENSIONS_DIR)/*.jar; \
	  do $(BUNDLE)/FirefoxPortable/App/firefox/tbb-firefox.exe \
             -profile $(DUMMYPROFILE)/profile \
             -install-global-extension $$extension; \
          done
	## Delete the dummy profile
	rm -fr $(DUMMYPROFILE)

## Set the language for Vidalia
patch-vidalia-language:
	## Patch Vidalia
	./patch-vidalia-language.sh $(BUNDLE)/Data/Vidalia/vidalia.conf $(LANGCODE)

## Set the language for Pidgin
patch-pidgin-language:
	## Patch Pidgin
ifeq ($(USE_PIDGIN),1)
	./patch-pidgin-language.sh $(BUNDLE)/PidginPortable/Data/settings/PidginPortableSettings.ini $(LANGCODE) \
                                   $(BUNDLE)/PidginPortable/App/Pidgin/locale \
                                   $(BUNDLE)/PidginPortable/App/GTK/share/locale
endif

patch-firefox-language:
	## Patch Firefox prefs.js
	./patch-firefox-language.sh $(BUNDLE)/FirefoxPortable/App/DefaultData/profile/prefs.js $(LANGCODE)

###
### Utilities
###

## Copy Firefox preferences from a run of FirefoxPortable to be the default
apply-prefs:
	cp $(DEST)/FirefoxPortable/Data/profile/prefs.js $(CONFIG_SRC)

## Export the source code of the bundle
SRCNAME=$(COMPRESSED_NAME)
SRCDEST=/tmp
SRCDESTPATH=$(SRCDEST)/$(SRCNAME)
srcdist:
	rm -fr $(SRCDESTPATH)
	svn export https://tor-svn.freehaven.net/svn/torbrowser/trunk/ \
                   $(SRCDESTPATH)
	cd $(SRCDEST); tar --exclude src/archived-patches \
                           --exclude src/current-patches  --exclude src/processtest \
                           -czvf $(SRCNAME)-src.tar.gz $(SRCNAME)
