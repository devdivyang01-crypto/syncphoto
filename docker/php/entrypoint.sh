#!/bin/sh
set -eu

cd /var/www/html

if [ "${SKIP_LARAVEL_BOOTSTRAP:-false}" != "true" ]; then
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache || true
fi

if [ "${MIGRATE_ON_START:-false}" = "true" ]; then
    php artisan migrate --force --no-interaction
fi

exec "$@"
