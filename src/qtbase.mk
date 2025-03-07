# This file is part of MXE.
# See index.html for further information.

PKG             := qtbase
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.4.2
$(PKG)_CHECKSUM := 3703c6a584193e759f5b9cbf0ea6022d685ab827
$(PKG)_SUBDIR   := $(PKG)-opensource-src-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-opensource-src-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := http://download.qt.io/official_releases/qt/5.4/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc postgresql freetds openssl harfbuzz zlib libpng jpeg sqlite pcre fontconfig freetype dbus icu4c

define $(PKG)_UPDATE
    $(WGET) -q -O- http://download.qt-project.org/official_releases/qt/5.1/ | \
    $(SED) -n 's,.*href="\(5\.[0-9]\.[^/]*\)/".*,\1,p' | \
    grep -iv -- '-rc' | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(1)' && \
        OPENSSL_LIBS="`'$(TARGET)-pkg-config' --libs-only-l openssl`" \
        PSQL_LIBS="-lpq -lsecur32 `'$(TARGET)-pkg-config' --libs-only-l openssl` -lws2_32" \
        SYBASE_LIBS="-lsybdb `'$(TARGET)-pkg-config' --libs-only-l gnutls` -liconv -lws2_32" \
        ./configure \
            -opensource \
            -confirm-license \
            -xplatform win32-g++ \
            -device-option CROSS_COMPILE=${TARGET}- \
            -device-option PKG_CONFIG='${TARGET}-pkg-config' \
            -force-pkg-config \
            -no-use-gold-linker \
            -release \
            -static \
            -prefix '$(PREFIX)/$(TARGET)/qt5.4.2' \
            -icu \
            -opengl desktop \
            -no-glib \
            -accessibility \
            -nomake examples \
            -nomake tests \
            -no-sql-mysql \
            -plugin-sql-sqlite \
            -plugin-sql-odbc \
            -plugin-sql-psql \
            -plugin-sql-tds -D Q_USE_SYBASE \
            -qt-zlib \
            -qt-libpng \
            -qt-libjpeg \
            -qt-sqlite \
            -fontconfig \
            -system-freetype \
            -system-harfbuzz \
            -qt-pcre \
            -openssl-linked \
            -dbus-linked \
            -v

    # invoke qmake with removed debug options as a workaround for
    # https://bugreports.qt-project.org/browse/QTBUG-30898
    $(MAKE) -C '$(1)' -j '$(JOBS)' QMAKE="$(1)/bin/qmake CONFIG-='debug debug_and_release'"
    rm -rf '$(PREFIX)/$(TARGET)/qt5.4.2'
    $(MAKE) -C '$(1)' -j 1 install
    ln -sf '$(PREFIX)/$(TARGET)/qt5.4.2/bin/qmake' '$(PREFIX)/bin/$(TARGET)'-qmake-qt5
endef


$(PKG)_BUILD_SHARED = $(subst -static ,-shared ,\
                      $($(PKG)_BUILD))
