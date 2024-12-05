/*********************************************************************

STM32L432KC.h

Jackson Philion and Zhian Zhou, December 5 2024
jphilion@g.hmc.edu and zzhou@g.hmc.edu

Header to include all other device-specific libraries, including the
custom ADC and modified DMA files made for our project. For more, see:

https://jacksonphilion.github.io/final-project-portfolio/ 

*********************************************************************/

#ifndef STM32L4_H
#define STM32L4_H


#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stm32l432xx.h>

// Include other peripheral libraries

#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_TIM.h"
#include "STM32L432KC_FLASH.h"
#include "STM32L432KC_USART.h"
#include "STM32L432KC_SPI.h"
#include "STM32L432KC_ADC.h"
#include "STM32L432KC_DMA.h"

// Global defines

#define HSI_FREQ 16000000 // HSI clock is 16 MHz
#define MSI_FREQ 4000000  // HSI clock is 4 MHz

#endif