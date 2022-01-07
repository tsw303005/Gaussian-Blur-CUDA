#!/bin/bash
make clean
make
time ./gaussian_blur ../../testcase/basic.png ./images/basic_single_cpu.png 3
make clean