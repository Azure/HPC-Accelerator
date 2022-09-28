#!/bin/bash

cyclecloud initialize --batch --force --url=https://localhost:443 --verify-ssl=false --username=$1 --password=$2
wget "https://jrslocker.blob.core.windows.net/repo/slurm-ndv4.v.1.tgz?sp=r&st=2022-09-28T22:21:58Z&se=2022-10-01T06:21:58Z&spr=https&sv=2021-06-08&sr=c&sig=u5D2gwsqOsS0%2B9lWFjUnMJoAeSpP95rAiPtu%2BromTtk%3D" -k -O "slurm-ndv4.v.1.tgz"
tar -xzvf slurm-ndv4.v.1.tgz
cd slurm-ndv4/projects/limits_1.0.0
cyclecloud project upload azure-storage
sleep 2
cd ../nhc_1.0.0/
cyclecloud project upload azure-storage
sleep 2
cd ../misc_ndv4_1.0.0/
cyclecloud project upload azure-storage
sleep 2
 cd ../misc_ubuntu_1.0.0/
cyclecloud project upload azure-storage
sleep 2
cd ../slurm_pyxis_enroot_1.0.0/
cyclecloud project upload azure-storage
sleep 2
sudo cp ../../scripts/slurm-2.6.4.txt /opt/cycle_server/config/data
cd ../../clusters/
sed -i "s/myprefix/$3/g" slurmcycle.json
sed -i "s/myregion/$4/g" slurmcycle.json
cyclecloud import_cluster -f slurm_cycle.txt -p slurmcycle.json -c Ndv4Slurm -t
sleep 2
cyclecloud create_cluster Ndv4Slurm deeplearning -p slurmcycle.json
