#!/bin/bash
RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'
clear
echo -e ""
echo -e "${BLUE}=========================== ${RED}Menu L2TP ${BLUE}===========================${NC}" 
echo -e ""
echo -e "* 1  : Creating L2TP Account" 
echo -e "* 2  : Deleting L2TP Account" 
echo -e "* 3  : Extending L2TP Account Active Life" 
echo -e ""
echo -e "${GREEN}=================================================================${NC}"
echo -e "${BLUE}=========================== ${RED}Menu PPTP ${BLUE}===========================${NC}"
echo -e ""
echo -e "* 4  : Create Account PPTP" 
echo -e "* 5  : Delete PPTP Account" 
echo -e "* 6  : Extending PPTP Account Active Life"
echo -e "* 7  : Check User Login PPTP" 
echo -e ""
echo -e "${GREEN}=================================================================${NC}"
echo -e "${BLUE}=========================== ${RED}Menu SSTP ${BLUE}===========================${NC}"
echo -e ""
echo -e "* 8  : Create Account SSTP" 
echo -e "* 9  : Delete SSTP Account" 
echo -e "* 10 : Extending SSTP Account Active Life" 
echo -e "* 11 : Check User Login SSTP" 
echo -e ""
echo -e "${GREEN}=================================================================${NC}" 
echo -e ""
read -p "     Select From Options [1-11 or x] :  " num
echo -e ""
case $num in
1)
add-l2tp
;;
2)
del-l2tp
;;
3)
renew-l2tp
;;
4)
add-pptp
;;
5)
del-pptp
;;
6)
renew-pptp
;;
7)
cek-pptp
;;
8)
add-sstp
;;
9)
del-sstp
;;
10)
renew-sstp
;;
11)
cek-sstp
;;
x)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac
