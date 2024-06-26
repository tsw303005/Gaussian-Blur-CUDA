# Gaussian-Blur-CUDA
- We implement Gaussian Blur with CUDA
- We used different size image to compare their performance


## Result
Before | After
:-----:|:------:|
![](./testcase/origin/mountain.png) | ![](./testcase/result/mountain.png)
![](./testcase/origin/bridge.png) |![](./testcase/result/bridge.png)
![](./testcase/origin/view.png) | ![](./testcase/result/view.png)


## Experiment
- CPU: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz
- GPU: GEFORCE GTX 1080 Ti



### Computation Performance Comparison between Sequential, OpenMP, CUDA
- Filter Matrix size: 53*53
- Multiple threads: 8
- Multiple GPU number: 2
- V3 version sequential implementation

Filename |Size|Single thread|Multiple threads|Single GPU|Multiple GPU
:----------:|:-----------------:|:-------------------:|:----------:|:-----------------:|:-------------:|
iceberg.png|0.8 MB|12.6372(s)|1.44974(s)|0.528766(s)|0.204902(s)
mountain.png|1.9 MB|23.9481(s)|2.5741(s)|0.594938(s)|0.238576(s)
bridge.png |2.1 MB|35.1401(s)|3.69399(s)|0.647862(s)|0.369114(s)
view.png|2.4 MB|46.6573(s)|4.82201(s)|0.701165(s)|0.300363(s)
candy.png|13.9 MB|362.181(s)|36.6829(s)|2.43379(s)|1.1862(s)

Time Profile | Speedup Factor
:------------:|:---------------:|
![](./testcase/result/iceberg_timeprofile.png) | ![](./testcase/result/iceberg_speedup.png)
![](./testcase/result/mountain_timeprofile.png) | ![](./testcase/result/mountain_speedup.png)
![](./testcase/result/bridge_timeprofile.png) | ![](./testcase/result/bridge_speedup.png)
![](./testcase/result/view_timeprofile.png) | ![](./testcase/result/view_speedup.png)
![](./testcase/result/candy_timeprofile.png) | ![](./testcase/result/candy_speedup.png)

### GPU performance on Big Size Data
Filename |Size|One GPU|Two GPU|
:----------:|:-----------------:|:-------------------:|:----------:
candy.png | 13.9 MB | 2.43379(s) | 1.1862(s)
jerry.png | 27.6 MB | 8.07605(s) | 4.20553(s)
large-candy.png | 79 MB | 21.5988 (s) | 11.0503 (s)

Time Profile | Speedup Factor
:------------:|:---------------:|
![](./testcase/result/GPU_compare.jpeg) | ![](./testcase/result/gpu_compare_speedup.jpeg)

## Acknowledgments
Our Gaussian Blur implementation is mainly based on the following two website.
- [Gaussian Blur introduction](https://en.wikipedia.org/wiki/Gaussian_blur)
- [Gaussian Blur implementation](http://blog.ivank.net/fastest-gaussian-blur.html)
