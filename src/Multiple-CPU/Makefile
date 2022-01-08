CC = clang
CXX = clang++
CXXFLAGS = -O3 -fopenmp -march=native --fast-math
CFLAGS = -O3 -lm -fopenmp -march=native --fast-math
EXES     := gaussian_blur

alls: $(EXES)

clean:
	rm -f $(EXES)

hw3-1: hw3-1.cc
	$(CXX) $(CXXFLAGS) -o $@ $?