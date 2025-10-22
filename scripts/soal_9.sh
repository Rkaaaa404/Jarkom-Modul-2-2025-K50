#!/bin/bash

# Soal 9 - Server Lindon (Static Server)
# Menyediakan arsip di http://static.K50.com/annals/

set -e

echo "[1/5] Install Nginx..."
apt-get update -y
apt-get install -y nginx

echo "[2/5] Siapkan direktori dan file arsip..."
mkdir -p /var/www/static.K50.com/annals
echo "Isi dari The Silmarillion" > /var/www/static.K50.com/annals/the_silmarillion.txt
echo "Isi dari The Hobbit" > /var/www/static.K50.com/annals/the_hobbit.txt
echo "Isi dari Unfinished Tales" > /var/www/static.K50.com/annals/unfinished_tales.md

echo "[3/5] Buat konfigurasi Nginx untuk static.K50.com..."
tee /etc/nginx/sites-available/static.K50.com > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;

    server_name static.K50.com;

    root /var/www/static.K50.com;
    index index.html;

    location /annals/ {
        autoindex on;
    }

    location / {
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/static_access.log;
    error_log /var/log/nginx/static_error.log;
}
EOF

echo "[4/5] Aktifkan konfigurasi..."
ln -sf /etc/nginx/sites-available/static.K50.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

echo "[5/5] Tes dan jalankan Nginx..."
nginx -t
rm -f /var/run/nginx.pid
nginx -s stop 2>/dev/null || true
nginx


echo "✅ Server Lindon siap diakses di http://static.K50.com/annals/"
