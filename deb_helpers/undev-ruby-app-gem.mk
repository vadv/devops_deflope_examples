# -*- mode: makefile; coding: utf-8 -*-

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

# General variables implemented by this rule file:
# UNDEV_RUBY_APP_SRC_DIR
# UNDEV_RUBY_APP_NAME
# UNDEV_RUBY_APP_INSTALLNAME
# UNDEV_RUBY_VERSION
# UNDEV_RUBY_NAMESERVER
# UNDEV_RUBY_SETUP_NAMESERVER
# UNDEV_RUBY_GEN_INSTALL
# UNDEV_RUBY_APP_SRC_DIR
# UNDEV_RUBY_APP_INSTALL

ifndef _cdbs_rules_undev_ruby_app
_cdbs_rules_undev_ruby_app = 1

export LC_ALL = en_US.UTF-8
export LANGUAGE = en_US.UTF-8
export LANG = en_US.UTF-8
unexport GEM_HOME
unexport GEM_PATH
unexport BUNDLE_GEMFILE
unexport BUNDLE_BIN_PATH
unexport RUBYOPT

DEB_DH_INSTALL_ARGS = -X./debian

_DEB_CONTROL_RUBY_VERSION = $(shell dpkg-control-parse './debian/control' 'Ruby-Version')
_DEB_CONTROL_APP_NAME = $(shell dpkg-control-parse './debian/control' 'Source')
_NAMESERVER = $(shell grep 'nameserver' '/etc/resolv.conf')

UNDEV_RUBY_VERSION ?= $(_DEB_CONTROL_RUBY_VERSION)
UNDEV_RUBY_APP_NAME ?= $(_DEB_CONTROL_APP_NAME)
UNDEV_RUBY_APP_INSTALL_NAME ?= $(UNDEV_RUBY_APP_NAME)
UNDEV_RUBY_APP_SRC_DIR ?= app
UNDEV_RUBY_APP_INSTALL ?= debian/install

UNDEV_RUBY_SETUP_NAMESERVER ?= 1
UNDEV_RUBY_NAMESERVER ?= "8.8.8.8"

UNDEV_RUBY_GEN_INSTALL ?= 1
UNDEV_RUBY_BUNDLE_INSTALL_ARGS ?= --without='development test'

debian/cdbs-undev-locales:
	echo "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8\n" > /etc/locale.gen
	if [ -x /usr/sbin/locale-gen ]; then /usr/sbin/locale-gen; fi
	touch $@

debian/cdbs-undev-ruby-resolv:
	@if [ $(UNDEV_RUBY_SETUP_NAMESERVER) -eq 1 ]; then \
	  if test -z "$(_NAMESERVER)"; then \
	    echo "nameserver $(UNDEV_RUBY_NAMESERVER)" >> /etc/resolv.conf; \
	  fi; \
	fi
	touch $@

common-build-arch common-build-indep:: debian/cdbs-undev-ruby-build

debian/cdbs-undev-ruby-build:: debian/cdbs-undev-locales debian/cdbs-undev-ruby-resolv
	@if test -z "$(UNDEV_RUBY_APP_NAME)"; then \
	  echo "error: UNDEV_RUBY_APP_NAME must be specified"; \
	  exit 1; \
	fi

	@if test -z "$(UNDEV_RUBY_VERSION)"; then \
	  echo "error: could not retrive UNDEV_RUBY_VERSION from debian/control"; \
	  echo "error: set it manualy in debian/rules or add to Build-Depends"; \
	  exit 1; \
	fi

	@if [ $(UNDEV_RUBY_GEN_INSTALL) -eq 1 ]; then \
	  rm -f $(UNDEV_RUBY_APP_INSTALL); \
	  echo "$(UNDEV_RUBY_APP_SRC_DIR)/* opt/$(UNDEV_RUBY_APP_INSTALL_NAME)" > $(UNDEV_RUBY_APP_INSTALL); \
	  echo "$(UNDEV_RUBY_APP_SRC_DIR)/.bundle opt/$(UNDEV_RUBY_APP_INSTALL_NAME)" >> $(UNDEV_RUBY_APP_INSTALL); \
	fi

	echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

	cd $(UNDEV_RUBY_APP_SRC_DIR); /opt/ruby-$(UNDEV_RUBY_VERSION)/bin/bundle install $(UNDEV_RUBY_BUNDLE_INSTALL_ARGS) --deployment --binstubs;

	rm -rf $(UNDEV_RUBY_APP_SRC_DIR)/vendor/bundle/ruby/*/cache/*
	rm -f  $(UNDEV_RUBY_APP_SRC_DIR)/vendor/bundle/ruby/*/gems/*/*{README,CHANGELOG,TAGS,LICENSE}*

	if test -e $(UNDEV_RUBY_APP_SRC_DIR)/bin; then sed -i 's%#!/usr/bin/env ruby%#!/opt/ruby-$(UNDEV_RUBY_VERSION)/bin/ruby%g' $(UNDEV_RUBY_APP_SRC_DIR)/bin/* || echo -n "" ; fi
	if test -e $(UNDEV_RUBY_APP_SRC_DIR)/script; then sed -i 's%#!/usr/bin/env ruby%#!/opt/ruby-$(UNDEV_RUBY_VERSION)/bin/ruby%g' $(UNDEV_RUBY_APP_SRC_DIR)/script/* || echo -n ""; fi
	if test -e $(UNDEV_RUBY_APP_SRC_DIR)/scripts; then sed -i 's%#!/usr/bin/env ruby%#!/opt/ruby-$(UNDEV_RUBY_VERSION)/bin/ruby%g' $(UNDEV_RUBY_APP_SRC_DIR)/scripts/* || echo -n ""; fi
	touch $@

cleanbuilddir::
	rm -f debian/cdbs-undev-*
endif
