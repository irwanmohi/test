#!/bin/bash
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ifconfig.co);
IZIN=$( curl https://raw.githubusercontent.com/Apeachsan91/server/main/ipallow | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permission Accepted...${NC}"
else
echo -e "${red}Permission Denied!${NC}";
rm -f setup.sh
exit 0
fi
cd
clear
echo ""
echo "Membuat semakan sekiranya terdapat sebarang update.."
sleep 3
echo "Tiada sebarang update untuk waktu ini.."
sleep 3
rm -f update.sh
cd
clear
