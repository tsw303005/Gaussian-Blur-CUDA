#!/bin/bash
make clean
make
srun -n1 -c8 ./gaussian_blur ../../testcase/origin/mountain.png ../../testcase/result/mountain.png 10
make clean