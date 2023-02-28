#!/bin/bash -l

#SBATCH -A naiss2023-22-203
#SBATCH -p node
#SBATCH -n 189
#SBATCH -t 1:00:00
#SBATCH -J crepl

script/run-traces.sh
