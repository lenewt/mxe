# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtactiveqt
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_CHECKSUM := 9e5ad3775a5484e0ca34f670f31efc0d03f9c2ed32c0c1611dcc76e4f77f8302
$(PKG)_SUBDIR    = $(subst qtbase,qtactiveqt,$(qtbase_SUBDIR))
$(PKG)_FILE      = $(subst qtbase,qtactiveqt,$(qtbase_FILE))
$(PKG)_URL       = $(subst qtbase,qtactiveqt,$(qtbase_URL))
$(PKG)_DEPS     := gcc qtbase

define $(PKG)_UPDATE
    echo $(qtbase_VERSION)
endef

define $(PKG)_BUILD
    cd '$(1)' && '$(PREFIX)/$(TARGET)/qt5.9.5/bin/qmake'
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
endef
