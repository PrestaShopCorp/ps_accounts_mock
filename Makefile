SHELL=/bin/bash -o pipefail
MODULE_NAME = ps_accounts
VERSION ?= $(shell git describe --tags 2> /dev/null || echo "v0.0.0")
SEM_VERSION ?= $(shell echo ${VERSION} | sed 's/^v//')
PACKAGE ?= ${MODULE_NAME}_mock-${VERSION}
PS_VERSION ?= 8.1.7
TESTING_IMAGE ?= prestashop/prestashop-flashlight:${PS_VERSION}
PS_ROOT_DIR ?= $(shell pwd)/prestashop/prestashop-${PS_VERSION}

export PHP_CS_FIXER_IGNORE_ENV = 1
export _PS_ROOT_DIR_ ?= ${PS_ROOT_DIR}
export PATH := ./vendor/bin:./tests/vendor/bin:$(PATH)

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
build: vendor tests/vendor

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

tests/vendor: composer.phar vendor
	./composer.phar install --working-dir tests -o;

prestashop:
	@mkdir -p ./prestashop

prestashop/prestashop-${PS_VERSION}: prestashop composer.phar
	@if [ ! -d "prestashop/prestashop-${PS_VERSION}" ]; then \
		git clone --depth 1 --branch ${PS_VERSION} https://github.com/PrestaShop/PrestaShop.git prestashop/prestashop-${PS_VERSION} > /dev/null; \
		if [ "${PS_VERSION}" != "1.6.1.24" ]; then \
			./composer.phar -d ./prestashop/prestashop-${PS_VERSION} install; \
    fi \
	fi;

# target: test                                                 - Static and unit testing
.PHONY: test
test: composer-validate lint php-lint phpstan

# target: docker-test                                          - Static and unit testing in docker
.PHONY: docker-test
docker-test: docker-lint docker-phpstan docker-phpunit

# target: composer-validate (or docker-composer-validate)      - Validates composer.json and composer.lock
.PHONY: composer-validate
composer-validate: vendor
	@./composer.phar validate --no-check-publish
docker-composer-validate:
	@$(call in_docker,make,composer-validate)

# target: lint (or docker-lint)                                - Lint the code and expose errors
.PHONY: lint docker-lint
lint: php-cs-fixer php-lint
docker-lint: docker-php-cs-fixer docker-php-lint

# target: lint-fix (or docker-lint-fix)                        - Automatically fix the linting errors
.PHONY: lint-fix docker-lint-fix
lint-fix: php-cs-fixer-fix
docker-lint-fix: docker-php-cs-fixer-fix

# target: php-cs-fixer (or docker-php-cs-fixer)                - Lint the code and expose errors
.PHONY: php-cs-fixer docker-php-cs-fixer  
php-cs-fixer: tests/vendor
	@php-cs-fixer fix --dry-run --diff;
docker-php-cs-fixer: tests/vendor
	@$(call in_docker,make,lint)

# target: php-cs-fixer-fix (or docker-php-cs-fixer-fix)        - Lint the code and fix it
.PHONY: php-cs-fixer-fix docker-php-cs-fixer-fix
php-cs-fixer-fix: tests/vendor
	@php-cs-fixer fix
docker-php-cs-fixer-fix: tests/vendor
	@$(call in_docker,make,lint-fix)

# target: php-lint (or docker-php-lint)                        - Lint the code with the php linter
.PHONY: php-lint docker-php-lint
php-lint:
	@find . -type f -name '*.php' -not -path "./vendor/*" -not -path "./tests/*" -not -path "./prestashop/*" -print0 | xargs -0 -n1 php -l -n | (! grep -v "No syntax errors" );
	@echo "php $(shell php -r 'echo PHP_VERSION;') lint passed";
docker-php-lint:
	@$(call in_docker,make,php-lint)

# target: phpstan (or docker-phpstan)                          - Run phpstan
.PHONY: phpstan docker-phpstan
phpstan: tests/vendor prestashop/prestashop-${PS_VERSION}
	phpstan analyse --memory-limit=-1 --configuration=./tests/phpstan/phpstan-local.neon;
docker-phpstan:
	@$(call in_docker,/usr/bin/phpstan,analyse --memory-limit=-1 --configuration=./tests/phpstan/phpstan-docker.neon)

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

define in_docker
	docker run \
	--rm \
	--workdir /var/www/html/modules/${MODULE_NAME} \
	--volume $(shell pwd):/var/www/html/modules/${MODULE_NAME}:rw \
	--entrypoint $1 ${TESTING_IMAGE} $2
endef
