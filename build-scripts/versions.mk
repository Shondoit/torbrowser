#!/usr/bin/make

RELEASE_VER=2.2.35

HTTPSEVERYWHERE_VER=1.2.2
FIREFOX_VER=10.0.2
LIBEVENT_VER=2.0.17-stable
LIBPNG_VER=1.5.9
NOSCRIPT_VER=2.3
OPENSSL_VER=1.0.0g
OTR_VER=3.2.0
PIDGIN_VER=2.6.4
QT_VER=4.7.4
TOR_VER=0.2.2.35
TORBUTTON_VER=1.4.5.1
VIDALIA_VER=0.2.17
ZLIB_VER=1.2.6

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
TORBUTTON_PACKAGE=torbutton-$(TORBUTTON_VER).xpi
NOSCRIPT_PACKAGE=addon-722-latest.xpi
HTTPSEVERYWHERE_PACKAGE=https-everywhere-$(HTTPSEVERYWHERE_VER).xpi

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
TORBUTTON_URL=https://www.torproject.org/dist/torbutton/$(TORBUTTON_PACKAGE)
NOSCRIPT_URL=https://addons.mozilla.org/firefox/downloads/latest/722/$(NOSCRIPT_PACKAGE)
HTTPSEVERYWHERE_URL=https://eff.org/files/$(HTTPSEVERYWHERE_PACKAGE)

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

fetch-source: $(FETCH_DIR)/$(ZLIB_PACKAGE) $(FETCH_DIR)/$(LIBPNG_PACKAGE) $(FETCH_DIR)/$(QT_PACKAGE) $(FETCH_DIR)/$(OPENSSL_PACKAGE) $(FETCH_DIR)/$(VIDALIA_PACKAGE) $(FETCH_DIR)/$(LIBEVENT_PACKAGE) $(FETCH_DIR)/$(TOR_PACKAGE) $(FETCH_DIR)/$(FIREFOX_PACKAGE) | $(FETCH_DIR) ;

$(FETCH_DIR):
	mkdir -p $(FETCH_DIR)

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

unpack-source: $(ZLIB_DIR) $(OPENSSL_DIR) $(LIBPNG_DIR $(QT_DIR) $(VIDALIA_DIR) $(LIBEVENT_DIR) $(TOR_DIR) $(FIREFOX_DIR)

$(ZLIB_DIR): $(FETCH_DIR)/$(ZLIB_PACKAGE)
	rm -rf $(ZLIB_DIR)
	cd $(FETCH_DIR) && tar -xmf $(ZLIB_PACKAGE)

unpack-libpng:
	-rm -rf $(FETCH_DIR)/libpng-$(LIBPNG_VER)
	cd $(FETCH_DIR) && tar -xvjf $(LIBPNG_PACKAGE)

unpack-qt:
	-rm -rf $(FETCH_DIR/qt-$(QT_VER)
	cd $(FETCH_DIR) && tar -xvzf $(QT_PACKAGE)

unpack-openssl:
	-rm -rf $(FETCH_DIR)/openssl-$(OPENSSL_VER)
	cd $(FETCH_DIR) && tar -xvzf $(OPENSSL_PACKAGE)

unpack-vidalia:
	-rm -rf $(FETCH_DIR)/vidalia-$(VIDALIA_VER)
	cd $(FETCH_DIR) && tar -xvzf $(VIDALIA_PACKAGE)

unpack-libevent:
	-rm -rf $(FETCH_DIR)/libevent-$(LIBEVENT_VER)
	cd $(FETCH_DIR) && tar -xvzf $(LIBEVENT_PACKAGE)

unpack-tor:
	-rm -rf $(FETCH_DIR)/tor-$(TOR_VER)
	cd $(FETCH_DIR) && tar -xvzf $(TOR_PACKAGE)

unpack-firefox:
	-rm -rf $(FETCH_DIR)/mozilla-release
	cd $(FETCH_DIR) && tar -xvjf $(FIREFOX_PACKAGE)
	cp ../src/current-patches/firefox/* $(FIREFOX_DIR)
	cp patch-any-src.sh $(FIREFOX_DIR)
	cd $(FIREFOX_DIR) && ./patch-any-src.sh

clean-fetch-%:
	rm -rf $(FETCH_DIR)/$($($*)_PACKAGE)

clean-fetch: clean-fetch-zlib clean-fetch-libpng clean-fetch-qt clean-fetch-openssl clean-fetch-vidalia clean-fetch-libevent clean-fetch-tor clean-fetch-firefox

.PHONY: clean-fetch
