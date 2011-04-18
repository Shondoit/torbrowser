###
### Makefile for building Tor USB bundle on Mac OS X
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### Copyright 2009, 2010 Jacob Appelbaum <jacob@appelbaum.net>
### Copyright 2010 Erinn Clark <erinn@torproject.org>
###
### You want to do the following currently supported activities:
# This downloads and compiles everything
### make -f windows.mk build-all-binaries
# This makes a generic bundle
### make -f windows.mk generic-bundle
# This makes the English bundle
### make -f windows.mk bundle_en-US
# This makes the German bundle
### make -f windows.mk bundle_de
# This makes the German compressed bundle
### make -f windows.mk compressed-bundle_de 
# It's possible you may also want to do:
### make -f windows.mk build-all-binaries
### make -f windows.mk all-compressed-bundles
### ...
### Look in tbbwin-alpha-dist/ for your files.
###
### See LICENSE for licensing information
###

#####################
### Configuration ###
#####################

## Include versions
include $(PWD)/versions.mk

## Location of required libraries
MING=/c/c/mingw/bin
QT=/c/Qt/$(QT_VER)/bin
OPENSSL=/e/build/openssl-$(OPENSSL_VER)
WIX=/c/Program Files/WiX/bin

## Location of bundle components
VIDALIA=$(FETCH_DIR)/vidalia-$(VIDALIA_VER)
TOR=$(FETCH_DIR)/tor-$(TOR_VER)
POLIPO=$(FETCH_DIR)/polipo-$(POLIPO_VER)
FIREFOX=$(FETCH_DIR)/FirefoxPortable-$(FIREFOX_VER)
PIDGIN=$(FETCH_DIR)/PidginPortable-$(PIDGIN_VER)

## Location of utility applications
PWD:=$(shell pwd)
PYTHON=/c/Python25/python.exe
SEVENZIP="/c/Program Files/7-Zip/7z.exe"
WGET=$(PYTHON) $(PWD)/pyget.py
VIRUSSCAN=$(PYTHON) $(PWD)/virus-scan.py
WINRAR="/c/Program Files/WinRAR/WinRAR.exe"


## Location of directory for source unpacking
FETCH_DIR=$(PWD)/build-alpha-$(ARCH_TYPE)
## Location of directory for prefix/destdir/compiles/etc
BUILT_DIR=$(FETCH_DIR)/built
TBB_FINAL=$(BUILT_DIR)/tbbwin-alpha-dist

source-dance: fetch-source unpack-source
	echo "We're ready for building now."

ZLIB_DIR=$(FETCH_DIR)/zlib-$(ZLIB_VER)
ZLIB_OPTS=--prefix=$(BUILT_DIR)
ZLIB_LDFLAGS=-Wl,--nxcompat -Wl,--dynamicbase
build-zlib:
	cd $(ZLIB_DIR) && CFLAGS=$(ZLIB_LDFLAGS) ./configure $(ZLIB_OPTS)
	cd $(ZLIB_DIR) && make
	cd $(ZLIB_DIR) && make install

OPENSSL_DIR=$(FETCH_DIR)/openssl-$(OPENSSL_VER)
OPENSSL_OPTS=-no-idea -no-rc5 -no-md2 shared zlib --prefix=$(BUILT_DIR) --openssldir=$(BUILT_DIR) -L$(BUILT_DIR)/lib \
	-Wl,--nxcompat -Wl,dynamicbase -I$(BUILT_DIR)/include
build-openssl:
	cd $(OPENSSL_DIR) && ./config $(OPENSSL_OPTS)
	cd $(OPENSSL_DIR) && make depend
	cd $(OPENSSL_DIR) && make
	cd $(OPENSSL_DIR) && make install

VIDALIA_DIR=$(FETCH_DIR)/vidalia-$(VIDALIA_VER)
VIDALIA_OPTS=-DWIN2K=1 -DCMAKE_BUILD_TYPE=minsizerel -DMINGW_BINARY_DIR=$(MING) -DOPENSSL_BINARY_DIR=$(OPENSSL) -DWIX_BINARY_DIR=$(WIX)
build-vidalia:
	-mkdir $(VIDALIA_DIR)/build
	cd $(VIDALIA_DIR)/build && cmake -G "MinGW Makefiles" $(VIDALIA_OPTS) ..

LIBEVENT_DIR=$(FETCH_DIR)/libevent-$(LIBEVENT_VER)
LIBEVENT_CFLAGS="-O -g"
LIBEVENT_OPTS=--prefix=$(BUILT_DIR) --enable-static --disable-shared --disable-dependency-tracking
build-libevent:
	cd $(LIBEVENT_DIR) && CFLAGS=$(LIBEVENT_CFLAGS) ./configure $(LIBEVENT_OPTS)
	cd $(LIBEVENT_DIR) && make -j2
	cd $(LIBEVENT_DIR) && sudo make install

TOR_DIR=$(FETCH_DIR)/tor-$(TOR_VER)
TOR_CFLAGS="-O -g -arch $(ARCH_TYPE) -I$(BUILT_DIR)/include"
TOR_LDFLAGS="-L$(BUILT_DIR)/lib"
TOR_OPTS=--enable-static-openssl --enable-static-libevent --with-openssl-dir=$(OPENSSL) --with-libevent-dir=$(BUILT_DIR)/lib \
	--prefix=$(BUILT_DIR) --disable-dependency-tracking
build-tor:
	cd $(TOR_DIR) && CFLAGS=$(TOR_CFLAGS) LDFLAGS=$(TOR_LDFLAGS) ./configure $(TOR_OPTS)
	cd $(TOR_DIR) && make
	cd $(TOR_DIR) && make install

build-firefox:
	echo "We're using a prebuilt firefox. Fix this someday!"

build-all-binaries: build-zlib build-openssl build-vidalia build-libevent build-tor
	echo "If we're here, we've done something right."

## Location of compiled libraries
COMPILED_LIBS=$(BUILT_DIR)/lib
## Location of compiled binaries
COMPILED_BINS=$(BUILT_DIR)/bin/

## Location of the libraries we've built
QT=$(COMPILED_LIBS)
OPENSSL=$(COMPILED_LIBS)
ZLIB=$(COMPILED_LIBS)
LIBEVENT=$(COMPILED_LIBS)

## Location of utility applications
WGET:=$(shell which wget)

## Size of split archive volumes for WinRAR
SPLITSIZE=1440k

## Location of config files
CONFIG_SRC=config

## Destination for the generic bundle
DEST=generic-bundle

## Name of the bundle
NAME=TorBrowser

## Where shall we put the finished files for distribution?
DISTDIR=tbbwin-alpha-dist

## Version and name of the compressed bundle (also used for source)
VERSION=2.2.24-1-alpha
DEFAULT_COMPRESSED_BASENAME=tor-browser-$(VERSION)-
IM_COMPRESSED_BASENAME=tor-im-browser-$(VERSION)-
DEFAULT_COMPRESSED_NAME=$(DEFAULT_COMPRESSED_BASENAME)
IM_COMPRESSED_NAME=$(IM_COMPRESSED_BASENAME)$(VERSION)

ifeq ($(USE_PIDGIN),1)
COMPRESSED_NAME=$(IM_COMPRESSED_NAME)
else
COMPRESSED_NAME=$(DEFAULT_COMPRESSED_NAME)
endif

## Extensions to install by default
DEFAULT_EXTENSIONS=torbutton.xpi

## Where to download Torbutton from
TORBUTTON=https://www.torproject.org/torbutton/releases/torbutton-$(TORBUTTON_VER).xpi
NOSCRIPT=https://secure.informaction.com/download/releases/noscript-$(NOSCRIPT_VER).xpi
BETTERPRIVACY=https://addons.mozilla.org/en-US/firefox/downloads/latest/6623/addon-6623-latest.xpi
HTTPSEVERYWHERE=https://eff.org/files/https-everywhere-$(HTTPSEVERY_VER).xpi
## Where to download Mozilla language packs
MOZILLA_LANGUAGE=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/$(FIREFOX_VER)/win32/xpi

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
	USE_PIDGIN=1 make -f windows.mk all-bundles
	make -f windows.mk clean
	USE_PIDGIN=0 make -f windows.mk all-bundles
	make -f windows.mk clean

all-bundles: all-compressed-bundles

all-compressed-bundles: compressed-bundle_ar \
	compressed-bundle_de \
	compressed-bundle_en-US \
	compressed-bundle_es-ES \
	compressed-bundle_fa \
	compressed-bundle_fr \
	compressed-bundle_nl \
	compressed-bundle_pl \
	compressed-bundle_pt-PT \
	compressed-bundle_ru \
	compressed-bundle_zh-CN \
	compressed-bundle_it

##
## Cleanup
##

clean:
	rm -fr $(DEST) *.stamp
	rm -f *~
	rm -fr *.xpi *.jar *.zip
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
## Scan .exe files against VirusTotal to check for false positives
##

virus-scan:
	$(VIRUSSCAN) $(VIDALIA)/build/src/vidalia/vidalia.exe
	$(VIRUSSCAN) $(POLIPO)/polipo.exe
	$(VIRUSSCAN) $(TOR)/src/or/tor.exe 
	$(VIRUSSCAN) $(TOR)/src/tools/tor-resolve.exe

##
## Generate a non-localized bundle and put in $(DEST)
##

## Install binaries, documentation, FirefoxPortable, PidginPortable, and launcher into $(DEST)
generic-bundle.stamp:
	make -f windows.mk generic-bundle
generic-bundle: directory-structure install-binaries install-docs install-firefoxportable install-pidginportable configure-apps launcher
	touch generic-bundle.stamp

APPDIR=$(DEST)/App
DOCSDIR=$(DEST)/Docs
DATADIR=$(DEST)/Data

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
	cp $(QT)/QtCore4.dll $(QT)/QtGui4.dll $(QT)/QtNetwork4.dll $(QT)/QtXml4.dll $(QT)/libgcc_s_dw2-1.dll $(APPDIR) 
	cp $(OPENSSL)/ssleay32.dll $(APPDIR)
	cp $(OPENSSL)/libeay32.dll $(APPDIR)
	cp $(VIDALIA)/build/src/vidalia/vidalia.exe $(APPDIR)
	cp $(POLIPO)/polipo.exe $(APPDIR)
	cp $(TOR)/src/or/tor.exe $(TOR)/src/tools/tor-resolve.exe $(APPDIR)

## Fixup
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
	cp $(POLIPO)/COPYING  $(POLIPO)/README.Windows $(DOCSDIR)/Polipo
	cp ../changelog.windows-2.2 $(DOCSDIR)/changelog
	cp ../README.WINDOWS-2.2 $(DOCSDIR)/README-TorBrowserBundle

## Copy over Firefox
install-firefox:
	cp -R $(FIREFOX) $(DEST)/FirefoxPortable

## Configure Firefox, Vidalia, Polipo and Tor
configure-apps:
	## Configure Firefox preferences
	#mkdir -p $(DEST)/.mozilla/Firefox/firefox.default
	cp -R $(CONFIG_SRC)/firefox-profiles.ini $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profiles.ini
	cp $(CONFIG_SRC)/bookmarks.html $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profile
	cp $(CONFIG_SRC)/no-polipo-4.0.js $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profile/prefs.js
	cp $(CONFIG_SRC)/Info.plist $(DEST)/Contents
	cp $(CONFIG_SRC)/PkgInfo $(DEST)/Contents
	cp $(CONFIG_SRC)/qt.conf $(DEST)/Contents/Resources
	cp $(CONFIG_SRC)/vidalia.icns $(DEST)/Contents/Resources

## Copy over PidginPortable
install-pidginportable:
ifeq ($(USE_PIDGIN),1)
	cp -R $(PIDGIN) $(DEST)/PidginPortable
endif

## Configure Firefox, FirefoxPortable, Vidalia, Polipo and Tor
configure-apps:

	## Configure Firefox preferences
	cp $(CONFIG_SRC)/no-polipo-4.0.js $(DEST)/FirefoxPortable/App/DefaultData/profile/
	cp $(CONFIG_SRC)/bookmarks.html $(DEST)/FirefoxPortable/App/DefaultData/profile/

	## Set up alternate launcher
	mv $(DEST)/FirefoxPortable/App/Firefox/firefox.exe $(DEST)/FirefoxPortable/App/Firefox/tbb-firefox.exe
	
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
	cd ../src/RelativeLink/ && $(MAKE)
	cp ../src/RelativeLink/StartTorBrowserBundle.exe $(DEST)/"Start Tor Browser.exe"

##
## How to create required extensions
##

## Torbutton development version
torbutton.xpi:
	$(WGET) -O $@ $(TORBUTTON)

## English comes as default
langpack_en-US.xpi:
	touch $@

## BetterPrivacy
betterprivacy.xpi:
	$(WGET) --no-check-certificate -O $@ $(BETTERPRIVACY)

## NoScript development version
noscript.xpi: 
	$(WGET) --no-check-certificate -O $@ $(NOSCRIPT)

## HTTPS Everywhere
httpseverywhere.xpi:
	$(WGET) --no-check-certificate -O $@ $(HTTPSEVERYWHERE)

## Generic language pack rule
langpack_%.xpi:
	$(WGET) --no-check-certificate -O $@ $(MOZILLA_LANGUAGE)/$*.xpi

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
	cd $(NAME)_$(LANGCODE); $(SEVENZIP) a -mx9 -sfx7z.sfx ../$(COMPRESSED_NAME)_$(LANGCODE).exe $(NAME)

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
install-extensions: $(filter-out langpack_en-US.xpi,langpack_$(LANGCODE).xpi)
	## Make a dummy profile to stop Firefox creating some large files
	cp -R $(BUNDLE)/FirefoxPortable/App/DefaultData $(DUMMYPROFILE)
ifneq ($(LANGCODE), en-US)
	mv langpack_$(LANGCODE).xpi $(BUNDLE)/FirefoxPortable/App/Firefox/extensions/langpack-$(LANGCODE)\@firefox.mozilla.org.zip
	$(SEVENZIP) x -o$(BUNDLE)/FirefoxPortable/App/Firefox/extensions/langpack-$(LANGCODE)\@firefox.mozilla.org $(BUNDLE)/FirefoxPortable/App/Firefox/extensions/langpack-$(LANGCODE)\@firefox.mozilla.org.zip
endif
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
				   $(BUNDLE)/PidginPortable/App/Pidgin/Gtk/share/locale
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
	git clone git://git.torproject.org/torbrowser.git \
		$(SRCDESTPATH)
	cd $(SRCDEST); tar --exclude src/archived-patches \
		--exclude src/current-patches  --exclude src/processtest \
		--exclude .git -czvf $(SRCNAME)-src.tar.gz $(SRCNAME)

