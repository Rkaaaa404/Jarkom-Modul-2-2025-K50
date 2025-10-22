#!/bin/bash
# === Valmar (ns2/slave) setup script ===
GROUP=K50
DOMAIN=${GROUP}.com

if ! command -v named &> /dev/null; then
    apt update -y
    apt install bind9 dnsutils -y
fi

mkdir -p /var/log/named
mkdir -p /etc/bind/zones
chown bind:bind /var/log/named

# Konfigurasi logging + zona slave
cat > /etc/bind/named.conf.local <<EOF

zone "${DOMAIN}" {
    type slave;
    masters { 192.236.3.3; };  // Tirion (master)
    file "/etc/bind/zones/db.${DOMAIN}";
};
EOF

# Konfigurasi forwarders
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    recursion yes;
    dnssec-validation no;
};
EOF

chown -R bind:bind /etc/bind

pkill named 2>/dev/null
named -u bind -c /etc/bind/named.conf &
echo "[Valmar] BIND9 slave (${DOMAIN}) started and waiting for zone transfer."
