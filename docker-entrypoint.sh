#!/bin/bash
set -e

echo "Iniciando contenedor Laravel/Bagisto..."
echo "=== CONFIGURACIÓN ACTUAL ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"
echo "=============================="

echo "Configurando storage..."
if [ -L "/var/www/html/public/storage" ]; then
    rm /var/www/html/public/storage
fi
ln -sfn /var/www/html/storage/app/public /var/www/html/public/storage


# Esperar a que la BD esté disponible con un enfoque más robusto
echo "Verificando conexión a la base de datos..."
until php -r "
try {
    \$pdo = new PDO('mysql:host='.\$_ENV['DB_HOST'].';port='.\$_ENV['DB_PORT'].';dbname='.\$_ENV['DB_DATABASE'], \$_ENV['DB_USERNAME'], \$_ENV['DB_PASSWORD']);
    echo 'OK';
} catch(PDOException \$e) {
    exit(1);
}
" > /dev/null 2>&1; do
    echo "Esperando conexión a la base de datos..."
    sleep 3
done

echo "Base de datos conectada. Configurando migraciones..."
# Asegurar que existe la tabla de migraciones
php artisan migrate:install --force > /dev/null 2>&1 || true

echo "Ejecutando migraciones..."
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