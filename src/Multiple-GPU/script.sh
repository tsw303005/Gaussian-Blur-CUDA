#!/bin/bash
make clean
make
srun -N1 -n1 -c2 --gres=gpu:2 ./gaussian_blur ../../testcase/origin/candy.png ../../testcase/result/candy.png
make clean