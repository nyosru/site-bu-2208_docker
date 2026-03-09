#FROM dockerhub.timeweb.cloud/library/node:latest AS node
FROM node:latest AS node
#FROM dockerhub.timeweb.cloud/library/php:8.2-fpm
FROM php:8.2-fpm

COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Устанавливаем последнюю версию npm
RUN npm install -g npm@latest && npm install -g npx --force

ARG PHPGROUP
ARG PHPUSER
ARG FOLDER

ENV PHPGROUP=${PHPGROUP}
ENV PHPUSER=${PHPUSER}
ENV FOLDER=${FOLDER}

WORKDIR ${FOLDER}

USER ${PHPUSER}

# Установка необходимых пакетов и расширений PHP.
# Добавлены PostgreSQL-драйверы для работы приложения с db_bu (PostgreSQL).
#RUN apt-get update -y \
#    && apt-get install -y git libzip-dev libxml2-dev \
#    && docker-php-ext-install pdo_mysql zip \
#    && docker-php-ext-enable zip
RUN apt-get update -y \
    && apt-get install -y git libzip-dev libxml2-dev libpq-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql pgsql zip \
    && docker-php-ext-enable zip

# Установка расширения SOAP
#RUN docker-php-ext-install soap \
#    && pecl install xdebug \
#    && docker-php-ext-enable xdebug

# Install GD extension
RUN apt-get update \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-enable gd

# Увеличиваем лимиты загрузки файлов
RUN echo "upload_max_filesize = 100M\npost_max_size = 100M" > /usr/local/etc/php/conf.d/uploads.ini

# # # Get latest Composer
COPY --from=dockerhub.timeweb.cloud/library/composer:latest /usr/bin/composer /usr/bin/composer


# Очистка кеша apt для уменьшения размера образа
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#RUN cd /2309livewire && chmod -R 0777 storage
