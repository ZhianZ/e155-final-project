/*********************************************************************

STM32L432KC_ADC.h

Jackson Philion and Zhian Zhou, December 5 2024
jphilion@g.hmc.edu and zzhou@g.hmc.edu

Source code for ADC functions.
For more, see:

https://jacksonphilion.github.io/final-project-portfolio/ 

*********************************************************************/


#include "STM32L432KC_ADC.h"

#include "customZZJP.h" // Includes definition of INPUT_PIN

// Function for dummy delay by executing nops
void ms_delay(int ms) {
   while (ms-- > 0) {
      volatile int x=1000;
      while (x-- > 0)
         __asm("nop");
   }
}

void configureADC(void) {
    // Enable GPIO Clock
    gpioEnable(GPIO_PORT_B);
    // Set the pin to analog function
    pinMode(PIN_INPUT, GPIO_ANALOG);

    // Set up ADC clock (RCC Side)
    RCC->AHB2ENR |= (RCC_AHB2ENR_ADCEN); // Enable ADC clock
    RCC->CCIPR |= _VAL2FLD(RCC_CCIPR_ADCSEL, 0b11); // System clock selected as ADC clock

    // Select and Scale ADC CLock (ADC Side)
        // We assume that ADC CCR CKMODE[1:0] is reset already to 0b00
    ADC1_COMMON->CCR |= _VAL2FLD(ADC_CCR_PRESC, 0b1001); // Set prescaler to 64
    /* ADC1_COMMON->CCR |= _VAL2FLD(ADC_CCR_PRESC, 0b1011); // 256 prescale test to be super long */

    // Calibrate ADC
    ADC1->CR &= ~(ADC_CR_DEEPPWD); // Disable deep power down 
    ADC1->CR |= (ADC_CR_ADVREGEN); // Enable ADC voltage regulator
    ms_delay(20); // Wait for the start up time of ADC voltage regulator
    ADC1->CR &= ~(ADC_CR_ADEN); // Ensure ADC is disabled
    ADC1->CR &= ~(ADC_CR_ADCALDIF); // Select input mode single-ended
    ADC1->CR |= ADC_CR_ADCAL; // Enable calibration
    while(ADC1->CR & ADC_CR_ADCAL); // Wait until calibration is completed
    ms_delay(1);

    // Enable ADC
    ADC1->ISR |= ADC_ISR_ADRDY; // Clear the ADRDY bit by writing ‘1’
    ADC1->CR |= ADC_CR_ADEN; // Enable ADC
    while(!(ADC1->ISR & ADC_ISR_ADRDY)); // Wait until ADC is ready for conversion
    ADC1->ISR |= ADC_ISR_ADRDY;

    // Configure ADC conversion
    ADC1->SMPR2 |= _VAL2FLD(ADC_SMPR2_SMP15, 2); // Set sampling time for channel 15 to 12.5 cycles\
    /*ADC1->SMPR2 |= _VAL2FLD(ADC_SMPR2_SMP15, 0b111); // 640.5 cycles test for slow logging */
    ADC1->CFGR |= (ADC_CFGR_DMAEN); // Enable DMA
    ADC1->CFGR |= (ADC_CFGR_DMACFG); // Select DMA circular mode
    ADC1->IER |= (ADC_IER_EOCIE); // Enable EOC interrupt
    // DMA Enable and circular mode could go here

    ADC1->CFGR |= (ADC_CFGR_CONT); // Select Continous conversions
    ADC1->SQR1 |= _VAL2FLD(ADC_SQR1_SQ1, 15); // Set channel 15 (PB0) as the 1st to be converted
    ADC1->SQR1 |= _VAL2FLD(ADC_SQR1_L, 0); // Set to only scan 1 channel
    ADC1->CFGR |= _VAL2FLD(ADC_CFGR_RES, 0); //0: 12-bit    1: 10-bit    2: 8-bit    3: 6-bit
    ADC1->CFGR |= ADC_CFGR_OVRMOD;  // Made it rewrite new conversions over data register - Jackson Added
    
}

void startADC(void) {
  ADC1->CR |= ADC_CR_ADSTART;  // Moved an initial start to here - Jackson Added
}

uint16_t readADC(void) {
    // Start ADC conversion
    // ADC1->CR |= ADC_CR_ADSTART; Jackson Moved to one time init

    // Acklowledge the Overrun
    ADC1->ISR |= ADC_ISR_OVR;

    // Wait for End of Conversion (EOC)
    while (!(ADC1->ISR & ADC_ISR_EOC));

    // Read the converted value
    uint16_t value = (int16_t) ADC1->DR;

    return value;
}