#!/bin/bash

##
# @name: debian.openvpn.sh
# Version: I.I.II
# @author: Doctype <doct.knowledge@gmail.com>
# @about: Openvpn package installer
##

# global variable
PWD=$(pwd);

## Normal colors
grey='\e[1;30m'
red='\e[0;31m'
green='\e[0;32m'
magenta='\e[0;35m'

## No color
noclr='\e[0m'

ipaddr=""
default=$(curl -4 icanhazip.com);
read -p "Enter IP address [$default]: " ipaddr
ipaddr=${ipaddr:-$default}

# clear terminal screen
clear

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "'||'  '|' '||''|.   .|'''.|    +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+"
echo -e " '|.  .'   ||   ||  ||..  '    |K| |n| |o| |w| |l| |e| |d| |g| |e|"
echo -e "  ||  |    ||...|'   ''|||.    +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+"
echo -e "   |||     ||      .     '||  ${grey}Created by Doctype${noclr}"
echo -e "    |     .||.     |'....|'   ${grey}Powered by VPS.Knowledge${noclr}"
echo -e "       Linux Debian-9         ${grey}2018-2020, All Rights Reserved.${noclr}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo -e "${magenta}This script will update apt, upgrade packages and install${noclr}"
echo -e "${magenta}needed and required packages to run OpenVPN Server.${noclr}"
echo

if [[ "$UID" -ne 0 ]]; then
    echo "${red}You need to run script as root!${noclr}"
    exit 0
fi

echo -n "Checking internet connection... "
ping -q -c 3 www.google.com
if [ ! "$?" -eq 0 ] ; then
    echo -e "${red}ERROR: Please check your internet connection${noclr}"
    exit 1;
fi

ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

function pakages {
    echo -n "Update, upgrade & install required packages."
    apt-get -qq update
    apt-get -qqy upgrade
    apt-get -qqy build-essensitial
    echo -e "[${green}DONE${noclr}]"
}

function question {
    # Get IP address
    ipaddr=""
    default=$(curl -4 icanhazip.com)
    read -p "Enter IP address [$default]: " ipaddr
    ipaddr=${ipaddr:-$default}

    # Get port
    default="1194"
    read -p "Enter port for OpenVPN [$default]: " port
    port=${port:-$default}

    # Get country
    default="US"
    read -p "Enter country [$default]: " country
    country=${country:-$default}

    # Get providence/state
    default="CA"
    read -p "Enter state [$default]: " province
    province=${province:-$default}

    # Get city
    default="SanFrancisco"
    read -p "Enter city [$default]: " city
    city=${city:-$default}

    # Get organization
    default="Fort-Funston"
    read -p "Enter organization [$default]: " organization
    organization=${organization:-$default}

    # Get email
    default="me@myhost.mydomain"
    read -p "Enter email [$default]: " email
    email=${email:-$default}

    # Get organization unit
    default="MyOrganizationalUnit"
    read -p "Enter organization unit [$default]: " organizationUnit
    organizationUnit=${organizationUnit:-$default}
}

function firewall {
    apt-get -y install ufw

    sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

    ufw allow 22
    ufw allow 80
    ufw allow 443
    ufw allow 1194/tcp

    echo '' > /etc/ufw/before.rules
    echo '*nat' >> /etc/ufw/before.rules
    echo ':POSTROUTING ACCEPT [0:0]' >> /etc/ufw/before.rules
    echo '-A POSTROUTING -o eth0 -j MASQUERADE' >> /etc/ufw/before.rules
    echo '-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE' >> /etc/ufw/before.rules
    echo 'COMMIT' >> /etc/ufw/before.rules
    echo '' >> /etc/ufw/before.rules
    echo '*filter' >> /etc/ufw/before.rules
    echo ':ufw-before-input - [0:0]' >> /etc/ufw/before.rules
    echo ':ufw-before-output - [0:0]' >> /etc/ufw/before.rules
    echo ':ufw-before-forward - [0:0]' >> /etc/ufw/before.rules
    echo ':ufw-not-local - [0:0]' >> /etc/ufw/before.rules
    echo '' >> /etc/ufw/before.rules
    echo '-A ufw-before-input -i lo -j ACCEPT' >> /etc/ufw/before.rules
    echo '-A ufw-before-output -o lo -j ACCEPT' >> /etc/ufw/before.rules
    echo '-A ufw-before-input -m state --state RELATED,ESTABLISHED -j ACCEPT' >> /etc/ufw/before.rules
    echo '-A ufw-before-output -m state --state RELATED,ESTABLISHED -j ACCEPT' >> /etc/ufw/before.rules
    echo '-A ufw-before-input -m state --state INVALID -j DROP' >> /etc/ufw/before.rules
    echo 'COMMIT' >> /etc/ufw/before.rules
}

function openvpn {
    apt-get -y install openvpn easy-rsa
    mkdir /etc/openvpn/easy-rsa/
    cp /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/

    sed -i 's/export KEY_COUNTRY="US"/export KEY_COUNTRY="$country"/' /etc/openvpn/easy-rsa/vars
    sed -i 's/export KEY_PROVINCE="CA"/export KEY_PROVINCE="$province"/' /etc/openvpn/easy-rsa/vars
    sed -i 's/export KEY_CITY="SanFrancisco"/export KEY_CITY="$city"/' /etc/openvpn/easy-rsa/vars
    sed -i 's/export KEY_ORG="Fort-Funston"/export KEY_ORG="$organization"/' /etc/openvpn/easy-rsa/vars
    sed -i 's/export KEY_EMAIL="me@myhost.mydomain"/export KEY_EMAIL="$email"/' /etc/openvpn/easy-rsa/vars
    sed -i 's/export KEY_OU="MyOrganizationalUnit"/export KEY_OU="$organizationUnit"/' /etc/openvpn/easy-rsa/vars

    cd /etc/openvpn/easy-rsa/
    source ./vars
    ./clean-all

    export EASY_RSA="${EASY_RSA:-.}"
    "$EASY_RSA/pkitool" --initca $*

    export EASY_RSA="${EASY_RSA:-.}"
    "$EASY_RSA/pkitool" --server server

    export EASY_RSA="${EASY_RSA:-.}"
    "$EASY_RSA/pkitool" client

    openssl dhparam -out /etc/openvpn/keys/dh2048.pem 2048

    mkdir /etc/openvpn/keys/
    cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/keys/
    cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn/keys/
    cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn/keys/
    cp /etc/openvpn/easy-rsa/keys/dh2048.pem /etc/openvpn/keys/
    cp /etc/openvpn/easy-rsa/keys/client.crt /etc/openvpn/keys/
    cp /etc/openvpn/easy-rsa/keys/client.key /etc/openvpn/keys/

    touch /etc/openvpn/server.conf
    echo "port $port" > /etc/openvpn/server.conf
    echo "proto tcp" >> /etc/openvpn/server.conf
    echo "dev tun" >> /etc/openvpn/server.conf
    echo "ca /etc/openvpn/keys/ca.crt" >> /etc/openvpn/server.conf
    echo "cert /etc/openvpn/keys/server.crt" >> /etc/openvpn/server.conf
    echo "key /etc/openvpn/keys/server.key" >> /etc/openvpn/server.conf
    echo "dh /etc/openvpn/keys/dh2048.pem" >> /etc/openvpn/server.conf
    echo "server 10.8.0.0 255.255.255.0" >> /etc/openvpn/server.conf
    echo "ifconfig-pool-persist ipp.txt" >> /etc/openvpn/server.conf
    echo "push \"redirect-gateway def1 bypass-dhcp\"" >> /etc/openvpn/server.conf
    echo "push \"dhcp-option DNS 8.8.8.8\"" >> /etc/openvpn/server.conf
    echo "push \"dhcp-option DNS 8.8.4.4\"" >> /etc/openvpn/server.conf
    echo "keepalive 10 120" >> /etc/openvpn/server.conf
    echo "cipher AES-128-CBC" >> /etc/openvpn/server.conf
    echo "comp-lzo" >> /etc/openvpn/server.conf
    echo "max-clients 40" >> /etc/openvpn/server.conf
    echo "user nobody" >> /etc/openvpn/server.conf
    echo "group nogroup" >> /etc/openvpn/server.conf
    echo "persist-key" >> /etc/openvpn/server.conf
    echo "persist-tun" >> /etc/openvpn/server.conf
    echo "status openvpn-status.log" >> /etc/openvpn/server.conf
    echo "log /var/log/openvpn.log" >> /etc/openvpn/server.conf
    echo "verb 3" >> /etc/openvpn/server.conf
    echo "mute 20" >> /etc/openvpn/server.conf
    echo "" >> /etc/openvpn/server.conf

    touch /etc/openvpn/client.ovpn
    echo "client" > /etc/openvpn/client.ovpn
    echo "dev tun" >> /etc/openvpn/client.ovpn
    echo "proto tcp" >> /etc/openvpn/client.ovpn
    echo "remote $ipaddr $port" >> /etc/openvpn/client.ovpn
    echo "resolv-retry infinite" >> /etc/openvpn/client.ovpn
    echo "nobind" >> /etc/openvpn/client.ovpn
    echo "user nobody" >> /etc/openvpn/client.ovpn
    echo "group nogroup" >> /etc/openvpn/client.ovpn
    echo "persist-key" >> /etc/openvpn/client.ovpn
    echo "persist-tun" >> /etc/openvpn/client.ovpn
    echo "mute-replay-warnings" >> /etc/openvpn/client.ovpn
    echo "ns-cert-type server" >> /etc/openvpn/client.ovpn
    echo "cipher AES-128-CBC" >> /etc/openvpn/client.ovpn
    echo "auth-user-pass" >> /etc/openvpn/client.ovpn
    echo "comp-lzo" >> /etc/openvpn/client.ovpn
    echo "verb 3" >> /etc/openvpn/client.ovpn
    echo "mute 20" >> /etc/openvpn/client.ovpn
    echo ";http-proxy-retry" >> /etc/openvpn/client.ovpn
    echo ";http-proxy [proxy server] [proxy port]" >> /etc/openvpn/client.ovpn
    echo ";http-proxy-option CUSTOM-HEADER Host [bugHost]" >> /etc/openvpn/client.ovpn
    echo ";http-proxy-option CUSTOM-HEADER X-Online-Host [bugHost]" >> /etc/openvpn/client.ovpn
    echo "" >> /etc/openvpn/client.ovpn
    echo "<ca>" >> /etc/openvpn/client.ovpn
    cat /etc/openvpn/keys/ca.crt >> /etc/openvpn/client.ovpn
    echo "</ca>" >> /etc/openvpn/client.ovpn
    echo "<cert>" >> /etc/openvpn/client.ovpn
    cat /etc/openvpn/keys/client.crt >> /etc/openvpn/client.ovpn
    echo "</cert>" >> /etc/openvpn/client.ovpn
    echo "<key>" >> /etc/openvpn/client.ovpn
    cat /etc/openvpn/keys/client.key >> /etc/openvpn/client.ovpn
    echo "</key>" >> /etc/openvpn/client.ovpn
}

function finish {
    /etc/init.d/openvpn start
    service openvpn restart
    ufw enable
    service ufw restart

    echo -e "${magenta}Start openvpn: /etc/init.d/openvpn start${noclr}"
    echo -e "${magenta}Restart openvpn: service openvpn restart${noclr}"
    echo -e "${magenta}Enable ufw: ufw enable${noclr}"
    echo -e "${magenta}Restart ufw: service ufw restart${noclr}"
    echo ""
    echo -e "${magenta}Done, reboot your system!.${noclr}"
}

function runScripts {
    pakages
    question
    firewall
    openvpn
}

runScripts
finish
exit 0
