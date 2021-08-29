#!/bin/bash

# update and upgrade
apt-get update && apt-get -y upgrade

# install dependencies
apt-get -y install build-essential curl git unzip

# install dropbear package
DEBIAN_FRONTEND=noninteractive apt-get -y install dropbear

# cp default dropbear config file
cp /etc/default/dropbear /etc/default/dropbear.bak

# edit dropbear config file
echo 'NO_START=0
DROPBEAR_PORT=5968
DROPBEAR_EXTRA_ARGS="-p 8695"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536' > /etc/default/dropbear

# start dropbear service
systemctl start dropbear

# enable dropbear service on server startup
systemctl enable dropbear

# check dropbear service status
# systemctl status dropbear

# [OPTIONAL] prompt details
echo "Congratulation, we are done with dropbear setup"
echo ""
echo "=============================================="
echo "[ DROPBEAR DETAIL ]"
echo "----------------------------------------------"
echo "Status: Started & Enabled"
echo "Hostname: example.com"
echo "Ipaddress: xxx.xxx.xxx.xxx"
echo "Ports:5968 & 8695(TLS)"
echo "=============================================="
