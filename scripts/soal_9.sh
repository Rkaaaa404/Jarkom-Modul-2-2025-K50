#!/bin/bash

# 1. Install Nginx
apt-get update
apt-get install -y nginx

# 2. Buat folder dan file arsip
mkdir -p "/var/www/html/annals"
touch "/var/www/html/annals/the_silmarillion.txt"
touch "/var/www/html/annals/the_hobbit.txt"
touch "/var/www/html/annals/unfinished_tales.md"

# 3. Buat file konfigurasi Nginx
tee /etc/nginx/sites-available/static > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;

    server_name static.K50.com;
    root /var/www/html;
    index index.html;

    location /annals/ {
        autoindex on;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# 4. Aktifkan site & nonaktifkan default
ln -s /etc/nginx/sites-available/static /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 5. Tes dan reload Nginx
nginx -t
service nginx reload
