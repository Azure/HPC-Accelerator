#!/bin/bash

set -ex

#### 
# Requirements: Ubuntu 18.04
####

# Install Docker and NVIDIA Docker                                                       
#### Install Docker                                                       
echo "\n---------------- Install Docker ----------------"
cd /mnt/resource
sudo apt install -y runc
sudo apt install -y containerd
sudo apt install -y docker.io
#### Install NV-DOCKER                                                       
echo "\n---------------- Install NV-Docker ----------------"
cd /mnt/resource
# If you have nvidia-docker 1.0 installed: we need to remove it and all existing GPU containers
docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f

set +e
sudo apt-get purge -y nvidia-docker
set -e

# Add the package repositories
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd

# Update the docker config file
sudo systemctl stop docker
sudo sh -c "echo '{  \"data-root\": \"/mnt/resource/docker\", \"bip\": \"152.26.0.1/16\", \"runtimes\": { \"nvidia\": { \"path\": \"/usr/bin/nvidia-container-runtime\", \"runtimeArgs\": [] } } }' > /etc/docker/daemon.json"
sudo systemctl restart docker

set +e
sudo docker run --runtime=nvidia --rm nvidia/cuda:11.0-base nvidia-smi
set -e

### Install NVtop
echo "\n---------------- Install NVtop ----------------"
sudo apt install -y cmake libncurses5-dev libncursesw5-dev git
cd /tmp
cp ${CYCLECLOUD_SPEC_PATH}/files/nvtop-1.2.2.tar.gz .
tar xzf nvtop-1.2.2.tar.gz
cd nvtop-1.2.2
cmake .
make
sudo make install
