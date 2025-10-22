#!/bin/bash
# Soal 12: Sirion Reverse Proxy + Basic Auth

set -e

ZONE="K50.com"
NGINX_CONF="/etc/nginx/sites-available/sirion.$ZONE"
HTPASSWD_FILE="/etc/nginx/.htpasswd"

echo "[0/8] Tambahkan record /etc/hosts..."
grep -q "sirion.$ZONE" /etc/hosts || echo "192.236.3.2   sirion.$ZONE www.$ZONE" >> /etc/hosts
grep -q "lindon.$ZONE" /etc/hosts || echo "192.236.3.5   lindon.$ZONE" >> /etc/hosts
grep -q "vingilot.$ZONE" /etc/hosts || echo "192.236.3.6   vingilot.$ZONE" >> /etc/hosts

echo "[1/8] Install Nginx dan apache2-utils..."
apt-get update -y
apt-get install -y nginx apache2-utils

echo "[2/8] Buat direktori admin dan index.html..."
mkdir -p /var/www/admin
echo "Welcome to the Admin Panel" > /var/www/admin/index.html
chown -R www-data:www-data /var/www/admin
chmod 755 /var/www/admin
chmod 644 /var/www/admin/index.html

echo "[3/8] Buat htpasswd untuk /admin..."
# user: admin, pass: rahasia
htpasswd -bc $HTPASSWD_FILE admin rahasia

echo "[4/8] Buat konfigurasi Nginx Sirion..."
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name www.$ZONE sirion.$ZONE;

    # Redirect /admin tanpa trailing slash
    location = /admin {
        return 301 /admin/;
    }

    # Default redirect ke /app/
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

echo "[5/8] Aktifkan konfigurasi..."
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/sirion.$ZONE
rm -f /etc/nginx/sites-enabled/default

echo "[6/8] Tes konfigurasi..."
nginx -t

echo "[7/8] Jalankan Nginx..."
rm -f /run/nginx.pid
nginx

echo "[8/8] Selesai ✅"
echo "Coba akses:"
echo "  http://www.$ZONE/static/ → Lindon"
echo "  http://www.$ZONE/app/    → Vingilot"
echo "  http://www.$ZONE/admin/  → Basic Auth (user: admin, pass: rahasia)"
