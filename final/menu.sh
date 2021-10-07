#!/bin/bash
clear
m="\033[0;1;36m"
y="\033[0;1;37m"
yy="\033[0;1;32m"
yl="\033[0;1;33m"
wh="\033[0m"
echo -e ""
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )
WKT=$(curl -s ipinfo.io/timezone )
IPVPS=$(curl -s ifconfig.me/ip )
echo -e ""
echo -e "$m-----------------------------------------------------------------$y"
echo -e "$m1 IP Vps       : $IPVPS"
echo -e "$m1 Isp Vps Name : $ISP"
echo -e "$m1 City         : $CITY"
echo -e "$m1 Waktu        : $WKT"
echo -e ""
echo -e "$m------------------------=$y SSH & OPENVPN $m=--------------------------$wh"
echo -e "$yy 1$y.   Create SSH & OpenVPN Account (add-ssh)"
echo -e "$yy 2$y.   Generate SSH & OpenVPN Trial Account (trial-ssh)"
echo -e "$yy 3$y.   Extending SSH & OpenVPN Account Active Life (renew-ssh)"
echo -e "$yy 4$y.   Delete SSH & OpenVpn Account (delete-ssh)"
echo -e "$yy 5$y.   Check User Login SSH & OpenVPN (cek-ssh)"
echo -e "$yy 6$y.   Daftar Member SSH & OpenVPN (member)"
echo -e "$yy 7$y.   Delete User Expired SSH & OpenVPN (del-exp)"
echo -e "$yy 8$y.   Set up Autokill SSH (autokill)"
echo -e "$yy 9$y.   Displays Users Who Do Multi Login SSH (ceklim)"
echo -e "$yy 10$y.  Restart Service Dropbear, Squid3, OpenVPN dan SSH (restart)"
echo -e ""
echo -e "$m--------------------------=$y WIREGUARD $m=----------------------------$wh"
echo -e "$yy 11$y.  Create Account Wireguard (add-wg)"
echo -e "$yy 12$y.  Delete Account Wireguard (del-wg)"
echo -e "$yy 13$y.  Check User Login Wireguard (cek-wg)"
echo -e "$yy 14$y.  Extending Account Wireguard Active Life (renew-wg)"
echo -e "$yy 15$y.  Check Wireguard User Interface(wg-show)"
echo -e ""
echo -e "$m-----------------------------=$y L2TP $m=------------------------------$wh"
echo -e "$yy 16$y.  Create Account L2TP (add-l2tp)"
echo -e "$yy 17$y.  Delete Account L2TP (del-l2tp)"
echo -e "$yy 18$y.  Extending Account L2TP Active Life (renew-l2tp)"
echo -e ""
echo -e "$m-----------------------------=$y PPTP $m=------------------------------$wh"
echo -e "$yy 19$y.  Create Account PPTP (add-pptp)"
echo -e "$yy 20$y.  Delete Account PPTP (del-pptp)"
echo -e "$yy 21$y.  Extending Account PPTP Active Life (renew-pptp)"
echo -e "$yy 22$y.  Check User Login Wireguard (cek-pptp)"
echo -e ""
echo -e "$m-----------------------------=$y SSTP $m=------------------------------$wh"
echo -e "$yy 23$y.  Create Account SSTP (add-sstp)"
echo -e "$yy 24$y.  Delete Account SSTP (del-sstp)"
echo -e "$yy 25$y.  Extending Account SSTP Active Life (renew-sstp)"
echo -e "$yy 26$y.  Check User Login SSTP (cek-sstp)"
echo -e ""
echo -e "$m--------------------------=$y SHADOWSOCKSR $m=-------------------------$wh"
echo -e "$yy 27$y.  Create Account SSR (add-ssr)"
echo -e "$yy 28$y.  Delete Account SSR (del-ssr)"
echo -e "$yy 29$y.  Extending Account SSR Active Life (renew-ssr)"
echo -e "$yy 30$y.  Show Other SSR Menu (ssr)"
echo -e ""
echo -e "$m--------------------------=$y SHADOWSOCKS $m=--------------------------$wh"
echo -e "$yy 31$y.  Create Account Shadowsocks (add-ss)"
echo -e "$yy 32$y.  Delete Account Shadowsocks (del-ss)"
echo -e "$yy 33$y.  Extending Account Shadowsocks Active Life (renew-ss)"
echo -e "$yy 34$y.  Check User Login Shadowsocks (cek-ss)"
echo -e ""
echo -e "$m--------------------------=$y V2RAY / VMESS $m=------------------------$wh"
echo -e "$yy 35$y.  Create Account V2RAY Vmess Websocket (add-vmess)"
echo -e "$yy 36$y.  Delete Account V2RAY Vmess Websocket (del-vmess)"
echo -e "$yy 37$y.  Extending Account Vmess Active Life (renew-vmess)"
echo -e "$yy 38$y.  Check User Login V2RAY (cek-vmess)"
echo -e "$yy 39$y.  Renew Certificate V2RAY Account (cert2vray)"
echo -e ""
echo -e "$m--------------------------=$y V2RAY / VLESS $m=------------------------$wh"
echo -e "$yy 40$y.  Create Account V2RAY Vless Websocket (add-vless)"
echo -e "$yy 41$y.  Delete Account V2RAY Vless Websocket (del-vless)"
echo -e "$yy 42$y.  Extending Account Vless Active Life (renew-vless)"
echo -e "$yy 43$y.  Check User Login V2RAY (cek-vless)"
echo -e ""
echo -e "$m----------------------------=$y TROJAN GFW $m=-------------------------$wh"
echo -e "$yy 44$y.  Create Account Trojan (add-tr)"
echo -e "$yy 45$y.  Deleting Account Trojan (del-tr)"
echo -e "$yy 46$y.  Extending Account Trojan Active Life (renew-tr)"
echo -e "$yy 47$y.  Check User Login Trojan (cek-tr)"
echo -e ""
echo -e "$m------------------------------=$y SYSTEM $m=--------------------------$wh"
echo -e "$yy 48$y.  Add Or Change Subdomain Host For VPS (add-host)"
echo -e "$yy 49$y.  Change Port Of Some Service (change-port)"
echo -e "$yy 50$y.  Webmin Menu (wbmn)"
echo -e "$yy 51$y.  Limit Bandwith Speed Server (limit-speed)"
echo -e "$yy 52$y.  Check Usage of VPS Ram (ram)"
echo -e "$yy 53$y.  Reboot VPS (reboot)"
echo -e "$yy 54$y.  Speedtest VPS (speedtest)"
echo -e "$yy 55$y.  Displaying System Information (info)"
echo -e "$yy 56$y.  Info Script Auto Install (about)"
echo -e "$yy 57$y.  Exit From VPS (axit) "
echo -e ""
echo -e "$m=================================================================$y"
echo -e ""
echo -e "$m1 GEO GABUT $m​​​​​"
echo -e ""
read -p "Select From Options [ 1 - 57 ] : " menu
echo -e ""
case $menu in
1)
usernew
;;
2)
trial
;;
3)
renew
;;
4)
deluser
;;
5)
cek
;;
6)
member
;;
7)
delete
;;
8)
autokill
;;
9)
ceklim
;;
10)
restart
;;
11)
add-wg
;;
12)
del-wg
;;
13)
cek-wg
;;
14)
renew-wg
;;
15)
wg show
;;
16)
add-l2tp
;;
17)
del-l2tp
;;
18)
renew-l2tp
;;
19)
add-pptp
;;
20)
del-pptp
;;
21)
renew-pptp
;;
22)
cek-pptp
;;
23)
add-sstp
;;
24)
del-sstp
;;
25)
renew-sstp
;;
26)
cek-sstp
;;
27)
add-ssr
;;
28)
del-ssr
;;
29)
renew-ssr
;;
30)
ssr
;;
31)
add-ss
;;
32)
del-ss
;;
33)
renew-ss
;;
34)
cek-ss
;;
35)
add-ws
;;
36)
del-ws
;;
37)
renew-ws
;;
38)
cek-ws
;;
39)
cert2vray
;;
40)
add-vless
;;
41)
del-vless
;;
42)
renew-vless
;;
43)
cek-ws
;;
44)
add-tr
;;
45)
del-tr
;;
46)
renew-tr
;;
47)
cek-tr
;;
48)
add-host
;;
49)
change-port
;;
50)
wbmn
;;
51)
limit-speed
;;
52)
ram
;;
53)
reboot
;;
54)
speedtest
;;
55)
info
;;
56)
about
;;
57)
exit
;;
*)
clear
menu
;;
esac

