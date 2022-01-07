#!/bin/bash
make clean
make
./gaussian_blur ../../../testcase/basic.png .././images/basic_single_cpu_v3.png 3
make clean