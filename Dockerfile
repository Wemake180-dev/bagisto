# Imagen base oficial con PHP 8.4 y Apache
FROM php:8.4-apache

# Instalar Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instalar dependencias del sistema necesarias para Laravel y extensiones
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libwebp-dev \
    libxpm-dev \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    opcache \
    calendar \
    intl

# Instalar Redis
RUN pecl install redis \
    && docker-php-ext-enable redis

# Habilitar mod_rewrite para Apache (necesario para Laravel)
RUN a2enmod rewrite

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY . .

# Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias de Node.js y compilar assets
RUN npm install && npm run build

# Crear directorio public en storage si no existe
RUN mkdir -p /var/www/html/storage/app/public

# Ajustar permisos (necesario para Laravel: storage y bootstrap/cache)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public

RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# Copiar configuración de Apache para habilitar Rewrite
RUN echo '<Directory /var/www/html>\n\
    AllowOverride All\n\
</Directory>' > /etc/apache2/conf-available/laravel.conf \
    && a2enconf laravel

# Exponer el puerto 80
EXPOSE 80

ENV APP_ENV=local

ENV APP_NAME=Bagisto
ENV APP_ENV=local
ENV APP_KEY=base64:IVCauzX+crlvfQvC9MGZ43U11DWn/8M5DAgYuqlZT08=
ENV APP_DEBUG=true
ENV APP_DEBUG_ALLOWED_IPS=
ENV APP_URL=http://localhost
ENV APP_ADMIN_URL=admin
ENV APP_TIMEZONE=Asia/Kolkata

ENV APP_LOCALE=en
ENV APP_FALLBACK_LOCALE=en
ENV APP_FAKER_LOCALE=en_US

ENV APP_CURRENCY=USD

ENV APP_MAINTENANCE_DRIVER=file
# APP_MAINTENANCE_STORE=database

ENV BCRYPT_ROUNDS=12

ENV LOG_CHANNEL=stack
ENV LOG_STACK=single
ENV LOG_DEPRECATIONS_CHANNEL=null
ENV LOG_LEVEL=debug

ENV DB_CONNECTION="mysql"
ENV DB_HOST="72.60.116.87"
ENV DB_PORT="3306"
ENV DB_DATABASE="lucella-db"
ENV DB_USERNAME="root"
ENV DB_PASSWORD="eFYw9gXZl2W5PCWgJCr2Gxeie9LUpSt6oaFL9kHckiUD6tYjm7qM1gEXg3eg3p2w"



# ejecutar script de entrada
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]