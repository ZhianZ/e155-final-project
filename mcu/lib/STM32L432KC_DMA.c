/***************************************************

// STM32L432KC_DMA.c

Zhian Zhou and Jackson Philion, November 10 2024

This file contains the DMA functions used for the E155
final project "Fix That Note!"

More can be found out about the project at the report below:


***************************************************/

#include "STM32L432KC_DMA.h"
#include "STM32L432KC_RCC.h"

void configureDMA() {

    ///////////////////  CONFIGURE CLOCK TO DMA  //////////////
    
    // Make sure AHB Prescaler is set to divide by 1, field cleared
    RCC->CFGR |= _VAL2FLD(RCC_CFGR_HPRE, 0b0000);

    ///////////////////  CONFIGURE DMA1  ///////////////////////
    
    /*  For DMA1, ADC1 is a top priority. It is on channel 1.
        C1S should be 0000 for ADC1 on Channel 1. Seems to be
        set in DMA1_CSELR register. */

    /*  DMA_CCRx PSIZE and MSIZE set the transfer sizes 
        PINC and MINC control whether address is automatically incremented
        DMA_CPARx or DMA_CMARx registers hold the first transfer address
        */

    // Set the peripheral register address in the DMA_CPARx Register
            // ADC_DR is 0x40 offset from 0x5004 0000. Binary representation below:
    DMA1_Channel1->CPAR |= 0b01010000000001000000000001000000;

    // Set the memory address in the DMA_CMARx register. 
            // SRAM1 has (data sheet) 48 Kbyte mapped at address 0x2000 0000 to 0x2000 BFFF, I think.
            // Binary representation of 0x2000 0000 below:
    DMA1_Channel1->CMAR |= 0b00100000000000000000000000000000;

    // Configure the total number of data to transfer in DMA_CNDTRx register
    // May not be necessary if we are using circular mode


    // In DMA_CCRx register, configure...
    // The channel priority


    // The data transfer direction (DIR=0 implies peripheral-to-memory)


    // The circular mode


    // The Peripheral and Memory Incremented mode


    // The Peripheral and Memory data size


    // The interrupt enable for half, full, transfer errors


    // FINALLY, activate the channel by setting EN bit in DMA_CCRx




}