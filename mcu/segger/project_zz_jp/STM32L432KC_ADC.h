// STM32L432KC_ADC.h
// Header for ADC functions

#ifndef STM32L4_ADC_H
#define STM32L4_ADC_H

#include <stdint.h>
#include <stm32l432xx.h>
#include "STM32L432KC_GPIO.h"

#define PIN_INPUT PA11

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void configureADC();

#endif