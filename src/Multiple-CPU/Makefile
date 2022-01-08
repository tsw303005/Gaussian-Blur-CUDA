CC = clang
CXX = clang++
CXXFLAGS = -O3 -fopenmp -march=native -ffast-math -lpng
CFLAGS = -O3 -lm -fopenmp -march=native -ffast-math -lpng
EXES     := gaussian_blur

alls: $(EXES)

clean:
	rm -f $(EXES)

hw3-1: hw3-1.cc
	$(CXX) $(CXXFLAGS) -o $@ $?