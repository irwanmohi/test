#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
blue='\e[1;34m'
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
echo " "
read -p "Masukkan Username Yang Akan Diganti Passwordnya: " Login
egrep "^$Login" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
read -p "Masukkan Password baru untuk user $username: " Pass
clear
echo "Connecting to server..."
sleep 0.5
echo "Mengubah Password..."
sleep 0.5
  egrep "^$Login" /etc/passwd >/dev/null
  echo -e "$Pass\n$Pass" | passwd $Login
  clear
  echo " "
  echo "Script by Kaizen Apeach"
  echo " "
  echo "---------------------------------------"
  echo -e "Password untuk user ${blue}$Login${NC} sudah berjaya diganti."
  echo -e "Password baru untuk user ${blue}$Login${NC} adalah ${red}$Pass${NC}"
  echo "--------------------------------------"
  echo " "
else
echo -e "Username ${red}$Login${NC} tidak dijumpai di VPS anda"
exit 0
fi
