#!/bin/bash
RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'

clear
echo -e ""
echo -e "${BLUE}========================== ${RED}Menu Trojan ${BLUE}==========================${NC}"
echo -e ""
echo -e "* [1]  : Create Trojan Account" 
echo -e "* [2]  : Deleting Trojan Account" 
echo -e "* [3]  : Extending Trojan Account Active Life"
echo -e "* [4]  : Check User Login Trojan" 
echo -e ""
echo -e "${GREEN}=================================================================${NC}"
echo -e ""
read -p "     Select From Options [1-4 or x] :  " num
echo -e ""
case $num in
1)
add-tr
;;
2)
del-tr
;;
3)
renew-tr
;;
4)
cek-tr
;;
x)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac
