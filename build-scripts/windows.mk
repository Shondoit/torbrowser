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
BUILD_NUM=1
PLATFORM=Windows

## Location of required libraries
MING=/c/MinGW/bin
QT_LIB=/c/Qt/$(QT_VER)/bin
OPENSSL_LIB=$(COMPILED_BINS)
WIX_LIB="/c/Program Files (x86)/Windows Installer XML v3.5/bin"

## Location of bundle components
VIDALIA=$(FETCH_DIR)/vidalia-$(VIDALIA_VER)
TOR=$(FETCH_DIR)/tor-$(TOR_VER)
FIREFOX=$(FETCH_DIR)/FirefoxPortable-$(FIREFOX_VER)
PIDGIN=$(FETCH_DIR)/PidginPortable-$(PIDGIN_VER)

## Location of utility applications
PWD:=$(shell pwd)
PYTHON=/c/Python26/python.exe
SEVENZIP="/c/Program Files/7-Zip/7z.exe"
PYGET=$(PYTHON) $(PWD)/pyget.py
WGET=wget
VIRUSSCAN=$(PYTHON) $(PWD)/virus-scan.py
WINRAR="/c/Program Files (x86)/WinRAR/WinRAR.exe"
CC=gcc


## Location of directory for source unpacking
FETCH_DIR=$(PWD)/build-alpha-windows
## Location of directory for prefix/destdir/compiles/etc
BUILT_DIR=$(FETCH_DIR)/built
TBB_FINAL=$(BUILT_DIR)/tbbwin-alpha-dist

source-dance: fetch-source unpack-source
	echo "We're ready for building now."

ZLIB_DIR=$(FETCH_DIR)/zlib-$(ZLIB_VER)
build-zlib:
	cp ../src/current-patches/zlib/* $(ZLIB_DIR)
	cp patch-any-src.sh $(ZLIB_DIR)
	cd $(ZLIB_DIR) && ./patch-any-src.sh
	cd $(ZLIB_DIR) && sed -i -e "s%prefix = /usr/local%prefix = ${BUILT_DIR}%" win32/Makefile.gcc
	cd $(ZLIB_DIR) && make -f win32/Makefile.gcc
	cd $(ZLIB_DIR) && make -f win32/Makefile.gcc install

OPENSSL_DIR=$(FETCH_DIR)/openssl-$(OPENSSL_VER)
OPENSSL_OPTS=-no-idea -no-rc5 -no-md2 shared zlib --prefix=$(BUILT_DIR) --openssldir=$(BUILT_DIR) -L$(BUILT_DIR)/lib -Wl,--nxcompat -Wl,--dynamicbase -I$(BUILT_DIR)/include
build-openssl:
	cd $(OPENSSL_DIR) && ./config $(OPENSSL_OPTS)
	cd $(OPENSSL_DIR) && make depend
	cd $(OPENSSL_DIR) && make
	cd $(OPENSSL_DIR) && make install

VIDALIA_DIR=$(FETCH_DIR)/vidalia-$(VIDALIA_VER)
VIDALIA_OPTS=-DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -Wl,--nxcompat -Wl,--dynamicbase" -DWIN2K=1 -DQT_MAKE_EXECUTABLE=/c/Qt/$(QT_VER)/bin/qmake -DCMAKE_BUILD_TYPE=minsizerel -DMINGW_BINARY_DIR=$(MING) -DOPENSSL_BINARY_DIR=$(OPENSSL) -DWIX_BINARY_DIR=$(WIX_LIB)
build-vidalia:
	-mkdir $(VIDALIA_DIR)/build
	cd $(VIDALIA_DIR)/build && cmake -G "MSYS Makefiles" $(VIDALIA_OPTS) ..
	cd $(VIDALIA_DIR)/build && make

LIBEVENT_DIR=$(FETCH_DIR)/libevent-$(LIBEVENT_VER)
LIBEVENT_CFLAGS="-I$(BUILT_DIR)/include -O -g"
LIBEVENT_LDFLAGS="-L$(BUILT_DIR)/lib -L$(BUILT_DIR)/bin -Wl,--nxcompat -Wl,--dynamicbase"
LIBEVENT_OPTS=--prefix=$(BUILT_DIR) --enable-static --disable-shared --disable-dependency-tracking
build-libevent:
	cd $(LIBEVENT_DIR) && CFLAGS=$(LIBEVENT_CFLAGS) LDFLAGS=$(LIBEVENT_LDFLAGS) ./configure $(LIBEVENT_OPTS)
	cd $(LIBEVENT_DIR) && make -j2
	cd $(LIBEVENT_DIR) && make install

TOR_DIR=$(FETCH_DIR)/tor-$(TOR_VER)
TOR_CFLAGS="-O -g -I$(BUILT_DIR)/include"
TOR_LDFLAGS="-L$(BUILT_DIR)/lib -L$(BUILT_DIR)/bin"
TOR_OPTS=--enable-static-libevent --with-libevent-dir=$(BUILT_DIR)/lib --prefix=$(BUILT_DIR)
build-tor:
	cd $(TOR_DIR) && CFLAGS=$(TOR_CFLAGS) LDFLAGS=$(TOR_LDFLAGS) ./configure $(TOR_OPTS)
	cd $(TOR_DIR) && make
	cd $(TOR_DIR) && make install

FIREFOX_DIR=/c/mozilla-build/mozilla-release
build-firefox:
	cp ../src/current-patches/firefox/* $(FIREFOX_DIR)
	cp patch-any-src.sh $(FIREFOX_DIR)
	cp $(CONFIG_SRC)/dot_mozconfig $(FIREFOX_DIR)/mozconfig
	cd $(FIREFOX_DIR) && ./patch-any-src.sh
#	cmd /c C:/mozilla-build/start-msvc9

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


## Size of split archive volumes for WinRAR
SPLITSIZE=1440k

## Location of config files
CONFIG_SRC=config

## Destination for the generic bundle
DEST="Generic Bundle"

## Name of the bundle
NAME="Tor Browser"

## Where shall we put the finished files for distribution?
DISTDIR=tbbwin-alpha-dist

## Version and name of the compressed bundle (also used for source)
VERSION=$(RELEASE_VER)-$(BUILD_NUM)
DEFAULT_COMPRESSED_BASENAME=tor-browser-$(VERSION)
IM_COMPRESSED_BASENAME=tor-im-browser-$(VERSION)
DEFAULT_COMPRESSED_NAME=$(DEFAULT_COMPRESSED_BASENAME)
IM_COMPRESSED_NAME=$(IM_COMPRESSED_BASENAME)$(VERSION)

ifeq ($(USE_PIDGIN),1)
COMPRESSED_NAME=$(IM_COMPRESSED_NAME)
else
COMPRESSED_NAME=$(DEFAULT_COMPRESSED_NAME)
endif

## Extensions to install by default
DEFAULT_EXTENSIONS=torbutton.xpi

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

all-bundles: all-compressed-bundles all-split-bundles

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

all-split-bundles: split-bundle_ar \
	split-bundle_de \
	split-bundle_en-US \
	split-bundle_es-ES \
	split-bundle_fa \
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
	mkdir -p $(DOCSDIR)

## Package up all the Vidalia and Tor pre-requisites
## Filenames extracted using Dependency Walker <http://www.dependencywalker.com/>
install-binaries: 
	cp $(MING)/mingwm10.dll $(APPDIR)
	cp $(MING)/libgnurx-0.dll $(APPDIR)
	cp $(QT_LIB)/QtCore4.dll $(QT_LIB)/QtGui4.dll $(QT_LIB)/QtNetwork4.dll $(QT_LIB)/QtXml4.dll $(QT_LIB)/libgcc_s_dw2-1.dll $(APPDIR) 
	cp $(OPENSSL_LIB)/ssleay32.dll $(APPDIR)
	cp $(OPENSSL_LIB)/libeay32.dll $(APPDIR)
	cp $(VIDALIA)/build/src/vidalia/vidalia.exe $(APPDIR)
	cp $(TOR)/src/or/tor.exe $(TOR)/src/tools/tor-resolve.exe $(APPDIR)

## Fixup
## Collect up license files
install-docs:
	mkdir -p $(DOCSDIR)/Vidalia
	mkdir -p $(DOCSDIR)/Tor
	mkdir -p $(DOCSDIR)/Qt
	mkdir -p $(DOCSDIR)/MinGW
	cp $(VIDALIA)/LICENSE* $(VIDALIA)/CREDITS $(DOCSDIR)/Vidalia
	cp $(TOR)/LICENSE $(TOR)/README $(DOCSDIR)/Tor
	cp $(QT_LIB)/../LICENSE.GPL* $(QT_LIB)/../LICENSE.LGPL $(DOCSDIR)/Qt
	cp $(MING)/../msys/1.0/share/doc/MSYS/COPYING $(DOCSDIR)/MinGW
	cp ../changelog.windows-2.2 $(DOCSDIR)/changelog
	cp ../README.WIN-2.2 $(DOCSDIR)/README-TorBrowserBundle

## Copy over FirefoxPortable
install-firefoxportable:
	cp -r $(FIREFOX) $(DEST)/FirefoxPortable

## Copy over PidginPortable
install-pidginportable:
ifeq ($(USE_PIDGIN),1)
	cp -r $(PIDGIN) $(DEST)/PidginPortable
endif

## Configure Firefox, FirefoxPortable, Vidalia, and Tor
configure-apps:

	mkdir -p $(DEST)/FirefoxPortable/Data/profile
	## Configure Firefox preferences
	cp $(CONFIG_SRC)/windows-4.0.js $(DEST)/FirefoxPortable/App/DefaultData/profile/prefs.js
	cp $(CONFIG_SRC)/windows-4.0.js $(DEST)/FirefoxPortable/Data/profile/prefs.js
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
	$(PYGET) -O $@ $(TORBUTTON)

## English comes as default
langpack_en-US.xpi:
	touch $@

## BetterPrivacy
betterprivacy.xpi:
	$(PYGET) -O $@ $(BETTERPRIVACY)

## NoScript development version
noscript.xpi: 
	$(PYGET) -O $@ $(NOSCRIPT)

## HTTPS Everywhere
httpseverywhere.xpi:
	$(PYGET) -O $@ $(HTTPSEVERYWHERE)

## Generic language pack rule
langpack_%.xpi:
	$(PYGET) -O $@ $(MOZILLA_LANGUAGE)/$*.xpi

##
## Customize the bundle
##

bundle_%:
	LANGCODE=$* make -f windows.mk bundle-localized
compressed-bundle_%:
	LANGCODE=$* make -f windows.mk compressed-bundle-localized
split-bundle_%:
	LANGCODE=$* make -f windows.mk split-bundle-localized

bundle-localized_%.stamp:
	make -f windows.mk copy-files_$* install-extensions install-torbutton install-httpseverywhere install-noscript \
	patch-vidalia-language patch-firefox-language patch-pidgin-language write-tbb-version
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
	cp -r $(DEST) $(NAME)_$*/$(NAME)

BUNDLE=$(NAME)_$(LANGCODE)/$(NAME)
DUMMYPROFILE=$(BUNDLE)/FirefoxPortable/App/DummyProfile

fix-install-rdf: $(filter-out langpack_en-US.xpi,langpack_$(LANGCODE).xpi)
ifneq ($(LANGCODE), en-US)
	rm -fr xx
	mkdir xx
	(cd xx && unzip ../langpack_$(LANGCODE).xpi && sed -i -e "s/em:maxVersion>6.0.1/em:maxVersion>6.0.*/" install.rdf && zip  -r ../langpack_$(LANGCODE).xpi .)
endif

install-extensions: $(filter-out langpack_en-US.xpi,langpack_$(LANGCODE).xpi)
	## Make a dummy profile to stop Firefox creating some large files
	cp -r $(BUNDLE)/FirefoxPortable/App/DefaultData $(DUMMYPROFILE)
	mkdir -p $(BUNDLE)/FirefoxPortable/Data/profile/extensions
ifneq ($(LANGCODE), en-US)
	mv langpack_$(LANGCODE).xpi $(BUNDLE)/FirefoxPortable/Data/profile/extensions/langpack-$(LANGCODE)@firefox.mozilla.org.xpi
endif
	rm -fr $(DUMMYPROFILE)

install-torbutton: torbutton.xpi
	mkdir -p $(BUNDLE)/FirefoxPortable/Data/profile/extensions/{e0204bd5-9d31-402b-a99d-a6aa8ffebdca}
	cp torbutton.xpi $(BUNDLE)/FirefoxPortable/Data/profile/extensions/{e0204bd5-9d31-402b-a99d-a6aa8ffebdca}/torbutton.zip
	(cd $(BUNDLE)/FirefoxPortable/Data/profile/extensions/{e0204bd5-9d31-402b-a99d-a6aa8ffebdca} && $(SEVENZIP) x *.zip && rm *.zip)

install-httpseverywhere: httpseverywhere.xpi
	mkdir -p $(BUNDLE)/FirefoxPortable/Data/profile/extensions/https-everywhere@eff.org
	cp httpseverywhere.xpi $(BUNDLE)/FirefoxPortable/Data/profile/extensions/https-everywhere@eff.org/httpseverywhere.zip
	(cd $(BUNDLE)/FirefoxPortable/Data/profile/extensions/https-everywhere@eff.org && $(SEVENZIP) x *.zip && rm *.zip)

install-betterprivacy: betterprivacy.xpi
	mkdir -p $(BUNDLE)/FirefoxPortable/Data/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\}
	cp betterprivacy.xpi $(BUNDLE)/FirefoxPortable/Data/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\}/betterprivacy.zip
	(cd $(BUNDLE)/FirefoxPortable/Data/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\} && $(SEVENZIP) x *.zip && rm *.zip)

install-noscript: noscript.xpi
	mkdir -p $(BUNDLE)/FirefoxPortable/Data/profile/extensions/\{73a6fe31-595d-460b-a920-fcc0f8843232\}
	cp noscript.xpi $(BUNDLE)/FirefoxPortable/Data/profile/extensions/\{73a6fe31-595d-460b-a920-fcc0f8843232\}/noscript.zip
	(cd $(BUNDLE)/FirefoxPortable/Data/profile/extensions/\{73a6fe31-595d-460b-a920-fcc0f8843232\} && $(SEVENZIP) x *.zip && rm *.zip)


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
	./patch-firefox-language.sh $(BUNDLE)/FirefoxPortable/Data/profile/prefs.js $(LANGCODE)
	sed -i -e "s/SHPONKA/$(LANGCODE)/g" $(BUNDLE)/FirefoxPortable/Data/profile/prefs.js
	sed -i -e "s/SHPONKA/$(LANGCODE)/g" $(BUNDLE)/FirefoxPortable/App/DefaultData/profile/prefs.js

###
### Utilities
###

## Copy Firefox preferences from a run of FirefoxPortable to be the default
apply-prefs:
	cp $(DEST)/FirefoxPortable/Data/profile/prefs.js $(CONFIG_SRC)

print-version:
	@echo $(RELEASE_VER)-$(BUILD_NUM)

write-tbb-version:
	printf 'user_pref("torbrowser.version", "%s");\n' "$(RELEASE_VER)-$(BUILD_NUM)-$(PLATFORM)" >> $(BUNDLE)/FirefoxPortable/App/DefaultData/profile/prefs.js
	printf 'user_pref("torbrowser.version", "%s");\n' "$(RELEASE_VER)-$(BUILD_NUM)-$(PLATFORM)" >> $(BUNDLE)/FirefoxPortable/Data/profile/prefs.js

## Tag the release
releasetag:
	git tag -s torbrowser-$(VERSION) -m "tagging $(VERSION)"

## Export the source code of the bundle
SRCNAME=$(COMPRESSED_NAME)
SRCDEST=/tmp
SRCDESTPATH=$(SRCDEST)/$(SRCNAME)
srcdist:
	git archive --format=tar --prefix=tor-browser-$(VERSION)-src/ torbrowser-$(VERSION) | gzip -9 > $(PWD)/tor-browser-$(VERSION)-src.tar.gz

