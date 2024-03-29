###
### Makefile for building Tor USB bundle on Gnu/Linux
###
### Copyright 2007 Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
### Copyright 2009 Jacob Appelbaum <jacob@appelbaum.net>
### Copyright 2010 Erinn Clark <erinn@torproject.org>
###
### You want to do the following currently supported activities:
# This downloads and compiles everything
### make -f linux-alpha.mk build-all-binaries
# This makes a generic bundle
### make -f linux-alpha.mk generic-bundle
# This makes the English bundle
### make -f linux-alpha.mk bundle_en-US
# This makes the German bundle
### make -f linux-alpha.mk bundle_de
# This makes the German compressed bundle
### make -f linux-alpha.mk compressed-bundle_de
# It's possible you may also want to do:
### make -f linux-alpha.mk build-all-binaries
### make -f linux-alpha.mk all-compressed-bundles
### ...
### Look in tbbl-dist/ for your files.
###
### See LICENSE for licensing information
###
### $Id: Makefile 19973 2009-07-12 02:26:03Z phobos $
###

#####################
### Configuration ###
#####################

## Include versions
include $(PWD)/versions-alpha.mk

## Architecture
ARCH_TYPE=$(shell uname -m)
BUILD_NUM=2
PLATFORM=Linux

## Location of directory for source unpacking
FETCH_DIR=/srv/build-trees/build-alpha-$(ARCH_TYPE)
## Location of directory for prefix/destdir/compiles/etc
BUILT_DIR=$(FETCH_DIR)/built
TBB_FINAL=$(BUILT_DIR)/TBBL

source-dance: fetch-source unpack-source
	echo "We're ready for building now."

ZLIB_DIR=$(FETCH_DIR)/zlib-$(ZLIB_VER)
ZLIB_OPTS=--shared --prefix=$(BUILT_DIR)
build-zlib:
	cd $(ZLIB_DIR) && ./configure $(ZLIB_OPTS)
	cd $(ZLIB_DIR) && make
	cd $(ZLIB_DIR) && make install

OPENSSL_DIR=$(FETCH_DIR)/openssl-$(OPENSSL_VER)
OPENSSL_OPTS=-no-idea -no-rc5 -no-md2 shared zlib --prefix=$(BUILT_DIR) --openssldir=$(BUILT_DIR) -I$(BUILT_DIR)/include -L$(BUILT_DIR)/lib
build-openssl:
	cd $(OPENSSL_DIR) && ./config $(OPENSSL_OPTS)
	cd $(OPENSSL_DIR) && make depend
	cd $(OPENSSL_DIR) && make
	cd $(OPENSSL_DIR) && make install

QT_DIR=$(FETCH_DIR)/qt-everywhere-opensource-src-$(QT_VER)
QT_BUILD_PREFS=-system-zlib -confirm-license -opensource -openssl-linked -no-qt3support -fast -release -nomake demos -nomake examples
QT_OPTS=$(QT_BUILD_PREFS) -prefix $(BUILT_DIR) -I $(BUILT_DIR)/include -I $(BUILT_DIR)/include/openssl/ -L$(BUILT_DIR)/lib
build-qt:
	cd $(QT_DIR) && ./configure $(QT_OPTS)
	cd $(QT_DIR) && make
	cd $(QT_DIR) && make install

QTSCRIPT_DIR=$(FETCH_DIR)/qtscriptgenerator
QTSCRIPT_OPTS=
build-qtscript:
	cd $(QTSCRIPT_DIR)/generator && $(BUILT_DIR)/bin/qmake
	cd $(QTSCRIPT_DIR)/generator && make -j4
	cd $(QTSCRIPT_DIR)/generator && ./generator --include-paths=/usr/include/
	cp ../src/current-patches/qt/000* $(QTSCRIPT_DIR)/qtbindings/qtscript_uitools
	cp patch-any-src.sh $(QTSCRIPT_DIR)/qtbindings/qtscript_uitools
	cd $(QTSCRIPT_DIR)/qtbindings/qtscript_uitools && ./patch-any-src.sh
	cd $(QTSCRIPT_DIR)/generator && $(BUILT_DIR)/bin/qmake
	cd $(QTSCRIPT_DIR)/generator && make -j4
	cd $(QTSCRIPT_DIR)/qtbindings && $(BUILT_DIR)/bin/qmake -recursive CONFIG+="release" INCLUDEPATH+=/srv/build-trees/build-alpha-i686/built/include
build-qtfoo:
	cd $(QTSCRIPT_DIR)/qtbindings && for i in $(ls -d qtscript_*); do make -C $i release; done


VIDALIA_DIR=$(FETCH_DIR)/vidalia-$(VIDALIA_VER)
VIDALIA_OPTS=-DOPENSSL_LIBCRYPTO=$(BUILT_DIR)/lib/libcrypto.so.1.0.0 -DOPENSSL_LIBSSL=$(BUILT_DIR)/lib/libssl.so.1.0.0 -DQT_QMAKE_EXECUTABLE=$(BUILT_DIR)/bin/qmake -DSCRIPT_DIR=$(QTSCRIPT_DIR)/plugins/script -DTOR_SOURCE_DIR=$(TOR_DIR) ..
build-vidalia:
	-rm -rf $(VIDALIA_DIR)/build
	-mkdir $(VIDALIA_DIR)/build
	cd $(VIDALIA_DIR)/build && cmake $(VIDALIA_OPTS) && make
#	cd $(VIDALIA_DIR)/build && DESTDIR=$(BUILT_DIR) make install

LIBEVENT_DIR=$(FETCH_DIR)/libevent-$(LIBEVENT_VER)
LIBEVENT_OPTS=--prefix=$(BUILT_DIR)
build-libevent:
	cd $(LIBEVENT_DIR) && ./configure $(LIBEVENT_OPTS)
	cd $(LIBEVENT_DIR) && make -j2
	cd $(LIBEVENT_DIR) && make install

LIBPNG_DIR=$(FETCH_DIR)/libpng-$(LIBPNG_VER)
LIBPNG_OPTS=--prefix=$(BUILT_DIR)
build-libpng:
	cd $(LIBPNG_DIR) && ./configure $(LIBPNG_OPTS)
	cd $(LIBPNG_DIR) && make
	cd $(LIBPNG_DIR) && make install

TOR_DIR=$(FETCH_DIR)/tor-$(TOR_VER)
TOR_OPTS=--enable-gcc-warnings --with-openssl-dir=$(BUILT_DIR) --with-zlib-dir=$(BUILT_DIR) --with-libevent-dir=$(BUILT_DIR)/lib --prefix=$(BUILT_DIR)
build-tor:
	cd $(TOR_DIR) && ./configure $(TOR_OPTS)
	cd $(TOR_DIR) && make -j2
	#cd $(TOR_DIR) && make install

## Polipo doesn't use autoconf, so we just have to hack their Makefile
## This probably needs to be updated if Polipo ever updates their Makefile
POLIPO_DIR=$(FETCH_DIR)/polipo-$(POLIPO_VER)
POLIPO_MAKEFILE=$(CONFIG_SRC)/polipo-Makefile
build-polipo:
	cp $(POLIPO_MAKEFILE) $(POLIPO_DIR)/Makefile
	cd $(POLIPO_DIR) && make && PREFIX=$(FETCH_DIR)/built/ make install.binary

build-pidgin:
	echo "We're not building pidgin yet!"

FIREFOX_DIR=$(FETCH_DIR)/mozilla-release
build-firefox:
	cp ../src/current-patches/firefox/* $(FIREFOX_DIR)
	cp patch-any-src.sh $(FIREFOX_DIR)
	cp $(CONFIG_SRC)/dot_mozconfig $(FIREFOX_DIR)/mozconfig
	cd $(FIREFOX_DIR) && ./patch-any-src.sh
	cd $(FIREFOX_DIR) && make -f client.mk build

copy-firefox:
	-rm -rf $(FETCH_DIR)/Firefox
	## This is so ugly. Update it to use cool tar --transform soon.
	cd $(FIREFOX_DIR) && make -C obj-$(ARCH_TYPE)-*/ package
	cp $(FIREFOX_DIR)/obj-$(ARCH_TYPE)-*/dist/*bz2 $(FETCH_DIR)
	cd $(FETCH_DIR) && tar -xvjf firefox-$(FIREFOX_VER).en-US.linux-$(ARCH_TYPE).tar.bz2 && mv firefox Firefox

# source-dance unpack-source
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
POLIPO=$(COMPILED_BINS)/polipo
#TOR=$(COMPILED_BINS)/tor
#VIDALIA=$(BUILT_DIR)/usr/local/bin/vidalia
TOR=$(FETCH_DIR)/tor-$(TOR_VER)/src/or/tor
VIDALIA=$(FETCH_DIR)/vidalia-$(VIDALIA_VER)/build/src/vidalia/vidalia
## Someday, this will be our custom Firefox
FIREFOX=$(FETCH_DIR)/Firefox
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
	USE_PIDGIN=1 make -f linux-alpha.mk all-bundles
	make -f linux-alpha.mk clean
	USE_PIDGIN=0 make -f linux-alpha.mk all-bundles
	make -f linux-alpha.mk clean

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
	compressed-bundle_it \
	compressed-bundle_vi

##
## Cleanup
##

clean:
	rm -fr *.tar.gz
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
	make -f linux-alpha.mk generic-bundle
generic-bundle: directory-structure \
		install-binaries \
		install-docs \
		install-firefox \
		install-pidgin \
		configure-apps \
		launcher \
		strip-it-stripper \
		remove-bundle-shared-lib-symlinks
	touch generic-bundle.stamp

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
	cp -d $(QT)/libQtScript.so* $(LIBSDIR)
	#rm $(LIBSDIR)/libQt*.so*.debug
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
	cp ../changelog.linux-2.3 $(DOCSDIR)/changelog
	# This should be updated to be more generic (version-wise) and more Linux specific
	cp ../README.LINUX-2.3 $(DOCSDIR)/README-TorBrowserBundle

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

## Configure Firefox, Vidalia, Polipo and Tor
configure-apps:
	## Configure Firefox preferences
	mkdir -p $(DEST)/Data/profile/extensions
	cp -R $(CONFIG_SRC)/firefox-profiles.ini $(DEST)/Data/profiles.ini
	cp $(CONFIG_SRC)/bookmarks.html $(DEST)/Data/profile
	cp $(CONFIG_SRC)/no-polipo-4.0.js $(DEST)/Data/profile/prefs.js
	## Configure Pidgin
ifeq ($(USE_PIDGIN),1)
	mkdir -p $(DEST)/PidginPortable/Data/settings/.purple
	cp $(CONFIG_SRC)/prefs.xml $(DEST)/PidginPortable/Data/settings/.purple
endif
	## Configure Vidalia
	mkdir -p $(DEST)/Data/Vidalia/plugins
	cp -r $(FETCH_DIR)/vidalia-plugins/tbb $(DEST)/Data/Vidalia/plugins
	mkdir -p $(DEST)/App/script
	cp $(FETCH_DIR)/qtscriptgenerator/plugins/script/* $(DEST)/App/script
ifeq ($(USE_PIDGIN),1)
	cp $(CONFIG_SRC)/alpha/vidalia.conf.ff+pidgin-linux $(DEST)/Data/Vidalia/vidalia.conf
else
	cp $(CONFIG_SRC)/alpha/vidalia.conf.ff-linux $(DEST)/Data/Vidalia/vidalia.conf
endif
	## Configure Polipo
	#cp $(CONFIG_SRC)/polipo.conf $(DEST)/Data/Polipo/polipo.conf
	## Configure Tor
	cp $(CONFIG_SRC)/torrc-linux $(DEST)/Data/Tor/torrc
	cp $(TOR_DIR)/src/config/geoip $(DEST)/Data/Tor/geoip
	chmod 700 $(DEST)/Data/Tor

# We've replaced the custom C program with a shell script for now...
launcher:
	cp ../src/RelativeLink/RelativeLink.sh $(DEST)/start-tor-browser
	chmod +x $(DEST)/start-tor-browser

strip-it-stripper:
	strip $(APPDIR)/tor
	#strip $(APPDIR)/polipo
	strip $(APPDIR)/vidalia
	strip $(LIBSDIR)/*.so*
	strip $(LIBSDIR)/libz/*.so*

remove-bundle-shared-lib-symlinks:
	./remove-shared-lib-symlinks $(LIBSDIR)
	./remove-shared-lib-symlinks $(LIBSDIR)/libz
	./remove-shared-lib-symlinks $(APPDIR)/script

##
## How to create required extensions
##

## Torbutton development version
torbutton.xpi:
	$(WGET) -O $@ $(TORBUTTON)

## NoScript development version
noscript.xpi:
	$(WGET) -O $@ $(NOSCRIPT)

## BetterPrivacy
betterprivacy.xpi:
	$(WGET) -O $@ $(BETTERPRIVACY)

## HTTPS Everywhere
httpseverywhere.xpi:
	$(WGET) -O $@ --no-check-certificate $(HTTPSEVERYWHERE)

## Generic language pack rule
langpack_%.xpi:
	$(WGET) -O $@ $(MOZILLA_LANGUAGE)/$*.xpi

## English comes as default
#langpack_en-US.xpi:
#	touch $@

##
## Customize the bundle
##

bundle_%:
	LANGCODE=$* make -f linux-alpha.mk bundle-localized
compressed-bundle_%:
	LANGCODE=$* make -f linux-alpha.mk compressed-bundle-localized

bundle-localized_%.stamp:
	make -f linux-alpha.mk copy-files_$* install-extensions install-lang-extensions patch-vidalia-language patch-firefox-language \
	patch-pidgin-language update-extension-pref write-tbb-version
	touch bundle-localized_$*.stamp

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

install-betterprivacy: betterprivacy.xpi
	mkdir -p $(BUNDLE)/Data/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\}
	cp betterprivacy.xpi $(BUNDLE)/Data/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\}/betterprivacy.zip
	(cd $(BUNDLE)/Data/profile/extensions/\{d40f5e7b-d2cf-4856-b441-cc613eeffbe3\}/ && unzip *.zip && rm *.zip);


## Language extensions need to be handled differently from other extensions
fix-install-rdf: $(filter-out langpack_en-US.xpi,langpack_$(LANGCODE).xpi)
ifneq ($(LANGCODE), en-US)
	rm -fr xx
	mkdir xx
	(cd xx && unzip ../langpack_$(LANGCODE).xpi && sed -i -e "s/em:maxVersion>6.0.1/em:maxVersion>6.0.*/" install.rdf && zip  -r ../langpack_$(LANGCODE).xpi .)
endif

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
	cp $(CONFIG_SRC)/bookmarks.html $(BUNDLE)/App/Firefox/defaults/profile/
	cp $(CONFIG_SRC)/no-polipo-4.0.js $(BUNDLE)/App/Firefox/defaults/profile/prefs.js
	cp $(CONFIG_SRC)/bookmarks.html $(BUNDLE)/Data/profile
	cp $(CONFIG_SRC)/no-polipo-4.0.js $(BUNDLE)/Data/profile/prefs.js
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

