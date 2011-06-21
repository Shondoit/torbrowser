###
### Makefile for building Tor USB bundle on Mac OS X
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### Copyright 2009, 2010 Jacob Appelbaum <jacob@appelbaum.net>
### Copyright 2010 Erinn Clark <erinn@torproject.org>
###
### You want to do the following currently supported activities:
# This downloads and compiles everything
### make -f osx.mk build-all-binaries
# This makes a generic bundle
### make -f osx.mk generic-bundle
# This makes the English bundle
### make -f osx.mk bundle_en-US
# This makes the German bundle
### make -f osx.mk bundle_de
# This makes the German compressed bundle
### make -f osx.mk compressed-bundle_de 
# It's possible you may also want to do:
### make -f osx.mk build-all-binaries
### make -f osx.mk all-compressed-bundles
### ...
### Look in tbbosx-dist/ for your files.
###
### See LICENSE for licensing information
###
### $Id: Makefile 19973 2009-07-12 02:26:03Z phobos $
###

#####################
### Configuration ###
#####################

## Architecture
ARCH_TYPE=$(shell uname -m)

## Location of directory for source unpacking
FETCH_DIR=/build
## Location of directory for prefix/destdir/compiles/etc
BUILT_DIR=$(FETCH_DIR)/built
TBB_FINAL=$(BUILT_DIR)/TBBL

## Versions for our source packages
HTTPSEVERY_VER=0.9.9.development.6
FIREFOX_VER=3.6.17
LIBEVENT_VER=2.0.12-stable
LIBPNG_VER=1.4.3
NOSCRIPT_VER=2.1.1.1
OPENSSL_VER=0.9.8p
OTR_VER=3.2.0
PIDGIN_VER=2.6.4
POLIPO_VER=1.0.4.1
QT_VER=4.6.2
TOR_VER=0.2.2.29-beta
TORBUTTON_VER=1.2.5
VIDALIA_VER=0.2.12
ZLIB_VER=1.2.5

## Extension IDs
FF_VENDOR_ID:=\{ec8030f7-c20a-464f-9b0e-13a3a9e97384\}

## File names for the source packages
ZLIB_PACKAGE=zlib-$(ZLIB_VER).tar.gz
OPENSSL_PACKAGE=openssl-$(OPENSSL_VER).tar.gz
QT_PACKAGE=qt-everywhere-opensource-src-$(QT_VER).tar.gz
VIDALIA_PACKAGE=vidalia-$(VIDALIA_VER).tar.gz
LIBEVENT_PACKAGE=libevent-$(LIBEVENT_VER).tar.gz
TOR_PACKAGE=tor-$(TOR_VER).tar.gz
POLIPO_PACKAGE=polipo-$(POLIPO_VER).tar.gz
PIDGIN_PACKAGE=pidgin-$(PIDGIN_VER).tar.bz2
FIREFOX_PACKAGE=firefox-$(FIREFOX_VER).tar.bz2

## Location of files for download
ZLIB_URL=http://www.gzip.org/zlib/$(ZLIB_PACKAGE)
OPENSSL_URL=http://www.openssl.org/source/$(OPENSSL_PACKAGE)
QT_URL=ftp://ftp.qt.nokia.com/qt/source/$(QT_PACKAGE)
VIDALIA_URL=http://www.torproject.org/vidalia/dist/$(VIDALIA_PACKAGE)
LIBEVENT_URL=http://www.monkey.org/~provos/$(LIBEVENT_PACKAGE)
TOR_URL=http://www.torproject.org/dist/$(TOR_PACKAGE)
POLIPO_URL=http://freehaven.net/~chrisd/polipo/$(POLIPO_PACKAGE)
PIDGIN_URL=http://sourceforge.net/projects/pidgin/files/Pidgin/$(PIDGIN_PACKAGE)
#FIREFOX_URL=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/$(FIREFOX_VER)/linux-i686/en-US/$(FIREFOX_PACKAGE)

fetch-source:
	-mkdir $(FETCH_DIR)
	$(WGET) --directory-prefix=$(FETCH_DIR) $(ZLIB_URL)
	$(WGET) --directory-prefix=$(FETCH_DIR) $(OPENSSL_URL)
	$(WGET) --directory-prefix=$(FETCH_DIR) $(VIDALIA_URL)
	$(WGET) --directory-prefix=$(FETCH_DIR) $(LIBEVENT_URL)
	$(WGET) --directory-prefix=$(FETCH_DIR) $(TOR_URL)
	$(WGET) --directory-prefix=$(FETCH_DIR) $(POLIPO_URL)

unpack-source:
	cd $(FETCH_DIR) && tar -xvzf $(ZLIB_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(OPENSSL_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(VIDALIA_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(LIBEVENT_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(TOR_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(POLIPO_PACKAGE)

source-dance: fetch-source unpack-source
	echo "We're ready for building now."


ZLIB_DIR=$(FETCH_DIR)/zlib-$(ZLIB_VER)
ZLIB_OPTS=--prefix=$(BUILT_DIR)
ZLIB_CFLAGS="-mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch $(ARCH_TYPE)"
ZLIB_LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk"
build-zlib:
	cd $(ZLIB_DIR) && CFLAGS=$(ZLIB_CFLAGS) LDFLAGS=$(ZLIB_LDFLAGS) ./configure $(ZLIB_OPTS)
	cd $(ZLIB_DIR) && make
	cd $(ZLIB_DIR) && make install

OPENSSL_DIR=$(FETCH_DIR)/openssl-$(OPENSSL_VER)
OPENSSL_OPTS=-no-idea -no-rc5 -no-md2 no-shared zlib -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk --prefix=$(BUILT_DIR) --openssldir=$(BUILT_DIR) -I$(BUILT_DIR)/lib
build-openssl:
	cd $(OPENSSL_DIR) && ./config $(OPENSSL_OPTS)
	cd $(OPENSSL_DIR) && make depend
	cd $(OPENSSL_DIR) && CC=/usr/bin/gcc-4.0 make
	cd $(OPENSSL_DIR) && make install

QT_DIR=$(FETCH_DIR)/qt-everywhere-opensource-src-$(QT_VER)
QT_BUILD_PREFS=-qt-zlib -universal -confirm-license -opensource -openssl-linked -no-qt3support \
	-fast -release -no-framework -nomake demos -nomake examples -sdk /Developer/SDKs/MacOSX10.4u.sdk/
QT_OPTS=$(QT_BUILD_PREFS) -prefix $(BUILT_DIR) -I $(BUILT_DIR)/include -I $(BUILT_DIR)/include/openssl/ -L $(BUILT_DIR)/lib
build-qt:
	cd $(QT_DIR) && ./configure $(QT_OPTS)
	cd $(QT_DIR) && make -j2
	cd $(QT_DIR) && make install

VIDALIA_DIR=$(FETCH_DIR)/vidalia-$(VIDALIA_VER)
VIDALIA_OPTS=-DOSX_TIGER_COMPAT=1 -DCMAKE_OSX_ARCHITECTURES=i386 -DOPENSSL_LIBRARY_DIR=$(BUILT_DIR)/lib -DCMAKE_BUILD_TYPE=debug ..
build-vidalia:
	export MACOSX_DEPLOYMENT_TARGET=10.4
	-mkdir $(VIDALIA_DIR)/build
	cd $(VIDALIA_DIR)/build && cmake $(VIDALIA_OPTS) \
	&& make && make dist-osx-libraries
	cd $(VIDALIA_DIR)/build && DESTDIR=$(BUILT_DIR) make install

LIBEVENT_DIR=$(FETCH_DIR)/libevent-$(LIBEVENT_VER)
LIBEVENT_CFLAGS="-O -g -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch i386"
LIBEVENT_LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk"
LIBEVENT_OPTS=--prefix=$(BUILT_DIR) --enable-static --disable-shared --disable-dependency-tracking CC="gcc-4.0"
build-libevent:
	cd $(LIBEVENT_DIR) && CFLAGS=$(LIBEVENT_CFLAGS) LDFLAGS=$(LIBEVENT_LDFLAGS) ./configure $(LIBEVENT_OPTS)
	cd $(LIBEVENT_DIR) && make -j2
	cd $(LIBEVENT_DIR) && make install

TOR_DIR=$(FETCH_DIR)/tor-$(TOR_VER)
TOR_CFLAGS="-I$(BUILT_DIR)/lib -O -g -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch i386"
TOR_LDFLAGS="-L$(BUILT_DIR)/lib -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk"
TOR_OPTS=--enable-static-openssl --enable-static-zlib --enable-static-libevent --with-openssl-dir=$(BUILT_DIR) --with-zlib-dir=$(BUILT_DIR) --with-libevent-dir=$(BUILT_DIR)/lib --prefix=$(BUILT_DIR) CC="gcc-4.0"
build-tor:
	cd $(TOR_DIR) && CFLAGS=$(TOR_CFLAGS) LDFLAGS=$(TOR_LDFLAGS) ./configure $(TOR_OPTS)
	cd $(TOR_DIR) && make $(MAKEFLAGS)
	cd $(TOR_DIR) && make install

## Polipo doesn't use autoconf, so we just have to hack their Makefile
## This probably needs to be updated if Polipo ever updates their Makefile
POLIPO_DIR=$(FETCH_DIR)/polipo-$(POLIPO_VER)
POLIPO_MAKEFILE=$(CONFIG_SRC)/polipo-Makefile
build-polipo:
	cp $(POLIPO_MAKEFILE) $(POLIPO_DIR)/Makefile
	cd $(POLIPO_DIR) && make CFLAGS="-mmacosx-version-min=10.4" \
	&& PREFIX=$(FETCH_DIR)/built/ make install.binary

build-pidgin:
	echo "We're not building pidgin yet!"

build-firefox:
	echo "We're using a prebuilt firefox. Fix this someday!"

build-all-binaries: build-zlib build-openssl build-vidalia build-libevent build-tor build-polipo
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

## Location of binary bundle components
VIDALIA=$(BUILT_DIR)/usr/local/bin/Vidalia.app/
TOR=$(COMPILED_BINS)/tor
POLIPO=$(COMPILED_BINS)/polipo
## Someday, this will be our custom Firefox
FIREFOX=$(FETCH_DIR)/Firefox.app
PIDGIN=$(COMPILED_BINS)/pidgin

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
DISTDIR=tbbosx-dist

## Version and name of the compressed bundle (also used for source)
VERSION=1.0.19-dev
DEFAULT_COMPRESSED_BASENAME=TorBrowser-$(VERSION)-osx-$(ARCH_TYPE)-
IM_COMPRESSED_BASENAME=TorBrowser-IM-$(VERSION)-
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
MOZILLA_LANGUAGE=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/$(FIREFOX_VER)/mac/xpi

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

#bundle: bundle_en-US
bundle: bundle_en-US

all-bundles-both:
	USE_PIDGIN=1 make -f osx.mk all-bundles
	make -f osx.mk clean
	USE_PIDGIN=0 make -f osx.mk all-bundles
	make -f osx.mk clean
	USE_SANDBOX=1 make -f osx.mk all-bundles
	make -f osx.mk clean
	USE_SANDBOX=0 make -f osx.mk all-bundles
	make -f osx.mk clean

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
	rm -fr $(DISTDIR)
	rm -fr *.app
	rm -fr $(DEST) *.stamp
	rm -f *~
	rm -fr *.xpi *.jar *.zip
	rm -fr $(NAME)_*
	cd ../src/RelativeLink/ && $(MAKE) clean

##
## Generate a non-localized bundle and put in $(DEST)
##

## Install binaries, documentation, FirefoxPortable, PidginPortable, and launcher into $(DEST)
generic-bundle.stamp:
	make -f osx.mk generic-bundle
generic-bundle: directory-structure install-binaries install-docs install-firefox install-pidgin configure-apps launcher strip-it-stripper
	touch generic-bundle.stamp

APPDIR=$(DEST)/Contents/MacOS
#LIBSDIR=$(DEST)/Contents/Frameworks
DOCSDIR=$(DEST)/Contents/Resources/Docs
DATADIR=$(DEST)/Contents/Resources/Data
TB_TMPDIR=$(DEST)/Contents/SharedSupport

## Build directory structure
directory-structure: 
	rm -fr $(DEST)
	mkdir -p $(APPDIR)
	mkdir -p $(APPDIR)/Firefox.app/Contents/MacOS/Data/profile
	mkdir -p $(APPDIR)/Firefox.app/Contents/MacOS/Data/plugins
	#mkdir -p $(LIBSDIR)
	mkdir -p $(DATADIR)/Tor
	mkdir -p $(DATADIR)/Vidalia
	mkdir -p $(DATADIR)/Polipo
	mkdir -p $(DOCSDIR)
	mkdir -p $(TB_TMPDIR)

## Package up all the Vidalia and Tor pre-requisites
## Firefox and Pidgin are installed in their own targets
install-binaries: 
	# zlib
	#cp -R $(ZLIB)/libz.1.2.3.dylib $(ZLIB)/libz.1.dylib $(ZLIB)/libz.dylib $(LIBSDIR)
	# Libevent
	#cp -R $(LIBEVENT)/libevent.a  $(LIBEVENT)/libevent_core.a $(LIBEVENT)/libevent_extra.a \
	#   $(LIBEVENT)/libevent.la $(LIBEVENT)/libevent_core.la $(LIBEVENT)/libevent_extra.la $(LIBSDIR)
	# OpenSSL
	#cp -R $(OPENSSL)/libcrypto.dylib $(OPENSSL)/libcrypto.0.9.8.dylib $(OPENSSL)/libssl.dylib \
	#   $(OPENSSL)/libssl.0.9.8.dylib $(LIBSDIR)
	#cp -R $(OPENSSL)/libcrypto* $(OPENSSL)/libssl* $(LIBSDIR)
	# Vidalia
	cp -R $(VIDALIA) $(APPDIR)/Vidalia.app
	# Polipo
	cp $(POLIPO) $(APPDIR)
	# Tor (perhaps we want tor-resolve too?)
	cp $(TOR) $(APPDIR)

## Fixup
## Collect up license files
install-docs:
	mkdir -p $(DOCSDIR)/Vidalia
	mkdir -p $(DOCSDIR)/Tor
	mkdir -p $(DOCSDIR)/Qt
	mkdir -p $(DOCSDIR)/Polipo
	cp $(VIDALIA_DIR)/LICENSE* $(VIDALIA_DIR)/CREDITS $(DOCSDIR)/Vidalia
	cp $(TOR_DIR)/LICENSE $(TOR_DIR)/README $(DOCSDIR)/Tor
	cp $(QT_DIR)/LICENSE.GPL* $(QT_DIR)/LICENSE.LGPL $(DOCSDIR)/Qt
	cp $(POLIPO_DIR)/COPYING  $(POLIPO_DIR)/README $(DOCSDIR)/Polipo
	cp ../LICENSE $(DEST)
	cp ../README.OSX $(DEST)/README-TorBrowserBundle

## Copy over Firefox
install-firefox:
	cp -R $(FIREFOX) $(APPDIR)
	# Due to various issues with a broken libxml2, we'll remove these...
	#rm -f $(APPDIR)/Firefox/components/libnkgnomevfs.so
	#rm -f $(APPDIR)/Firefox/components/libmozgnome.so

## Copy over Pidgin
install-pidgin:
ifeq ($(USE_PIDGIN),1)
	cp -R $(PIDGIN) $(APPDIR)
endif

## Configure Firefox, Vidalia, Polipo and Tor
configure-apps:
	## Configure Firefox preferences
	#mkdir -p $(DEST)/.mozilla/Firefox/firefox.default
	cp -R $(CONFIG_SRC)/firefox-profiles.ini $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profiles.ini
	cp $(CONFIG_SRC)/bookmarks.html $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profile
	cp $(CONFIG_SRC)/prefs.js $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profile/prefs.js
	cp $(CONFIG_SRC)/Info.plist $(DEST)/Contents
	cp $(CONFIG_SRC)/PkgInfo $(DEST)/Contents
	cp $(CONFIG_SRC)/qt.conf $(DEST)/Contents/Resources
	cp $(CONFIG_SRC)/vidalia.icns $(DEST)/Contents/Resources
	## Configure Pidgin
ifeq ($(USE_PIDGIN),1)
	mkdir -p $(DEST)/PidginPortable/Data/settings/.purple
	cp $(CONFIG_SRC)/prefs.xml $(DEST)/PidginPortable/Data/settings/.purple
endif
	## Configure Vidalia
	mkdir -p $(DEST)/Library/Vidalia
ifeq ($(USE_SANDBOX),1)
	cp $(CONFIG_SRC)/vidalia.conf.ff-osx-sandbox $(DEST)/Library/Vidalia/vidalia.conf
else
	cp $(CONFIG_SRC)/vidalia.conf.ff-osx $(DEST)/Library/Vidalia/vidalia.conf
endif
	## Configure Polipo
	cp $(CONFIG_SRC)/polipo.conf $(DEST)/Contents/Resources/Data/Polipo/polipo.conf
	## Configure Tor
	#cp $(CONFIG_SRC)/torrc-osx $(DEST)/Contents/Resources/Data/Tor/torrc
	cp $(CONFIG_SRC)/torrc-osx $(DEST)/Library/Vidalia/torrc
	cp $(TOR_DIR)/src/config/geoip $(DEST)/Contents/Resources/Data/Tor/geoip
	chmod 700 $(DATADIR)/Tor

# We've replaced the custom C program with a shell script for now...
launcher:
	cp ../src/RelativeLink/RelativeLinkOSX.sh $(DEST)/Contents/MacOS/TorBrowserBundle
	chmod +x $(DEST)/Contents/MacOS/TorBrowserBundle

strip-it-stripper:
	strip $(APPDIR)/tor
	strip $(APPDIR)/polipo
	strip $(APPDIR)/Vidalia.app/Contents/MacOS/Vidalia
	#strip $(LIBSDIR)/*

##
## How to create required extensions
##

## Torbutton development version
torbutton.xpi:
	$(WGET) --no-check-certificate -O $@ $(TORBUTTON)

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

## English comes as default
#langpack_en-US.xpi:
#	touch $@

##
## Customize the bundle
##

bundle_%:
	LANGCODE=$* make -f osx.mk bundle-localized
compressed-bundle_%:
	LANGCODE=$* make -f osx.mk compressed-bundle-localized
bundle-localized_%.stamp:
	make -f osx.mk copy-files_$* install-extensions install-betterprivacy install-httpseverywhere install-noscript install-lang-extensions patch-vidalia-language patch-firefox-language patch-pidgin-language update-extension-pref final
	touch bundle-localized_$*.stamp

bundle-localized: bundle-localized_$(LANGCODE).stamp

compressed-bundle-localized: bundle-localized_$(LANGCODE).stamp
	-rm -f $(DISTDIR)/$(COMPRESSED_NAME)_$(LANGCODE).zip
	-mkdir $(DISTDIR)
	#hdiutil create -volname "Tor Browser Bundle for OS X" -format UDBZ -imagekey zlib-level=9 -srcfolder $(DISTDIR)/tmp/ $(DISTDIR)/$(DEFAULT_COMPRESSED_BASENAME)$(LANGCODE).dmg
	zip -r $(DISTDIR)/$(DEFAULT_COMPRESSED_BASENAME)$(LANGCODE).zip $(NAME)_$(LANGCODE).app
	rm *.zip *.xpi

copy-files_%: generic-bundle.stamp
	rm -fr $(NAME)_$*
	#mkdir $(NAME)_$*
	cp -r $(DEST) $(NAME)_$*

BUNDLE=$(NAME)_$(LANGCODE)
DUMMYPROFILE=$(BUNDLE)/Library

## This is a little overcomplicated, but I'm keeping it here in case there are
## extensions we want to use in the future
install-extensions: $(DEFAULT_EXTENSIONS)
	for extension in torbutton.xpi; \
		do \
			cp $$extension $$extension.zip; \
			ext_id=$$(unzip -p $$extension.zip install.rdf | sed -n '/<em:id>/{s#[^<]*<em:id>\(.*\)</em:id>#\1#p;q;}'); \
			mkdir -p $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/$$ext_id; \
			cp $$extension $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/$$ext_id/$$extension.zip; \
			(cd $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/$$ext_id/ && unzip *.zip && rm *.zip); \
		done

## Language extensions need to be handled differently from other extensions
install-lang-extensions: $(filter-out langpack_en-US.xpi,langpack_$(LANGCODE).xpi)
ifneq ($(LANGCODE), en-US)
	mkdir -p $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/langpack-$(LANGCODE)@firefox.mozilla.org
	cp langpack_$(LANGCODE).xpi $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/langpack-$(LANGCODE)@firefox.mozilla.org/langpack_$(LANGCODE).zip
	(cd $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/langpack-$(LANGCODE)@firefox.mozilla.org && unzip *.zip && rm *.zip)
endif

install-betterprivacy: betterprivacy.xpi
	mkdir -p $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\}
	cp betterprivacy.xpi $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\}/betterprivacy.zip
	(cd $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\} && unzip *.zip && rm *.zip)
	
install-httpseverywhere: httpseverywhere.xpi
	mkdir -p $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/https-everywhere@eff.org
	cp httpseverywhere.xpi $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/https-everywhere@eff.org/httpseverywhere.zip
	(cd $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/https-everywhere@eff.org && unzip *.zip && rm *.zip)
	
install-noscript: noscript.xpi
	mkdir -p $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/\{73a6fe31-595d-460b-a920-fcc0f8843232\}
	cp noscript.xpi $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/\{73a6fe31-595d-460b-a920-fcc0f8843232\}/noscript.zip
	(cd $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/\{73a6fe31-595d-460b-a920-fcc0f8843232\} && unzip *.zip && rm *.zip)

## Set the language for Vidalia
patch-vidalia-language:
	## Patch Vidalia
	./patch-vidalia-language.sh $(BUNDLE)/Library/Vidalia/vidalia.conf $(LANGCODE) -e

## Set the language for Pidgin
patch-pidgin-language:
	## Patch Pidgin
ifeq ($(USE_PIDGIN),1)
	./patch-pidgin-language.sh $(BUNDLE)/PidginPortable/Data/settings/PidginPortableSettings.ini $(LANGCODE) \
                                   $(BUNDLE)/PidginPortable/App/Pidgin/locale \
                                   $(BUNDLE)/PidginPortable/App/GTK/share/locale
endif

patch-firefox-language:
	## Patch the default Firefox prefs.js
	## Don't use {} because they aren't always interpreted correctly. Thanks, sh. 
	cp $(CONFIG_SRC)/prefs.js $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/prefs.js
	cp $(CONFIG_SRC)/bookmarks.html $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile
	./patch-firefox-language.sh $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/prefs.js $(LANGCODE) -e

## Fix prefs.js since extensions.checkCompatibility, false doesn't work
update-extension-pref:
	ext_ver=$$(sed -n '/em:version/{s,.*="\(.*\)".*,\1,p;q;}' $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/langpack-$(LANGCODE)@firefox.mozilla.org/install.rdf); \
	sed -i -e "s/SHPONKA/langpack-$(LANGCODE)@firefox.mozilla.org:$$ext_ver/g" $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/prefs.js

final: 
	mv $(BUNDLE) $(BUNDLE).app
