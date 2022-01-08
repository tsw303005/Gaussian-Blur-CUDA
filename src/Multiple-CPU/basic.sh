#!/bin/bash
make clean
make
srun -n1 -c8 ./gaussian_blur ../../testcase/bridge.png ./images/bridge-multi-cpu-omp.png 3
make clean