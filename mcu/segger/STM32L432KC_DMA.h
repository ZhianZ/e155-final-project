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
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void configureDMA(void);
void configureDMA_prototype(void);
#endif