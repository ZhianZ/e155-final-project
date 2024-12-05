/*********************************************************************

fft.h

Jackson Philion and Zhian Zhou, December 5 2024
jphilion@g.hmc.edu and zzhou@g.hmc.edu

This header file supports fft.c, the main file which contains the
helper functions we created for our FFT and SPI processes.
For more, see:

https://jacksonphilion.github.io/final-project-portfolio/ 

*********************************************************************/


#include <stdio.h>
#include "arm_math.h"

#define FFT_SIZE 2048  // FFT size
#define SAMPLE_RATE 12500 // Sampling rate in Hz

float32_t calculate_frequency(const uint16_t *signal);

