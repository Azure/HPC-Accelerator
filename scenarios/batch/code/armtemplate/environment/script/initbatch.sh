#!/bin/bash -e
apt-get -y update 
apt-get install 
DEBIAN_FRONTEND=noninteractive apt-get install software-properties-common -y
DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:deadsnakes/ppa 
apt-get update -y

# Dependent Packages
DEBIAN_FRONTEND=noninteractive apt-get install unzip wget curl git jq gnupg gnupg2 software-properties-common python3.9 python3-pip docker.io redis-tools -y
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-setuptools 


ln -s -f /usr/bin/python3.9 /usr/local/bin/python
alias python3="python"

apt install python3.8-venv

# terraform cli install 
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install terraform

#az cli install
curl -sL https://aka.ms/InstallAzureCLIDeb | bash