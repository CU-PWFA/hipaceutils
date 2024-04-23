#!/bin/bash

#SBATCH --partition=aa100
#SBATCH --job-name=hipace-example
#SBATCH --output=hipace-example.%j.out
#SBATCH --qos=normal
#SBATCH --time=02:00:00
#SBATCH --qos=normal
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:1
#SBATCH --mail-user=leah.ghartman@gmail.com

# path to executable and input script
EXE=/projects/leha2242/software/hipace/build/bin/hipace
INPUTS=inputs_normalized

# GPU-aware MPI
export MPICH_GPU_SUPPORT_ENABLED=1

# expose one GPU per MPI rank
export CUDA_VISIBLE_DEVICES=$SLURM_LOCALID

# run everything
srun ${EXE} ${INPUTS}
