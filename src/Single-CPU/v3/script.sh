#!/bin/bash
make clean
make
./gaussian_blur ../../../testcase/origin/mountain.png ../../../testcase/result/mountain.png 3
make clean