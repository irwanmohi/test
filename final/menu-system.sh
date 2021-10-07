#!/bin/bash
clear
echo -e "==========================[ Menu VPS ]========================" | lolcat
echo -e "==============================================================" | lolcat
echo -e ""
echo -e "	*	[1]  Set Auto Reboot VPS" 
echo -e "	*	[2]  Change Port Of Some Service"
echo -e "	*	[3]  Autobackup Data VPS" 
echo -e "	*	[4]  Backup Data VPS" 
echo -e "	*	[5]  Restore Data VPS"
echo -e "	*	[6]  Webmin Menu" 
echo -e "	*	[7]  Update To Latest Kernel" 
echo -e "	*	[8]  Check Usage Bandwith Server"
echo -e "	*	[9]  Limit Bandwith Speed Server" 
echo -e "	*	[10] Check Usage of VPS Ram" 
echo -e "	*	[11] Reboot VPS" 
echo -e "	*	[12] Speedtest VPS" 
echo -e "	*	[13] Update To Latest Script Version" 
echo -e "	*	[14] Displaying System Information" 
echo -e "	*	[15] Info Script Auto Install"
echo -e ""
echo -e "==============================================================" | lolcat
read -p "     Select From Options [number or x] :  " num
echo -e ""
case $num in
1)
auto-reboot
;;
2)
change-port
;;
3)
autobackup
;;
4)
backup
;;
5)
restore
;;
6)
webmin
;;
7)
kernel-up
;;
8)
vnstat
;;
9)
speed-limiter
;;
10)
ram
;;
11)
reboot
;;
12)
speedtest
;;
13)
update
;;
14)
info 
;;
15)
about
;;
x)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac
