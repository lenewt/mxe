# This file is part of MXE.
# See index.html for further information.

PKG             := icu4c
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 54.2
$(PKG)_MAJOR    := $(word 1,$(subst ., ,$($(PKG)_VERSION)))
$(PKG)_CHECKSUM := 9544367d7e62e958689102fe2f8a84a18fea0bd480318c6008ce0397b98f0398
$(PKG)_SUBDIR   := icu-release-$(subst .,-,$($(PKG)_VERSION))/icu4c
$(PKG)_FILE     := release-$(subst .,-,$($(PKG)_VERSION)).tar.gz
$(PKG)_URL      := https://github.com/unicode-org/icu/archive/refs/tags/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc

define $(PKG)_UPDATE
    echo 54.2 # We don't want to update ICU and the version listing url is not available anyway
endef

define $(PKG)_BUILD_COMMON
    cd '$(1)/source' && autoreconf -fi
    mkdir '$(1).native' && cd '$(1).native' && '$(1)/source/configure' \
        CC=$(BUILD_CC) CXX=$(BUILD_CXX)
    $(MAKE) -C '$(1).native' -j '$(JOBS)'

    mkdir '$(1).cross' && cd '$(1).cross' && '$(1)/source/configure' \
        $(MXE_CONFIGURE_OPTS) \
        --with-cross-build='$(1).native' \
        CFLAGS=-DU_USING_ICU_NAMESPACE=0 \
        CXXFLAGS='--std=gnu++0x' \
        SHELL=bash

    $(MAKE) -C '$(1).cross' -j '$(JOBS)' install
    ln -sf '$(PREFIX)/$(TARGET)/bin/icu-config' '$(PREFIX)/bin/$(TARGET)-icu-config'
endef

define $(PKG)_BUILD_SHARED
    $($(PKG)_BUILD_COMMON)
    # icu4c installs its DLLs to lib/. Move them to bin/.
    mv -fv $(PREFIX)/$(TARGET)/lib/icu*.dll '$(PREFIX)/$(TARGET)/bin/'
    # add symlinks icu*<version>.dll.a to icu*.dll.a
    for lib in `ls '$(PREFIX)/$(TARGET)/lib/' | grep 'icu.*\.dll\.a' | cut -d '.' -f 1 | tr '\n' ' '`; \
    do \
        ln -fs "$(PREFIX)/$(TARGET)/lib/$${lib}.dll.a" "$(PREFIX)/$(TARGET)/lib/$${lib}$($(PKG)_MAJOR).dll.a"; \
    done
endef

define $(PKG)_BUILD
    $($(PKG)_BUILD_COMMON)
    # Static libs are prefixed with an `s` but the config script
    # doesn't detect it properly, despite the STATIC_PREFIX="s" line
    $(SED) -i 's,ICUPREFIX="icu",ICUPREFIX="sicu",' '$(PREFIX)/$(TARGET)/bin/icu-config'
endef
