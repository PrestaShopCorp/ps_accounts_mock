# PS Accounts Mock e2e environment

## Introduction

This is a basic env to avoid shipping a faulty mock. We mainly want to test the module is installing on each target PrestaShop version.

## Start the environment

1. Create your own configuration from the default values:

```shell
cp .env.dist .env
```

2. start docker environment:

```shell
docker compose up
```

Or in detached mode:

```shell
docker compose up -d
```

Or specifically only starting PrestaShop (and its dependencies) with special commands to be sure your containers and volumes will be recreacted/renewed:

```shell
docker compose up prestashop --force-recreate --renew-anon-volumes
```
