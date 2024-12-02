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

/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////  GLOBAL VARIABLES  //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

uint16_t buffer1[BUFFER_SIZE]; // Buffer 1 for ADC data
uint16_t buffer2[BUFFER_SIZE]; // Buffer 2 for ADC data

volatile uint32_t *DMAptr = buffer1; // Points to the buffer being filled by DMA
volatile uint32_t *FFTptr = buffer2; // Points to the buffer ready for processing
volatile uint8_t FFTReady = 1; // Flag indicating if FFTptr is ready for processing

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////  main.c LOOP  /////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////


int main(void) {
  ///////////////////////////////  Set Up MCU and Timer  /////////////////////////////////////
  configureFlash();
  configureClock();
  RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
  initTIM(TIM2);


  ///////////////////////////////  Configure Interrupts  /////////////////////////////////////
  __enable_irq();  //Enable Interrupts Globally
  NVIC_EnableIRQ(DMA1_Channel1_IRQn);  //Enable DMA Interrupt
  NVIC_SetPriority(DMA1_Channel1_IRQn, 0);  //Set DMA as Top priority


  //////////////////////////////  Set Up DMA and ADC  ////////////////////////////////////////
  configureDMA_prototype();  //Configure DMA first
  configureADC();  //Configure ADC second
  startADC();
  

  //////////////////////  Test Function (2 buffers, each 2 uint16 tall)  ///////////////////// 

  uint16_t val0;
  uint16_t val1;
  uint16_t val2;
  uint16_t val3;
  uint32_t *startAbuf1 = buffer1;
  uint32_t *startAbuf2 = buffer2;
  uint8_t whileEntry = 1;

  delay_millis(TIM2, 2000);

  while (whileEntry) {
        
      printf("start buffer1 \n");
      for(int i=0; i<2048; i++){
      printf("%d\n",buffer1[i]);
      }

      printf("start buffer2 \n");
      for(int k=0; k<2048; k++){
      printf("%d\n",buffer2[k]);
      }
      /* GET THE CURRENT ADC DATA REGISTER VALUE

      testingVar = readADC();
      // Print ADC Value
      printf("ADC testingVar is: %d\n", testingVar);
      */
      

      /*  GET THE FIRST TWO ENTRIES FROM EACH BUFFER

      // Read ADC values from their buffers in memory
      val0 = buffer1[0];
      val1 = buffer1[1];
      val2 = buffer2[0];
      val3 = buffer2[1];
      // Print Memory value
      printf("Buffer1 [0] holds: %d\nBuffer1 [1] holds: %d\nBuffer2 [0] holds: %d\nBuffer2 [1] holds: %d\n", val0, val1, val2, val3);
      */


      // delay_millis(TIM2, 100);

      whileEntry = whileEntry-1;
  }

  return 0;
}

/*************************** End of file ****************************/
