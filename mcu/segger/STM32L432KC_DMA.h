/***************************************************

// STM32L432KC_DMA.h

Zhian Zhou and Jackson Philion, November 10 2024

This file supports the DMA functions used for the E155
final project "Fix That Note!"

More can be found out about the project at the report below:


***************************************************/

#ifndef STM32L4_DMA_H
#define STM32L4_DMA_H

#include <stdint.h> // Include stdint header
#include <stm32l432xx.h>

///////////////////////////////////////////////////////////////////////////////
// Definitions
///////////////////////////////////////////////////////////////////////////////

#define BUFFER_SIZE 2048 // TBD
uint16_t buffer1[BUFFER_SIZE]; // Buffer 1 for ADC data
uint16_t buffer2[BUFFER_SIZE]; // Buffer 2 for ADC data

volatile uint32_t *DMAptr = buffer1; // Points to the buffer being filled by DMA
volatile uint32_t *FFTptr = buffer2; // Points to the buffer ready for processing
volatile uint8_t FFTReady = 0; // Flag indicating if FFTptr is ready for processing

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void configureDMA(void);

#endif