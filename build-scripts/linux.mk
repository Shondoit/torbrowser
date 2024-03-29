###
### Makefile for building Tor USB bundle on Gnu/Linux
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### Copyright 2009 Jacob Appelbaum <jacob@appelbaum.net>
### Copyright 2010 Erinn Clark <erinn@torproject.org>
###
###
### See LICENSE for licensing information
###

#####################
### Configuration ###
#####################

## Architecture
ARCH_TYPE=$(shell uname -m)
BUILD_NUM=10
PLATFORM=Linux

## Build machine specific settings
# Number of cpu cores used to build in parallel
NUM_CORES=2

## Location of directory for source downloading
FETCH_DIR=/srv/build-trees/build-alpha
## Location of directory for source unpacking/building
BUILD_DIR=$(FETCH_DIR)/$(ARCH_TYPE)
## Location of directory for prefix/destdir/compiles/etc
BUILT_DIR=$(BUILD_DIR)/built
TBB_FINAL=$(BUILT_DIR)/TBBL

## Include versions (must happen after variable definitions above
include $(PWD)/versions.mk

ZLIB_OPTS=--shared --prefix=$(BUILT_DIR)
build-zlib: $(ZLIB_DIR)
	cd $(ZLIB_DIR) && ./configure $(ZLIB_OPTS)
	cd $(ZLIB_DIR) && make -j $(NUM_CORES)
	cd $(ZLIB_DIR) && make install
	touch $(STAMP_DIR)/build-zlib

LIBPNG_OPTS=--prefix=$(BUILT_DIR)
build-libpng: $(LIBPNG_DIR)
	cd $(LIBPNG_DIR) && ./configure $(LIBPNG_OPTS)
	cd $(LIBPNG_DIR) && make
	cd $(LIBPNG_DIR) && make install
	touch $(STAMP_DIR)/build-libpng

OPENSSL_OPTS=-no-idea -no-rc5 -no-md2 shared zlib --prefix=$(BUILT_DIR) --openssldir=$(BUILT_DIR) -I$(BUILT_DIR)/include -L$(BUILT_DIR)/lib
build-openssl: build-zlib $(OPENSSL_DIR)
	cd $(OPENSSL_DIR) && ./config $(OPENSSL_OPTS)
	cd $(OPENSSL_DIR) && make depend
	cd $(OPENSSL_DIR) && make
	cd $(OPENSSL_DIR) && make install_sw
	touch $(STAMP_DIR)/build-openssl

QT_BUILD_PREFS=-system-zlib -confirm-license -opensource -openssl-linked -no-webkit -no-qt3support -fast -release -nomake demos -nomake examples
QT_OPTS=$(QT_BUILD_PREFS) -prefix $(BUILT_DIR) -I $(BUILT_DIR)/include -I $(BUILT_DIR)/include/openssl/ -L$(BUILT_DIR)/lib
build-qt: build-zlib build-openssl $(QT_DIR)
	cd $(QT_DIR) && ./configure $(QT_OPTS)
	cd $(QT_DIR) && make -j $(NUM_CORES)
	cd $(QT_DIR) && make install
	touch $(STAMP_DIR)/build-qt

VIDALIA_OPTS=-DOPENSSL_LIBCRYPTO=$(BUILT_DIR)/lib/libcrypto.so.1.0.0 -DOPENSSL_LIBSSL=$(BUILT_DIR)/lib/libssl.so.1.0.0 -DCMAKE_BUILD_TYPE=debug -DQT_QMAKE_EXECUTABLE=$(BUILT_DIR)/bin/qmake ..
build-vidalia: build-openssl build-qt $(VIDALIA_DIR)
	-mkdir $(VIDALIA_DIR)/build
	cd $(VIDALIA_DIR)/build && cmake $(VIDALIA_OPTS) && make -j $(NUM_CORES)
	cd $(VIDALIA_DIR)/build && DESTDIR=$(BUILT_DIR) make install
	touch $(STAMP_DIR)/build-vidalia

LIBEVENT_OPTS=--prefix=$(BUILT_DIR)
build-libevent: build-zlib build-openssl $(LIBEVENT_DIR)
	cd $(LIBEVENT_DIR) && ./configure $(LIBEVENT_OPTS)
	cd $(LIBEVENT_DIR) && make -j $(NUM_CORES)
	cd $(LIBEVENT_DIR) && make install
	touch $(STAMP_DIR)/build-libevent

TOR_OPTS=--with-openssl-dir=$(BUILT_DIR) --with-zlib-dir=$(BUILT_DIR) --with-libevent-dir=$(BUILT_DIR)/lib --prefix=$(BUILT_DIR)

build-pidgin:
	echo "We're not building pidgin yet!"

build-firefox: config/dot_mozconfig $(FIREFOX_DIR)
	cp config/dot_mozconfig $(FIREFOX_DIR)/mozconfig
	cp branding/* $(FIREFOX_DIR)/browser/branding/official
	cd $(FIREFOX_DIR) && make -f client.mk build
	touch $(STAMP_DIR)/build-firefox

copy-firefox:
	-rm -rf $(BUILD_DIR)/Firefox
	## This is so ugly. Update it to use cool tar --transform soon.
	cd $(FIREFOX_DIR) && make -C obj-$(ARCH_TYPE)-*/ package
	cp $(FIREFOX_DIR)/obj-$(ARCH_TYPE)-*/dist/*bz2 $(BUILD_DIR)
	cd $(BUILD_DIR) && tar -xvjf firefox-$(FIREFOX_VER).en-US.linux-$(ARCH_TYPE).tar.bz2 && mv firefox Firefox

build-all-binaries: source-dance build-zlib build-openssl build-libpng build-qt build-vidalia build-libevent build-tor build-firefox
	echo "If we're here, we've done something right."

## Location of compiled libraries
COMPILED_LIBS=$(BUILT_DIR)/lib
## Location of compiled binaries
COMPILED_BINS=$(BUILT_DIR)/bin/

## Location of the libraries we've built
LIBEVENT=$(COMPILED_LIBS)
LIBPNG=$(COMPILED_LIBS)
OPENSSL=$(COMPILED_LIBS)
QT=$(COMPILED_LIBS)
ZLIB=$(COMPILED_LIBS)

## Location of binary bundle components
TOR=$(COMPILED_BINS)/tor
VIDALIA=$(BUILT_DIR)/usr/local/bin/vidalia
## Someday, this will be our custom Firefox
FIREFOX=$(BUILD_DIR)/Firefox
PIDGIN=$(COMPILED_BINS)/pidgin

## Location of utility applications
WGET:=$(shell which wget)

## Destination for the generic bundle
DEST=generic-bundle

## Name of the bundle
NAME=tor-browser

## Where shall we put the finished files for distribution?
DISTDIR=tbbl-alpha-dist

## Version and name of the compressed bundle (also used for source)
VERSION=$(RELEASE_VER)-$(BUILD_NUM)-dev
DEFAULT_COMPRESSED_BASENAME=tor-browser-gnu-linux-$(ARCH_TYPE)-$(VERSION)-
IM_COMPRESSED_BASENAME=tor-im-browser-gnu-linux-$(VERSION)-
DEFAULT_COMPRESSED_NAME=$(DEFAULT_COMPRESSED_BASENAME)$(VERSION)
IM_COMPRESSED_NAME=$(IM_COMPRESSED_BASENAME)$(VERSION)

ifeq ($(USE_PIDGIN),1)
COMPRESSED_NAME=$(IM_COMPRESSED_NAME)
else
COMPRESSED_NAME=$(DEFAULT_COMPRESSED_NAME)
endif

## Extensions to install by default
DEFAULT_EXTENSIONS=torbutton.xpi noscript.xpi httpseverywhere.xpi

## Where to download Mozilla language packs
MOZILLA_LANGUAGE=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/$(FIREFOX_VER)/linux-i686/xpi

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
	USE_PIDGIN=1 make -f linux.mk all-bundles
	make -f linux.mk clean
	USE_PIDGIN=0 make -f linux.mk all-bundles
	make -f linux.mk clean

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
	rm -fr *.tar.gz
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
	make -f linux.mk generic-bundle
generic-bundle: directory-structure \
		install-binaries \
		install-docs \
		install-firefox \
		install-pidgin \
		configure-apps \
		launcher \
		strip-it-stripper \
		remove-bundle-shared-lib-symlinks
	touch $(STAMP_DIR)/generic-bundle.stamp

APPDIR=$(DEST)/App
LIBSDIR=$(DEST)/Lib
DOCSDIR=$(DEST)/Docs
DATADIR=$(DEST)/Data
TB_TMPDIR=$(DEST)/tmp

## Build directory structure
directory-structure: 
	rm -fr $(DEST)
	mkdir -p $(APPDIR)
	mkdir -p $(LIBSDIR)
	mkdir -p $(LIBSDIR)/libz
	mkdir -p $(DATADIR)/Tor
	mkdir -p $(DATADIR)/Vidalia
	mkdir -p $(DATADIR)/profile
	mkdir -p $(DOCSDIR)
	mkdir -p $(TB_TMPDIR)

## Package up all the Vidalia and Tor pre-requisites
## Firefox and Pidgin are installed in their own targets
install-binaries:
	# A minimal set of Qt libs and the proper symlinks
	cp -d $(QT)/libQtCore.so* $(LIBSDIR)
	cp -d $(QT)/libQtGui.so* $(LIBSDIR)
	cp -d $(QT)/libQtNetwork.so* $(LIBSDIR)
	cp -d $(QT)/libQtXml.so* $(LIBSDIR)
	# zlib
	cp -d $(ZLIB)/libz.so $(ZLIB)/libz.so.1 $(ZLIB)/libz.so.1.2.6 $(LIBSDIR)/libz
	# Libevent
	cp -d $(LIBEVENT)/libevent-2.0.so.5 $(LIBEVENT)/libevent-2.0.so.5.1.5 $(LIBEVENT)/libevent_core.so \
	   $(LIBEVENT)/libevent_core-2.0.so.5 $(LIBEVENT)/libevent_core-2.0.so.5.1.5 \
	   $(LIBEVENT)/libevent_extra-2.0.so.5 $(LIBEVENT)/libevent_extra-2.0.so.5.1.5 \
	   $(LIBEVENT)/libevent_extra.so $(LIBEVENT)/libevent.so $(LIBSDIR)
	# libpng
	cp -d $(LIBPNG)/libpng15.so* $(LIBSDIR)
	# OpenSSL
	cp -d $(OPENSSL)/libssl.so* $(OPENSSL)/libcrypto.so* $(LIBSDIR)
	chmod 644 $(LIBSDIR)/libssl.so*
	chmod 644 $(LIBSDIR)/libcrypto.so*
	# Vidalia
	cp $(VIDALIA) $(APPDIR)
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
	cp ../changelog.linux-2.2 $(DOCSDIR)/changelog
	# This should be updated to be more generic (version-wise) and more Linux specific
	cp ../README.LINUX-2.2 $(DOCSDIR)/README-TorBrowserBundle

## Copy over Firefox
install-firefox:
	cp -R $(FIREFOX) $(APPDIR)
	# Due to various issues with a broken libxml2, we'll remove these...
	rm -f $(APPDIR)/Firefox/components/libnkgnomevfs.so
	rm -f $(APPDIR)/Firefox/components/libmozgnome.so

## Copy over Pidgin
install-pidgin:
ifeq ($(USE_PIDGIN),1)
	cp -R $(PIDGIN) $(APPDIR)
endif

## Configure Firefox, Vidalia, and Tor
configure-apps:
	## Configure Firefox preferences
	mkdir -p $(DEST)/Data/profile/extensions
	cp -R config/firefox-profiles.ini $(DEST)/Data/profiles.ini
	cp config/bookmarks.html $(DEST)/Data/profile
	cp config/prefs.js $(DEST)/Data/profile/prefs.js
	## Configure Pidgin
ifeq ($(USE_PIDGIN),1)
	mkdir -p $(DEST)/PidginPortable/Data/settings/.purple
	cp config/prefs.xml $(DEST)/PidginPortable/Data/settings/.purple
endif
	## Configure Vidalia
ifeq ($(USE_PIDGIN),1)
	cp config/vidalia.conf.ff+pidgin-linux $(DEST)/Data/Vidalia/vidalia.conf
else
	cp config/vidalia.conf.ff-linux $(DEST)/Data/Vidalia/vidalia.conf
endif
	## Configure Tor
	cp config/torrc-linux $(DEST)/Data/Tor/torrc
	cp $(TOR_DIR)/src/config/geoip $(DEST)/Data/Tor/geoip
	chmod 700 $(DEST)/Data/Tor

# We've replaced the custom C program with a shell script for now...
launcher:
	cp ../src/RelativeLink/RelativeLink.sh $(DEST)/start-tor-browser
	chmod +x $(DEST)/start-tor-browser

strip-it-stripper:
	strip $(APPDIR)/tor
	strip $(APPDIR)/vidalia
	strip $(LIBSDIR)/*.so*
	strip $(LIBSDIR)/libz/*.so*

remove-bundle-shared-lib-symlinks:
	./remove-shared-lib-symlinks $(LIBSDIR)
	./remove-shared-lib-symlinks $(LIBSDIR)/libz

##
## Customize the bundle
##

bundle_%:
	LANGCODE=$* make -f linux.mk bundle-localized
compressed-bundle_%:
	LANGCODE=$* make -f linux.mk compressed-bundle-localized

bundle-localized_%.stamp:
	make -f linux.mk copy-files_$* install-extensions install-lang-extensions patch-vidalia-language patch-firefox-language \
	patch-pidgin-language update-extension-pref write-tbb-version
	touch $(STAMP_DIR)/bundle-localized_$*.stamp

bundle-localized: bundle-localized_$(LANGCODE).stamp

compressed-bundle-localized: bundle-localized_$(LANGCODE).stamp
	-rm -f $(DISTDIR)/$(COMPRESSED_NAME)_$(LANGCODE).tar.gz
	-mkdir $(DISTDIR)
	tar -cvf - $(NAME)_$(LANGCODE) |tardy -unu 0 -una root -gnu 0 -gna wheel |gzip -c9 >$(DISTDIR)/$(DEFAULT_COMPRESSED_BASENAME)$(LANGCODE).tar.gz
	rm *.zip *.xpi

copy-files_%: generic-bundle.stamp
	rm -fr $(NAME)_$*
	#mkdir $(NAME)_$*
	cp -r $(DEST) $(NAME)_$*

BUNDLE=$(NAME)_$(LANGCODE)
DUMMYPROFILE=$(BUNDLE)/.mozilla/

## This is a little overcomplicated, but I'm keeping it here in case there are
## extensions we want to use in the future
install-extensions: $(DEFAULT_EXTENSIONS)
	for extension in *.xpi; \
		do \
			cp $$extension $$extension.zip; \
			ext_id=$$(unzip -p $$extension.zip install.rdf | sed -n '/<em:id>/{s#[^<]*<em:id>\(.*\)</em:id>#\1#p;q}'); \
			mkdir -p $(BUNDLE)/Data/profile/extensions/$$ext_id; \
			cp $$extension $(BUNDLE)/Data/profile/extensions/$$ext_id/$$extension.zip; \
			(cd $(BUNDLE)/Data/profile/extensions/$$ext_id/ && unzip *.zip && rm *.zip); \
		done

## Language extensions need to be handled differently from other extensions
install-lang-extensions: $(filter-out langpack_en-US.xpi,langpack_$(LANGCODE).xpi)
ifneq ($(LANGCODE), en-US)
	mkdir -p $(BUNDLE)/Data/profile/extensions
	cp langpack_$(LANGCODE).xpi $(BUNDLE)/Data/profile/extensions/langpack-$(LANGCODE)@firefox.mozilla.org.xpi
endif

## Set the language for Vidalia
patch-vidalia-language:
	## Patch Vidalia
	./patch-vidalia-language.sh $(BUNDLE)/Data/Vidalia/vidalia.conf $(LANGCODE) -e

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
	mkdir -p $(BUNDLE)/App/Firefox/defaults/profile/
	cp config/bookmarks.html $(BUNDLE)/App/Firefox/defaults/profile/
	cp config/prefs.js $(BUNDLE)/App/Firefox/defaults/profile/prefs.js
	cp config/bookmarks.html $(BUNDLE)/Data/profile
	cp config/prefs.js $(BUNDLE)/Data/profile/prefs.js
	./patch-firefox-language.sh $(BUNDLE)/App/Firefox/defaults/profile/prefs.js $(LANGCODE) -e
	./patch-firefox-language.sh $(BUNDLE)/Data/profile/prefs.js $(LANGCODE) -e

## Fix prefs.js since extensions.checkCompatibility, false doesn't work
update-extension-pref:
	sed -i -e "s/SHPONKA/$(LANGCODE)/g" $(BUNDLE)/Data/profile/prefs.js
	sed -i -e "s/SHPONKA/$(LANGCODE)/g" $(BUNDLE)/App/Firefox/defaults/profile/prefs.js

print-version:
	@echo $(RELEASE_VER)-$(BUILD_NUM)

write-tbb-version:
	printf 'user_pref("torbrowser.version", "%s");\n' "$(RELEASE_VER)-$(BUILD_NUM)-$(PLATFORM)-$(ARCH_TYPE)" >> $(BUNDLE)/App/Firefox/defaults/profile/prefs.js
	printf 'user_pref("torbrowser.version", "%s");\n' "$(RELEASE_VER)-$(BUILD_NUM)-$(PLATFORM)-$(ARCH_TYPE)" >> $(BUNDLE)/Data/profile/prefs.js

