#!/bin/sh
set -e

# Apache listen di port yang diberikan Cloud Run
sed -ri "s/Listen [0-9]+/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:[0-9]+>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Cache config/route/view saat container start (env var Cloud Run sudah tersedia di sini).
# Tidak ada migrasi di sini.
php artisan package:discover --ansi
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec "$@"
