#di TIRION

#Instalasi BIND9
apt update
apt install bind9 -y

#Edit file konfigurasi utama zona di /etc/bind/named.conf.local
zone "K50.com" {
    type master;
    file "/etc/bind/zones/db.K50.com";
    allow-transfer { 192.236.3.4; };   # hanya Valmar boleh ambil zona
    notify yes;                        # otomatis beri tahu Valmar kalau zona berubah
};

#Tambahkan forwarders ke internet
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

#Buat folder zona dan file db.K50.com di folder tersebut
$TTL    604800
@       IN      SOA     ns1.K50.com. root.K50.com. (
                        2025101101      ; Serial (ubah tiap kali edit)
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      ns1.K50.com.
@       IN      NS      ns2.K50.com.

ns1     IN      A       192.236.3.3
ns2     IN      A       192.236.3.4
@       IN      A       192.236.3.2

#Restart dan cek syntax
named-checkconf
named-checkzone K50.com /etc/bind/zones/db.K50.com
named -g -c /etc/bind/named.conf &

#di VALMAR

#install BIND9 dan tambahkan zona slave /etc/bind/named.conf.local
zone "K50.com" {
    type slave;
    masters { 192.236.3.3; };
    file "/var/lib/bind/db.K50.com";
};

#Tambahkan forwarders juga, edit /etc/bind/named.conf.options
options {
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    recursion yes;
    dnssec-validation no;
}

#Ubah resolver di semua host non-router
nameserver 192.236.3.3
nameserver 192.236.3.4
nameserver 192.168.122.1