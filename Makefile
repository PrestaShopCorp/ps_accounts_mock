.PHONY: help clean build version zip
VERSION ?= v1.0.1
MODULE = ps_accounts
PACKAGE ?= ${MODULE}_mock-${VERSION}

# target: default                                - Calling build by default
default: build

# target: help                                   - Get help on this file
help:
	@egrep "^#" Makefile

# target: clean                                  - Clean up the repository
clean:
	git -c core.excludesfile=/dev/null clean -X -d -f

# target: build                                  - Setup PHP & Node.js locally
build: vendor

composer.phar:
	@php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');";
	@php composer-setup.php;
	@php -r "unlink('composer-setup.php');";

vendor: composer.phar
	./composer.phar install -o;

define zip_it
$(eval TMP_DIR := $(shell mktemp -d))
mkdir -p ${TMP_DIR}/${MODULE};
cp -r $(shell cat .zip-contents) ${TMP_DIR}/${MODULE};
cd ${TMP_DIR} && zip -9 -r $1 ./${MODULE};
mv ${TMP_DIR}/$1 ./dist;
rm -rf ${TMP_DIR:-/dev/null};
endef

# target: zip                                  - Make a distributable zip
zip: dist build
	@$(call zip_it,${PACKAGE}.zip)

dist:
	@mkdir -p ./dist
