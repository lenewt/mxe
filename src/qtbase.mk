# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtbase
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.9.3
$(PKG)_CHECKSUM := 9e7c44005e7691dc7c85165bd4510282c47f0163521f4973eab71dbdb39a9982
$(PKG)_SUBDIR   := $(PKG)-opensource-src-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-opensource-src-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.qt.io/official_releases/qt/5.9/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc dbus fontconfig freetds freetype harfbuzz jpeg libmysqlclient libpng openssl pcre2 postgresql sqlite zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- https://download.qt.io/official_releases/qt/5.8/ | \
    $(SED) -n 's,.*href="\(5\.[0-9]\.[^/]*\)/".*,\1,p' | \
    grep -iv -- '-rc' | \
    sort |
    tail -1
endef

define $(PKG)_BUILD
    # ICU is buggy. See #653. TODO: reenable it some time in the future.
    cd '$(1)' && \
        OPENSSL_LIBS="`'$(TARGET)-pkg-config' --libs-only-l openssl`" \
        PSQL_LIBS="-lpq -lsecur32 `'$(TARGET)-pkg-config' --libs-only-l openssl pthreads` -lws2_32" \
        SYBASE_LIBS="-lsybdb `'$(TARGET)-pkg-config' --libs-only-l gnutls` -liconv -lws2_32" \
        PKG_CONFIG="${TARGET}-pkg-config" \
        PKG_CONFIG_SYSROOT_DIR="/" \
        PKG_CONFIG_LIBDIR="$(PREFIX)/$(TARGET)/lib/pkgconfig" \
        ./configure \
            -opensource \
            -confirm-license \
            -xplatform win32-g++ \
            -device-option CROSS_COMPILE=${TARGET}- \
            -device-option PKG_CONFIG='${TARGET}-pkg-config' \
            -pkg-config \
            -force-pkg-config \
            -no-use-gold-linker \
            -release \
            -static \
            -prefix '$(PREFIX)/$(TARGET)/qt5.9.3' \
            -no-icu \
            -opengl desktop \
            -no-glib \
            -accessibility \
            -nomake examples \
            -nomake tests \
            -plugin-sql-mysql \
            -mysql_config $(PREFIX)/$(TARGET)/bin/mysql_config \
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
            -no-pch \
            -v \
            $($(PKG)_CONFIGURE_OPTS)

    $(MAKE) -C '$(1)' -j '$(JOBS)'
    rm -rf '$(PREFIX)/$(TARGET)/qt5.9.3'
    $(MAKE) -C '$(1)' -j 1 install
    ln -sf '$(PREFIX)/$(TARGET)/qt5.9.3/bin/qmake' '$(PREFIX)/bin/$(TARGET)'-qmake-qt5

    # setup cmake toolchain
    echo 'set(CMAKE_SYSTEM_PREFIX_PATH "$(PREFIX)/$(TARGET)/qt5.9.3" ${CMAKE_SYSTEM_PREFIX_PATH})' > '$(CMAKE_TOOLCHAIN_DIR)/$(PKG).cmake'

    # add libs to CMake config of Qt5Core to fix static linking
    $(SED) -i 's,set(_Qt5Core_LIB_DEPENDENCIES \"\"),set(_Qt5Core_LIB_DEPENDENCIES \"ole32;uuid;ws2_32;advapi32;shell32;user32;kernel32;mpr;version;winmm;z;pcre2-16\"),g' '$(PREFIX)/$(TARGET)/qt5.9.3/lib/cmake/Qt5Core/Qt5CoreConfig.cmake'
    $(SED) -i 's,set(_Qt5Gui_LIB_DEPENDENCIES \"Qt5::Core\"),set(_Qt5Gui_LIB_DEPENDENCIES \"Qt5::Core;ole32;uuid;ws2_32;advapi32;shell32;user32;kernel32;mpr;version;winmm;z;pcre2-16;png16;harfbuzz;z\"),g' '$(PREFIX)/$(TARGET)/qt5.9.3/lib/cmake/Qt5Gui/Qt5GuiConfig.cmake'
    $(SED) -i 's,set(_Qt5Widgets_LIB_DEPENDENCIES \"Qt5::Gui;Qt5::Core\"),set(_Qt5Widgets_LIB_DEPENDENCIES \"Qt5::Gui;Qt5::Core;gdi32;comdlg32;oleaut32;imm32;opengl32;png16;harfbuzz;ole32;uuid;ws2_32;advapi32;shell32;user32;kernel32;mpr;version;winmm;z;pcre2-16;shell32;uxtheme;dwmapi\"),g' '$(PREFIX)/$(TARGET)/qt5.9.3/lib/cmake/Qt5Widgets/Qt5WidgetsConfig.cmake'
endef


$(PKG)_BUILD_SHARED = $(subst -static ,-shared ,\
                      $($(PKG)_BUILD))
