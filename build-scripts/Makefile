###
### Makefile for building Tor USB bundle
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### See LICENSE for licensing information
###
### $Id$
###

MING=/c/MinGW/bin
QT=/c/Qt/4.3.2/bin
VIDALIA=/c/build/vidalia
TOR=/c/build/tor-0.2.0.12-alpha
SEVENZIP="/c/Program Files/7-Zip/7z.exe"

FIREFOX_SRC="FirefoxPortable"
CONFIG_SRC=config

BINARIES=binaries
DOCS=docs

DEST="Tor Browser"

all:
	echo "Nothing to do"

## Package up all the Vidalia and Tor pre-requisites
## Filenames extracted using Dependency Walker <http://www.dependencywalker.com/>
install-binaries:
	rm -fr $(BINARIES)
	mkdir $(BINARIES)
	cp $(MING)/mingwm10.dll $(BINARIES)
	cp $(QT)/QtCore4.dll $(QT)/QtGui4.dll \
           $(QT)/QtNetwork4.dll $(QT)/QtXml4.dll $(BINARIES) 
	cp $(VIDALIA)/src/vidalia/vidalia.exe $(BINARIES)
	cp $(TOR)/src/or/tor.exe $(TOR)/src/tools/tor-resolve.exe $(BINARIES)

## Collect up license files
install-docs:
	rm -fr $(DOCS)
	mkdir -p $(DOCS)/vidalia
	mkdir -p $(DOCS)/tor
	mkdir -p $(DOCS)/qt
	mkdir -p $(DOCS)/mingw
	cp $(VIDALIA)/LICENSE $(VIDALIA)/COPYING $(VIDALIA)/AUTHORS $(QT)/../LICENSE.GPL $(DOCS)/vidalia
	cp $(TOR)/LICENSE $(TOR)/AUTHORS $(DOCS)/tor
	cp $(QT)/../LICENSE.GPL $(DOCS)/qt
	cp $(MING)/../COPYING $(DOCS)/mingw

TORBUTTON=torbutton-1.1.12-alpha.xpi
$(TORBUTTON):
	wget http://torbutton.torproject.org/dev/releases/$(TORBUTTON)

bundle: package-files install-torbutton patch-language launcher

launcher:
	echo 'start /b .\\App\\vidalia.exe --datadir .\\Data\\Vidalia\\' > $(DEST)/"Tor Browser.bat"

## This dummy profile is created just for installing extensions, otherwise Firefox
## will output files in the default one
DUMMYPROFILE=$(DEST)/FirefoxPortable/App/DummyProfile

package-files: install-binaries install-docs $(TORBUTTON)
	## Build directory structure
	rm -fr $(DEST)
	mkdir -p $(DEST)/App
	mkdir -p $(DEST)/Data/Tor
	mkdir -p $(DEST)/Data/Vidalia
	mkdir -p $(DEST)/Docs
	## Copy over Firefox Portable
	cp -R $(FIREFOX_SRC) $(DEST)/FirefoxPortable
	## Configure Firefox preferences
	cp $(CONFIG_SRC)/prefs.js $(DEST)/FirefoxPortable/App/DefaultData/profile/
	cp $(CONFIG_SRC)/user.js $(DEST)/FirefoxPortable/App/DefaultData/profile/
	cp $(CONFIG_SRC)/bookmarks.html $(DEST)/FirefoxPortable/App/DefaultData/profile/
	## Configure FirefoxPortable
	cp $(CONFIG_SRC)/FirefoxPortable.ini $(DEST)/FirefoxPortable
	## Configure Vidalia
	cp $(CONFIG_SRC)/vidalia.conf $(DEST)/Data/Vidalia
	## Configure Tor
	cp $(CONFIG_SRC)/torrc $(DEST)/Data/Tor
	## Copy over Vidalia and Tor
	cp -R $(BINARIES)/* $(DEST)/App
	## Copy over documentation
	cp -R $(DOCS)/* $(DEST)/Docs

## Install torbutton (TODO: add -no-remote if Firefox is running?)
install-torbutton:
	## Make a dummy profile to stop Firefox creating some large files
	cp -R $(DEST)/FirefoxPortable/App/DefaultData $(DUMMYPROFILE)
	$(DEST)/FirefoxPortable/App/firefox/firefox.exe \
         -profile $(DUMMYPROFILE) \
         -install-global-extension $(TORBUTTON)
	rm -fr $(DUMMYPROFILE)

## Install Quick Locale Switcher extension
install-qls: quick_locale_switcher.xpi
	## Make a dummy profile to stop Firefox creating some large files
	cp -R $(DEST)/FirefoxPortable/App/DefaultData $(DUMMYPROFILE)
	$(DEST)/FirefoxPortable/App/firefox/firefox.exe \
         -profile $(DUMMYPROFILE) \
         -install-global-extension $<
	rm -fr $(DUMMYPROFILE)

## Download language packs
langpack_fa.xpi:
	wget -O $@ https://addons.mozilla.org/en-US/firefox/downloads/file/18157/persian_language_pack-2.0.0.6-fx.xpi

langpack_zh-cn.xpi:
	wget -O $@ http://releases.mozilla.org/pub/mozilla.org/firefox/releases/2.0.0.11/win32/xpi/zh-CN.xpi

## Download Quick Locale Switcher
quick_locale_switcher.xpi:
	wget -O $@ https://addons.mozilla.org/en-US/firefox/downloads/file/20672/quick_locale_switcher-1.6.3.7-fx+mz+tb+sb+nvu+ns+sm+fl.xpi

## Set the language for Vidalia and Firefox
## Currently supported: en: English; fa: Farsi; zh-cn: Chinese simplified
LANGCODE?=en
patch-language:
	## Patch Vidalia
	./patch-language.sh $(DEST)/Data/Vidalia/vidalia.conf $(LANGCODE)
	## Download the required language pack
	rm -f langpack.xpi
ifeq ($(LANGCODE),fa)
	make langpack_fa.xpi
	cp langpack_fa.xpi langpack.xpi
	cp $(CONFIG_SRC)/prefs_fa.js $(DEST)/FirefoxPortable/App/DefaultData/profile/prefs.js
endif
ifeq ($(LANGCODE),zh-cn)
	make langpack_zh-cn.xpi
	cp langpack_zh-cn.xpi langpack.xpi
	cp $(CONFIG_SRC)/prefs_zh-cn.js $(DEST)/FirefoxPortable/App/DefaultData/profile/prefs.js
endif
	## Install the language pack if exists
	cp -R $(DEST)/FirefoxPortable/App/DefaultData $(DUMMYPROFILE)
	$(DEST)/FirefoxPortable/App/firefox/firefox.exe \
         -profile $(DUMMYPROFILE) \
         -install-global-extension langpack.xpi
	rm -fr $(DUMMYPROFILE)

## Copy Firefox preferences from a run of FirefoxPortable to be the default
apply-prefs:
	cp $(DEST)/FirefoxPortable/Data/profile/prefs.js $(CONFIG_SRC)

compress-bundle:
	$(SEVENZIP) a -sfx7z.sfx "Tor Browser.exe" $(DEST)

clean:
	rm -f *~
	rm -fr $(DEST) $(BINARIES) $(DOCS)
	rm -f "Tor Browser.exe"

## Export the source code of the bundle
SRCVERSION=0.0.5
SRCNAME=torbrowser-$(SRCVERSION)
SRCDEST=/tmp
SRCDESTPATH=$(SRCDEST)/$(SRCNAME)
srcdist:
	rm -fr $(SRCDESTPATH)
	svn export https://tor-svn.freehaven.net/svn/torbrowser/trunk/ \
                   $(SRCDESTPATH)
	cd $(SRCDEST); tar --exclude www --exclude src -czvf \
                       $(SRCNAME)-src.tar.gz $(SRCNAME) 
