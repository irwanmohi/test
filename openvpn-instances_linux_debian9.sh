#!/usr/bin/env bash

ipaddr=$( ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1 )

apt-get -y -qq install openvpn &>/dev/null
wget -q "https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz" &>/dev/null
tar xzf EasyRSA-3.0.8.tgz
mv EasyRSA-3.0.8 /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
./easyrsa --batch init-pki
./easyrsa --batch build-ca nopass
./easyrsa --batch gen-dh
openvpn --genkey --secret ta.key
./easyrsa --batch build-server-full server nopass
./easyrsa --batch build-client-full client nopass

# customserv.conf - openvpn with custom config file
echo "# OVPN SERVER-CUSTOM CONFIG
# ----------------------------
port 989
proto tcp
dev tun

ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key
dh /etc/openvpn/easy-rsa/pki/dh.pem
tls-auth /etc/openvpn/easy-rsa/pki/ta.key 0

client-cert-not-required
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push \"redirect-gateway def1 bypass-dhcp\"
push \"dhcp-option DNS 1.1.1.1\"
push \"dhcp-option DNS 8.8.8.8\"
keepalive 10 120
cipher AES-256-CBC
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/ovpn-stat.log
log /var/log/openvpn/ovpn-auth.log
verb 3
mute 20
explicit-exit-notify 1
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so
username-as-common-name" > /etc/openvpn/server/servcustom.conf

# stunnelserv.conf - openvpn with stunnel4
echo "# OVPN SERVER-STUNNEL CONFIG
# ----------------------------
port 990
proto tcp
dev tun

ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key
dh /etc/openvpn/easy-rsa/pki/dh.pem
tls-auth /etc/openvpn/easy-rsa/pki/ta.key 0

client-cert-not-required
server 10.9.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push \"redirect-gateway def1 bypass-dhcp\"
push \"dhcp-option DNS 8.8.8.8\"
push \"dhcp-option DNS 1.1.1.1\"
push \"dhcp-option DNS 1.0.0.1\"
keepalive 10 120
cipher AES-256-CBC
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/ovpn-stat.log
log /var/log/openvpn/ovpn-auth.log
verb 3
mute 20
explicit-exit-notify 1
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so
username-as-common-name" > /etc/openvpn/server/servstunnel.conf


#
# OPENVPN SERVER CONFIG FILES
##
# obfs4serv.conf - openvpn with obfsproxy
echo "# OVPN SERVER-OBFS4 CONFIG
# ----------------------------
port 991
proto tcp
dev tun

ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key
dh /etc/openvpn/easy-rsa/pki/dh.pem
tls-auth /etc/openvpn/easy-rsa/pki/ta.key 0

client-cert-not-required
server 10.10.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push \"redirect-gateway def1 bypass-dhcp\"
push \"dhcp-option DNS 1.1.1.1\"
push \"dhcp-option DNS 8.8.8.8\"
push \"dhcp-option DNS 8.8.4.4\"
keepalive 10 120
cipher AES-256-CBC
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/ovpn-stat.log
log /var/log/openvpn/ovpn-auth.log
verb 3
mute 20
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so
username-as-common-name" > /etc/openvpn/server/servobfs4.conf

#
# OPENVPN CLIENT CONFIG FILES
##
# customClient.conf - Custom client config file
echo "# OVPN CLIENT-CUSTOM CONFIG
# ----------------------------
client
dev tun
proto tcp
remote $ipaddr 989
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
key-direction 1
keepalive 5 60
auth SHA256
comp-lzo
verb 3
auth-user-pass

;http-proxy-retry
;http-proxy $ipaddress 3128
;http-proxy-option CUSTOM-HEADER Protocol HTTP/1.1
;http-proxy-option CUSTOM-HEADER Host HOSTNAME
;http-proxy-option CUSTOM-HEADER X-Online-Host HOSTNAME" > /etc/openvpn/client/custom.ovpn

echo "" >> /etc/openvpn/client/custom.ovpn
echo "<ca>" >> /etc/openvpn/client/custom.ovpn
cat /etc/openvpn/easy-rsa/pki/ca.crt >> /etc/openvpn/client/custom.ovpn
echo "</ca>" >> /etc/openvpn/client/custom.ovpn
echo ""
echo "<tls-auth>"
cat /etc/openvpn/easy-rsa/pki/ta.key >> /etc/openvpn/client/custom.ovpn
echo "</tls-auth>"
echo ""

# stunnelClient.conf - Stunnel client config file
echo "# OVPN CLIENT-STUNNEL CONFIG
# ----------------------------
client
pull
dev tun
proto tcp
remote 127.0.0.1 1194
route $ipaddr 255.255.255.255 net_gateway
resolv-retry infinite
persist-key
persist-tun
script-security 3
auth-user-pass
comp-lzo
ping 5
ping-restart 10
verb 3" > /etc/openvpn/client/stunnel.ovpn

echo "" >> /etc/openvpn/client/stunnel.ovpn
echo "<ca>" >> /etc/openvpn/client/stunnel.ovpn
cat /etc/openvpn/easy-rsa/pki/ca.crt >> /etc/openvpn/client/stunnel.ovpn
echo "</ca>" >> /etc/openvpn/client/stunnel.ovpn
echo ""
echo "<tls-auth>"
cat /etc/openvpn/easy-rsa/pki/ta.key >> /etc/openvpn/client/stunnel.ovpn
echo "</tls-auth>"
echo ""

# obfs4Client.conf - obfsproxy client config file
echo "# OVPN CLIENT-OBFS4 CONFIG
# ----------------------------
client
pull
dev tun
proto tcp
remote $ipaddr 991
socks-proxy 127.0.0.1 9090
route $ipaddr 255.255.255.255 net_gateway
resolv-retry infinite
persist-key
persist-tun
script-security 3
auth-user-pass
comp-lzo
ping 5
ping-restart 10
verb 3" > /etc/openvpn/client/obfsproxy.ovpn

echo "" >> /etc/openvpn/client/obfsproxy.ovpn
echo "<ca>" >> /etc/openvpn/client/obfsproxy.ovpn
cat /etc/openvpn/easy-rsa/pki/ca.crt >> /etc/openvpn/client/obfsproxy.ovpn
echo "</ca>" >> /etc/openvpn/client/obfsproxy.ovpn
echo ""
echo "<tls-auth>"
cat /etc/openvpn/easy-rsa/pki/ta.key >> /etc/openvpn/client/obfsproxy.ovpn
echo "</tls-auth>"
echo ""

echo ""
echo "###########################################"
echo "[ OPENVPN DETAILS ]"
echo "-------------------------------------------"
echo "Service: Enabled"
echo "Hostname: $servhostname"
echo "Ipaddress: $ipaddr"
echo "Custom Client: 989"
echo "Stunnel Client: 990"
echo "Obfs4 Client: 991"
echo "Banner: Enable"
echo "-------------------------------------------"
echo "Start OpenVPN Server instances:"
echo "systemctl start openvpn@servcustom.conf"
echo "systemctl start openvpn@servstunnel.conf"
echo "systemctl start openvpn@servobfs4.conf.conf"
echo "###########################################"
