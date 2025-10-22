#!/bin/bash

ZONE_FILE="/etc/bind/zones/db.K50.com"
DOMAIN="K50.com"

echo "[*] Menaikkan serial number di $ZONE_FILE..."

# Ambil serial lama dari baris SOA (angka pertama dalam tanda kurung)
old_serial=$(awk '/SOA/,/\)/ { if ($1 ~ /^[0-9]+$/) { print $1; exit } }' "$ZONE_FILE")

if [[ -z "$old_serial" ]]; then
  echo "[!] Gagal menemukan serial number di file zona."
  exit 1
fi

# Hitung serial baru
new_serial=$((old_serial + 1))

# Ganti serial lama dengan serial baru di file zona
sed -i "0,/$old_serial/s//$new_serial/" "$ZONE_FILE"

echo "[*] Serial lama: $old_serial"
echo "[*] Serial baru: $new_serial"

# Menggunakan 'tee -a' untuk APPEND (menambahkan) ke file.
tee -a /etc/bind/zones/db.K50.com > /dev/null <<'EOF'

; Service Aliases (CNAME Records for public-facing names)
www         IN      CNAME   sirion.K50.com.
static      IN      CNAME   lindon.K50.com.
app         IN      CNAME   vingilot.K50.com.
EOF

# Restart BIND
echo "[*] Me-restart BIND9..."
pkill named 2>/dev/null
named -u bind -c /etc/bind/named.conf &

echo "CNAME records berhasil di-append"
