FROM php:7.1-cli
ENV DRUSH_VERSION 8.1.15

## install supervisor
RUN pecl install redis -y && docker-php-ext-enable redis
RUN /usr/local/bin/docker-php-ext-install pcntl
RUN apt-get -y update && apt-get -y install python-pip && pip install supervisor

# Install the PHP extensions we need
RUN apt-get clean -y && \
apt-get update && \
apt-get install -y --no-install-recommends \
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
    libmcrypt-dev && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
    docker-php-ext-install sockets gd pdo_mysql mysqli opcache intl bcmath zip && \
    docker-php-ext-enable sockets bcmath zip pdo_mysql

# drush command
RUN curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar" && \
  chmod +x /usr/local/bin/drush

# install composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
		&& php composer-setup.php \
		&& php -r "unlink('composer-setup.php');" \
		&& mv composer.phar /usr/local/bin/composer

EXPOSE 9001

VOLUME /app/web
WORKDIR /app/web

CMD ["/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
