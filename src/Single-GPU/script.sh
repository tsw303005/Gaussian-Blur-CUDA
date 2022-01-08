#!/bin/bash
make clean
make
nvprof ./gaussian_blur ../../testcase/origin/mountain.png ../../testcase/result/mountain.png
make clean