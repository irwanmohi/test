#!/bin/bash
#Script Auto Reboot Vps

RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'

# Auto Reboot
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
cek=$(cat /home/autoreboot)
function start () {
echo "0 0 * * * root /usr/bin/reboot" > /etc/cron.d/reboot
echo "start" > /home/autoreboot
echo "Done"
}
function start () {
echo "0 0 * * * root /usr/bin/reboot" > /etc/cron.d/reboot
echo "start" > /home/autoreboot
echo "Done"
}
function stop () {
rm /etc/cron.d/reboot
sleep 0.5
echo > /home/autoreboot
echo "Done"
}

#Status Auto Reboot
if [[ "$cek" = "start" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
clear

# Echo Shell
echo -e "${GREEN}========================================================= ${NC}"
figlet Auto Reboot | lolcat
echo -e "${GREEN}========================================================= ${NC}"
echo -e "Status $sts"
echo -e "  1. Start Auto Reboot"
echo -e "  2. Stop Auto Reboot"
echo -e ""
echo -e "Press CTRL+C to return"
read -rp "Please Enter The Correct Number : " -e num
if [[ "$num" = "1" ]]; then
start
elif [[ "$num" = "2" ]]; then
stop
else
echo "You Entered The Wrong Number"
fi