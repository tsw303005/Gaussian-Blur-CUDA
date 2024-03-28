#include <iostream>
#include <math.h>
#include <string>
#include <png.h>
#include <algorithm>

#define PI std::acos(-1)
#define r 10
#define rs (int)ceil((double)r * 2.57)
#define Rs 53 // filter matrix size
#define BK 16 // block dim
#define THREAD 256

int read_png(const char *filename, unsigned char **image, unsigned *height, unsigned *width, unsigned *channels);
void write_png(const char *filename, png_bytep image, const unsigned height, const unsigned width, const unsigned channels);
void gaussian_filter(double **host_filter_matrix, double *wsum);
__global__ void gaussian_blur(unsigned char *src, unsigned char *tar, double *device_filter_matrix, unsigned height, unsigned width, unsigned channels, double wsum);

// calculate time
struct timespec start, timeEnd;
double total_time = 0.0;
double timeDiff(struct timespec start, struct timespec timeEnd){
    // function used to measure time in nano resolution
    float output;
    float nano = 1000000000.0;
    if(timeEnd.tv_nsec < start.tv_nsec) output = ((timeEnd.tv_sec - start.tv_sec -1)+(nano+timeEnd.tv_nsec-start.tv_nsec)/nano);
    else output = ((timeEnd.tv_sec - start.tv_sec)+(timeEnd.tv_nsec-start.tv_nsec)/nano);
    return output;
}

int main(int argc, char **argv)
{
    unsigned height, width, channels;
    unsigned char *host_src = NULL;
    unsigned char *device_src = NULL;
    unsigned char *host_tar = NULL;
    unsigned char *device_tar = NULL;
    double *host_filter_matrix = NULL;
    double *device_filter_matrix = NULL;
    double wsum = 0;

    // read image
    if (read_png(argv[1], &host_src, &height, &width, &channels)) {
        std::cout << "[Info]: Cannot read image file \n\n";
        std::cout << "[Info]: Calculation -------- FAIL\n";
        exit(1);
    }

    // allocate memory
    host_tar = (unsigned char*)malloc(sizeof(unsigned char) * height * width * channels);

    // allocate device_src more memory to prevent out of memory
    clock_gettime(CLOCK_MONOTONIC, &start); // get start time
    cudaMalloc(&device_src, height * width * channels * sizeof(unsigned char));
    cudaMalloc(&device_tar, height * width * channels * sizeof(unsigned char));
    cudaMemcpy(device_src, host_src, height * width * channels * sizeof(unsigned char), cudaMemcpyHostToDevice);

    // precalculate gaussian filter
    gaussian_filter(&host_filter_matrix, &wsum);

    cudaMalloc((void**)(&device_filter_matrix), sizeof(double) * (2 * rs + 1) * (2 * rs + 1));
    cudaMemcpy((void*)device_filter_matrix, host_filter_matrix, sizeof(double) * (2 * rs + 1) * (2 * rs + 1), cudaMemcpyHostToDevice);

    // calculate block size and thread number
    int x = (width % BK) ? width / BK + 1 : width / BK;
    int y = (height % BK) ? height / BK + 1 : height / BK;
    dim3 blocks_size(x, y);
    dim3 threads_size(THREAD);

    // gaussian blur algorithm
    gaussian_blur<<<blocks_size, threads_size>>>(device_src, device_tar, device_filter_matrix, height, width, channels, wsum);

    clock_gettime(CLOCK_MONOTONIC, &timeEnd); // get end time
    total_time += timeDiff(start, timeEnd); // update computation time

    // write result back to host
    cudaMemcpy(host_tar, device_tar, height * width * channels * sizeof(unsigned char), cudaMemcpyDeviceToHost);
    // clock_gettime(CLOCK_MONOTONIC, &timeEnd); // get end time
    // total_time += timeDiff(start, timeEnd); // update computation time

    // write image back
    write_png(argv[2], host_tar, height, width, channels);

    std::cout << "[Info]: Result saved in " << argv[2] << std::endl;
    std::cout << "[Info]: Calculation -------- SUCCESS\n";
    std::cout << "[Info]: Total Executioin time = " << total_time << std::endl;

    // free image array
    free(host_src);
    free(host_tar);
    free(host_filter_matrix);
    cudaFree(device_src);
    cudaFree(device_tar);
    cudaFree(device_filter_matrix);

    return 0;
}

__global__ void gaussian_blur(unsigned char *src, unsigned char *tar, double *device_filter_matrix, unsigned height, unsigned width, unsigned channels, double wsum) {
    __shared__ unsigned char R_arr[Rs + BK][Rs + BK];
    __shared__ unsigned char G_arr[Rs + BK][Rs + BK];
    __shared__ unsigned char B_arr[Rs + BK][Rs + BK];

    int row_block = blockIdx.y * BK;
    int col_block = blockIdx.x * BK;
    int row_pixel = row_block + threadIdx.x / BK;
    int col_pixel = col_block + threadIdx.x % BK;
    int row_inner = threadIdx.x / BK;
    int col_inner = threadIdx.x % BK;
    int get_row_pixel, get_col_pixel;
    double result[3];

    for (int i = threadIdx.x / 64; i < Rs + BK; i += 4) { // 4 = threadnum / 64
        for (int j = threadIdx.x % 64; j < Rs + BK; j += 64) {
            get_row_pixel = min(height - 1, max(0, row_block - rs + i));
            get_col_pixel = min(width - 1, max(0, col_block - rs + j));
            R_arr[i][j] = src[(get_row_pixel * width + get_col_pixel) * channels + 2];
            G_arr[i][j] = src[(get_row_pixel * width + get_col_pixel)* channels + 1];
            B_arr[i][j] = src[(get_row_pixel * width + get_col_pixel) * channels + 0];
        }
    }
    __syncthreads();

    if (row_pixel < height and col_pixel < width) {
        result[0] = result[1] = result[2] = 0.0;
        for (int i = 0; i <= Rs; i++) {
            for (int j = 0; j <= Rs; j++) {
                result[2] += (double)R_arr[row_inner + i][col_inner + j] * device_filter_matrix[Rs * j + i];
                result[1] += (double)G_arr[row_inner + i][col_inner + j] * device_filter_matrix[Rs * j + i];
                result[0] += (double)B_arr[row_inner + i][col_inner + j] * device_filter_matrix[Rs * j + i];
            }
        }

        tar[channels * (row_pixel * width + col_pixel) + 2] = round(result[2] / wsum);
        tar[channels * (row_pixel * width + col_pixel) + 1] = round(result[1] / wsum);
        tar[channels * (row_pixel * width + col_pixel) + 0] = round(result[0] / wsum);
    }
    
}

void gaussian_filter(double **host_filter_matrix, double *wsum) {
    int dsq;
    double a = (double)(PI * 2 * r * r);
    double b = 2 * r * r;
    double wght;
    
    (*host_filter_matrix) = (double*)malloc(sizeof(double) * (2 * rs + 1) * (2 * rs + 1));

    for (int i = 0; i <= 2 * rs; i++) {
        for (int j = 0; j <= 2 * rs; j++) {
            dsq = (i - rs) * (i - rs) + (j - rs) * (j - rs);
            wght = exp((double)(-1 * dsq) / b) / a;
            (*host_filter_matrix)[(2 * rs + 1) * i + j] = wght;
            (*wsum) += wght;
        }
     }
}

int read_png(const char *filename, unsigned char **image, unsigned *height, unsigned *width, unsigned *channels) {
    unsigned char sig[8];
    FILE *infile;
    infile = fopen(filename, "rb");

    fread(sig, 1, 8, infile);
    if (!png_check_sig(sig, 8))
        return 1; /* bad signature */

    png_structp png_ptr;
    png_infop info_ptr;

    png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png_ptr)
        return 4; /* out of memory */

    info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr) {
        png_destroy_read_struct(&png_ptr, NULL, NULL);
        return 4; /* out of memory */
    }

    png_init_io(png_ptr, infile);
    png_set_sig_bytes(png_ptr, 8);
    png_read_info(png_ptr, info_ptr);
    int bit_depth, color_type;
    png_get_IHDR(png_ptr, info_ptr, width, height, &bit_depth, &color_type, NULL, NULL, NULL);

    png_uint_32 i, rowbytes;
    png_bytep row_pointers[*height];
    png_read_update_info(png_ptr, info_ptr);
    rowbytes = png_get_rowbytes(png_ptr, info_ptr);
    *channels = (int)png_get_channels(png_ptr, info_ptr);

    // cudaMallocHost(&host_t, height * width * channels * sizeof(unsigned char));
    if ((*image = (unsigned char *)malloc(rowbytes * *height)) == NULL) {
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        return 3;
    }

    for (i = 0; i < *height; ++i)
        row_pointers[i] = *image + i * rowbytes;
    png_read_image(png_ptr, row_pointers);
    png_read_end(png_ptr, NULL);
    return 0;
}

void write_png(const char *filename, png_bytep image, const unsigned height, const unsigned width, const unsigned channels) {
    FILE *fp = fopen(filename, "wb");
    png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    png_infop info_ptr = png_create_info_struct(png_ptr);
    png_init_io(png_ptr, fp);
    png_set_IHDR(png_ptr, info_ptr, width, height, 8,
                 PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
    png_set_filter(png_ptr, 0, PNG_NO_FILTERS);
    png_write_info(png_ptr, info_ptr);
    png_set_compression_level(png_ptr, 1);

    png_bytep row_ptr[height];
    for (int i = 0; i < height; ++i) {
        row_ptr[i] = image + i * width * channels * sizeof(unsigned char);
    }
    png_write_image(png_ptr, row_ptr);
    png_write_end(png_ptr, NULL);
    png_destroy_write_struct(&png_ptr, &info_ptr);
    fclose(fp);
}