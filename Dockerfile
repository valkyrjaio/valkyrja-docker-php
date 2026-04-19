FROM phusion/baseimage:latest

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get -y install software-properties-common

RUN add-apt-repository ppa:ondrej/php

ADD docker/apt /etc/apt

RUN apt-get update

RUN apt-get -y --reinstall --allow-unauthenticated install nginx

RUN apt-get -y --reinstall --allow-unauthenticated install php7.1

# Install php7.1-fpm with needed extensions
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-fpm
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-cli
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-common
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-json
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-opcache
#RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-mysql
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-phpdbg
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-mbstring
#RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-imap
#RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-ldap
#RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-pgsql
#RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-pspell
#RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-recode
#RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-tidy
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-dev
#RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-intl
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-gd
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-curl
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-zip
RUN apt-get -y --reinstall --allow-unauthenticated install php7.1-xml
RUN apt-get -y --reinstall --allow-unauthenticated install php-xdebug

# Install redis
#RUN apt-get update && apt-get -y install redis-server && service redis-server stop

# Update apt-get and download inotify tools
RUN apt-get update
RUN apt-get -y install inotify-tools

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Update the default nginx config
COPY docker/conf/site.conf /etc/nginx/sites-enabled/default

# Add an sh file for sync
COPY ./docker/sync.sh /var/www/sync.sh
COPY ./docker/sync-site.sh /var/www/sync-site.sh
RUN chmod 755 /var/www/sync.sh
RUN chmod 755 /var/www/sync-site.sh

RUN echo 'alias valkyrja="php /var/www/site/valkyrja"' >> ~/.bash_profile
RUN echo '. ~/.bash_profile && . /etc/bash_completion.d/valkyrja' >> ~/.bashrc
ADD ./docker/bash_completion/valkyrja /etc/bash_completion.d

# Copy this repo into place.
ADD ./valkyrja /var/www/site

# 777 the storage directory for twig cache
RUN chmod -R 777 /var/www/site/storage

RUN chmod +x /var/www/site/valkyrja
RUN sed -i 's/\r//' /etc/bash_completion.d/valkyrja

#RUN ln -sf /dev/stdout /var/log/nginx/access.log
#RUN ln -sf /dev/stderr /var/log/nginx/error.log
#RUN ln -sf /dev/stdout /var/log/php7.1-fpm.log
