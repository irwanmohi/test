#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- https://icanhazip.com);
izin
clear
IP=$(wget -qO- https://icanhazip.com);
if [[ "$domain" = "" ]]; then
domain=$(cat /home/domain)
else
domain=$IP
fi
ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2)"
sqd="$(cat ~/log-install.txt | grep -w "Squid" | cut -d: -f2)"
ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
Login=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari="1"
Pass=1
clear
dibuat=$(date +"%b %C, %Y")
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "======================================" 
echo -e "Information SSH & OpenVPN Account " | lolcat
echo -e "======================================" 
echo -e "Domain         : $domain"
echo -e "Host           : $MYIP"
echo -e "Username       : $Login "
echo -e "Password       : $Pass"
echo -e "======================================"
echo -e "OpenSSH        : 22"
echo -e "Dropbear       : 143"
echo -e "SSL/TLS        : $ssl"
echo -e "WS Dropbear    : 8880"
echo -e "WS OpenSSH     : 2095"
echo -e "WS OpenVPN     : 2082"
echo -e "WS TLS         : 222"
echo -e "Port Squid     : $sqd"
echo -e "OpenVPN TCP    : http://$MYIP:81/client-tcp-$ovpn.ovpn"
echo -e "OpenVPN UDP    : http://$MYIP:81/client-udp-$ovpn2.ovpn"
echo -e "OpenVPN SSL    : http://$MYIP:81/client-tcp-ssl.ovpn"
echo -e "OpenVPN OHP    : http://$MYIP:81/tcp-ohp.ovpn"
echo -e "badvpn         : 7100, 7200, 7300"
echo -e "===================================="
echo -e "Payload WebSocket"
echo -e "GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]"
echo -e "===================================="
echo -e "Sett HttpCustom"
echo -e "bug.com:8880@$Login:$Pass"
echo -e "===================================="
echo -e "Aktif Selama   : $masaaktif Hari"
echo -e "Created On     : $dibuat"
echo -e "Expired On     : $exp"
echo -e "===================================="
echo -e "Script Created By THIRASTORE" | lolcat
echo -e ""

