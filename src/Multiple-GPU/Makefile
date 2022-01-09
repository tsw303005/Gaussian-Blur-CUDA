CC = clang
CXX = clang++
CXXFLAGS = -O3 -fopenmp -march=native -ffast-math -lpng
CFLAGS = -O3 -lm -fopenmp -march=native -ffast-math -lpng
NVFLAGS  := -std=c++11 -O3 -Xptxas="-v" -arch=sm_61 -Xcompiler -fopenmp -use_fast_math -lpng
LDFLAGS  := -lm
EXES     := gaussian_blur

alls: $(EXES)

clean:
	rm -f $(EXES)

gaussian_blur: gaussian_blur.cu
	nvcc $(NVFLAGS) $(LDFLAGS) -o $@ $?