# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtwebsockets
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_CHECKSUM := e0f14442eb0013cbc790c5a99fa2bd0ef4fc6cfbbcdc9b4117b4aad3b7f16eeb
$(PKG)_SUBDIR    = $(subst qtbase,qtwebsockets,$(qtbase_SUBDIR))
$(PKG)_FILE      = $(subst qtbase,qtwebsockets,$(qtbase_FILE))
$(PKG)_URL       = $(subst qtbase,qtwebsockets,$(qtbase_URL))
$(PKG)_DEPS     := gcc qtbase

define $(PKG)_UPDATE
    echo $(qtbase_VERSION)
endef

define $(PKG)_BUILD
    cd '$(1)' && '$(PREFIX)/$(TARGET)/qt5.9.5/bin/qmake'
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
endef
