#!/bin/bash
make clean
make
srun -n1 -c1 ./gaussian_blur ../../../testcase/origin/bridge.png ../../../testcase/result/bridge.png 10
make clean