#!/bin/bash
yum install -y nfs-utils

mkdir -p /shared
echo "10.21.2.4:/shared /shared nfs bg,rw,hard,noatime,nolock,rsize=65536,wsize=65536,vers=3,tcp,_netdev 0 0" >>/etc/fstab

mkdir -p /apps
echo "10.21.2.4:/apps /apps nfs bg,rw,hard,noatime,nolock,rsize=65536,wsize=65536,vers=3,tcp,_netdev 0 0" >>/etc/fstab

mount -a

chmod 777 /shared

chmod 777 /apps

