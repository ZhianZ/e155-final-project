/*********************************************************************

STM32L432KC_DMA.h

Jackson Philion and Zhian Zhou, December 5 2024
jphilion@g.hmc.edu and zzhou@g.hmc.edu

Header for DMA functions, supports the .c version of this file.
For more, see:

https://jacksonphilion.github.io/final-project-portfolio/ 

*********************************************************************/

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