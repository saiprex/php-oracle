FROM php:7.4-fpm

RUN apt-get update

RUN apt-get install -y \
    libmcrypt-dev \
    wget zip git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    alien libaio1

# for development
RUN apt-get install -y \
    iputils-ping

RUN mkdir /opt/oracle \
    && cd /opt/oracle \
    && wget https://download.oracle.com/otn_software/linux/instantclient/oracle-instantclient-basic-linuxx64.rpm \
    && wget https://download.oracle.com/otn_software/linux/instantclient/oracle-instantclient-devel-linuxx64.rpm \
    && alien -i oracle-instantclient-basic-linuxx64.rpm \
    && alien -i oracle-instantclient-devel-linuxx64.rpm \
    && export ORACLE_HOME=/usr/lib/oracle/19.8/client64 \
    && export LD_LIBRARY_PATH=/usr/lib/oracle/19.8/client64:$LD_LIBRARY_PATH \
    && export C_INCLUDE_PATH=/usr/include/oracle/19.8/client64 \
    && pecl install oci8 \
    && docker-php-ext-enable oci8 \
    && docker-php-ext-configure pdo_oci \
    && docker-php-ext-install pdo_oci

RUN apt-get install -y zlib1g-dev libicu-dev g++ \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install pdo_mysql zip \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN wget https://github.com/composer/composer/releases/download/1.10.8/composer.phar -O /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer && composer self-update

RUN apt-get install -y nodejs npm

RUN usermod -u 1001 www-data && groupmod -g 1001 www-data

WORKDIR /var/www
