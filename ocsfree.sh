#!/bin/bash
# Script by : _Dreyannz_

# install webserver extensions
apt-get -y install nginx
apt-get -y install php7.0-fpm php7.0-cli libssh2-1 php-ssh2 php7.0 apache2
service apache2 restart
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mkdir -p /home/vps/public_html
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/lanundarat87/xxx/main/Res/Other/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/lanundarat87/xxx/main/Res/Other/vps.conf"
wget -O /etc/nginx/conf.d/monitoring.conf "https://raw.githubusercontent.com/lanundarat87/xxx/main/Res/Other/monitoring.conf"
sed -i 's/listen = \/run\/php\/php7.0-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/7.0/fpm/pool.d/www.conf
sed -i $MYIP2 /home/vps/public_html/index.php;
service php7.0-fpm restart
service nginx restart
cd /home/vps/public_html
wget https://raw.githubusercontent.com/Dreyannz/VPS_Site/master/Version%203.0/index.php
wget --quiet https://raw.githubusercontent.com/Dreyannz/VPS_Site/master/Version%203.0/server.php
