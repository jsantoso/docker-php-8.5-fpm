#!/bin/bash

source /etc/bashrc

set -e

ip -4 route list match 0/0 | awk '{print $$3" host.docker.internal"}' >> /etc/hosts

if [ ! -z "$ENABLE_XDEBUG" ]; then
  echo "*** Enabling xdebug"
  docker-php-ext-enable xdebug
fi

# If we're launching in local mode, set container to dev mode
if [[ "$APP_ENV" == "local" ]] ; then
  echo "*** Local mode - disabling opcache, setting development.ini"
  rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
  ln -fs /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
fi

exec $@
