#!/bin/bash
make clean
make
./gaussian_blur ../../../testcase/bridge.png ../images/bridge_single_cpu_v3.png 3
make clean