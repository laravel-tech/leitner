FROM php:8.2-fpm

ARG user
ARG uid

WORKDIR /var/www

COPY composer.lock composer.json /var/www/html/

RUN apt-get update && apt-get install -y \
    iputils-ping \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libpng-dev libxpm-dev \
    libfreetype6-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd \
    --enable-gd \
    --with-webp=\usr\include/ \
    --with-jpeg=/usr/include/ \
    --with-xpm=/ussr/include/ \
    --with-freetype=/usr/include/
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

COPY . .

RUN chown root:root /var/www

RUN chmod -R 777 /var/www/

USER $user
