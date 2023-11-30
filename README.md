# PS Accounts Mock

This repository is shared for the solely purpose of providing a ps_accounts mock.
It does nothing, but help you integrates with the ps_accounts module.

See: https://packagist.org/packages/prestashop/prestashop-accounts-installer

## Use with PrestaShop Flashlight

See: https://github.com/prestashop/prestashop-flashlight

Supposing you have a `./e2e-env` folder in your `my_module` PrestaShop module, it may contain:

```
./e2e-env
├── docker-compose.yml
└── init-scripts
    └── install-module.sh
```

### docker-compose.yml

```yml
services:
  prestashop:
    image: prestashop/prestashop-flashlight:latest
    depends_on:
      mysql:
        condition: service_healthy
    volumes:
      - ..:/var/www/html/modules/my_module:rw
      - ./init-scripts:/tmp/init-scripts:ro
    environment:
      - PS_DOMAIN=localhost:8000
      - INIT_SCRIPTS_DIR=/tmp/init-scripts
      - DEBUG_MODE=true
    ports:
      - 8000:80
    networks:
      - prestashop

  mysql:
    image: mariadb:lts
    container_name: prestashop-mysql
    healthcheck:
      test:
        [
          "CMD",
          "mysqladmin",
          "ping",
          "--host=localhost",
          "--user=prestashop",
          "--password=prestashop",
        ]
      interval: 5s
      timeout: 10s
      retries: 5
    environment:
      - MYSQL_HOST=mysql
      - MYSQL_USER=prestashop
      - MYSQL_PASSWORD=prestashop
      - MYSQL_ROOT_PASSWORD=prestashop
      - MYSQL_PORT=3306
      - MYSQL_DATABASE=prestashop
    expose:
      - 3306
    networks:
      - prestashop

networks:
  prestashop:
    driver: bridge
```

And the script install-module.sh:

```sh
set -eu

cd "$PS_FOLDER"
echo "* [my_module] installing the module..."
php -d memory_limit=-1 bin/console prestashop:module --no-interaction install "my_module"

echo "* [ps_accounts_mock] downloading..."
wget -q -O /tmp/ps_accounts.zip "https://github.com/PrestaShopCorp/ps_accounts_mock/releases/download/0.0.0/ps_accounts.zip"
echo "* [ps_accounts_mock] unziping..."
unzip -qq /tmp/ps_accounts.zip -d /var/www/html/modules
echo "* [ps_accounts_mock] installing the module..."
php -d memory_limit=-1 bin/console prestashop:module --no-interaction install "ps_accounts"
```
