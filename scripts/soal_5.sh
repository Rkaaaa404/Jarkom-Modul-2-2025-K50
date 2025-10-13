#!/bin/bash

# Script untuk append A records ke db.K50.com

# Menggunakan 'tee -a' untuk APPEND (menambahkan) ke file, bukan overwrite.
# 'EOF' diapit kutip tunggal biar isinya dianggap literal,
# jadi simbol kayak '$' nggak akan diekspansi sama shell.
tee -a /etc/bind/zones/db.K50.com > /dev/null <<'EOF'

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

echo "A records berhasil di-append ke /etc/bind/zones/db.K50.com"
echo "Jangan lupa naikin Serial Number terus run: rndc reload"