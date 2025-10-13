#!/bin/bash

# Script untuk append CNAME records ke db.K50.com

# Menggunakan 'tee -a' untuk APPEND (menambahkan) ke file.
tee -a /etc/bind/zones/db.K50.com > /dev/null <<'EOF'

; Service Aliases (CNAME Records for public-facing names)
www         IN      CNAME   sirion.K50.com.
static      IN      CNAME   lindon.K50.com.
app         IN      CNAME   vingilot.K50.com.
EOF

echo "CNAME records berhasil di-append ke /etc/bind/zones/db.K50.com"
echo "Janlup naikin serial number terus run command: rndc reload"