#!/bin/bash
make clean
make
nvprof ./gaussian_blur ../../testcase/basic.png ./images/single-gpu.png 
make clean