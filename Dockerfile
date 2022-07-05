FROM php:8.0-apache

ENV LARAVEL_PROCS_NUMBER=1
ENV APACHE_SERVER_NAME=localhost
ENV WORKDIR=/var/www/html
ENV STORAGE_DIR=${WORKDIR}/storage
ENV APACHE_DOCUMENT_ROOT=${WORKDIR}/public
# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmemcached-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    openssh-server \
    zip \
    unzip \
    supervisor \
    sqlite3  \
    nano \
    cron

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers

# Install PHP extensions zip, mbstring, exif, bcmath, intl
RUN docker-php-ext-configure gd
RUN docker-php-ext-install  zip mbstring exif pcntl bcmath -j$(nproc) gd intl

# Install Redis and enable it
RUN pecl install redis  && docker-php-ext-enable redis

# Install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql


# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Copy php.ini file
COPY php.ini   $PHP_INI_DIR/conf.d/

# 2. Apache configs + document root.
RUN echo "ServerName ${APACHE_SERVER_NAME}" >> /etc/apache2/apache2.conf

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
# Set working directory
WORKDIR $WORKDIR

COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN ln -s /usr/local/bin/entrypoint.sh /

ENTRYPOINT ["entrypoint.sh"]

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

RUN chmod 755 $WORKDIR

# entrypoint
CMD [ "entrypoint" ]


