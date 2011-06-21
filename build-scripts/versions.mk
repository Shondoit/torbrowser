#!/usr/bin/make

RELEASE_VER=2.2.28

HTTPSEVERY_VER=0.9.9.development.6
FIREFOX_VER=4.0.1
LIBEVENT_VER=2.0.12-stable
LIBPNG_VER=1.4.3
NOSCRIPT_VER=2.1.1.1
OPENSSL_VER=1.0.0d
OTR_VER=3.2.0
PIDGIN_VER=2.6.4
POLIPO_VER=1.0.4.1
QT_VER=4.6.2
TOR_VER=0.2.2.28-beta
TORBUTTON_VER=1.3.3-alpha
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
PIDGIN_PACKAGE=pidgin-$(PIDGIN_VER).tar.bz2
FIREFOX_PACKAGE=firefox-$(FIREFOX_VER).tar.bz2

## Location of files for download
ZLIB_URL=http://www.zlib.net/$(ZLIB_PACKAGE)
OPENSSL_URL=http://www.openssl.org/source/$(OPENSSL_PACKAGE)
QT_URL=ftp://ftp.qt.nokia.com/qt/source/$(QT_PACKAGE)
VIDALIA_URL=http://www.torproject.org/dist/vidalia/$(VIDALIA_PACKAGE)
LIBEVENT_URL=http://www.monkey.org/~provos/$(LIBEVENT_PACKAGE)
TOR_URL=http://www.torproject.org/dist/$(TOR_PACKAGE)
PIDGIN_URL=http://sourceforge.net/projects/pidgin/files/Pidgin/$(PIDGIN_PACKAGE)
#FIREFOX_URL=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/$(FIREFOX_VER)/linux-i686/en-US/$(FIREFOX_PACKAGE)

fetch-source:
	-mkdir $(FETCH_DIR)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(ZLIB_URL)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(OPENSSL_URL)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(VIDALIA_URL)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(LIBEVENT_URL)
	$(WGET) --no-check-certificate --directory-prefix=$(FETCH_DIR) $(TOR_URL)

unpack-source:
	cd $(FETCH_DIR) && tar -xvzf $(ZLIB_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(OPENSSL_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(VIDALIA_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(LIBEVENT_PACKAGE)
	cd $(FETCH_DIR) && tar -xvzf $(TOR_PACKAGE)


