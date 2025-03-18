# HiPACE++ Utilities

This repository contains input decks, analysis scripts, Jupyter notebooks, and example configurations for working with HiPACE++. The file structure is as follows:

```bash
.
├── analysis/			# Contains all resources related to data analysis
│   ├── notebooks/		# Interactive Jupyter Notebooks (walkthroughs, basic analysis, etc.)
│   └── scripts/		# Automation scripts for analysis tasks
├── decks/			# Collection of important and interesting input decks
├── jobex.sh		# Job batch script for running on the Great Lakes cluster at the University of Michigan
├── profile.hipace	# Environment setup file for HiPACE++ on the Great Lakes cluster
└── README.md		# Overview of the project, usage instructions, and documentation
```

# Installation Instructions

Installation instructions for certain clusters are not included in the HiPACE++ documentation. For clusters I've worked with that aren't covered there, I provide installation details for here. If your cluster isn't listed here, refer to the [official HiPACE++ documentation](https://hipace.readthedocs.io/en/latest/building/hpc.html).

I've written documentation for the following HPC machines:

- [Great Lakes @ UofM](#great-lakes--uofm)
- [CURC @ CU Boulder](#curc--cu-boulder)

## Great Lakes @ UofM

Log in with ```ssh <yourid>@greatlakes.arc-ts.umich.edu```.

### Building for GPU

Create a file ``` profile.hipace ``` and ``` source ``` it whenever you log in and want to work with HiPACE++. This repository includes an example profile [here](https://github.com/leahghartman/hipaceutils/blob/main/profile.hipace), but here's a copy-and-paste version for convenience:

```bash
# Required dependencies
module load cmake
module load gcc
module load cuda
module load hdf5
module load openmpi

# Optimize CUDA compilation for V100 on Great Lakes
export AMREX_CUDA_ARCH=7.0

# Compiler environment hints
export CC=gcc
export CXX=g++
export CUDACXX=nvcc
export CUDAHOSTCXX=${CXX}
```

Download HiPACE++ from GitHub (the first time, and whenever you want the latest version):

```bash
git clone https://github.com/Hi-PACE/hipace.git $HOME/hipace # or any other path you prefer
```

Compile the code using CMake (I would do this line-by-line):

```bash
source profile.hipace # load the correct modules
cd $HOME/hipace   # or where HiPACE++ is installed
rm -rf build
cmake -S . -B build -DHiPACE_COMPUTE=CUDA
cmake --build build -j 16
```

You can learn about the HiPACE++ input file format in the [Get Started](https://hipace.readthedocs.io/en/latest/run/get_started.html) section of the official documentation, which will help you create an input file tailored to your simulation needs. After setting up your input file (which I have an example of [here](https://github.com/leahghartman/hipaceutils/blob/main/decks/plasma-prof)), modify the example job script below and use it to submit a simulation (this script in file form is available [here](https://github.com/leahghartman/hipaceutils/blob/main/jobex.sh)).

```bash
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

#SBATCH --mail-user=<yourid>@umich.edu
#SBATCH --mail-type=BEGIN,END

# The application(s) to execute along with its input arguments and options:

##################################################################################
# EDIT BELOW HERE
##################################################################################

# Select the input file, root directory, and data directory
export INPUTFILE=/path/to/input/file

export ROOT_DIR=/path/to/hipace/root/directory
export DATA_DIR=/path/to/data/output/directory

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
```

Note that this example simulation runs on 4 GPUs, since ``` --nodes=2 ``` and ``` --gres=gpu:2 ``` yields two nodes with two GPUs each.

## CURC @ CU Boulder

Before proceeding with the documentation, I’d like to mention that although I worked on this cluster, it was only for a brief period. I’ve updated the job script I previously used when I did have access, but I’m unsure if it will work as I never actually ran it on CURC. Nonetheless, it should be sufficient to help you get started.

Log in with ``` ssh <yourid>@login.rc.colorado.edu ```.

### Building for GPU

Create a ``` profile.hipace ``` and ``` source ``` it whenever you log in and want to work with HiPACE++. This repository includes an example profile [here](https://github.com/leahghartman/hipaceutils/blob/main/profile.hipace) (please note that the CUDA optimization line in this file is specific to Great Lakes, not CURC), but here's a copy-and-paste version for convenience:

```bash
# Required dependencies
module load cmake
module load gcc
module load cuda
module load hdf5
module load openmpi

# Optimize CUDA compilation for A100 on CURC
export AMREX_CUDA_ARCH=8.0

# Compiler environment hints
export CC=gcc
export CXX=g++
export CUDACXX=nvcc
export CUDAHOSTCXX=${CXX}
``` 

Download HiPACE++ from GitHub (the first time, and whenever you want the latest version):

```bash
git clone https://github.com/Hi-PACE/hipace.git $HOME/hipace # or any other path you prefer
```

Compile the code using CMake (I would do this line-by-line):

```bash
source profile.hipace # load the correct modules
cd $HOME/hipace   # or where HiPACE++ is installed
rm -rf build
cmake -S . -B build -DHiPACE_COMPUTE=CUDA
cmake --build build -j 16
```

You can get familiar with the HiPACE++ input file format in the official documentation's [Get Started](https://hipace.readthedocs.io/en/latest/run/get_started.html) section, to prepare an input file that suits your simulation needs. After setting up your input file (which I have an example of [here](https://github.com/leahghartman/hipaceutils/blob/main/decks/plasma-prof)), modify the example job script below and use it to submit a simulation.

```bash
#!/bin/bash

#SBATCH --partition=aa100
#SBATCH --job-name=hipace-example
#SBATCH --qos=normal
#SBATCH --time=02:00:00
#SBATCH --qos=normal
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --gres=gpu:2
#SBATCH --mail-user=<yourid>@colorado.edu

# The application(s) to execute along with its input arguments and options:                                                                                                 
                                                                                                                                                                            
##################################################################################
# EDIT BELOW HERE                                                                                                                                                           
##################################################################################                                                                                          
                                                                                                                                                                            
# Select the input file, root directory, and data directory                                                                                                                 
export INPUTFILE=/path/to/input/file                                                                                                                                        
                                                                                                                                                                            
export ROOT_DIR=/path/to/hipace/root/directory                                                                                                                              
export DATA_DIR=/path/to/data/output/directory                                                                                                                              
                                                                                                                                                                            
# Name of run (OPTIONAL; can be blank, no space)                                                                                                                            
RUNTITLE=test                                                                                                                                                               
                                                                                                                                                                            
# GPU settings                                                                                                                                                              
export MPICH_GPU_SUPPORT_ENABLED=1              # GPU-aware MPI                                                                                                             
export CUDA_VISIBLE_DEVICES=$SLURM_LOCALID      # Expose one GPU per MPI rank                                                                                               
                                                                                                                                                                            
#################################################################################                                                                                           
                                                                                                                                                                            
# Path to HiPACE++ executable and new directory name                                                                                                                        
export EXEC=hipace.MPI.CUDA.DP.LF                                                                                                                                           
export DIR_NAME=hip_${RUNTITLE}_${SLURM_JOB_ID}%.rc.colorado.edu                                                                                                        
                                                                                                                                                                            
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
```

Note that this example simulation runs on 2 GPUs, since ``` --nodes=2 ``` and ``` --gres=gpu:2 ``` yields two nodes with two GPUs each.

