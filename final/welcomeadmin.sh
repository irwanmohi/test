#!/bin/bash
clear
NORMAL=`echo "\033[m"`
NUMBER=`echo "\033[33m"` #yellow
LRED=`echo "\033[0m\033[1;31m"`
neofetch | lolcat
echo -e ""
echo -e "${NUMBER} #Silahkan ketik ${LRED}menu${NUMBER} untuk masuk ke Fitur Menu VPS ${NORMAL}"
echo -e ""
