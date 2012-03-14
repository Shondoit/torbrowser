#!/usr/bin/make

RELEASE_VER=2.3.12-alpha

HTTPSEVERY_VER=2.0development.4
FIREFOX_VER=11.0
LIBEVENT_VER=2.0.17-stable
LIBPNG_VER=1.5.7
NOSCRIPT_VER=2.3
OPENSSL_VER=1.0.1-beta1
OTR_VER=3.2.0
PIDGIN_VER=2.6.4
QT_VER=4.7.4
TOR_VER=0.2.3.12-alpha
TORBUTTON_VER=1.4.5.1
VIDALIA_VER=0.3.1
ZLIB_VER=1.2.6

## Extension IDs
FF_VENDOR_ID:=\{ec8030f7-c20a-464f-9b0e-13a3a9e97384\}

## Extensions
TORBUTTON=https://www.torproject.org/dist/torbutton/torbutton-$(TORBUTTON_VER).xpi
NOSCRIPT=https://addons.mozilla.org/firefox/downloads/latest/722/addon-722-latest.xpi
BETTERPRIVACY=https://addons.mozilla.org/en-US/firefox/downloads/latest/6623/addon-6623-latest.xpi
HTTPSEVERYWHERE=https://eff.org/files/https-everywhere-$(HTTPSEVERY_VER).xpi

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

fetch-source: fetch-zlib fetch-openssl fetch-libpng fetch-qt fetch-vidalia fetch-libevent fetch-tor fetch-firefox clone-qtscript clone-vidalia
fetch-source-osx: fetch-zlib fetch-openssl fetch-vidalia fetch-libevent fetch-tor fetch-firefox
	-mkdir $(FETCH_DIR)

fetch-zlib:
	-rm -f $(FETCH_DIR)/$(ZLIB_PACKAGE)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(ZLIB_URL)

fetch-libpng:
	-rm -f $(FETCH_DIR)/$(LIBPNG_PACKAGE)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(LIBPNG_URL)

fetch-qt:
	-rm -f $(FETCH_DIR)/$(QT_PACKAGE)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(QT_URL)

fetch-openssl:
	-rm -f $(FETCH_DIR)/$(OPENSSL_PACKAGE)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(OPENSSL_URL)

fetch-vidalia:
	-rm -f $(FETCH_DIR)/$(VIDALIA_PACKAGE)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(VIDALIA_URL)

fetch-libevent:
	-rm -f $(FETCH_DIR)/$(LIBEVENT_PACKAGE)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(LIBEVENT_URL)

fetch-tor:
	-rm -f $(FETCH_DIR)/$(TOR_PACKAGE)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(TOR_URL)

fetch-firefox:
	-rm -f $(FETCH_DIR)/$(FIREFOX_PACKAGE)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(FIREFOX_URL)

clone-qtscript:
	git clone git://gitorious.org/qt-labs/qtscriptgenerator.git $(FETCH_DIR)/qtscriptgenerator

clone-vidalia:
	-rm -rf $(FETCH_DIR)/vidalia-$(VIDALIA_VER)
	git clone https://git.torproject.org/vidalia.git $(FETCH_DIR)/vidalia-$(VIDALIA_VER)
	cd $(FETCH_DIR)/vidalia-$(VIDALIA_VER) && git fetch origin
	cd $(FETCH_DIR)/vidalia-$(VIDALIA_VER) && git checkout alpha

clone-vidalia-plugins:
	-rm -rf $(FETCH_DIR)/vidalia-plugins
	git clone https://git.torproject.org/vidalia-plugins.git $(FETCH_DIR)/vidalia-plugins

unpack-source: unpack-zlib unpack-openssl unpack-libpng unpack-qt unpack-vidalia unpack-libevent unpack-tor unpack-firefox

unpack-zlib:
	-rm -rf $(FETCH_DIR)/zlib-$(ZLIB_VER)
	cd $(FETCH_DIR) && tar -xvzf $(ZLIB_PACKAGE)

unpack-libpng:
	-rm -rf $(FETCH_DIR)/libpng-$(LIBPNG_VER)
	cd $(FETCH_DIR) && tar -xvjf $(LIBPNG_PACKAGE)

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
	-rm -rf $(FETCH_DIR)/tor-$(TOR-VER)
	cd $(FETCH_DIR) && tar -xvzf $(TOR_PACKAGE)

unpack-firefox:
	-rm -rf $(FETCH_DIR)/mozilla-release
	cd $(FETCH_DIR) && tar -xvjf $(FIREFOX_PACKAGE)
