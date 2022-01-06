#include <iostream>
#include <math.h>
#include <string>
#include <png.h>

int read_png(const std::string filename, unsigned char **image, unsigned *height,
             unsigned *width, unsigned *channels);


int main(int argc, char **argv) {
    std::string filename = argv[1];
    unsigned int height, width, channels;
    unsigned char *image = NULL;

    // read image
    if (!read_png(filename, &image, &height, &width, &channels)) {
        std::cout<< "[Info]: Cannot read image file \n\n";
        exit(1);
    }

    
    return 0;
}

int read_png(const std::string filename, unsigned char **image, unsigned *height,
             unsigned *width, unsigned *channels)
{
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

  //cudaMallocHost(&host_t, height * width * channels * sizeof(unsigned char));
  if ((*image = (unsigned char *)malloc(rowbytes * *height)) == NULL)
  {
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    return 3;
  }

  for (i = 0; i < *height; ++i)
    row_pointers[i] = *image + i * rowbytes;
  png_read_image(png_ptr, row_pointers);
  png_read_end(png_ptr, NULL);
  return 0;
}