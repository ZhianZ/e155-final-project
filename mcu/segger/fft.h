#include <stdio.h>
#include "arm_math.h"

#define FFT_SIZE 2048  // FFT size
#define SAMPLE_RATE 12500 // Sampling rate in Hz

float32_t calculate_frequency(const uint16_t *signal);

