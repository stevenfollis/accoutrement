#!/bin/bash

# Store license URL
DOCKEREEURL=$1

# Update the apt package index
sudo apt-get -qq update

# Install packages to allow apt to use a repository over HTTPS
sudo apt-get -qq install \
  apt-transport-https \
  curl \
  software-properties-common

# Add Docker’s official GPG key using your customer Docker EE repository URL
curl -fsSL $DOCKEREEURL/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
sudo add-apt-repository \
   "deb [arch=amd64] $DOCKEREEURL/ubuntu \
   $(lsb_release -cs) \
   stable-17.06"

# Update the apt package index
sudo apt-get -qq update

# Install the latest version of Docker EE
# dpkg produces lots of chatter
# redirect to abyss via https://askubuntu.com/a/258226
sudo apt-get -qq install docker-ee > /dev/null

# Finished
echo "Finished installing Docker EE"