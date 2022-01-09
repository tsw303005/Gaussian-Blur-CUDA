#!/bin/bash
make clean
make
srun -N1 -n1 -c1 --gres=gpu:1 ./gaussian_blur ../../testcase/origin/jerry.png ../../testcase/result/jerry.png
make clean