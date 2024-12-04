/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start

*/

/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////  FILE INCLUSIONS  ///////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include "STM32L432KC.h"

#include "customZZJP.h" // Includes declarations of global variables and defines BUFFER_SIZE

#include "arm_math.h"
#include "arm_const_structs.h"

#include "fft.h"

/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////  GLOBAL VARIABLES  //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

uint16_t buffer1[BUFFER_SIZE]; // Buffer 1 for ADC data
uint16_t buffer2[BUFFER_SIZE]; // Buffer 2 for ADC data

volatile uint32_t *DMAptr = buffer1; // Points to the buffer being filled by DMA
volatile uint32_t *FFTptr = buffer2; // Points to the buffer ready for processing
volatile uint8_t FFTReady = 1; // Flag indicating if FFTptr is ready for processing

/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////  HELPER FUNCTIONS  //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

void send_frequency_via_spi(float32_t frequency) {
    uint16_t rounded_frequency = (uint16_t)roundf(frequency);

    // Pull CS(PA11) low to select the FPGA 
    digitalWrite(PA11, 0);

    // Transmit the frequency as a 16-bit value
    uint8_t high_byte = (rounded_frequency >> 8) & 0xFF;
    uint8_t low_byte = rounded_frequency & 0xFF;
    spiSendReceive(high_byte);
    spiSendReceive(low_byte);

    // Pull CS high to deselect the FPGA
    digitalWrite(PA11, 1);
}

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////  main.c LOOP  /////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////


int main(void) {
  ///////////////////////////////  Set Up MCU and Timer  /////////////////////////////////////
  configureFlash();
  configureClock();
  RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
  initTIM(TIM2);

  //////////////////////////////  Set Up SPI  ////////////////////////////////////////
  initSPI(1, 0, 0);

  ///////////////////////////////  Configure Interrupts  /////////////////////////////////////
  __enable_irq();  //Enable Interrupts Globally
  NVIC_EnableIRQ(DMA1_Channel1_IRQn);  //Enable DMA Interrupt
  NVIC_SetPriority(DMA1_Channel1_IRQn, 0);  //Set DMA as Top priority

  //////////////////////////////  Set Up DMA and ADC  ////////////////////////////////////////
  configureDMA_prototype();  //Configure DMA first
  configureADC();  //Configure ADC second
  startADC();

  //////////////////////  Test Function (2 buffers, each 2 uint16 tall)  ///////////////////// 

  while (1) {
        if (!FFTReady) {
            // Calculate the frequency from FFTptr buffer
            float32_t frequency = calculate_frequency(FFTptr);
            printf("%.2f Hz\n",frequency);

            // Transmit the frequency over SPI
            send_frequency_via_spi(frequency);

            FFTReady = 1; // Flag indicating FFT done
        }
    }
  return 0;
}

/*************************** End of file ****************************/
