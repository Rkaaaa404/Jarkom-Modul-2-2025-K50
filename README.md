# Jarkom-Modul-2-2025-K50

| Nama                    | NRP        |
| ----------------------- | ---------- |
| Rayka Dharma Pranandita | 5027241039 |
| Yasykur Khalis J M Y    | 5027241112 |

# Prefix IP

| Kelompok | Prefix IP |
| -------- | --------- |
| K-50     | 192.236   |

## Soal 1

Buat Topologi dan tetapkan alamat dan default gateway tiap tokoh sesuai glosarium yang sudah diberikan:  
![Topologi](assets/topology.png)

Network Config:

- **Eonwe**:
```
# WAN Interface
auto eth0
iface eth0 inet dhcp

# LAN Interface ke Jalur Barat
auto eth1
iface eth1 inet static
address 192.236.1.1
netmask 255.255.255.0

# LAN Interface ke Jalur Timur
auto eth2
iface eth2 inet static
address 192.236.2.1
netmask 255.255.255.0

# LAN Interface ke Pelabuhan DMZ
auto eth3
iface eth3 inet static
address 192.236.3.1
netmask 255.255.255.0

# Otomatis menjalankan iptables untuk connect ke internet luar
up iptables -t nat -A POSTROUTING -o eth0 -j    MASQUERADE -s 192.236.0.0/16 

```

- **Barat**:    
Kurang lebih menggunakan format berikut, dengan adjustment angka akhir adress untuk tiap node/client
```
auto eth0
iface eth0 inet static
	address 192.236.1.2
	netmask 255.255.255.0
	gateway 192.236.1.1

    # autorun untuk bisa connect ke internet luar
	up echo nameserver 192.168.122.1 > /etc/resolv.conf
```
- **Timur**:    
Kurang lebih menggunakan format berikut, dengan adjustment angka akhir adress untuk tiap node/client
```
auto eth0
iface eth0 inet static
	address 192.236.2.2
	netmask 255.255.255.0
	gateway 192.236.2.1
	
    # autorun untuk bisa connect ke internet luar
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
```
- **Pelabuhan DMZ**:    
Kurang lebih menggunakan format berikut, dengan adjustment angka akhir adress untuk tiap node/client
```
auto eth0
iface eth0 inet static
	address 192.236.3.3
	netmask 255.255.255.0
	gateway 192.236.3.1
	
    # autorun untuk bisa connect ke internet luar
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
```

## Soal 2
Memastikan jalur WAN di router aktif dan NAT meneruskan trafik keluar sehingga host di dalam dapat mencapai layanan di luar menggunakan IP address.

Hal ini dilakukan dengan menambahkan network config:
- **Router (Eonwe)**
```@router
up iptables -t nat -A POSTROUTING -o eth0 -j    MASQUERADE -s 192.236.0.0/16
```
- **Client/Host/Nodes**
```@client
up echo nameserver 192.168.122.1 > /etc/resolv.conf
```

Proof:
![Test ping google.com](assets/connect-ext.png)

## Soal 3
Kabar dari Barat menyapa Timur. Pastikan kelima klien dapat saling berkomunikasi lintas jalur (routing internal via Eonwe berfungsi), lalu pastikan setiap host non-router menambahkan resolver 192.168.122.1 saat interfacenya aktif agar akses paket dari internet tersedia sejak awal.

Seperti yang dibahas tadi, kami sudah menambahkan echo nameserver  saat interfacenya aktif, selanjutnya untuk memastikan koneksi antar client bisa terjadi kami menambahkan config ip forwarding di Router (Eonwe):
![nano config systctl](assets/ip-forward.png)
Setelah itu run config:    
![run systctl](assets/systcl-ip-forward.png)    

Proof:
- Koneksi Barat ke Timur:
  ![ping west to east](assets/west-to-east.png)
- Koneksi Timur ke Barat:
  ![ping easr to west](assets/east-to-west.png)
  