#!/bin/bash
set -e

echo "Iniciando contenedor Laravel/Bagisto..."

# Esperar a que la BD esté disponible
echo "Verificando conexión a la base de datos..."
until php artisan migrate:status > /dev/null 2>&1; do
    echo "Esperando conexión a la base de datos..."
    sleep 3
done

echo "Base de datos conectada. Ejecutando migraciones..."
php artisan migrate --force

# Solo en desarrollo: ejecutar seeders
if [ "$APP_ENV" = "local" ] || [ "$RUN_SEEDERS" = "true" ]; then
    echo "Ejecutando seeders..."
    php artisan db:seed --force
fi

# Optimizaciones
echo "Optimizando aplicación..."
php artisan config:cache
php artisan route:cache

echo "¡Aplicación lista!"

# Ejecutar el comando pasado (apache2-foreground)
exec "$@"