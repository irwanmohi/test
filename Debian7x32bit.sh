#
#!/bin/bash
#

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

if [[ -e /etc/debian_version ]]; then
	OS=debian
	GROUPNAME=nogroup
	RCLOCAL='/etc/rc.local'
else
	echo "Looks like you aren't running this installer on Debian or Ubuntu"
	exit 2
fi

ipAddr=$(wget -qO- ipv4.icanhazip.com);
ipAddress="s/xxxxxxxxx/$ipAddr/g";

cd ~

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# set time GMT +8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# sources list
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/FrogyX/IntK/master/Configs/sources.list"
wget "http://www.dotdeb.org/dotdeb.gpg" && apt-key add dotdeb.gpg && rm dotdeb.gpg
wget "http://www.webmin.com/jcameron-key.asc" && apt-key add jcameron-key.asc && rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba* && apt-get -y --purge remove apache2* && apt-get -y --purge remove sendmail* && apt-get -y --purge remove bind9*

# update
apt-get update && apt-get -y upgrade

# install required webserver pakages
apt-get -y install nginx php5-fpm php5-cli
# apt-get -y install  php5-mysql apt-get -y install  php5-mcrypt

# install essential package
apt-get -y install htop && apt-get -y install slurm
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# Install figlet
cd
apt-get install figlet
echo "clear" >> .bashrc
echo 'figlet -k "$HOSTNAME"' >> .bashrc
echo 'echo -e "=============================="' >> .bashrc
echo 'echo -e "Contact Us"' >> .bashrc
echo 'echo -e "------------------------------"' >> .bashrc
echo 'echo -e " Facebook: Doctype.Int"' >> .bashrc
echo 'echo -e " Whatsapp: +60149541324"' >> .bashrc
echo 'echo -e " Telegram: @Doctype"' >> .bashrc
echo 'echo -e " Website: https://int-knowledge.my"' >> .bashrc
echo 'echo -e "=============================="' >> .bashrc
echo 'echo -e ""' >> .bashrc

# configure webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/FrogyX/IntK/master/Configs/nginx.conf"
mkdir -p /home/domain/public_html
echo "<center><h1>Int-Knowledge <b>|</b> <i>Doctype</i></h1></center>" > /home/domain/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/domain/public_html/phpinfo.php
wget -O /etc/nginx/conf.d/domain.conf "https://raw.githubusercontent.com/FrogyX/IntK/master/Configs/domain.conf"
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# configure openvpn server
cd
apt-get -y install openvpn
wget -O /etc/openvpn/vpnKeys.tar "https://raw.githubusercontent.com/FrogyX/IntK/master/Configs/vpnKeys.tar"
cd /etc/openvpn/
tar xf vpnKeys.tar
wget -O /etc/openvpn/server.conf "https://raw.githubusercontent.com/FrogyX/IntK/master/Configs/vpnServer.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/newiptables.conf
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/FrogyX/IntK/master/Configs/iptables"
chmod +x /etc/network/if-up.d/iptables
service openvpn restart

# configure openvpn client
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn "https://raw.githubusercontent.com/FrogyX/IntK/master/Configs/vpnClient.conf"
sed -i $ipAddress /etc/openvpn/client.ovpn
cp client.ovpn /home/domain/public_html/

# configure ssh
cd
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 2020' /etc/ssh/sshd_config
service ssh restart

# configure dropbear
cd
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 4343"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# configure squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/FrogyX/IntK/master/Configs/squid.conf"
sed -i $ipAddress /etc/squid3/squid.conf
service squid3 restart

# install fail2ban
cd
apt-get -y install fail2ban

# install and configure webmin
cd
apt-get -y -f install webmin
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart

# Instal & configure DDoS Flate
if [ -d '/usr/local/ddos' ]; then
	echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1

# command script
wget -O /usr/bin/menu "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/mainMenu.sh"
wget -O /usr/bin/01 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/trialAccount.sh"
wget -O /usr/bin/02 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/generateAccount.sh"
wget -O /usr/bin/03 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/createAccount.sh"
wget -O /usr/bin/04 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/renewAccount.sh"
wget -O /usr/bin/05 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/changePassword.sh"
wget -O /usr/bin/06 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/lockAccount.sh"
wget -O /usr/bin/07 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/unlockAccount.sh"
wget -O /usr/bin/08 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/deleteAccount.sh"
wget -O /usr/bin/09 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/listAccount.sh"
wget -O /usr/bin/10 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/onlineAccount.sh"
wget -O /usr/bin/11 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/monitorBandwidth.sh"
wget -O /usr/bin/12 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/monitorPerformance.sh"
wget -O /usr/bin/13 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/speedtest_cli.py"
wget -O /usr/bin/14 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/detailServer.sh"
wget -O /usr/bin/15 "https://raw.githubusercontent.com/FrogyX/IntK/master/scriptBash/servicesRestart.sh"

chmod +x /usr/bin/menu
chmod +x /usr/bin/01
chmod +x /usr/bin/02
chmod +x /usr/bin/03
chmod +x /usr/bin/04
chmod +x /usr/bin/05
chmod +x /usr/bin/06
chmod +x /usr/bin/07
chmod +x /usr/bin/08
chmod +x /usr/bin/09
chmod +x /usr/bin/10
chmod +x /usr/bin/11
chmod +x /usr/bin/12
chmod +x /usr/bin/13
chmod +x /usr/bin/14
chmod +x /usr/bin/15

# restart pakages service
chown -R www-data:www-data /home/domain/public_html
service ssh restart
service openvpn restart
service dropbear restart
service squid3 restart
service fail2ban restart
service nginx restart
service php-fpm restart
service webmin restart

rm -f /root/Debian7x32bit.sh

# final step
echo "You need [reboot] your server to complete this setup."

echo "###################################"
echo "Int-Knowledge | Doctype"
echo "###################################"
