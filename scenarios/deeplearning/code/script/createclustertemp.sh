#!/bin/bash

/usr/local/bin/cyclecloud initialize --batch --force --url=https://localhost:443 --verify-ssl=false --username=$1 --password=$2
wget  https://bmhpcwus2.blob.core.windows.net/share/cc-slurm/slurm-custom-v0.6.tgz
tar -xzvf slurm-custom-v0.6.tgz
cd slurm-custom
/usr/local/bin/cyclecloud project upload
cd templates
/usr/local/bin/cyclecloud import_template slurm-ngc -f ./slurm-custom.txt -c slurm