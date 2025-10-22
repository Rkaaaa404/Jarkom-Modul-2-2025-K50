#!/bin/bash

# --- Configs ---
REVERSE_ZONE="3.236.192.in-addr.arpa"
MASTER_IP="192.236.3.3"

# Deklarasi slave zone di named.conf.local
tee -a /etc/bind/named.conf.local > /dev/null <<EOF

zone "$REVERSE_ZONE" {
    type slave;
    file "/var/lib/bind/db.192.236.3";
    masters { $MASTER_IP; };
};
EOF

# Reload
pkill named 2>/dev/null
named -u bind -c /etc/bind/named.conf &

echo "Setup reverse slave di Valmar selesai. Cek syslog buat liat transfer log."
