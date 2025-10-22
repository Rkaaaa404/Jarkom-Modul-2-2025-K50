#!/bin/bash

# Soal 11 - Reverse Proxy Sirion

set -e

ZONE="K50.com"
NGINX_CONF_DIR="/etc/nginx"
SITES_AVAILABLE="$NGINX_CONF_DIR/sites-available"
SITES_ENABLED="$NGINX_CONF_DIR/sites-enabled"

echo "[0/6] Menambahkan record /etc/hosts..."
grep -q "sirion.$ZONE" /etc/hosts || echo "192.236.3.2   sirion.$ZONE [www.$ZONE](http://www.$ZONE)" >> /etc/hosts
grep -q "lindon.$ZONE" /etc/hosts || echo "192.236.3.5   lindon.$ZONE" >> /etc/hosts
grep -q "vingilot.$ZONE" /etc/hosts || echo "192.236.3.6   vingilot.$ZONE" >> /etc/hosts

echo "[1/6] Instal nginx..."
apt-get update -y
apt-get install -y nginx

echo "[2/6] Membuat konfigurasi reverse proxy..."
mkdir -p "$SITES_AVAILABLE" "$SITES_ENABLED"

tee "$SITES_AVAILABLE/sirion.$ZONE" > /dev/null <<'EOF'
server {
listen 80;
server_name www.K50.com sirion.K50.com;

# Proxy ke Lindon untuk /static → arahkan ke /annals/ di backend
location /static/ {
    proxy_pass http://lindon.K50.com/annals/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

# Proxy ke Vingilot untuk /app → arahkan ke root backend
location /app/ {
    proxy_pass http://vingilot.K50.com/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

# Default: redirect ke /app
location / {
    return 301 /app/;
}

access_log /var/log/nginx/sirion_access.log;
error_log /var/log/nginx/sirion_error.log;

}
EOF

echo "[3/6] Aktifkan konfigurasi..."
ln -sf "$SITES_AVAILABLE/sirion.$ZONE" "$SITES_ENABLED/sirion.$ZONE"
rm -f "$SITES_ENABLED/default"

echo "[4/6] Uji konfigurasi..."
nginx -t

echo "[5/6] Jalankan nginx..."
rm -f /var/run/nginx.pid
nginx -s stop 2>/dev/null || true
nginx

echo "✅ Sirion siap sebagai reverse proxy:"
echo "   [http://www.K50.com/static/](http://www.K50.com/static/) → Lindon (annals)"
echo "   [http://www.K50.com/app/](http://www.K50.com/app/)    → Vingilot"
echo "   Header Host & X-Real-IP diteruskan."
