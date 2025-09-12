#!/bin/bash
set -e

echo "Iniciando contenedor Laravel/Bagisto..."
echo "=== CONFIGURACIÓN ACTUAL ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"
echo "=============================="

# Test de conectividad TCP
echo "1. Probando conectividad TCP..."
timeout 10 bash -c "cat < /dev/null > /dev/tcp/$DB_HOST/$DB_PORT" && echo "✅ TCP conecta" || echo "❌ TCP falla"

# Test con mysql command
echo "2. Probando comando mysql directo..."
mysql -h$DB_HOST -P$DB_PORT -u$DB_USERNAME -p$DB_PASSWORD -e "SELECT 1 as test;" 2>&1 | head -10

echo "3. Listando bases de datos disponibles..."
mysql -h$DB_HOST -P$DB_PORT -u$DB_USERNAME -p$DB_PASSWORD -e "SHOW DATABASES;" 2>&1 | head -10

echo "4. Probando Laravel config..."
php artisan config:clear
php artisan config:cache

echo "5. Test de Laravel migrate:status con debug..."
php artisan migrate:status --verbose 2>&1 | head -15

echo "=========================="

echo "Configurando storage..."
if [ -L "/var/www/html/public/storage" ]; then
    rm /var/www/html/public/storage
fi
ln -sfn /var/www/html/storage/app/public /var/www/html/public/storage


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