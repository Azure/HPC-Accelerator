#!/bin/bash
#
#SBATCH --job-name=test
#
#SBATCH --get-user-env
#SBATCH --time=5:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --output=TestJob.out

srun echo "Start process"
srun hostname
srun sleep 60
srun echo "End process"
