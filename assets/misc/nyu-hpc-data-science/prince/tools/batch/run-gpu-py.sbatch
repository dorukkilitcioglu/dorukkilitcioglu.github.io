#!/bin/bash

#SBATCH --job-name=pygpu
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=32GB
#SBATCH --cpus-per-task=2
#SBATCH --mem=64GB
#SBATCH --time=4:00:00
#SBATCH --gres=gpu:1
#SBATCH --mail-type=END
#SBATCH --mail-user=<net_id>@nyu.edu

module purge
module load cuda/9.0.176
module load cudnn/9.0v7.0.5
module load anaconda3/4.3.1
source activate <env_name>

python 