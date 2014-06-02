# -*- mode: makefile; coding: utf-8 -*-

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

ifndef _cdbs_rules_undev_ruby
_cdbs_rules_undev_ruby = 1

# General variables implemented by this rule file
# UNDEV_RUBY_VERSION
# UNDEV_RUBY_TARBALL
# UNDEV_RUBY_PREFIX
# UNDEV_RUBY_CONFIGURE_FLAGS
# UNDEV_RUBY_EXTRA_CONFIGURE_FLAGS
# UNDEV_RUBY_SETUP_NAMESERVER
# UNDEV_RUBY_RUBYGEMS_VERSION
# UNDEV_RUBY_NAMESERVER
# UNDEV_RUBY_GEN_INSTALL

UNDEV_RUBY_VERSION ?= $(shell ls -1 | grep 'tar.gz' | grep -v cdbs | sed s'/ruby-\(.*\)\.tar\.gz/\1/g')
UNDEV_RUBY_TARBALL ?= ruby-$(UNDEV_RUBY_VERSION).tar.gz
UNDEV_RUBY_PREFIX ?= /opt/ruby-$(UNDEV_RUBY_VERSION)

UNDEV_RUBY_LIB_MAJOR_VERSION = $(shell echo $(UNDEV_RUBY_VERSION) | head -c 1)
UNDEV_RUBY_LIB_MINOR_VERSION = $(shell echo $(UNDEV_RUBY_VERSION) | head -c 3)

ifeq ($(UNDEV_RUBY_LIB_MINOR_VERSION),1.9)
	UNDEV_RUBY_LIB_VERSION = 1.9.1
else ifeq ($(UNDEV_RUBY_LIB_MINOR_VERSION),1.8)
	UNDEV_RUBY_LIB_VERSION = 1.8
else ifeq ($(UNDEV_RUBY_LIB_MINOR_VERSION),2.0)
	UNDEV_RUBY_LIB_VERSION = 2.0.0
else
	UNDEV_RUBY_LIB_VERSION = 2.1.0
endif

UNDEV_RUBY_EXTRA_CONFIGURE_FLAGS ?= ""
UNDEV_RUBY_CONFIGURE_FLAGS ?= --prefix=$(UNDEV_RUBY_PREFIX) \
	--enable-shared \
	--with-out-ext=tk \
	--disable-install-doc \
	$(UNDEV_RUBY_EXTRA_CONFIGURE_FLAGS)

UNDEV_RUBY_GEN_INSTALL ?= 1
UNDEV_RUBY_INSTALL_PREFIX = $(shell echo $(UNDEV_RUBY_PREFIX) | sed s'%^/%%')

UNDEV_RUBY_SETUP_NAMESERVER ?= 1
UNDEV_RUBY_NAMESERVER ?= "8.8.8.8"
UNDEV_RUBY_RUBYGEMS_VERSION ?= 1.8.25

# Setup debhelper and autotools
DEB_CONFIGURE_EXTRA_FLAGS = $(UNDEV_RUBY_CONFIGURE_FLAGS)
DEB_MAKE_INSTALL_TARGET = install DESTDIR=$(CURDIR)/debian/tmp

# Setup environment
export LC_ALL = en_US.UTF-8
export LANGUAGE = en_US.UTF-8
export LANG = en_US.UTF-8
export RUBY_DIR = $(CURDIR)/debian/tmp/$(UNDEV_RUBY_PREFIX)
export GEM_PATH = $(RUBY_DIR)/lib/ruby/gems/$(UNDEV_RUBY_LIB_VERSION)
export GEM_HOME = $(GEM_PATH)
export RUBYLIB  = $(RUBY_DIR)/lib/ruby/$(UNDEV_RUBY_LIB_VERSION):$(RUBY_DIR)/lib/ruby/$(UNDEV_RUBY_LIB_VERSION)/x86_64-linux

unexport BUNDLE_GEMFILE
unexport BUNDLE_BIN_PATH
unexport RUBYOPT

# Parse files
_NAMESERVER = $(shell grep 'nameserver' '/etc/resolv.conf')

debian/cdbs-undev-ruby-resolv:
	@if [ $(UNDEV_RUBY_SETUP_NAMESERVER) -eq 1 ]; then \
	  if test -z "$(_NAMESERVER)"; then \
	    echo "nameserver $(UNDEV_RUBY_NAMESERVER)" >> /etc/resolv.conf; \
	  fi; \
	fi
	touch $@

debian/cdbs-undev-locales:
	echo "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8\n" > /etc/locale.gen
	if [ -x /usr/sbin/locale-gen ]; then /usr/sbin/locale-gen; fi
	touch $@

debian/cdbs-undev-ruby-tarball:
	tar zxf $(UNDEV_RUBY_TARBALL) --strip 1
	touch $@

pre-build:: debian/cdbs-undev-locales debian/cdbs-undev-ruby-tarball

#https://github.com/carlhuda/bundler/issues/2445
common-install-arch:: debian/cdbs-undev-ruby-resolv
	LD_PRELOAD=$(RUBY_DIR)/lib/libruby.so $(RUBY_DIR)/bin/ruby $(RUBY_DIR)/bin/gem install rubygems-update --no-ri --no-rdoc -v "$(UNDEV_RUBY_RUBYGEMS_VERSION)" || exit 0
	LD_PRELOAD=$(RUBY_DIR)/lib/libruby.so $(RUBY_DIR)/bin/ruby $(RUBY_DIR)/bin/update_rubygems || exit 0
	REALLY_GEM_UPDATE_SYSTEM=1 LD_PRELOAD=$(RUBY_DIR)/lib/libruby.so $(RUBY_DIR)/bin/ruby $(RUBY_DIR)/bin/gem update --system $(UNDEV_RUBY_RUBYGEMS_VERSION) || exit 0
	LD_PRELOAD=$(RUBY_DIR)/lib/libruby.so $(RUBY_DIR)/bin/ruby $(RUBY_DIR)/bin/gem install bundler --no-ri --no-rdoc --bindir=$(RUBY_DIR)/bin
	sed -i '1 c#!$(UNDEV_RUBY_PREFIX)/bin/ruby' $(RUBY_DIR)/bin/bundle $(RUBY_DIR)/bin/gem

	@if [ $(UNDEV_RUBY_GEN_INSTALL) -eq 1 ]; then \
	  rm -f debian/install; \
	  echo "$(UNDEV_RUBY_INSTALL_PREFIX)/* $(UNDEV_RUBY_INSTALL_PREFIX)" > debian/install; \
	fi

cleanbuilddir::
	rm -f debian/cdbs-undev-*

endif
