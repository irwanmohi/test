#!/bin/bash
# Program: OHPServer Kaizen

export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

# installing ohpserver
if [[ -e /usr/bin/ohpserver  ]]; then
echo -e "ohpserver already install"
sleep 3;clear
else
echo -e "installing ohpserver"
sleep 3;clear
wget https://github.com/lfasmpao/open-http-puncher/releases/download/0.1/ohpserver-linux32.zip
unzip ohpserver-linux32.zip
rm *.zip
mv ohpserver /usr/bin/
chmod +x /usr/bin/ohpserver
fi

# adding kaizen for ohpserver
if [[ -e /usr/bin/kaizen  ]]; then
echo -e "kaizen for ohpserver exist but will be update"
sleep 3;clear
rm /usr/bin/kaizen
cat> /usr/bin/kaizen << END
#!/bin/bash
screen -dmS dropbear ohpserver -port 50001 -proxy $MYIP:80443 -tunnel $MYIP:143
screen -dmS openvpn ohpserver -port 50000 -proxy $MYIP:80443 -tunnel $MYIP:1194
#screen -dmS vless ohpserver -port 8058 -proxy $MYIP:80443 -tunnel $MYIP:880
END
chmod +x /usr/bin/kaizen
else
echo -e "adding kaizen for ohpserver"
sleep 3;clear
cat> /usr/bin/kaizen << END
#!/bin/bash
screen -dmS dropbear ohpserver -port 50001 -proxy $MYIP:80443 -tunnel $MYIP:143
screen -dmS openvpn ohpserver -port 50000 -proxy $MYIP:80443 -tunnel $MYIP:1194
#screen -dmS vless ohpserver -port 8058 -proxy $MYIP:80443 -tunnel $MYIP:880
END
chmod +x /usr/bin/kaizen
fi

# adding kaizen service for running
if [[ -e /etc/systemd/system/kaizen.service  ]]; then
echo -e "kaizen service already adding"
sleep 3;clear
else
echo -e "adding kaizen service for running"
sleep 3;clear
cat> /etc/systemd/system/kaizen.service << END
[Unit]
Description=OHP KAIZEN
[Service]
Type=forking
ExecStart=/usr/bin/kaizen
[Install]
WantedBy=multi-user.target
END
systemctl daemon-reload
service kaizen start
systemctl enable kaizen
fi

if [[ -e /root/log-ohp.txt  ]]; then
rm /root/log-ohp.txt
echo -e "Installation has been completed!!"
echo ""
echo ""
echo "DROPBEAR : 8170" | tee -a log-ohp.txt
echo "Openvpn Non : 50000" | tee -a log-ohp.txt
echo ""
echo ""
read -n 1 -r -s -p $'Press any key to reboot...\n';reboot
else
echo -e "Installation has been completed!!"
echo ""
echo ""
echo "DROPBEAR : 50001" | tee -a log-ohp.txt
echo "OPENVPN : 50000" | tee -a log-ohp.txt
echo ""
fi
