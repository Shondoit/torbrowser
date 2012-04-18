#!/usr/bin/make

RELEASE_VER=2.2.35

ZLIB_VER=1.2.6
OPENSSL_VER=1.0.0h
LIBPNG_VER=1.5.9
QT_VER=4.8.1
VIDALIA_VER=0.2.17
LIBEVENT_VER=2.0.17-stable
TOR_VER=0.2.2.35
PIDGIN_VER=2.6.4
FIREFOX_VER=11.0
MOZBUILD_VER=1.5.1
PYMAKE_VER=87d436cd8974
TORBUTTON_VER=1.4.5.1
NOSCRIPT_VER=2.3.4
HTTPSEVERYWHERE_VER=2.0.1
OTR_VER=3.2.0
OBFSPROXY_VER=0.1.1

## Extension IDs
FF_VENDOR_ID:=\{ec8030f7-c20a-464f-9b0e-13a3a9e97384\}

## File names for the source packages
ZLIB_PACKAGE=zlib-$(ZLIB_VER).tar.gz
OPENSSL_PACKAGE=openssl-$(OPENSSL_VER).tar.gz
LIBPNG_PACKAGE=libpng-$(LIBPNG_VER).tar.bz2
QT_PACKAGE=qt-everywhere-opensource-src-$(QT_VER).tar.gz
VIDALIA_PACKAGE=vidalia-$(VIDALIA_VER).tar.gz
LIBEVENT_PACKAGE=libevent-$(LIBEVENT_VER).tar.gz
TOR_PACKAGE=tor-$(TOR_VER).tar.gz
PIDGIN_PACKAGE=pidgin-$(PIDGIN_VER).tar.bz2
FIREFOX_PACKAGE=firefox-$(FIREFOX_VER).source.tar.bz2
MOZBUILD_PACKAGE=MozillaBuildSetup-$(MOZBUILD_VER).exe
PYMAKE_PACKAGE=$(PYMAKE_VER).tar.bz2
TORBUTTON_PACKAGE=torbutton-$(TORBUTTON_VER).xpi
NOSCRIPT_PACKAGE=addon-722-latest.xpi
HTTPSEVERYWHERE_PACKAGE=https-everywhere-$(HTTPSEVERYWHERE_VER).xpi
OBFSPROXY_PACKAGE=obfsproxy-$(OBFSPROXY_VER).tar.gz

## Location of files for download
ZLIB_URL=http://www.zlib.net/$(ZLIB_PACKAGE)
OPENSSL_URL=http://www.openssl.org/source/$(OPENSSL_PACKAGE)
LIBPNG_URL=ftp://ftp.simplesystems.org/pub/libpng/png/src/$(LIBPNG_PACKAGE)
QT_URL=ftp://ftp.qt.nokia.com/qt/source/$(QT_PACKAGE)
VIDALIA_URL=http://www.torproject.org/dist/vidalia/$(VIDALIA_PACKAGE)
LIBEVENT_URL=https://github.com/downloads/libevent/libevent/$(LIBEVENT_PACKAGE)
TOR_URL=http://www.torproject.org/dist/$(TOR_PACKAGE)
PIDGIN_URL=http://sourceforge.net/projects/pidgin/files/Pidgin/$(PIDGIN_PACKAGE)
FIREFOX_URL=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/$(FIREFOX_VER)/source/$(FIREFOX_PACKAGE)
MOZBUILD_URL=https://ftp.mozilla.org/pub/mozilla.org/mozilla/libraries/win32/$(MOZBUILD_PACKAGE)
PYMAKE_URL=https://hg.mozilla.org/users/bsmedberg_mozilla.com/pymake/archive/$(PYMAKE_PACKAGE)
TORBUTTON_URL=https://www.torproject.org/dist/torbutton/$(TORBUTTON_PACKAGE)
NOSCRIPT_URL=https://addons.mozilla.org/firefox/downloads/latest/722/$(NOSCRIPT_PACKAGE)
HTTPSEVERYWHERE_URL=https://eff.org/files/$(HTTPSEVERYWHERE_PACKAGE)
OBFSPROXY_URL=https://www.torproject.org/dist/obfsproxy/$(OBFSPROXY_PACKAGE)

# Provide some mappings between lower and upper case, which means we don't need
# to rely on shell shenanigans when we need the upper case version. This is
# necessary because our targets are lowercase, and our variables uppercase.
zlib=ZLIB
libpng=LIBPNG
qt=QT
openssl=OPENSSL
vidalia=VIDALIA
libevent=LIBEVENT
tor=TOR
firefox=FIREFOX
pidgin=PIDGIN
mozbuild=MOZBUILD
pymake=PYMAKE
obfsproxy=OBFSPROXY

# The locations of the unpacked tarballs
ZLIB_DIR=$(BUILD_DIR)/zlib-$(ZLIB_VER)
LIBPNG_DIR=$(BUILD_DIR)/libpng-$(LIBPNG_VER)
QT_DIR=$(BUILD_DIR)/qt-$(QT_VER)
OPENSSL_DIR=$(BUILD_DIR)/openssl-$(OPENSSL_VER)
VIDALIA_DIR=$(BUILD_DIR)/vidalia-$(VIDALIA_VER)
LIBEVENT_DIR=$(BUILD_DIR)/libevent-$(LIBEVENT_VER)
TOR_DIR=$(BUILD_DIR)/tor-$(TOR_VER)
FIREFOX_DIR=$(BUILD_DIR)/firefox-$(FIREFOX_VER)
MOZBUILD_DIR=$(BUILD_DIR)/mozilla-build
PYMAKE_DIR=$(BUILD_DIR)/pymake-$(PYMAKE_VER)
OBFSPROXY_DIR=$(BUILD_DIR)/obfsproxy-$(OBFSPROXY_VER)

# Empty targets are written in arch-dependent $(BUILD_DIR). Usual
# VPATH issues documented below should be avoided as the paths of
# these targes are never used in dependents recipes. We only make use
# of targets existence.
#
#   http://mad-scientist.net/make/vpath.html
#
STAMP_DIR=$(FETCH_DIR)
vpath build-% $(STAMP_DIR)
vpath patch-% $(STAMP_DIR)
vpath %.stamp $(STAMP_DIR)

fetch-source: $(FETCH_DIR)/$(ZLIB_PACKAGE) $(FETCH_DIR)/$(LIBPNG_PACKAGE) $(FETCH_DIR)/$(QT_PACKAGE) $(FETCH_DIR)/$(OPENSSL_PACKAGE) $(FETCH_DIR)/$(VIDALIA_PACKAGE) $(FETCH_DIR)/$(LIBEVENT_PACKAGE) $(FETCH_DIR)/$(TOR_PACKAGE) $(FETCH_DIR)/$(FIREFOX_PACKAGE) $(FETCH_DIR)/$(OBFSPROXY_PACKAGE) | $(FETCH_DIR) ;

source-dance: fetch-source unpack-source ;

$(FETCH_DIR):
	mkdir -p $(FETCH_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# XXX
# If we can, we should definitely add some stuff here to check signatures -
# at least for those packages that support it.

$(FETCH_DIR)/$(ZLIB_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(ZLIB_URL)

$(FETCH_DIR)/$(LIBPNG_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(LIBPNG_URL)

$(FETCH_DIR)/$(QT_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(QT_URL)

$(FETCH_DIR)/$(OPENSSL_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(OPENSSL_URL)

$(FETCH_DIR)/$(VIDALIA_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(VIDALIA_URL)

$(FETCH_DIR)/$(LIBEVENT_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(LIBEVENT_URL)

$(FETCH_DIR)/$(TOR_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(TOR_URL)

$(FETCH_DIR)/$(FIREFOX_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(FIREFOX_URL)

$(FETCH_DIR)/$(MOZBUILD_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(MOZBUILD_URL)

$(FETCH_DIR)/$(PYMAKE_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(PYMAKE_URL)

torbutton.xpi:
	$(WGET) --no-check-certificate -O $@ $(TORBUTTON_URL)

noscript.xpi:
	$(WGET) --no-check-certificate -O $@ $(NOSCRIPT_URL)

httpseverywhere.xpi:
	$(WGET) --no-check-certificate -O $@ $(HTTPSEVERYWHERE_URL)

## Generic language pack rule, needs OS-specific MOZILLA_LANGUAGE
langpack_%.xpi:
	$(WGET) --no-check-certificate -O $@ $(MOZILLA_LANGUAGE)/$*.xpi

## English comes as default, so nothing to do here for the language packe
langpack_en-US.xpi:
	touch $@

$(FETCH_DIR)/$(OBFSPROXY_PACKAGE): | $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(OBFSPROXY_URL)

unpack-source: $(ZLIB_DIR) $(OPENSSL_DIR) $(LIBPNG_DIR $(QT_DIR) $(VIDALIA_DIR) $(LIBEVENT_DIR) $(TOR_DIR) $(FIREFOX_DIR) $(OBFSPROXY_DIR)


$(ZLIB_DIR): $(FETCH_DIR)/$(ZLIB_PACKAGE) | $(BUILD_DIR)
	rm -rf $(ZLIB_DIR)
	cd $(FETCH_DIR) && tar -xmf $(ZLIB_PACKAGE) -C $(BUILD_DIR)/

$(LIBPNG_DIR): $(FETCH_DIR)/$(LIBPNG_PACKAGE)
	rm -rf $(LIBPNG_DIR)
	cd $(FETCH_DIR) && tar -xmf $(LIBPNG_PACKAGE) -C $(BUILD_DIR)/

$(QT_DIR): $(FETCH_DIR)/$(QT_PACKAGE) | $(BUILD_DIR)
	rm -rf $(QT_DIR) $(FETCH_DIR)/qt-everywhere-opensource-src-$(QT_VER)
	cd $(FETCH_DIR) && tar -xmf $(QT_PACKAGE) -C $(BUILD_DIR)/
	mv $(BUILD_DIR)/qt-everywhere-opensource-src-$(QT_VER) $(QT_DIR)

$(OPENSSL_DIR): $(FETCH_DIR)/$(OPENSSL_PACKAGE) ../src/current-patches/openssl/*patch | $(BUILD_DIR)
	rm -rf $(OPENSSL_DIR)
	cd $(FETCH_DIR) && tar -xmf $(OPENSSL_PACKAGE) -C $(BUILD_DIR)/
	cp ../src/current-patches/openssl/*patch $(OPENSSL_DIR)
	cp patch-any-src.sh $(OPENSSL_DIR)
	cd $(OPENSSL_DIR) && ./patch-any-src.sh

$(VIDALIA_DIR): $(FETCH_DIR)/$(VIDALIA_PACKAGE) | $(BUILD_DIR)
	rm -rf $(VIDALIA_DIR)
	cd $(FETCH_DIR) && tar -xmf $(VIDALIA_PACKAGE) -C $(BUILD_DIR)/
ifeq (MacOS,$(PLATFORM))
	cp ../src/current-patches/vidalia/*patch $(VIDALIA_DIR)
	cp patch-any-src.sh $(VIDALIA_DIR)
	cd $(VIDALIA_DIR) && ./patch-any-src.sh
endif

$(LIBEVENT_DIR): $(FETCH_DIR)/$(LIBEVENT_PACKAGE) | $(BUILD_DIR)
	rm -rf $(LIBEVENT_DIR)
	cd $(FETCH_DIR) && tar -xmf $(LIBEVENT_PACKAGE) -C $(BUILD_DIR)/

$(TOR_DIR): $(FETCH_DIR)/$(TOR_PACKAGE) | $(BUILD_DIR)
	rm -rf $(TOR_DIR)
	cd $(FETCH_DIR) && tar -xmf $(TOR_PACKAGE) -C $(BUILD_DIR)/

$(FIREFOX_DIR): $(FETCH_DIR)/$(FIREFOX_PACKAGE) ../src/current-patches/firefox/* | $(BUILD_DIR)
	rm -rf $(FIREFOX_DIR) $(FETCH_DIR)/mozilla-release
	cd $(FETCH_DIR) && tar -xmf $(FIREFOX_PACKAGE) -C $(BUILD_DIR)/
	mv $(BUILD_DIR)/mozilla-release $(FIREFOX_DIR)
	cp ../src/current-patches/firefox/* $(FIREFOX_DIR)
	cp patch-any-src.sh $(FIREFOX_DIR)
	cd $(FIREFOX_DIR) && ./patch-any-src.sh

$(MOZBUILD_DIR): $(FETCH_DIR)/$(MOZBUILD_PACKAGE) ../src/current-patches/mozilla-build/start-msvc.patch ../src/current-patches/mozilla-build/guess-msvc-x64.bat patch-mozilla-build.sh | $(BUILD_DIR)
	rm -rf $(MOZBUILD_DIR) /c/mozilla-build
# We could try passing a /D argument here, but then we'd need to convert
# mingw paths into windows paths. We'll just go with the default here.
	cd $(FETCH_DIR) && cmd.exe /c "$(MOZBUILD_PACKAGE) /S"
	mv /c/mozilla-build $(MOZBUILD_DIR)
# We have to patch mozillabuild
	cp ../src/current-patches/mozilla-build/start-msvc.patch $(MOZBUILD_DIR)
	cp ../src/current-patches/mozilla-build/guess-msvc-x64.bat $(MOZBUILD_DIR)
	cp patch-mozilla-build.sh $(MOZBUILD_DIR)
	cd $(MOZBUILD_DIR) && ./patch-mozilla-build.sh $(MSVC_VER)

$(PYMAKE_DIR): $(FETCH_DIR)/$(PYMAKE_PACKAGE) | $(BUILD_DIR)
	rm -rf $(PYMAKE_DIR)
	cd $(FETCH_DIR) && tar -xmf $(PYMAKE_PACKAGE) -C $(BUILD_DIR)/

$(OBFSPROXY_DIR): $(FETCH_DIR)/$(OBFSPROXY_PACKAGE) | $(BUILD_DIR)
	rm -rf $(OBFSPROXY_DIR)
	cd $(FETCH_DIR) && tar -xmf $(OBFSPROXY_PACKAGE) -C $(BUILD_DIR)/


clean-fetch-%:
	rm -rf $(FETCH_DIR)/$($($*)_PACKAGE)

clean-fetch: clean-fetch-zlib clean-fetch-libpng clean-fetch-qt clean-fetch-openssl clean-fetch-vidalia clean-fetch-libevent clean-fetch-tor clean-fetch-firefox clean-fetch-obfsproxy

clean-unpack-%:
	rm -rf $($($*)_DIR)

clean-unpack: clean-unpack-zlib clean-unpack-libpng clean-unpack-qt clean-unpack-openssl clean-unpack-vidalia clean-unpack-libevent clean-unpack-tor clean-unpack-firefox clean-unpack-obfsproxy

clean-build-%:
	rm -rf $($($*)_DIR)
	rm -rf build-$*

clean-build: clean-build-zlib clean-build-libpng clean-build-qt clean-build-openssl clean-build-vidalia clean-build-libevent clean-build-tor clean-build-firefox clean-build-obfsproxy

.PHONY: clean-fetch clean-unpack clean-build

