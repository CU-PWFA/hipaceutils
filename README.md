# HiPACE++ Utilities

This repository contains input decks, analysis scripts, Jupyter notebooks, and example configurations for workign with HiPACE++. The file structure is as follows:

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

## Great Lakes @ UofM

Log in with ```ssh <yourid>@greatlakes.arc-ts.umich.edu```.

### Running on GPU

Create a file ``` profile.hipace ``` and ``` source ``` it whenever you log in and want to work with HiPACE++. I include an example profile in this repository, but here is the copy-and-paste version:

```
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

```
git clone https://github.com/Hi-PACE/hipace.git $HOME/hipace # or any other path you prefer
```

Compile the code using CMake

```bash
source profile.hipace # load the correct modules
cd $HOME/src/hipace   # or where HiPACE++ is installed
rm -rf build
cmake -S . -B build -DHiPACE_COMPUTE=CUDA
cmake --build build -j 16
```






