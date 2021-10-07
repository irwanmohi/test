#!/bin/bash

#Install SHC
apt-get install build-essential -y
wget -c https://github.com/neurobin/shc/archive/4.0.2.tar.gz
tar xzvf 4.0.2.tar.gz 
cd shc-4.0.2/
./configure 
make
make install


#Masuk Direktori
cd /usr/bin

#Encrypt File
shc -f add-host
shc -f add-l2tp
shc -f add-pptp
shc -f add-ss
shc -f add-ssh
shc -f add-ssr
shc -f add-sstp
shc -f add-tr
shc -f add-vless
shc -f add-wg
shc -f add-ws
shc -f autobackup
shc -f autokill
shc -f backup
shc -f cek-pptp
shc -f cek-ss
shc -f cek-ssh
shc -f cek-sstp
shc -f cek-tr
shc -f cek-vless
shc -f cek-wg
shc -f cek-ws
shc -f cert
shc -f change-port
shc -f del-l2tp
shc -f del-pptp
shc -f del-ss
shc -f del-ssh
shc -f del-ssr
shc -f del-sstp
shc -f del-tr
shc -f del-vless
shc -f del-wg
shc -f del-ws
shc -f delete
shc -f info
shc -f izin
shc -f kernel
shc -f list-ssh
shc -f menu-l2tp
shc -f menu-ssh
shc -f menu-system
shc -f menu-tr
shc -f menu-v2ray
shc -f menu-wr
shc -f menu
shc -f mulog
shc -f port-ovpn
shc -f port-squid
shc -f port-ssl
shc -f port-sstp
shc -f port-tr
shc -f port-vless
shc -f port-wg
shc -f port-ws
shc -f reboot
shc -f renew-l2tp
shc -f renew-pptp
shc -f renew-ss
shc -f renew-ssh
shc -f renew-ssr
shc -f renew-sstp
shc -f renew-tr
shc -f renew-vless
shc -f renew-wg
shc -f renew-ws
shc -f restar
shc -f restore
shc -f strt
shc -f swapkvm
shc -f tendang
shc -f trial-ssh
shc -f xp



#Move file
mv add-host.x add-host
mv add-l2tp.x add-l2tp
mv add-pptp.x add-pptp
mv add-ss.x add-ss
mv add-ssh.x add-ssh
mv add-ssr.x add-ssr
mv add-sstp.x add-sstp
mv add-tr.x add-tr
mv add-vless.x add-vless
mv add-wg.x add-wg
mv add-ws.x add-ws
mv autobackup.x autobackup
mv autokill.x autokill
mv backup.x backup
mv cek-pptp.x cek-pptp
mv cek-ss.x cek-ss
mv cek-ssh.x cek-ssh
mv cek-sstp.x cek-sstp
mv cek-tr.x cek-tr
mv cek-vless.x cek-vless
mv cek-wg.x cek-wg
mv cek-ws.x cek-ws
mv cert.x cert
mv change-port.x change-port
mv del-l2tp.x del-l2tp
mv del-pptp.x del-pptp
mv del-ss.x del-ss
mv del-ssh.x del-ssh
mv del-ssr.x del-ssr
mv del-sstp.x del-sstp
mv del-tr.x del-tr
mv del-vless.x del-vless
mv del-wg.x del-wg
mv del-ws.x del-ws
mv delete.x delete
mv info.x info
mv izin.x izin
mv kernel.x kernel
mv list-ssh.x list-ssh
mv menu-l2tp.x menu-l2tp
mv menu-ssh.x menu-ssh
mv menu-system.x menu-system
mv menu-tr.x menu-tr
mv menu-v2ray.x menu-v2ray
mv menu-wr.x menu-wr
mv menu.x menu
mv mulog.x mulog
mv port-ovpn.x port-ovpn
mv port-squid.x port-squid
mv port-ssl.x port-ssl
mv port-sstp.x port-sstp
mv port-tr.x port-tr
mv port-vless.x port-vless
mv port-wg.x port-wg
mv port-ws.x port-ws
mv reboot.x reboot
mv renew-l2tp.x renew-l2tp
mv renew-pptp.x renew-pptp
mv renew-ss.x renew-ss
mv renew-ssh.x renew-ssh
mv renew-ssr.x renew-ssr
mv renew-sstp.x renew-sstp
mv renew-tr.x renew-tr
mv renew-vless.x renew-vless
mv renew-wg.x renew-wg
mv renew-ws.x renew-ws
mv restart.x restart
mv restore.x restore
mv strt.x strt
mv swapkvm.x swapkvm
mv tendang.x tendang
mv trial-ssh.x trial-ssh
mv xp.x xp

#Remove Extension
rm -f *.x.c
clear
echo -e "Encrypt Shell Susuccessful..."
rm -f encrypt
cd
rm -rf shc-4.0.2
rm -rf 4.0.2.tar.gz
rm -rf master.zip
