/*********************************************************************

STM32L432KC_ADC.h

Jackson Philion and Zhian Zhou, December 5 2024
jphilion@g.hmc.edu and zzhou@g.hmc.edu

Header for ADC functions, supports the .c version of this file.
For more, see:

https://jacksonphilion.github.io/final-project-portfolio/ 

*********************************************************************/

#ifndef STM32L4_ADC_H
#define STM32L4_ADC_H

#include <stdint.h>
#include <stm32l432xx.h>
#include "STM32L432KC_GPIO.h"

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void ms_delay(int ms);
void configureADC(void);
void startADC(void);
uint16_t readADC(void);

#endif