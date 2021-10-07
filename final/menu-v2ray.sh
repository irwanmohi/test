#!/bin/bash
RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'

clear
echo -e "${GREEN}=================================================================${NC}"
echo -e "${BLUE}=========================== ${RED}Menu VMESS ${BLUE}==========================${NC}"                    
echo -e ""
echo -e "- [01]      : Create V2ray Vmess WS Account"
echo -e "- [02]      : Deleting V2ray Vmess WS Account"       
echo -e "- [03]      : Extending Vmess Account Active Life" 
echo -e "- [04]      : Check User Login V2ray" 
echo -e "- [05]      : Renew Certificate V2ray Account"                                                          
echo -e ""
echo -e "${GREEN}=================================================================${NC}"
echo -e "${BLUE}=========================== ${RED}Menu VLESS ${BLUE}==========================${NC}"
echo -e ""
echo -e "- [06]      : Create V2ray Vless WS Account"
echo -e "- [07]      : Deleting V2ray Vless WS Account" 
echo -e "- [08]      : Extending Vless Account Active Life" 
echo -e "- [09]      : Check User Login V2ray" 
echo -e ""
echo -e "${GREEN}=================================================================${NC}"
echo -e ""
read -p "     Select From Options [1-9 or x] :  " num
echo -e ""
case $num in
1)
add-ws
;;
2)
del-ws
;;
3)
renew-ws
;;
4)
cek-ws
;;
5)
cert2vray
;;
6)
add-vless
;;
7)
del-vless
;;
8)
renew-vless
;;
9)
cek-vless
;;
x)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac
