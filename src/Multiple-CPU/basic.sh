#!/bin/bash
#SBATCH -c 1
#SBATCH -n 8
make clean
make
srun ./gaussian_blur ../../testcase/basic.png ./images/multi-cpu-omp.png 3
make clean