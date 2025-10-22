#!/bin/bash
# Soal 10 - Web Dinamis (PHP-FPM + Nginx) untuk Debian 13 (Trixie fix pakai bookworm repo)

set -e

echo "[+] Update repo & install dependensi dasar..."
apt update -y
apt install -y lsb-release ca-certificates curl gnupg2 apt-transport-https

echo "[+] Tambahkan repository PHP (pakai bookworm karena trixie belum didukung)..."
mkdir -p /usr/share/keyrings
curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury.gpg
echo "deb [signed-by=/usr/share/keyrings/sury.gpg] https://packages.sury.org/php/ bookworm main" > /etc/apt/sources.list.d/php.list

apt update -y

echo "[+] Instal Nginx dan PHP-FPM..."
apt install -y nginx php8.2-fpm php8.2-cli

echo "[+] Jalankan PHP-FPM..."
mkdir -p /run/php
php-fpm8.2 -D
sleep 2

PHP_SOCK=$(find /run/php -name "php*-fpm.sock" | head -n 1)
echo "    Socket PHP-FPM: $PHP_SOCK"

echo "[+] Siapkan direktori web..."
mkdir -p /var/www/app.K50.com

cat > /var/www/app.K50.com/index.php <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Home - App K50</title></head>
<body>
<h1>Selamat datang di App K50!</h1>
<p>Halaman ini disajikan melalui PHP-FPM.</p>
<a href="/about">Pergi ke halaman About</a>
</body>
</html>
EOF

cat > /var/www/app.K50.com/about.php <<'EOF'
<!DOCTYPE html>
<html>
<head><title>About - App K50</title></head>
<body>
<h1>About</h1>
<p>Halaman ini tampil tanpa ekstensi .php (rewrite Nginx).</p>
<a href="/">Kembali ke Home</a>
</body>
</html>
EOF

echo "[+] Konfigurasi Nginx untuk app.K50.com..."
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

cat > /etc/nginx/sites-available/app.K50.com <<EOF
server {
    listen 80;
    server_name app.K50.com;

    root /var/www/app.K50.com;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location /about {
        rewrite ^/about\$ /about.php last;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_SOCK;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/app.K50.com /etc/nginx/sites-enabled/app.K50.com

echo "[+] Jalankan Nginx (tanpa systemctl)..."
nginx -g 'daemon off;' &
sleep 3

echo "[+] Tambahkan host lokal ke /etc/hosts..."
grep -q "app.K50.com" /etc/hosts || echo "127.0.0.1 app.K50.com" >> /etc/hosts

echo "[+] Tes akses ke web..."
curl -s http://app.K50.com/ | head -n 5

echo "[✓] Web dinamis app.K50.com aktif!"
