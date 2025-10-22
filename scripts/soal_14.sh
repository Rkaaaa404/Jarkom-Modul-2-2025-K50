#!/bin/bash
# Soal 14 - Vingilot: log client IP asli lewat Sirion (fixed)

set -e

ZONE="K50.com"
NGINX_CONF="/etc/nginx/sites-available/vingilot.$ZONE"

echo "[0/5] Pastikan direktori root dan log ada..."
mkdir -p /var/www/vingilot
touch /var/log/nginx/vingilot_access.log /var/log/nginx/vingilot_error.log

echo "[1/5] Install Nginx dan PHP-FPM jika belum ada..."
apt-get update -y
apt-get install -y nginx php-fpm

echo "[2/5] Tambahkan log_format di http context (jika belum ada)..."
if ! grep -q "log_format custom" /etc/nginx/nginx.conf; then
    sed -i '/http {/a \
    \    log_format custom '\''$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'\'';' /etc/nginx/nginx.conf
fi

echo "[3/5] Buat konfigurasi Nginx Vingilot..."
cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name vingilot.$ZONE;

    root /var/www/vingilot;
    index index.php index.html;

    access_log /var/log/nginx/vingilot_access.log custom;
    error_log  /var/log/nginx/vingilot_error.log;

    location / {
        try_files \$uri /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param REMOTE_ADDR \$http_x_real_ip;  # Pastikan PHP melihat IP asli
    }
}
EOF

echo "[4/5] Aktifkan konfigurasi..."
mkdir -p /etc/nginx/sites-enabled
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/vingilot.$ZONE
rm -f /etc/nginx/sites-enabled/default

echo "[5/5] Tes dan reload Nginx..."
nginx -t
systemctl reload nginx || nginx -s reload

echo "✅ Vingilot siap, access log sekarang mencatat IP asli klien."
echo "Cek log: /var/log/nginx/vingilot_access.log"
