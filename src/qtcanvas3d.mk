# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtcanvas3d
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_CHECKSUM := 67a66e7ea91fb6fbf08a117daeccc9e22bf91cb7a688c9dc65d2a0837664a5e3
$(PKG)_SUBDIR    = $(subst qtbase,qtcanvas3d,$(qtbase_SUBDIR))
$(PKG)_FILE      = $(subst qtbase,qtcanvas3d,$(qtbase_FILE))
$(PKG)_URL       = $(subst qtbase,qtcanvas3d,$(qtbase_URL))
$(PKG)_DEPS     := gcc qtbase qtdeclarative

define $(PKG)_UPDATE
    echo $(qtbase_VERSION)
endef

define $(PKG)_BUILD
    cd '$(1)' && '$(PREFIX)/$(TARGET)/qt5.9.5/bin/qmake'
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
endef
