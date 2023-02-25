FROM php:8.0-apache
MAINTAINER Sparkle Nigera

# ENV APPHOST http://localhost:80
ENV APPHTTPS false
ENV DATABASE_NAME osticket
ENV DATABASE_USERNAME osticket
ENV DATABASE_PASSWORD osticket
ENV OSTICKET_VERSION 1.9.14
ENV HOME /var/www/html/

RUN apt-get update && \
    apt-get install -y --install-recommends \
    curl \
    nano \
    cron \
    libzip-dev \
    libz-dev \
    libssl-dev \
    libxml2-dev \
    libmcrypt-dev \
    libc-client-dev \
    # unzip \
    # wget \
    libkrb5-dev

# Install gd
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd

# Install APCu
RUN pecl install apcu \
    && docker-php-ext-enable apcu

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN pecl config-set php_ini "$PHP_INI_DIR/php.ini"
RUN ls -l "$PHP_INI_DIR/"
#RUN ls -l /usr/src/php/ext/

# Install the PHP mcrypt extention
RUN pecl install mcrypt-1.0.4 \
   && echo "extension=mcrypt.so" > "$PHP_INI_DIR/php.ini"
# RUN docker-php-ext-install mcrypt
# Install mbstring
#RUN docker-php-ext-install mbstring
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions mbstring pdo_mysql zip exif pcntl gd
# Install xml
RUN docker-php-ext-install xml
# Install fileinfo
RUN docker-php-ext-install fileinfo
# Install the PHP pdo_mysql extention
RUN docker-php-ext-install mysqli \
    && docker-php-ext-install pdo_mysql
# Install zip
RUN apt-get install -y \
        zlib1g-dev \
    && docker-php-ext-install zip
# Install imap
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
        && docker-php-ext-install imap \
        && docker-php-ext-enable imap
# Install Intl
RUN docker-php-ext-install intl
# Install Zend OPcache
RUN docker-php-ext-install opcache 

# Cleaning up

# RUN pecl clear-cache


# Copy app code
COPY ./build /var/www/html/
# Copy error for DEBUG
COPY build/error.ini  /usr/local/etc/php/conf.d/

# Configure cron job
# Add crontab file in the cron directory
RUN crontab /var/www/html/crontab
# Create the log file to be able to run tail
RUN touch /var/log/cron.log
# Reload cron
RUN service cron reload

# Enable Apache mod_rewrite
RUN a2enmod rewrite
# Change Apache User
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
# Bind Apache User with our User
RUN usermod --non-unique --uid 1000 www-data
RUN groupmod --non-unique --gid 1000 www-data
RUN chown -hR www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

VOLUME ["/var/www/html/storage", "/var/www/html/custom"]

CMD cron; apache2-foreground
RUN touch /var/www/html/config.php
RUN chmod 766 /var/www/html/config.php
# RUN chown www-data:www-data -R
EXPOSE 80
