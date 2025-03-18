#!/bin/bash

# "#SBATCH" directives that convey submission options:
#SBATCH --job-name=hipace-example
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --gres=gpu:2
#SBATCH --mem-per-cpu=1g
#SBATCH --time=2:00:00
#SBATCH --account=agrt98
#SBATCH --export=ALL
#SBATCH --partition=gpu

#SBATCH --mail-user=lghart@umich.edu
#SBATCH --mail-type=BEGIN,END

# The application(s) to execute along with its input arguments and options:

##################################################################################
# EDIT BELOW HERE
##################################################################################

# Select the input file, root directory, and data directory
export INPUTFILE=~/hipaceutils/decks/plasma-prof

export ROOT_DIR=~/hipace
export DATA_DIR=/scratch/agrt_root/agrt98/lghart/hiresults

# Name of run (OPTIONAL; can be blank, no space)
RUNTITLE=test

# GPU settings
export MPICH_GPU_SUPPORT_ENABLED=1		# GPU-aware MPI
export CUDA_VISIBLE_DEVICES=$SLURM_LOCALID	# Expose one GPU per MPI rank

#################################################################################

# Path to HiPACE++ executable and new directory name
export EXEC=hipace.MPI.CUDA.DP.LF
export DIR_NAME=hip_${RUNTITLE}_${SLURM_JOB_ID}%.nyx.engin.umich.edu

# Set directory up to output data
mkdir ${DATA_DIR}/${DIR_NAME}
cp -f ${ROOT_DIR}/build/bin/${EXEC} ${DATA_DIR}/${DIR_NAME}
cp -f ${INPUTFILE} ${DATA_DIR}/${DIR_NAME}/hi-stdin

cd ${DATA_DIR}/${DIR_NAME}

# Add text file for notes
touch notes
echo run did not finish >> notes

# Run code
srun ${EXEC} ${INPUTFILE}

# Remove executable and notes if job ran successfully
rm -f ${EXEC} notes
