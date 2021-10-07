#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- https://icanhazip.com);
IZIN=$(curl https://raw.githubusercontent.com/Dork96/rentScript/main/ipvps | grep $MYIP)
if [ $MYIP = $IZIN ]; then
clear
echo -e ""
echo -e "${green}Permission Accepted...${NC}"
else
clear
echo -e ""
echo -e "======================================="
echo -e "${red}=====[ Permission Denied...!!! ]=====${NC}";
echo -e "Contact WA https//wa.me/+6285717614888"
echo -e "For Registration IP VPS"
echo -e "======================================="
echo -e ""
exit 0
fi
# DELETE AKUN EXPIRED
               hariini=`date +%Y-%m-%d`
               cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
               totalaccounts=`cat /tmp/expirelist.txt | wc -l`
               for((i=1; i<=$totalaccounts; i++ ))
               do
               tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
               username=`echo $tuserval | cut -f1 -d:`
               userexp=`echo $tuserval | cut -f2 -d:`
               userexpireinseconds=$(( $userexp * 86400 ))
               tglexp=`date -d @$userexpireinseconds`             
               tgl=`echo $tglexp |awk -F" " '{print $3}'`
               while [ ${#tgl} -lt 2 ]
               do
               tgl="0"$tgl
               done
               while [ ${#username} -lt 15 ]
               do
               username=$username" " 
               done
               bulantahun=`echo $tglexp |awk -F" " '{print $2,$6}'`
               echo "echo "Expired- User : $username Expire at : $tgl $bulantahun"" >> /usr/local/bin/alluser
               todaystime=`date +%s`
               if [ $userexpireinseconds -ge $todaystime ] ;
               then
		    	:
               else
               
               userdel $username
               fi
               done
# DELETE
clear
echo -e "================================"
echo -e "===== Create SSH & OpenVPN ====="
echo -e ""
read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (Days): " masaaktif

#IP=$(wget -qO- https://icanhazip.com);
if [[ "$domain" = "" ]]; then
domain=$(cat /root/domain)
else
domain=$MYIP
fi
ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2)"
sqd="$(cat ~/log-install.txt | grep -w "Squid" | cut -d: -f2)"
ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
sleep 1
clear
dibuat=$(date +"%b %C, %Y")
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "==================================" 
echo -e "Information SSH & OpenVPN Account " | lolcat
echo -e "==================================" 
echo -e "Domain         : $domain"
echo -e "Host           : $MYIP"
echo -e "Username       : $Login "
echo -e "Password       : $Pass"
echo -e "=================================="
echo -e "OpenSSH        : 22"
echo -e "Dropbear       : 143"
echo -e "SSL/TLS        :$ssl"
echo -e "WS Dropbear    : 8880"
echo -e "WS OpenSSH     : 2095"
echo -e "WS OpenVPN     : 2082"
echo -e "WS TLS         : 222"
echo -e "Port Squid     :$sqd"
echo -e "OpenVPN TCP    : http://$MYIP:81/client-tcp-$ovpn.ovpn"
echo -e "OpenVPN UDP    : http://$MYIP:81/client-udp-$ovpn2.ovpn"
echo -e "OpenVPN SSL    : http://$MYIP:81/client-tcp-ssl.ovpn"
echo -e "OpenVPN OHP    : http://$MYIP:81/tcp-ohp.ovpn"
echo -e "Badvpn UDPGW   : 7100, 7200, 7300"
echo -e "================================"
echo -e "Payload WebSocket"
echo -e "GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]"
echo -e "================================"
echo -e "HttpCustom"
echo -e "bug.com:8880@$Login:$Pass"
echo -e "================================"
echo -e "Aktif Selama   : $masaaktif Days"
echo -e "Created On     : $dibuat"
echo -e "Expired On     : $exp"
echo -e "===================================="
echo -e "Script Created By THIRASTORE" | lolcat
echo -e ""
