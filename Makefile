SHELL=/bin/bash -o pipefail
MODULE_NAME = ps_accounts
VERSION ?= $(shell git describe --tags 2> /dev/null || echo "v0.0.0")
SEM_VERSION ?= $(shell echo ${VERSION} | sed 's/^v//')
PACKAGE ?= ${MODULE_NAME}_mock-${VERSION}
PS_VERSION ?= latest
TESTING_IMAGE ?= prestashop/prestashop-flashlight:${PS_VERSION}
PS_ROOT_DIR ?= $(shell pwd)/prestashop/prestashop-${PS_VERSION}

# target: default                                - Calling build by default
default: build

# target: help                                   - Get help on this file
.PHONY: help
help:
	@egrep "^#" Makefile

# target: clean                                  - Clean up the repository
.PHONY: clean
clean:
	git -c core.excludesfile=/dev/null clean -X -d -f

# target: build                                  - Setup PHP & Node.js locally
.PHONY: build
build: vendor

# target: zip                                  - Make a distributable zip
.PHONY: zip
zip: dist build
	@$(call zip_it,${PACKAGE}.zip)
	cp ./dist/${PACKAGE}.zip ./dist/${MODULE_NAME}_mock.zip
	cp ./dist/${PACKAGE}.zip ./dist/${MODULE_NAME}.zip

dist:
	@mkdir -p ./dist

composer.phar:
	@php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');";
	@php composer-setup.php;
	@php -r "unlink('composer-setup.php');";

vendor: composer.phar
	./composer.phar install -o;

define replace_version
	echo "Setting up version: ${VERSION}..."
	sed -i.bak -e "s/\(VERSION = \).*/\1\'${2}\';/" ${1}/${MODULE_NAME}.php
	sed -i.bak -e "s/\($this->version = \).*/\1\'${2}\';/" ${1}/${MODULE_NAME}.php
	sed -i.bak -e "s|\(<version><!\[CDATA\[\)[0-9a-z.-]\{1,\}]]></version>|\1${2}]]></version>|" ${1}/config.xml
	rm -f ${1}/${MODULE_NAME}.php.bak ${1}/config.xml.bak
endef

define zip_it
	$(eval TMP_DIR := $(shell mktemp -d))
	mkdir -p ${TMP_DIR}/${MODULE_NAME};
	cp -r $(shell cat .zip-contents) ${TMP_DIR}/${MODULE_NAME};
	$(call replace_version,${TMP_DIR}/${MODULE_NAME},${SEM_VERSION})
	cd ${TMP_DIR} && zip -9 -r $1 ./${MODULE_NAME};
	mv ${TMP_DIR}/$1 ./dist;
	rm -rf ${TMP_DIR};
endef
