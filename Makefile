.PHONY: help clean build version zip
VERSION ?= 0.0.0
PACKAGE ?= ps_accounts-${VERSION}-mock

# target: default                                - Calling build by default
default: build

# target: help                                   - Get help on this file
help:
	@egrep "^#" Makefile

# target: clean                                  - Clean up the repository
clean:
	git -c core.excludesfile=/dev/null clean -X -d -f

# target: build                                  - Setup PHP & Node.js locally
build: vendor tools/vendor

composer.phar:
	@php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');";
	@php composer-setup.php;
	@php -r "unlink('composer-setup.php');";

vendor: composer.phar
	./composer.phar install -o;

define zip_it
$(eval TMP_DIR := $(shell mktemp -d))
mkdir -p ${TMP_DIR}/ps_accounts;
cp -r $(shell cat .zip-contents) ${TMP_DIR}/ps_accounts;
cd ${TMP_DIR} && zip -9 -r $1 ./ps_accounts;
mv ${TMP_DIR}/$1 ./dist;
rm -rf ${TMP_DIR:-/dev/null};
endef

zip: dist
	@$(call zip_it,${PACKAGE}.zip)

dist:
	@mkdir -p ./dist
