#!/bin/bash
make clean
make
./gaussian_blur ../../../testcase/origin/bridge.png ../../../testcase/result/bridge.png 3
make clean