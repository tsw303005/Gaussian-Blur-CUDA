#!/bin/bash
make clean
make
nvprof ./gaussian_blur ../../testcase/origin/candy.png ../../testcase/result/candy.png
make clean