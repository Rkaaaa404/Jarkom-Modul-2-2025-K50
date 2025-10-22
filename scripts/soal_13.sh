#!/bin/bash
# Soal 13: Sirion Reverse Proxy + Canonical Host Redirect

set -e

ZONE="K50.com"
NGINX_CONF="/etc/nginx/sites-available/sirion.$ZONE"
HTPASSWD_FILE="/etc/nginx/.htpasswd"

echo "[0/6] Tambahkan record /etc/hosts..."
grep -q "sirion.$ZONE" /etc/hosts || echo "192.236.3.2   sirion.$ZONE" >> /etc/hosts
grep -q "lindon.$ZONE" /etc/hosts || echo "192.236.3.5   lindon.$ZONE" >> /etc/hosts
grep -q "vingilot.$ZONE" /etc/hosts || echo "192.236.3.6   vingilot.$ZONE" >> /etc/hosts

echo "[1/6] Install Nginx & apache2-utils..."
apt-get update -y
apt-get install -y nginx apache2-utils

echo "[2/6] Buat htpasswd untuk /admin (user: admin, pass: rahasia)..."
htpasswd -bc $HTPASSWD_FILE admin rahasia

echo "[3/6] Buat konfigurasi Nginx Sirion..."
cat > $NGINX_CONF <<EOF
# Server block untuk canonical redirect
server {
    listen 80;
    server_name 192.236.3.2 sirion.$ZONE;

    # Redirect semua ke hostname kanonik
    return 301 http://www.$ZONE\$request_uri;
}

# Server block utama untuk www.K50.com
server {
    listen 80;
    server_name www.$ZONE;

    # Default redirect ke /app/ jika root diakses
    location = / {
        return 301 /app/;
    }

    # Proxy ke Lindon untuk /static/
    location /static/ {
        proxy_pass http://lindon.$ZONE/annals/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Proxy ke Vingilot untuk /app/
    location /app/ {
        proxy_pass http://vingilot.$ZONE/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Basic Auth untuk /admin/
    location /admin/ {
        auth_basic "Restricted Area";
        auth_basic_user_file $HTPASSWD_FILE;
        alias /var/www/admin/;
        index index.html;
    }

    access_log /var/log/nginx/sirion_access.log;
    error_log  /var/log/nginx/sirion_error.log;
}
EOF

echo "[4/6] Aktifkan konfigurasi..."
mkdir -p /etc/nginx/sites-enabled
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/sirion.$ZONE
rm -f /etc/nginx/sites-enabled/default

echo "[5/6] Tes konfigurasi..."
nginx -t

echo "[6/6] Jalankan Nginx..."
rm -f /run/nginx.pid
nginx

echo "✅ Sirion siap dengan canonical redirect!"
echo "Coba akses:"
echo "  http://192.236.3.2/      → redirect ke http://www.$ZONE/"
echo "  http://sirion.$ZONE/     → redirect ke http://www.$ZONE/"
echo "  http://www.$ZONE/static/ → Lindon"
echo "  http://www.$ZONE/app/    → Vingilot"
echo "  http://www.$ZONE/admin/  → Basic Auth (user: admin, pass: rahasia)"
