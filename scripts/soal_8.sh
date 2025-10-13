#!/bin/bash
# ________+++++ SIRION +++++______
# --- Configs ---
DOMAIN="K50.com"
REVERSE_ZONE="3.236.192.in-addr.arpa"
REVERSE_ZONE_FILE="/etc/bind/zones/db.192.236.3"
SLAVE_IP="192.236.3.4"

# Deklarasi zone di named.conf.local
tee -a /etc/bind/named.conf.local > /dev/null <<EOF

zone "$REVERSE_ZONE" {
    type master;
    file "$REVERSE_ZONE_FILE";
    allow-transfer { $SLAVE_IP; };
};
EOF

# Buat file reverse zone
tee $REVERSE_ZONE_FILE > /dev/null <<EOF
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. root.$DOMAIN. (
                        $(date +%Y%m%d)01      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      ns1.$DOMAIN.
@       IN      NS      ns2.$DOMAIN.

; PTR Records
2       IN      PTR     sirion.$DOMAIN.
5       IN      PTR     lindon.$DOMAIN.
6       IN      PTR     vingilot.$DOMAIN.
EOF

# Validasi & reload
named-checkconf
named-checkzone $REVERSE_ZONE $REVERSE_ZONE_FILE
rndc reload

echo "Setup reverse master di Tirion selesai." 


# ________+++++ VALMAR +++++______
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
rndc reload

echo "Setup reverse slave di Valmar selesai. Cek syslog buat liat transfer log."