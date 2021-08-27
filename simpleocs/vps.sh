sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install python-software-properties -y && sudo add-apt-repository ppa:keithw/mosh -y && sudo apt-get update && sudo apt-get install mosh -y && sudo tasksel && sudo apt-get install php5 php5-gd php5-mysql php5-curl php5-cli php5-cgi php5-dev -y && sudo a2enmod rewrite expires headers mime deflate filter && sudo service apache2 restart && sudo apt-get install phpmyadmin -y && sudo apt-get install vim -y && sudo apt-get install git-core git-gui git-doc -y && cd ~ && mkdir ~/.ssh
cd ~/.ssh && ssh-keygen -t rsa -C "ryan@digitalbrands.com" && git config --global user.name "Ryan Frankel" && git config --global user.email "ryan@digitalbrands.com"
sudo apt-add-repository ppa:chris-lea/node.js -y && sudo apt-get update && sudo apt-get install nodejs -y && sudo aptitude install npm -y && sudo npm install -g less && git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle && cd ~ && git init && git remote add vimrc git@github.com:digital-brands/.vimrc.git && git pull vimrc master && mkdir ~/.vim/colors && curl -L http://www.vim.org/scripts/download_script.php?src_id=13400 > ~/.vim/colors/wombat256mod.vim && sudo add-apt-repository ppa:webupd8team/java -y && sudo apt-get update && sudo apt-get install oracle-java7-installer -y && sudo apt-get install sendmail -y && sudo apt-get install libjpeg-progs gifsicle optipng imagemagick -y && cd ~ && git clone git://github.com/git/git.git ./git/ && cd git/contrib/subtree && make && sudo install -m 755 git-subtree /usr/lib/git-core && cd ~ && rm -rf ./git

1. Create Website subdirectory

    `cd /home/`
    `sudo mkdir {site-name}`
     `cd {site-name}`
    `sudo mkdir public_html && sudo mkdir logs`

1. Set up a Virtual Host - /etc/apache2/sites-available

<VirtualHost *:80>
    ServerAdmin ryan@digitalbrands.com
    ServerName {site-url}
    ServerAlias www.{site-url}
    DocumentRoot /home/{site-url}/public_html
    ErrorLog /home/{site-url}/logs/error.log
    CustomLog /home/{site-url}/logs/access.log combined
</VirtualHost>

1. Enable Site

    `sudo a2ensite {virtualhost-filename}

1. Set the permissions

`sudo chgrp -R www-data public_html/ && sudo chmod -R g+w public_html/ && sudo find public_html/ -type d -exec sudo chmod g+s {} \; && sudo chown -R www-data public_html/`
