#!/bin/bash

cyclecloud initialize --batch --force --url=https://localhost:443 --verify-ssl=false --username=$1 --password=$2
wget "https://github.com/Azure/HPC-Accelerator/raw/main/scenarios/deeplearning/code/script/slurm-ndv4.v.1.tgz" -k -O "slurm-ndv4.v.1.tgz"
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
cyclecloud import_cluster -f slurm_cycle.txt -p slurmcycle.json -c Ndv4Slurm
sleep 2
cyclecloud create_cluster Ndv4Slurm deeplearning -p slurmcycle.json
echo "CycleCloud UI IP:"; ip route get 8.8.8.8 | grep -oP 'src \K[^ ]+'
