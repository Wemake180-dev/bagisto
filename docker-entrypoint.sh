#!/bin/bash
set -e

echo "Iniciando contenedor Laravel/Bagisto..."
echo "=== CONFIGURACIÓN ACTUAL ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"
echo "SKIP_DB_SEED: $SKIP_DB_SEED"
echo "=============================="

# CRÍTICO: Manejar el enlace simbólico correctamente
echo "Configurando storage..."

# Asegurar que los directorios existen en storage
mkdir -p /var/www/html/storage/app/public
mkdir -p /var/www/html/storage/framework/{cache,sessions,views}
mkdir -p /var/www/html/storage/logs

# IMPORTANTE: Si public/storage existe como directorio real (por el volumen), eliminarlo
if [ -d "/var/www/html/public/storage" ] && [ ! -L "/var/www/html/public/storage" ]; then
    echo "Encontrado directorio real en public/storage, eliminando para crear enlace simbólico..."
    rm -rf /var/www/html/public/storage
fi

# Eliminar enlace simbólico viejo si existe
if [ -L "/var/www/html/public/storage" ]; then
    echo "Eliminando enlace simbólico antiguo..."
    rm /var/www/html/public/storage
fi

# Crear enlace simbólico
echo "Creando enlace simbólico..."
ln -sfn /var/www/html/storage/app/public /var/www/html/public/storage

# Verificar
if [ -L "/var/www/html/public/storage" ]; then
    echo "✓ Enlace simbólico creado correctamente"
    echo "  Apunta a: $(readlink -f /var/www/html/public/storage)"
else
    echo "✗ ERROR: No se pudo crear el enlace simbólico"
fi

# Permisos
chown -R www-data:www-data /var/www/html/storage
chmod -R 775 /var/www/html/storage

# Esperar a que la BD esté disponible
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

# Verificar si debemos ejecutar seeders
if [ "$SKIP_DB_SEED" != "true" ]; then
    echo "Verificando si la base de datos necesita seeders..."
    
    # Verificar si la tabla cms_page_channels está vacía
    TABLE_COUNT=$(php -r "
    try {
        \$pdo = new PDO('mysql:host='.\$_ENV['DB_HOST'].';port='.\$_ENV['DB_PORT'].';dbname='.\$_ENV['DB_DATABASE'], \$_ENV['DB_USERNAME'], \$_ENV['DB_PASSWORD']);
        \$stmt = \$pdo->query('SELECT COUNT(*) FROM cms_page_channels');
        if (\$stmt) {
            echo \$stmt->fetchColumn();
        } else {
            echo '0';
        }
    } catch(Exception \$e) {
        echo '0';
    }
    " 2>/dev/null || echo "0")
    
    if [ "$TABLE_COUNT" = "0" ] || [ -z "$TABLE_COUNT" ]; then
        echo "Base de datos vacía. Ejecutando seeders..."
        php artisan db:seed --force || {
            echo "Advertencia: Algunos seeders fallaron, pero continuando..."
        }
        echo "Seeders completados."
    else
        echo "Base de datos ya tiene $TABLE_COUNT registros. Saltando seeders..."
    fi
else
    echo "SKIP_DB_SEED está activo, saltando verificación de seeders..."
fi

# IMPORTANTE: Forzar recreación del enlace con Artisan (por si acaso)
echo "Ejecutando storage:link de Laravel..."
php artisan storage:link --force || true

# Debug: mostrar estructura para verificación
echo "=== Verificación de Storage ==="
echo "Contenido de storage/app/public (primeros 5 archivos):"
ls -la /var/www/html/storage/app/public/ 2>/dev/null | head -6 || echo "Directorio vacío o no existe"
echo ""
echo "Estado del enlace simbólico:"
ls -la /var/www/html/public/ | grep storage || echo "Enlace no encontrado"
echo "=============================="

# Optimizaciones (con manejo de errores)
echo "Optimizando aplicación..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Permisos finales (importante hacerlo después de todo)
echo "Ajustando permisos finales..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "¡Aplicación lista! Iniciando Apache..."

# Ejecutar el comando pasado (apache2-foreground)
exec "$@"