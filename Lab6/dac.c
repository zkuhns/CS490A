/*
 * Authors: Zach Kuhns Luke Hopkins
 * Lab 6 Analog to Digital Conversion
 */

#include "stdint.h"
#include "tm4c123gh6pm.h"

// Initialize the DAC outputs
void DAC_Init() {
	GPIO_PORTB_DEN_R = 0x3F;
	GPIO_PORTB_DIR_R = 0x3F;
	GPIO_PORTB_DR8R_R = 0x3F;
	GPIO_PORTB_AFSEL_R = 0x00;
	GPIO_PORTB_AMSEL_R = 0x00;
}

// Send the output to the DAC ports
void DAC_Out(uint32_t output) {
	GPIO_PORTB_DATA_R = output;
}
