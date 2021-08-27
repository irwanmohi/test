#!/bin/bash

# Check for git
#############################################################
hash git >/dev/null 2>&1 || {
  echo "Error: git is not installed. Trying to install..."
  sudo apt-get install git -y
}

# Clone the repo and run the install script
#############################################################
cd $HOME \
&& git clone --quiet --recursive https://github.com/db-pj/server-setup &> /dev/null \
&& . $HOME/server-setup/server-setup-20-04.sh
