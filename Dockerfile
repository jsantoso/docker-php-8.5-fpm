FROM php:8.5-fpm
WORKDIR /var/www

LABEL maintainer="Jeffrey Santoso <jeffrey.k.santoso@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
ENV PHP_DISPLAY_ERRORS  off
ENV PHP_ERROR_REPORTING  E_ALL & ~E_NOTICE
ENV XDEBUG_HOST host.docker.internal
ENV XDEBUG_PORT 9000
ENV XDEBUG_IDE_KEY PHPSTORM

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
        apt-utils \
        vim \
        libpng-dev \
        zlib1g-dev \
        libpspell-dev \
        libldap2-dev \
        libcurl4 \
        libcurl3-dev \ 
        libbz2-dev \ 
        libpq-dev \
        libxml2-dev \
        libz-dev \
        libzip-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libreadline-dev \
        librabbitmq-dev \
        unzip \
        libonig-dev \
        iproute2 \
        iputils-ping \
        imagemagick \
        lftp \
        poppler-utils \
        zip \
        p7zip-full \
        pdftk \
        expect \
        mkisofs \
        dcmtk \
        wget \
        libmagickwand-dev \
        tesseract-ocr \
        unixodbc \
        unixodbc-dev \

    && apt-get autoclean && apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
    &&  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \

    && echo alias ll=\'ls -lF\' >> /root/.bashrc

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \

    && /usr/local/bin/docker-php-ext-install mbstring \
    && /usr/local/bin/docker-php-ext-install iconv \
    && /usr/local/bin/docker-php-ext-install gd \
    && /usr/local/bin/docker-php-ext-install bz2 \
    && /usr/local/bin/docker-php-ext-install pdo \
    && /usr/local/bin/docker-php-ext-install pdo_pgsql \
    && /usr/local/bin/docker-php-ext-install pgsql \
    && /usr/local/bin/docker-php-ext-install soap \
    && /usr/local/bin/docker-php-ext-install xml \
    && /usr/local/bin/docker-php-ext-install zip \
    && /usr/local/bin/docker-php-ext-install bcmath \
    && /usr/local/bin/docker-php-ext-install ldap \
    && /usr/local/bin/docker-php-ext-install curl \
    && /usr/local/bin/docker-php-ext-install sockets \
    && /usr/local/bin/docker-php-ext-install ctype \

    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install pdo_odbc

ADD etc/ImageMagick/policy.xml /etc/ImageMagick-6/policy.xml

RUN pecl install xmlrpc-beta && docker-php-ext-enable xmlrpc \
    && pecl install redis && docker-php-ext-enable redis \
    && pecl install amqp-beta && docker-php-ext-enable amqp \
    && pecl install xdebug \
    && pecl install memcached \
    && echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

ARG IMAGICK_VERSION=3.8.0

RUN curl -L -o /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/refs/tags/${IMAGICK_VERSION}.tar.gz \
    && tar --strip-components=1 -xf /tmp/imagick.tar.gz \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && rm -rf /tmp/*

RUN sed -i 's/pm\.max_children = [0-9]*/pm.max_children = 50/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm\.start_servers = [0-9]*/pm.start_servers = 10/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm\.min_spare_servers = [0-9]*/pm.min_spare_servers = 5/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm\.max_spare_servers = [0-9]*/pm.max_spare_servers = 20/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;pm\.max_requests/pm.max_requests/' /usr/local/etc/php-fpm.d/www.conf 

ADD conf.d/php.ini /etc/php/8.5/php.ini
ADD conf.d/xdebug.ini /etc/php/8.5/xdebug.ini

RUN mkdir -p /etc/php/8.5/fpm/conf.d \
    && ln -s /etc/php/8.5/php.ini /etc/php/8.5/fpm/conf.d/90-tris.ini \
    && ln -s /etc/php/8.5/xdebug.ini /etc/php/8.5/fpm/conf.d/90-xdebug.ini \

    && mkdir -p /etc/php/8.5/cli/conf.d \
    && ln -s /etc/php/8.5/php.ini /etc/php/8.5/cli/conf.d/90-tris.ini \
    && ln -s /etc/php/8.5/xdebug.ini /etc/php/8.5/cli/conf.d/90-xdebug.ini \

    && mkdir -p /usr/local/etc/php/conf.d \
    && ln -s /etc/php/8.5/php.ini /usr/local/etc/php/conf.d/90-tris.ini \
    && ln -s /etc/php/8.5/xdebug.ini /usr/local/etc/php/conf.d/90-xdebug.ini

WORKDIR /var/www/html

EXPOSE 9000

COPY start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh", "php-fpm"]
