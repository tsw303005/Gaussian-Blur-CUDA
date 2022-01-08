#!/bin/bash
make clean
make
nvprof ./gaussian_blur ../../testcase/origin/bridge.png ../../testcase/result/bridge.png
make clean