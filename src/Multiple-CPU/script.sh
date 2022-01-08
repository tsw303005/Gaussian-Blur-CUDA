#!/bin/bash
make clean
make
srun -n1 -c8 ./gaussian_blur ../../testcase/origin/bridge.png ../../testcase/result/bridge.png 3
make clean