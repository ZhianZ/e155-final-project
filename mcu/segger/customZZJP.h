/*
This header file contains the global variables used by Zhian Zhou and
Jackson Philion's final project.
*/

#ifndef CUSTOMZZJP_H
#define CUSTOMZZJP_H

#include <stdint.h>

#define PIN_INPUT PB0  // Definition for ADC.h

#define BUFFER_SIZE 2048  // Definition for these variables, as well as 

extern uint16_t buffer1[BUFFER_SIZE];
extern uint16_t buffer2[BUFFER_SIZE];

extern volatile uint32_t *DMAptr;
extern volatile uint32_t *FFTptr;
extern volatile uint8_t FFTReady;

#endif