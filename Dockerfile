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

# Copiar y hacer ejecutable el script de entrada
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh


# ejecutar script de entrada
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]