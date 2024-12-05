/*********************************************************************

STM32L432KC_DMA.c

Jackson Philion and Zhian Zhou, December 5 2024
jphilion@g.hmc.edu and zzhou@g.hmc.edu

This file contains the source code for the supporting DMA functions.
For more, see:

https://jacksonphilion.github.io/final-project-portfolio/ 

*********************************************************************/

#include "STM32L432KC_DMA.h"
#include "customZZJP.h" // Includes definition of externs and defines BUFFER_SIZE


void configureDMA(void) {

    ///////////////////  CONFIGURE CLOCK TO DMA  //////////////
    // Enable DMA1 clock
    RCC->AHB1ENR |= (RCC_AHB1ENR_DMA1EN); 
    
    // Make sure AHB Prescaler is set to divide by 1, field cleared
    RCC->CFGR &= ~(RCC_CFGR_HPRE);

    ///////////////////  CONFIGURE DMA1  ///////////////////////
    
    /*  For DMA1, ADC1 is a top priority. It is on channel 1.
        C1S should be 0000 for ADC1 on Channel 1. Seems to be
        set in DMA1_CSELR register. */
    DMA1_CSELR->CSELR &= ~(DMA_CSELR_C1S);

    /*  DMA_CCRx PSIZE and MSIZE set the transfer sizes 
        PINC and MINC control whether address is automatically incremented
        DMA_CPARx or DMA_CMARx registers hold the first transfer address
        */

    // Set the peripheral register address in the DMA_CPARx Register
            // ADC_DR is 0x40 offset from 0x5004 0000. Binary representation below:
    // DMA1_Channel1->CPAR |= 0b01010000000001000000000001000000;
    DMA1_Channel1->CPAR |= _VAL2FLD(DMA_CPAR_PA, (uint32_t)&ADC1->DR);

    // Set the memory address in the DMA_CMARx register. 
            // SRAM1 has (data sheet) 48 Kbyte mapped at address 0x2000 0000 to 0x2000 BFFF, I think.
            // Binary representation of 0x2000 0000 below:
    // DMA1_Channel1->CMAR |= 0b00100000000000000000000000000000;
    DMA1_Channel1->CMAR = (uint32_t)buffer1;

    // Configure the total number of data to transfer in DMA_CNDTRx register
    // May not be necessary if we are using circular mode
    DMA1_Channel1->CNDTR |= _VAL2FLD(DMA_CNDTR_NDT, BUFFER_SIZE);

    // In DMA_CCRx register, configure...
    DMA1_Channel1->CCR &= ~(0xFFFFFFFF); // Reset DMA channel configuration
    // The channel priority
    DMA1_Channel1->CCR |= _VAL2FLD(DMA_CCR_PL, 3); // Channel priority very high

    // The data transfer direction (DIR=0 implies peripheral-to-memory)
    DMA1_Channel1->CCR &= ~(DMA_CCR_DIR);

    // The circular mode
    // DMA1_Channel1->CCR |= (DMA_CCR_CIRC);

    // The Peripheral and Memory Incremented mode
    DMA1_Channel1->CCR &= ~(DMA_CCR_PINC); // Disable peripheral increment mode
    DMA1_Channel1->CCR |= (DMA_CCR_MINC); // Enable memory increment mode

    // The Peripheral and Memory data size
    DMA1_Channel1->CCR |= _VAL2FLD(DMA_CCR_MINC, 1); // Memory data size 16 bits

    // The interrupt enable for full transfer
     DMA1_Channel1->CCR |= DMA_CCR_TCIE;

    // FINALLY, activate the channel by setting EN bit in DMA_CCRx
    DMA1_Channel1->CCR |= (DMA_CCR_EN);

    // Enable DMA1 Channel 1 interrupt in NVIC
    NVIC_EnableIRQ(DMA1_Channel1_IRQn);
    NVIC_SetPriority(DMA1_Channel1_IRQn, 0);

}






void configureDMA_prototype(void) {

    ///////////////////  CONFIGURE CLOCK TO DMA  //////////////
    // Enable DMA1 clock
    RCC->AHB1ENR |= (RCC_AHB1ENR_DMA1EN); 
    
    // Make sure AHB Prescaler is set to divide by 1, field cleared
    RCC->CFGR &= ~(RCC_CFGR_HPRE);

    ///////////////////  Configure Addresses and DMA_CNDTR  ///////////////////////
    
    // Set DMA Channel 1 Input to ADC1
    DMA1_CSELR->CSELR &= ~(DMA_CSELR_C1S);

    // Set the peripheral register address. Should point to the ADC1 Data Register
    DMA1_Channel1->CPAR |= _VAL2FLD(DMA_CPAR_PA, (uint32_t)&ADC1->DR);

    // Set the memory address in DMA_CMARx. We always initialize with buffer1
    DMA1_Channel1->CMAR = (uint32_t)buffer1;

    // Configure the total number of data to transfer in DMA_CNDTRx register
    DMA1_Channel1->CNDTR |= _VAL2FLD(DMA_CNDTR_NDT, BUFFER_SIZE);

    ///////////////  Channel Configuration Register (CCR)  ///////////////

    // Reset the whole channel configuration
    DMA1_Channel1->CCR &= ~(0xFFFFFFFF); // Reset DMA channel configuration
    // The channel priority
    DMA1_Channel1->CCR |= _VAL2FLD(DMA_CCR_PL, 3); // Channel priority very high
    // The data transfer direction
    DMA1_Channel1->CCR &= ~(DMA_CCR_DIR); //DIR=0 implies peripheral-to-memory
    // Disable circular mode
    DMA1_Channel1->CCR &= ~(DMA_CCR_CIRC); //CIR=0 means it won't loop and autostart

    // The Peripheral and Memory Incremented mode
    DMA1_Channel1->CCR &= ~(DMA_CCR_PINC); // Disable peripheral increment mode, always read ADC1_DR
    DMA1_Channel1->CCR |= (DMA_CCR_MINC); // Enable memory increment mode

    // The Peripheral and Memory data size
    DMA1_Channel1->CCR |= _VAL2FLD(DMA_CCR_MSIZE, 0b01); // Memory data size 16 bits
    DMA1_Channel1->CCR |= _VAL2FLD(DMA_CCR_PSIZE, 0b01); // Peripheral data size 16 bits

    // The interrupt enable for full transfer
     DMA1_Channel1->CCR |= DMA_CCR_TCIE;

    // FINALLY, activate the channel by setting EN bit in DMA_CCRx
    DMA1_Channel1->CCR |= (DMA_CCR_EN);

}

void DMA1_Channel1_IRQHandler(void) {
    // Check for Transfer Complete
    if (DMA1->ISR & DMA_ISR_TCIF1) {
        DMA1->IFCR = DMA_IFCR_CGIF1; // Clear Global interrupt flag (clears all subflags)

        // Disable DMA1 to make changes
        DMA1_Channel1->CCR &= ~(DMA_CCR_EN);

        // Ensure FFT processing is complete before switching buffers
        if (!FFTReady) {
            return; // Skip switching if FFT buffer hasn't been processed
        }

        // Switch buffers
        if (DMAptr == buffer1) {
            DMAptr = buffer2; // DMA will now write to buffer2
            FFTptr = buffer1; // FFT processing will use buffer1
        } else {
            DMAptr = buffer1; // DMA will now write to buffer1
            FFTptr = buffer2; // FFT processing will use buffer2
        }

        // Mark FFT buffer as not ready
        FFTReady = 0;  // TODO NEED TO ENABLE THIS FOR REAL SYSTEM TO WORK PLEASE DON'T FORGET

        // Update DMA memory address
        DMA1_Channel1->CMAR = (uint32_t)DMAptr;

        // Acknowledge the OVR bit in ADC
        ADC1->ISR |= ADC_ISR_OVR;

        // Refill DMA CNDTR
        DMA1_Channel1->CNDTR |= BUFFER_SIZE;

        // Re-enable DMA channel
        DMA1_Channel1->CCR |= DMA_CCR_EN;
    }
}
