#!/bin/bash
make clean
make
./gaussian_blur ../../../testcase/origin/candy.png ../../../testcase/result/candy.png 3
make clean