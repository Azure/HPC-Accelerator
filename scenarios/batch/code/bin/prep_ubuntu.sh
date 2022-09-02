#!/bin/bash -xe

#-- helper script for environment prep on Ubuntu 18.04, 20.04, 20.10 ++>

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# https://releases.hashicorp.com/terraform/
sudo apt-get install -y wget unzip
wget https://releases.hashicorp.com/terraform/0.14.4/terraform_0.14.4_linux_amd64.zip
sudo unzip terraform_0.14.4_linux_amd64.zip
sudo mv terraform /usr/local/bin

# https://docs.docker.com/engine/install/ubuntu/
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $(whoami)

sudo apt-get install -y jq redis-tools python3-pip
sudo pip3 install -r ../src/requirements.txt

terraform -v
az version
docker version
