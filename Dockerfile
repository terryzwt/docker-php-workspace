FROM php:7.1-cli
ENV DRUSH_VERSION 8.1.15

# Install the PHP extensions we need
RUN apt-get clean -y && apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    mysql-client \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libicu-dev \
    libssl-dev \
    libmcrypt-dev \
    python-pip \
    && pip install supervisor
## install php extension
RUN docker-php-ext-install sockets gd pdo_mysql pgsql mysqli opcache intl bcmath zip && \
    docker-php-ext-enable sockets bcmath zip pdo_mysql pcntl

## install redis & memcache
RUN pecl install redis -y && docker-php-ext-enable redis
RUN pecl install memcached && docker-php-ext-enable memcached

# install drush
RUN curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar" && \
  chmod +x /usr/local/bin/drush

# install composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
		&& php composer-setup.php \
		&& php -r "unlink('composer-setup.php');" \
		&& mv composer.phar /usr/local/bin/composer

VOLUME /app
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

CMD ["/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
