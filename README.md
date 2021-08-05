>>Step 1
apt update && apt upgrade -y --fix-missing && update-grub && sleep 2 && reboot

>>Step 2 (Version 1)
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen && wget -O setup.sh 'https://script.gegevps.com/setup.sh' && chmod +x setup.sh && screen -S setup ./setup.sh && rm -rf ./setup.sh

>>Step 2 (Version 2)
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen && wget --no-check-certificate -O debian.sh 'https://script2.gegevps.com/debian.sh' && chmod +x debian.sh && screen -S debian ./debian.sh && rm -rf ./debian.sh
