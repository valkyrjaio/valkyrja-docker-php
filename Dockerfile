#
# This file is part of the Valkyrja Docker package.
#
# Copyright (c) 2016-present Melech Mizrachi
#
# Released under the MIT License. See LICENSE.md for details.
#

FROM php:8.4.27-fpm-bookworm

# Install nginx, the inotify tools, and the libraries the PHP extensions need
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        inotify-tools \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the PHP extensions that the base image does not include
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd zip

RUN pecl install xdebug-3.5.3 \
    && docker-php-ext-enable xdebug

# Start a debug session only when the request asks for one, and connect to the IDE on the host
RUN { \
        echo 'xdebug.mode=debug'; \
        echo 'xdebug.start_with_request=trigger'; \
        echo 'xdebug.client_host=host.docker.internal'; \
    } > /usr/local/etc/php/conf.d/xdebug.ini

# Update the default nginx config
COPY docker/conf/site.conf /etc/nginx/sites-enabled/default

# Add an sh file for sync
COPY ./docker/sync.sh /var/www/sync.sh
COPY ./docker/sync-site.sh /var/www/sync-site.sh
RUN chmod 755 /var/www/sync.sh
RUN chmod 755 /var/www/sync-site.sh

RUN echo 'alias valkyrja="php /var/www/site/app/bin/cli"' >> ~/.bash_profile
RUN echo '. ~/.bash_profile && . /etc/bash_completion.d/valkyrja' >> ~/.bashrc
ADD ./docker/bash_completion/valkyrja /etc/bash_completion.d/

# Copy this repo into place.
ADD ./valkyrja /var/www/site

# Let PHP-FPM write the logs, the cache, and the compiled views
RUN chmod -R 777 /var/www/site/app/storage

RUN chmod +x /var/www/site/app/bin/cli
RUN sed -i 's/\r//' /etc/bash_completion.d/valkyrja

# Run nginx in the background and PHP-FPM in the foreground as the main process
CMD ["sh", "-c", "nginx && exec php-fpm"]
