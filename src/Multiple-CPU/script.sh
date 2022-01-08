#!/bin/bash
make clean
make
srun -n1 -c12 ./gaussian_blur ../../testcase/origin/view.png ../../testcase/result/view.png 10
make clean