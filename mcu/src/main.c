/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start

*/

#include <stdio.h>
#include "STM32L432KC.h"

#include "../lib/arm_math.h"

/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/
int main(void) {
    configureFlash();
    configureClock();

    configureADC(); // Configure ADC
    
    // Initialize timer 2 for delay
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    initTIM(TIM2);

    while (1) {
        // Read ADC value
        uint8_t adcValue = readADC();

        // Print ADC value
        printf("ADC Value: %d\n", adcValue);

        // Add delay
        delay_millis(TIM2, 500);
    }

    return 0;
}

/*************************** End of file ****************************/
