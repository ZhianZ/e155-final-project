#include "fft.h"

float32_t input[FFT_SIZE];   // Float input for FFT
float32_t output[FFT_SIZE];  // FFT output (complex interleaved)
float32_t magnitudes[FFT_SIZE / 2]; // Magnitude array
float32_t hann_window[FFT_SIZE];  // Hanning window

float32_t calculate_frequency(const uint16_t *signal) {
    // Normalize input signal
    float32_t norm_signal[FFT_SIZE];
    for (size_t i = 0; i < FFT_SIZE; i++) {
        norm_signal[i] = (signal[i] / 4096.0f) * 2.0f - 1.0f;
    }

    // Apply Hanning window
    for (int i = 0; i < FFT_SIZE; i++) {
        hann_window[i] = 0.5f * (1 - cosf(2 * M_PI * i / (FFT_SIZE - 1))); // Hanning window
        input[i] = norm_signal[i] * hann_window[i]; // Apply window to the signal
    }

    // Initialize the RFFT instance
    arm_rfft_fast_instance_f32 S;
    arm_rfft_fast_init_f32(&S, FFT_SIZE);

    // Perform the FFT
    arm_rfft_fast_f32(&S, input, output, 0); // Forward FFT

    // Compute the magnitude (complex magnitude)
    arm_cmplx_mag_f32(output, magnitudes, FFT_SIZE / 2);

    // Find the dominant frequency
    float32_t maxValue;
    uint32_t maxIndex;
    arm_max_f32(magnitudes, FFT_SIZE / 2, &maxValue, &maxIndex);

    // Calculate the dominant frequency
    float32_t dominant_frequency = (float32_t)maxIndex * SAMPLE_RATE / FFT_SIZE;

    return dominant_frequency;
}