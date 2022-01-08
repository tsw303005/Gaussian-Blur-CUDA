# Gaussian-Blur-CUDA
- We implement Gaussian Blur with C++ (Sequential), OpenMP, and CUDA
- We used different size image to compare their performance

## Build with
- C++
- OpenMP
- CUDA

## Getting Started
1. cd into the directory
2. modify the script.sh to choose the input image you want
3. execute the script.sh (make sure Makefile is here)</br>
- Example to execute single-gpu program (make sure that you have already had gpu and cuda installed)

```
cd src/Single-GPU
./script.sh
```

## Experiment
Filename  |Single CPU thread|Multiple CPU thread|Single GPU
:----------:|:-----------------:|:-------------------:|:----------:
