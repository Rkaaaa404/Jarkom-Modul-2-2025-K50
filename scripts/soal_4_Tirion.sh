#!/bin/bash
# === Tirion (ns1/master) setup script ===
GROUP=K50
DOMAIN=${GROUP}.com

# Pastikan bind9 terpasang
if ! command -v named &> /dev/null; then
    apt update -y
    apt install bind9 dnsutils -y
fi

mkdir -p /var/log/named
chown bind:bind /var/log/named

# Konfigurasi utama zona
cat > /etc/bind/named.conf.local << EOF
zone "${DOMAIN}" {
    type master;
    file "/etc/bind/zones/db.${DOMAIN}";
    allow-transfer { 192.236.3.4; };   // Valmar
    notify yes;
};
EOF

# Konfigurasi untuk forwarders ke internet
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;   // forward ke DNS eksternal
    };

    allow-query { any; };
    recursion yes;

    dnssec-validation no;

    listen-on { any; };
};
EOF

# File zona utama
mkdir -p /etc/bind/zones
cat > /etc/bind/zones/db.${DOMAIN} <<EOF
\$TTL 604800
@       IN      SOA     ns1.${DOMAIN}. admin.${DOMAIN}. (
                        2025101201 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
        IN      NS      ns1.${DOMAIN}.
        IN      NS      ns2.${DOMAIN}.
ns1     IN      A       192.236.3.3
ns2     IN      A       192.236.3.4
@       IN      A       192.236.3.2   ; Sirion / front door
EOF

# Pastikan permission aman
chown -R bind:bind /etc/bind

# Jalankan BIND
pkill named
named -u bind -c /etc/bind/named.conf &
echo "[Tirion] BIND9 master (${DOMAIN}) started."
