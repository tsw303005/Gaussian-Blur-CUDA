#!/bin/bash
make clean
make
./gaussian_blur ../../testcase/basic.png ./images/basic_single_gpu.png
make clean