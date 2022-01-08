#!/bin/bash
make clean
make
srun -n1 -c8 ./gaussian_blur ../../testcase/origin/candy.png ../../testcase/result/candy.png 10
make clean