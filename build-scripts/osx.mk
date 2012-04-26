###
### Makefile for building Tor USB bundle on Mac OS X
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


## Architecture
ARCH_TYPE=i386
BUILD_NUM=8
PLATFORM=MacOS

## Set OSX-specific backwards compatibility options
OSX_VERSION=10.5
CC=
# These can probably be left alone for OSX_VERSION 10.5 and up
SDK_PATH=/Developer/SDKs/MacOSX10.6.sdk
SDK=-sdk $(SDK_PATH)
MIN_VERSION=-mmacosx-version-min=$(OSX_VERSION)
CF_MIN_VERSION=-isysroot $(SDK_PATH)
LD_MIN_VERSION=-Wl,-syslibroot,$(SDK_PATH)
BACKWARDS_COMPAT=$(MIN_VERSION) $(CF_MIN_VERSION) $(LD_MIN_VERSION)

## Build machine specific settings
# Number of cpu cores used to build in parallel
NUM_CORES=4

## Location of directory for source fetching
FETCH_DIR=$(PWD)/build
## Location of directory for source unpacking/building
BUILD_DIR=$(FETCH_DIR)/$(ARCH_TYPE)
## Location of directory for prefix/destdir/compiles/etc
BUILT_DIR=$(BUILD_DIR)/built
TBB_FINAL=$(BUILT_DIR)/tbbosx-dist

## Include versions (must happen after variable definitions above
include $(PWD)/versions.mk

ZLIB_OPTS=--prefix=$(BUILT_DIR)
ZLIB_CFLAGS="-arch $(ARCH_TYPE)"
build-zlib: $(ZLIB_DIR)
	cd $(ZLIB_DIR) && CFLAGS=$(ZLIB_CFLAGS) ./configure $(ZLIB_OPTS)
	cd $(ZLIB_DIR) && make -j $(NUM_CORES)
	cd $(ZLIB_DIR) && make install
	touch $(STAMP_DIR)/build-zlib

OPENSSL_OPTS=-no-rc5 -no-md2 -no-man shared zlib $(BACKWARDS_COMPAT) --prefix=$(BUILT_DIR) --openssldir=$(BUILT_DIR) -L$(BUILT_DIR)/lib -I$(BUILT_DIR)/include
build-openssl: build-zlib $(OPENSSL_DIR)
ifeq (x86_64,$(ARCH_TYPE))
	cd $(OPENSSL_DIR) && ./Configure darwin64-x86_64-cc $(OPENSSL_OPTS)
else
	cd $(OPENSSL_DIR) && ./Configure darwin-i386-cc $(OPENSSL_OPTS)
endif
	cd $(OPENSSL_DIR) && make depend
# Do not use -j for the following make call, random build errors might happen.
	cd $(OPENSSL_DIR) && make
	cd $(OPENSSL_DIR) && make install_sw
	touch $(STAMP_DIR)/build-openssl


QT_BUILD_PREFS=-system-zlib -confirm-license -opensource -openssl-linked -no-qt3support \
	-fast -release -no-webkit -no-framework -nomake demos -nomake examples $(SDK) -arch $(ARCH_TYPE)
QT_OPTS=$(QT_BUILD_PREFS) -prefix $(BUILT_DIR) -I $(BUILT_DIR)/include -I $(BUILT_DIR)/include/openssl/ -L $(BUILT_DIR)/lib
build-qt: build-zlib build-openssl $(QT_DIR)
	cd $(QT_DIR) && ./configure $(QT_OPTS)
	cd $(QT_DIR) && make -j $(NUM_CORES)
	cd $(QT_DIR) && make install
	touch $(STAMP_DIR)/build-qt

VIDALIA_OPTS=-DCMAKE_OSX_ARCHITECTURES=$(ARCH_TYPE) -DQT_QMAKE_EXECUTABLE=$(BUILT_DIR)/bin/qmake \
	-DCMAKE_BUILD_TYPE=debug ..
build-vidalia: build-openssl build-qt $(VIDALIA_DIR)
	-mkdir $(VIDALIA_DIR)/build
	cd $(VIDALIA_DIR)/build && \
	MACOSX_DEPLOYMENT_TARGET=$(OSX_VERSION) cmake $(VIDALIA_OPTS) \
	&& make -j $(NUM_CORES) && make dist-osx-libraries
	cd $(VIDALIA_DIR)/build && DESTDIR=$(BUILT_DIR) make install
	cp -r $(QT_DIR)/src/gui/mac/qt_menu.nib $(VIDALIA)/Contents/Resources/
	touch $(STAMP_DIR)/build-vidalia

LIBEVENT_CFLAGS="-arch $(ARCH_TYPE) $(MIN_VERSION) $(CF_MIN_VERSION) -arch $(ARCH_TYPE)"
LIBEVENT_LDFLAGS="-L$(BUILT_DIR)/lib $(LD_MIN_VERSION)"
LIBEVENT_OPTS=--prefix=$(BUILT_DIR) --enable-static --disable-shared --disable-dependency-tracking $(CC)
build-libevent: build-zlib build-openssl $(LIBEVENT_DIR)
	cd $(LIBEVENT_DIR) && CFLAGS=$(LIBEVENT_CFLAGS) LDFLAGS=$(LIBEVENT_LDFLAGS) ./configure $(LIBEVENT_OPTS)
	cd $(LIBEVENT_DIR) && make -j $(NUM_CORES)
	cd $(LIBEVENT_DIR) && make install
	touch $(STAMP_DIR)/build-libevent

TOR_CFLAGS="-arch $(ARCH_TYPE) -I$(BUILT_DIR)/include $(MIN_VERSION) $(CF_MIN_VERSION)"
TOR_LDFLAGS="-L$(BUILT_DIR)/lib $(LD_MIN_VERSION)"
TOR_OPTS=--enable-gcc-warnings-advisory --enable-static-openssl --enable-static-libevent --with-openssl-dir=$(BUILT_DIR)/lib --with-libevent-dir=$(BUILT_DIR)/lib --prefix=$(BUILT_DIR) --disable-dependency-tracking $(CC)

build-firefox: $(FIREFOX_DIR) config/mozconfig-osx-$(ARCH_TYPE)
	cp config/mozconfig-osx-$(ARCH_TYPE) $(FIREFOX_DIR)/mozconfig
	cp branding/* $(FIREFOX_DIR)/browser/branding/official
	cd $(FIREFOX_DIR) && make -f client.mk build
	touch $(STAMP_DIR)/build-firefox

copy-firefox:
	-rm -rf $(BUILD_DIR)/Firefox.app
	cp -r $(FIREFOX_DIR)/obj*/dist/*.app $(BUILD_DIR)/Firefox.app

build-all-binaries: build-zlib build-openssl build-vidalia build-libevent build-tor build-firefox
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
## Someday, this will be our custom Firefox
FIREFOX=$(BUILD_DIR)/Firefox.app
PIDGIN=$(COMPILED_BINS)/pidgin

## Location of utility applications
WGET:=$(shell which wget)

## Destination for the generic bundle
DEST=generic-bundle

## Name of the bundle
NAME=TorBrowser

## Where shall we put the finished files for distribution?
DISTDIR=tbbosx-dist

## Version and name of the compressed bundle (also used for source)
VERSION=$(RELEASE_VER)-$(BUILD_NUM)
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

## Where to download Mozilla language packs
MOZILLA_LANGUAGE=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/latest/mac/xpi

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
	rm -fr *.app
	rm -fr $(DEST) *.stamp
	rm -f *~
	rm -fr *.xpi *.jar *.zip
	rm -fr $(NAME)_*
	rm -f $(STAMP_DIR)/*.stamp
	cd ../src/RelativeLink/ && $(MAKE) clean

##
## Generate a non-localized bundle and put in $(DEST)
##

## Install binaries, documentation, FirefoxPortable, PidginPortable, and launcher into $(DEST)
generic-bundle.stamp:
	make -f osx.mk generic-bundle
generic-bundle: directory-structure install-binaries install-docs install-firefox configure-apps launcher strip-it-stripper
	touch $(STAMP_DIR)/generic-bundle.stamp

APPDIR=$(DEST)/Contents/MacOS
DOCSDIR=$(DEST)/Contents/Resources/Docs
DATADIR=$(DEST)/Contents/Resources/Data
TB_TMPDIR=$(DEST)/Contents/SharedSupport

## Build directory structure
directory-structure: 
	rm -fr $(DEST)
	mkdir -p $(APPDIR)
	mkdir -p $(APPDIR)/Firefox.app/Contents/MacOS/Data/profile
	mkdir -p $(APPDIR)/Firefox.app/Contents/MacOS/Data/plugins
	mkdir -p $(DATADIR)/Tor
	mkdir -p $(DATADIR)/Vidalia
	mkdir -p $(DOCSDIR)
	mkdir -p $(TB_TMPDIR)

## Package up all the Vidalia and Tor pre-requisites
## Firefox and Pidgin are installed in their own targets
install-binaries:
	chmod 644 $(BUILT_DIR)/lib/libssl.*
	chmod 644 $(BUILT_DIR)/lib/libcrypto.*
	$(BUILT_DIR)/bin/macdeployqt $(VIDALIA) -no-plugins
	# Vidalia
	cp -R $(VIDALIA) $(APPDIR)/Vidalia.app
	cp $(TOR) $(APPDIR)

## Fixup
## Collect up license files
install-docs:
	mkdir -p $(DOCSDIR)/Vidalia
	mkdir -p $(DOCSDIR)/Tor
	mkdir -p $(DOCSDIR)/Qt
	cp $(VIDALIA_DIR)/LICENSE* $(VIDALIA_DIR)/CREDITS $(DOCSDIR)/Vidalia
	cp $(TOR_DIR)/LICENSE $(TOR_DIR)/README $(DOCSDIR)/Tor
	cp $(QT_DIR)/LICENSE.GPL* $(QT_DIR)/LICENSE.LGPL $(DOCSDIR)/Qt
	cp ../changelog.osx-2.2 $(DOCSDIR)/changelog
	cp ../LICENSE $(DEST)
	cp ../README.OSX-2.2 $(DEST)/README-TorBrowserBundle

## Copy over Firefox
install-firefox:
	cp -R $(FIREFOX) $(APPDIR)

## Configure Firefox, Vidalia, and Tor
configure-apps:
	## Configure Firefox preferences
	#mkdir -p $(DEST)/.mozilla/Firefox/firefox.default
	cp -R config/firefox-profiles.ini $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profiles.ini
	cp config/bookmarks.html $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profile
	cp config/prefs.js $(DEST)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profile/prefs.js
	cp config/Info.plist $(DEST)/Contents
	cp config/PkgInfo $(DEST)/Contents
	cp config/qt.conf $(DEST)/Contents/MacOS/Vidalia.app/Contents/Resources
	cp config/vidalia.icns $(DEST)/Contents/Resources

	## Configure Vidalia
	mkdir -p $(DEST)/Library/Vidalia
ifeq ($(USE_SANDBOX),1)
	cp config/vidalia.conf.ff-osx-sandbox $(DEST)/Library/Vidalia/vidalia.conf
else
	cp config/vidalia.conf.ff-osx $(DEST)/Library/Vidalia/vidalia.conf
endif

	## Configure Tor
	cp config/torrc-osx $(DEST)/Library/Vidalia/torrc
	cp $(TOR_DIR)/src/config/geoip $(DEST)/Contents/Resources/Data/Tor/geoip
	chmod 700 $(DATADIR)/Tor

# We've replaced the custom C program with a shell script for now...
launcher:
	cp ../src/RelativeLink/RelativeLinkOSX.sh $(DEST)/Contents/MacOS/TorBrowserBundle
	chmod +x $(DEST)/Contents/MacOS/TorBrowserBundle

strip-it-stripper:
	strip $(APPDIR)/tor
	strip $(APPDIR)/Vidalia.app/Contents/MacOS/Vidalia

##
## Customize the bundle
##

bundle_%:
	LANGCODE=$* make -f osx.mk bundle-localized
compressed-bundle_%:
	LANGCODE=$* make -f osx.mk compressed-bundle-localized
bundle-localized_%.stamp:
	make -f osx.mk copy-files_$* install-extensions install-httpseverywhere install-noscript install-lang-extensions patch-vidalia-language patch-firefox-language patch-pidgin-language update-extension-pref write-tbb-version final
	touch $(STAMP_DIR)/bundle-localized_$*.stamp

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
	mkdir -p $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/
	cp langpack_$(LANGCODE).xpi $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/extensions/langpack-$(LANGCODE)@firefox.mozilla.org.xpi
endif

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
	cp config/prefs.js $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/prefs.js
	cp config/bookmarks.html $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile
	./patch-firefox-language.sh $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/prefs.js $(LANGCODE) -e

## Fix prefs.js since extensions.checkCompatibility, false doesn't work
update-extension-pref:
	sed -i -e "s/SHPONKA/$(LANGCODE)/g" $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/prefs.js
	sed -i -e "s/SHPONKA/$(LANGCODE)/g" $(BUNDLE)/Contents/MacOS/Firefox.app/Contents/MacOS/Data/profile/prefs.js

print-version:
	@echo $(RELEASE_VER)-$(BUILD_NUM)

write-tbb-version:
	printf 'user_pref("torbrowser.version", "%s");\n' "$(RELEASE_VER)-$(BUILD_NUM)-$(PLATFORM)-$(ARCH_TYPE)" >> $(BUNDLE)/Library/Application\ Support/Firefox/Profiles/profile/prefs.js

final: 
	mv $(BUNDLE) $(BUNDLE).app
