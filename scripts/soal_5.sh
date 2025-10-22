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

# Tambahkan A records baru
echo "[*] Menambahkan A records ke $ZONE_FILE..."

tee -a "$ZONE_FILE" > /dev/null <<'EOF'

; hostname record
eonwe       IN      A       192.236.1.1    ; IP eth1 Eonwe
earendil    IN      A       192.236.1.2
elwing      IN      A       192.236.1.3
cirdan      IN      A       192.236.2.2
elrond      IN      A       192.236.2.3
maglor      IN      A       192.236.2.4
sirion      IN      A       192.236.3.2
tirion      IN      A       192.236.3.3
valmar      IN      A       192.236.3.4
lindon      IN      A       192.236.3.5
vingilot    IN      A       192.236.3.6
EOF

# Restart BIND
echo "[*] Me-restart BIND9..."
pkill named 2>/dev/null
named -u bind -c /etc/bind/named.conf &

echo "[✅] A records berhasil ditambahkan dan serial zone dinaikkan!"
