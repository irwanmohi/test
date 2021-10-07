#!/bin/bash

cd

figlet -f slant Install WS | lolcat
# Install Template
wget -q -O /usr/local/bin/ws-drop "https://raw.githubusercontent.com/Dork96/Final/main/ws-dropbear.py"
wget -q -O /usr/local/bin/ws-openssh "https://raw.githubusercontent.com/Dork96/Final/main/ws-openssh.py"
wget -q -O /usr/local/bin/ws-ovpn "https://raw.githubusercontent.com/Dork96/Final/main/ws-ovpn.py"
wget -q -O /usr/local/bin/ws-tls "https://raw.githubusercontent.com/Dork96/Final/main/ws-tls.py"

chmod +x /usr/local/bin/ws-dropbear
chmod +x /usr/local/bin/ws-openssh
chmod +x /usr/local/bin/ws-ovpn
chmod +x /usr/local/bin/ws-tls

echo -e "Configurating CDN" | lolcat

# Dropbear
cat > /etc/systemd/system/ws-dropbear.service << END
[Unit]
Description=SSH Over CDN WS Dropbear
Documentation=https://wuzzzssh.xyz
After=network.target nss-lookup.target
[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/ws-dropbear
Restart=on-failure
[Install]
WantedBy=multi-user.target
END

# OpenSSH
cat > /etc/systemd/system/ws-openssh.service << END
[Unit]
Description=SSH Over CDN WS Dropbear
Documentation=https://wuzzzssh.xyz
After=network.target nss-lookup.target
[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/ws-openssh
Restart=on-failure
[Install]
WantedBy=multi-user.target
END

# OpenVPN
cat > /etc/systemd/system/ws-openvpn.service << END
[Unit]
Description=SSH Over CDN WS OpenVPN
Documentation=https://wuzzssh.xyz
After=network.target nss-lookup.target
[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/ws-ovpn
Restart=on-failure
[Install]
WantedBy=multi-user.target
END

# Stunnel
cat > /etc/systemd/system/ws-stunnel.service << END
[Unit]
Description=SSH Over CDN WS Stunnel
Documentation=https://wuzzzssh.xyz
After=network.target nss-lookup.target
[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/ws-tls
Restart=on-failure
[Install]
WantedBy=multi-user.target
END

# Exec Start
systemctl daemon-reload

# Activated
systemctl enable ws-dropbear.service
systemctl enable ws-openssh.service
systemctl enable ws-openvpn.service
systemctl enable ws-stunnel.service

# Restart
systemctl restart ws-dropbear.service
systemctl restart ws-openssh.service
systemctl restart ws-openvpn.service
systemctl restart ws-stunnel.service

#BadVPN WS
wget https://github.com/ambrop72/badvpn/archive/master.zip
unzip master.zip
cd badvpn-master
mkdir build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
sudo make install

# Install Module
apt install dnsutils jq -y
apt-get install net-tools -y
apt-get install tcpdump -y
apt-get install dsniff -y
apt install grepcidr -y

echo -e "Instaled Websocket Succes..."
rm -f websock.sh