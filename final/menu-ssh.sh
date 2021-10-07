#!/bin/bash
RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'

clear
echo -e ""
echo -e "${GREEN}=================================================================${NC}"
echo -e "${BLUE}======================= ${RED}Menu SSH & OpenVPN ${BLUE}======================${NC}"
echo -e ""
echo -e "* [1]    : Create SSH & OpenVPN Account" 
echo -e "* [2]    : Generate SSH & OpenVPN Trial Account" 
echo -e "* [3]    : Extending SSH & OpenVPN Account Active Life" 
echo -e "* [4]    : Delete SSH & OpenVPN Account" 
echo -e "* [5]    : Check User Login SSH & OpenVPN" 
echo -e "* [6]    : Daftar Member SSH & OpenVPN" 
echo -e "* [7]    : Delete User Expired SSH & OpenVPN"
echo -e "* [8]    : Set up Autokill SSH"
echo -e "* [9]    : Displays Users Who Do Multi Login SSH"
echo -e "* [10]   : Restart Service Dropbear, Squid3, OpenVPN dan SSH" 
echo -e ""
echo -e "${GREEN}=================================================================${NC}"
echo -e ""
read -p "     Select From Options [1-8 or x] :  " port
echo -e ""
case $port in
1)
add-ssh
;;
2)
trial-ssh
;;
3)
renew-ssh
;;
4)
del-ssh
;;
5)
cek-ssh
;;
6)
list-ssh
;;
7)
delete
;;
8)
autokill
;;
9)
mulog
;;
10)
restart
;;
x)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac
