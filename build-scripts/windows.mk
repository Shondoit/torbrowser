###
### Makefile for building Tor USB bundle on Windows
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### Copyright 2009, 2010 Jacob Appelbaum <jacob@appelbaum.net>
### Copyright 2010 Erinn Clark <erinn@torproject.org>
###
### See LICENSE for licensing information
###


#####################
### Configuration ###
#####################

BUILD_NUM=8
PLATFORM=Windows

## Location of required libraries
MING=/c/MinGW/bin
QT_LIB=/c/Qt/$(QT_VER)/bin
OPENSSL_LIB=$(COMPILED_BINS)
WIX_LIB="/c/Program Files (x86)/Windows Installer XML v3.5/bin"

## Location of bundle components
VIDALIA=$(BUILD_DIR)/vidalia-$(VIDALIA_VER)
TOR=$(BUILD_DIR)/tor-$(TOR_VER)
FIREFOX=$(BUILD_DIR)/FirefoxPortable-$(FIREFOX_VER)
PIDGIN=$(BUILD_DIR)/PidginPortable-$(PIDGIN_VER)

## Location of utility applications
PWD:=$(shell pwd)
PYTHON=$(MOZBUILD_DIR)/python/python.exe
PYMAKE=$(PYMAKE_DIR)/make.py
SEVENZIP="/c/Program Files/7-Zip/7z.exe"
WGET=wget
VIRUSSCAN=$(PYTHON) $(PWD)/virus-scan.py
WINRAR="/c/Program Files (x86)/WinRAR/WinRAR.exe"
CC=gcc

MSVC_VER=9

## Build machine specific settings
# Number of cpu cores used to build in parallel
NUM_CORES=2

## Location of directory for source unpacking
FETCH_DIR=$(PWD)/build-alpha-windows
## Location of directory for source unpacking/building
## This must be different from FETCH_DIR
BUILD_DIR=$(FETCH_DIR)/build
## Location of directory for prefix/destdir/compiles/etc
BUILT_DIR=$(BUILD_DIR)/built
TBB_FINAL=$(BUILT_DIR)/tbbwin-alpha-dist

## Include versions (must happen after variable definitions above
include $(PWD)/versions.mk

build-zlib: $(ZLIB_DIR)
	cd $(ZLIB_DIR) && sed -i -e "s%prefix = /usr/local%prefix = ${BUILT_DIR}%" win32/Makefile.gcc
	cd $(ZLIB_DIR) && LDFLAGS="-Wl,--nxcompat -Wl,--dynamicbase" make -f win32/Makefile.gcc -j $(NUM_CORES)
	cd $(ZLIB_DIR) && BINARY_PATH="$(BUILT_DIR)/bin" INCLUDE_PATH="$(BUILT_DIR)/include" LIBRARY_PATH="$(BUILT_DIR)/lib" make -f win32/Makefile.gcc install
	touch $(STAMP_DIR)/build-zlib

OPENSSL_OPTS=-no-idea -no-rc5 -no-md2 shared zlib --prefix=$(BUILT_DIR) --openssldir=$(BUILT_DIR) -L$(BUILT_DIR)/lib -Wl,--nxcompat -Wl,--dynamicbase -I$(BUILT_DIR)/include
build-openssl: build-zlib $(OPENSSL_DIR)
	cd $(OPENSSL_DIR) && ./config $(OPENSSL_OPTS)
	cd $(OPENSSL_DIR) && make depend
	cd $(OPENSSL_DIR) && make
	cd $(OPENSSL_DIR) && make install_sw
	touch $(STAMP_DIR)/build-openssl

QT_BUILD_PREFS=-system-zlib -confirm-license -opensource -openssl-linked -no-qt3support -fast -release -nomake demos -nomake examples
QT_OPTS=$(QT_BUILD_PREFS) -prefix $(BUILT_DIR) -I $(BUILT_DIR)/include -I $(BUILT_DIR)/include/openssl/ -L$(BUILT_DIR)/lib
build-qt: build-zlib build-openssl $(QT_DIR)
	cd $(QT_DIR) && ./configure $(QT_OPTS)
	cd $(QT_DIR) && make -j $(NUM_CORES)
	cd $(QT_DIR) && make install
	touch $(STAMP_DIR)/build-qt

VIDALIA_OPTS=-DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -Wl,--nxcompat -Wl,--dynamicbase" -DWIN2K=1 -DQT_MAKE_EXECUTABLE=/c/Qt/$(QT_VER)/bin/qmake -DCMAKE_BUILD_TYPE=minsizerel -DMINGW_BINARY_DIR=$(MING) -DOPENSSL_BINARY_DIR=$(OPENSSL) -DWIX_BINARY_DIR=$(WIX_LIB)
# XXX Once we build qt on windows, we'll want to add build-qt here
build-vidalia: build-openssl $(VIDALIA_DIR)
	-mkdir $(VIDALIA_DIR)/build
	cd $(VIDALIA_DIR)/build && cmake -G "MSYS Makefiles" $(VIDALIA_OPTS) ..
	cd $(VIDALIA_DIR)/build && make -j $(NUM_CORES)
	touch $(STAMP_DIR)/build-vidalia

LIBEVENT_CFLAGS="-I$(BUILT_DIR)/include"
LIBEVENT_LDFLAGS="-L$(BUILT_DIR)/lib -L$(BUILT_DIR)/bin -Wl,--nxcompat -Wl,--dynamicbase"
LIBEVENT_OPTS=--prefix=$(BUILT_DIR) --enable-static --disable-shared --disable-dependency-tracking
build-libevent: build-zlib build-openssl $(LIBEVENT_DIR)
	cd $(LIBEVENT_DIR) && CFLAGS=$(LIBEVENT_CFLAGS) LDFLAGS=$(LIBEVENT_LDFLAGS) ./configure $(LIBEVENT_OPTS)
	cd $(LIBEVENT_DIR) && make -j $(NUM_CORES)
	cd $(LIBEVENT_DIR) && make install
	touch $(STAMP_DIR)/build-libevent

TOR_CFLAGS="-I$(BUILT_DIR)/include"
TOR_LDFLAGS="-L$(BUILT_DIR)/lib -L$(BUILT_DIR)/bin"
TOR_OPTS=--enable-gcc-warnings --enable-static-libevent --with-libevent-dir=$(BUILT_DIR)/lib --prefix=$(BUILT_DIR)
build-tor:PATH+=:$(BUILT_DIR)/bin 

build-firefox: $(FIREFOX_DIR) config/dot_mozconfig $(MOZBUILD_DIR) $(MOZBUILD_DIR)/start-msvc$(MSVC_VER).bat | $(PYTHON) $(PYMAKE_DIR)
	cp config/dot_mozconfig $(FIREFOX_DIR)/mozconfig
	cp branding/* $(FIREFOX_DIR)/browser/branding/official
	cd $(MOZBUILD_DIR) && cmd.exe /c "start-msvc$(MSVC_VER).bat $(FIREFOX_DIR) $(PYTHON) $(PYMAKE)"
	touch $(STAMP_DIR)/build-firefox

copy-firefox:
	-rm -rf $(FIREFOX)
	-mkdir -p $(FIREFOX)
	cp -r config/firefox-portable/* $(FIREFOX)
	cp "/c/Program Files (x86)/Microsoft Visual Studio 9.0/VC/redist/x86/Microsoft.VC90.CRT/"msvc*90.dll $(FIREFOX)/App/Firefox
	cp -r $(FIREFOX_DIR)/obj-*/dist/bin/* $(FIREFOX)/App/Firefox

build-all-binaries: build-zlib build-openssl build-vidalia build-libevent build-tor build-firefox copy-firefox
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

all-bundles: all-compressed-bundles

all-compressed-bundles: compressed-bundle_ar \
	compressed-bundle_de \
	compressed-bundle_en-US \
	compressed-bundle_es-ES \
	compressed-bundle_fa \
	compressed-bundle_fr \
	compressed-bundle_it \
	compressed-bundle_ko \
	compressed-bundle_nl \
	compressed-bundle_pl \
	compressed-bundle_pt-PT \
	compressed-bundle_ru \
	compressed-bundle_vi \
	compressed-bundle_zh-CN

##
## Cleanup
##

clean:
	rm -fr $(DEST) *.stamp
	rm -f *~
	rm -fr *.xpi *.jar *.zip
	rm -fr $(NAME)_*
	rm -f $(STAMP_DIR)/*.stamp
	cd ../src/RelativeLink/ && $(MAKE) clean

## Also remove the output files
reallyclean: clean
	rm -fr $(IM_COMPRESSED_BASENAME)*_*.exe
	rm -fr $(IM_COMPRESSED_BASENAME)*_*.rar 
	rm -fr $(DEFAULT_COMPRESSED_BASENAME)*_*.exe
	rm -fr $(DEFAULT_COMPRESSED_BASENAME)*_*.rar

##
## Scan .exe files against VirusTotal to check for false positives
##

virus-scan: | $(PYTHON)
	$(VIRUSSCAN) $(VIDALIA)/build/src/vidalia/vidalia.exe
	$(VIRUSSCAN) $(TOR)/src/or/tor.exe

##
## Generate a non-localized bundle and put in $(DEST)
##

## Install binaries, documentation, FirefoxPortable, PidginPortable, and launcher into $(DEST)
generic-bundle.stamp:
	make -f windows.mk generic-bundle
generic-bundle: directory-structure install-binaries install-docs install-firefoxportable install-pidginportable configure-apps launcher
	touch $(STAMP_DIR)/generic-bundle.stamp

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
	cp $(QT_LIB)/QtCore4.dll $(QT_LIB)/QtGui4.dll $(QT_LIB)/QtNetwork4.dll $(QT_LIB)/QtXml4.dll $(QT_LIB)/libgcc_s_dw2-1.dll $(APPDIR) 
	cp $(OPENSSL_LIB)/ssleay32.dll $(APPDIR)
	cp $(OPENSSL_LIB)/libeay32.dll $(APPDIR)
	cp $(VIDALIA)/build/src/vidalia/vidalia.exe $(APPDIR)
	cp $(TOR)/src/or/tor.exe $(APPDIR)

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
	mkdir -p $(DEST)/FirefoxPortable/App/DefaultData/profile
	## Configure Firefox preferences
	cp config/prefs.js $(DEST)/FirefoxPortable/App/DefaultData/profile/prefs.js
	cp config/prefs.js $(DEST)/FirefoxPortable/Data/profile/prefs.js
	cp config/bookmarks.html $(DEST)/FirefoxPortable/App/DefaultData/profile/

	## Set up alternate launcher
	mv $(DEST)/FirefoxPortable/App/Firefox/firefox.exe $(DEST)/FirefoxPortable/App/Firefox/tbb-firefox.exe

	## Configure FirefoxPortable
	cp config/FirefoxPortable.ini $(DEST)/FirefoxPortable
	cp config/FirefoxPortableSettings.ini $(DEST)/FirefoxPortable/Data/settings
	
	## Configure PidginPortable
ifeq ($(USE_PIDGIN),1)
	cp config/PidginPortable.ini $(DEST)/PidginPortable
	mkdir -p $(DEST)/PidginPortable/Data/settings/.purple
	cp config/prefs.xml $(DEST)/PidginPortable/Data/settings/.purple
	cp config/PidginPortableSettings.ini $(DEST)/PidginPortable/Data/settings
endif
	## Configure Vidalia
ifeq ($(USE_PIDGIN),1)
	cp config/vidalia.conf.ff+pidgin $(DEST)/Data/Vidalia/vidalia.conf
else
	cp config/vidalia.conf.ff $(DEST)/Data/Vidalia/vidalia.conf
endif
	## Configure Tor
	cp config/torrc $(DEST)/Data/Tor
	cp $(TOR)/src/config/geoip $(DEST)/Data/Tor

launcher:
	cd ../src/RelativeLink/ && $(MAKE)
	cp ../src/RelativeLink/StartTorBrowserBundle.exe $(DEST)/"Start Tor Browser.exe"

##
## Customize the bundle
##

bundle_%:
	LANGCODE=$* make -f windows.mk bundle-localized
compressed-bundle_%:
	LANGCODE=$* make -f windows.mk compressed-bundle-localized

bundle-localized_%.stamp:
	make -f windows.mk copy-files_$* install-extensions install-torbutton install-httpseverywhere install-noscript \
	patch-vidalia-language patch-firefox-language patch-pidgin-language write-tbb-version
	touch $(STAMP_DIR)/bundle-localized_$*.stamp

bundle-localized: bundle-localized_$(LANGCODE).stamp

compressed-bundle-localized: bundle-localized_$(LANGCODE).stamp
	rm -f $(COMPRESSED_NAME)_$(LANGCODE).exe
	cd $(NAME)_$(LANGCODE); $(SEVENZIP) a -mx9 -sfx7z.sfx ../$(COMPRESSED_NAME)_$(LANGCODE).exe $(NAME)

copy-files_%: generic-bundle.stamp
	rm -fr $(NAME)_$*
	mkdir $(NAME)_$*
	cp -r $(DEST) $(NAME)_$*/$(NAME)

BUNDLE=$(NAME)_$(LANGCODE)/$(NAME)
DUMMYPROFILE=$(BUNDLE)/FirefoxPortable/App/DummyProfile

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
	cp $(DEST)/FirefoxPortable/Data/profile/prefs.js config

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
	cd .. && git archive --format=tar --prefix=tor-browser-$(VERSION)-src/ torbrowser-$(VERSION) | gzip -9 > $(PWD)/tor-browser-$(VERSION)-src.tar.gz

$(PYTHON): | $(MOZBUILD_DIR) ;
