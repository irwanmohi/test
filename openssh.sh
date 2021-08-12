#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
	echo "You need to run this as root!"
	exit 1
fi

if [[ -e /etc/debian_version ]]; then
	OS=debian
	GROUPNAME=nogroup
	RCLOCAL='/etc/rc.local'
else
	echo "Looks like you aren't running this installer on Debian."
	exit 2
fi

# Install Required Packages
function packages {
	echo "Updating the server and installing required packages..."
	# Update the server
	apt-get -y update > /dev/null 2>&1
	echo "Package update complete. . ."
	apt-get -y upgrade > /dev/null 2>&1
	echo "Server upgrade complete. . ."
	# Install required packages
	echo "Installing required packages..."
	apt-get -y install build-essential > /dev/null 2>&1
}

# User Input
# Get user input for required variables
function input {
	#Note
	echo "Insert the following values, required  for setup: "
	echo "You can leave the value as default. "

	# Get IP address
	default=$(wget -qO- ipv4.icanhazip.com)
	read -p "Enter IP address [$default]: " IP
	IP=${IP:-$default}

	# Get main port
	default="22"
	read -p "Enter port for SSH [$default]: " mainport
	mainport=${mainport:-$default}

	# Get extra port
	default="2020"
	read -p "Enter extra port for SSH [$default]: " altport
	altport=${altport:-$default}

	# Get KeyRegenerationInterval
	default="3600"
	read -p "Enter KeyRegenerationInterval [$default]: " KeyRegInterval
	KeyRegInterval=${KeyRegInterval:-$default}

	# Get ServerKeyBits
	default="1024"
	read -p "Enter ServerKeyBits [$default]: " ServerKeyBits
	ServerKeyBits=${ServerKeyBits:-$default}

	# Get ClientAliveInterval
	default="120"
	read -p "Enter ClientAliveInterval [$default]: " ClientAliveInterval
	ClientAliveInterval=${ClientAliveInterval:-$default}

	# ClientAliveCountMax
	default="2"
	read -p "Enter ClientAliveCountMax [$default]: " ClientAliveCountMax
	ClientAliveCountMax=${ClientAliveCountMax:-$default}
}

function secureshell {
	sed -i -e "s/Port 22/Port $mainport/" /etc/ssh/sshd_config
	sed -i -e "a/Port $altport/" /etc/ssh/sshd_config
	sed -i -e "s/KeyRegenerationInterval 3600/KeyRegenerationInterval $KeyRegInterval" /etc/ssh/sshd_config
	sed -i -e "s/ServerKeyBits 1024/ServerKeyBits $ServerKeyBits" /etc/ssh/sshd_config
	sed -i -e "s/ClientAliveInterval 120/ClientAliveInterval $ClientAliveInterval" /etc/ssh/sshd_config
	sed -i -e "s/ClientAliveCountMax 2/ClientAliveCountMax $ClientAliveCountMax" /etc/ssh/sshd_config
}

input
packages
secureshell
