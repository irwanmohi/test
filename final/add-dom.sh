#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Checking VPS"
IZIN=$( curl https://raw.githubusercontent.com/Apeachsan91/server/main/ipallow | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permission Accepted...${NC}"
else
echo -e "${red}Permission Denied!${NC}";
echo "Only For Premium Users"
exit 0
fi

clear
source /root/mail.conf
cd
clear
echo ""
read -p "Sila masukkan Domain anda :" domain
domain=$domain
echo -e "$domain" >> /root/mail.conf
echo $domain > /root/domain
echo "DONE...!"
echo "Your new Domain is : ${domain}"
certv2ray
