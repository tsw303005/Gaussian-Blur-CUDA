#include <iostream>
#include <math.h>
#include <string>
#include <png.h>
#include <algorithm>

#define PI std::acos(-1)

int read_png(const char *filename, unsigned char **image, unsigned *height, unsigned *width, unsigned *channels);
void write_png(const char *filename, png_bytep image, const unsigned height, const unsigned width, const unsigned channels);
void gaussian_blur(unsigned char **src_image, unsigned char **tar_image, const unsigned height, const unsigned width, const unsigned channels, const unsigned r);


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
    unsigned height, width, channels, kernel;
    unsigned char *image = NULL;
    unsigned char *tar_image = NULL;
    unsigned r = strtol(argv[3], 0, 10);

    // read image
    if (read_png(argv[1], &image, &height, &width, &channels)) {
        std::cout << "[Info]: Cannot read image file \n\n";
        std::cout << "[Info]: Calculation -------- FAIL\n";
        exit(1);
    }

    tar_image = (unsigned char*)malloc(sizeof(unsigned char) * height * width * channels);
    clock_gettime(CLOCK_MONOTONIC, &start);
    // start to calculate guassian blur value
    gaussian_blur(&image, &tar_image, height, width, channels, r);
    clock_gettime(CLOCK_MONOTONIC, &timeEnd);
    total_time += timeDiff(start, timeEnd);


    // write image back
    write_png(argv[2], tar_image, height, width, channels);

    std::cout << "[Info]: Result saved in " << argv[2] << std::endl;
    std::cout << "[Info]: Calculation -------- SUCCESS\n";
    std::cout << "[Info]: Total Executioin time = " << total_time << std::endl;

    // free image array
    free(image);
    free(tar_image);

    return 0;
}

void gaussian_blur(unsigned char **src_image, unsigned char **tar_image, const unsigned height, const unsigned width, const unsigned channels, const unsigned r) {
    int rs = ceil((double)r * 2.57);
    int x, y, dsq;
    double val[channels];
    double wght, wsum;
    double a = (double)(PI * 2 * r * r);
    double b = 2 * r * r;

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            wsum = 0;
            for (int now = 0; now < channels; now++) val[now] = 0;
            for (int iy = i - rs; iy < i + rs + 1; iy++) {
                for (int ix = j - rs; ix < j + rs + 1; ix++) {
                    x = std::min((int)width-1, std::max(0, ix));
                    y = std::min((int)height-1, std::max(0, iy));
                    dsq = (ix-j) * (ix-j) + (iy-i) * (iy-i);
                    wght = exp((double)(-1 * dsq) / b) / a;
                    //std::cout<< wght << std::endl;
                    for (unsigned now = 0; now < channels; now++) val[now] += (*src_image)[channels * (y * width + x) + now] * wght;
                    wsum += wght;
                }
            }
            for (unsigned now = 0; now < channels; now++) (*tar_image)[channels * (i * width + j) + now] = round(val[now]/wsum);
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