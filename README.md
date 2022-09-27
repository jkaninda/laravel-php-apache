[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/jkaninda/laravel-php-apache/build-verify-package?logo=github&style=flat-square)](https://github.com/jkaninda/laravel-php-apache/actions)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/jkaninda/laravel-php-apache?style=flat-square)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/jkaninda/laravel-php-apache?style=flat-square)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/jkaninda/laravel-php-apache?style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/jkaninda/laravel-php-apache?style=flat-square)

# Laravel PHP-APACHE Docker image

> 🐳 Docker image for a PHP-APACHE container created to run Laravel or any php based applications.

- [Docker Hub](https://hub.docker.com/r/jkaninda/laravel-php-apache)
- [Github](https://github.com/jkaninda/laravel-php-apache)


## Specifications:

* PHP 8.1 / 8.0 / 7.4 / 7.2
* Composer
* OpenSSL PHP Extension
* XML PHP Extension
* PDO PHP Extension(pdo_mysql,pdo_pgsql)
* Redis PHP Extension
* Mbstring PHP Extension
* PCNTL PHP Extension
* ZIP PHP Extension
* GD PHP Extension
* BCMath PHP Extension
* Memcached
* Laravel Cron Job
* Laravel Schedule
* Laravel Envoy
* Supervisord

## Simple docker-compose usage:

```yml
version: '3'
services:
    app:
        image: jkaninda/laravel-php-apache:latest
        container_name: app
        restart: unless-stopped   
        ports:
         - "80:80"   
        volumes:
        #Project root
            - ./:/var/www/html
            #- ~/.ssh:/root/.ssh # If you use private CVS
        environment:
           - APP_ENV=development # Optional, or production
           #- LARAVEL_PROCS_NUMBER=1 # Optional, Laravel queue:work process number    
        networks:
            - default #if you're using networks between containers

```
## Laravel `artisan` command usage:
### Open php-fpm
```sh
docker-compose exec app /bin/bash

```

### Laravel migration
```sh
php atisan  migrate

```

## Docker run
```sh
 docker-compose up -d

``` 
## Supervisord
### Add more supervisor process in
> /var/www/html/conf/worker/supervisor.conf

### Custom php.ini
> /var/www/html/conf/php/php.ini

### Storage permision issue
> docker-compose exec app /bin/bash 

> chown -R www-data:www-data /var/www/html/storage

> chmod -R 775 /var/www/html/storage

> P.S. please give a star if you like it :wink:


