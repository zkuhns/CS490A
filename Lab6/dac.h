/*
 * Authors: Zach Kuhns Luke Hopkins
 * Lab 6 Analog to Digital Conversion
 */

#include "stdint.h"
#include "tm4c123gh6pm.h"

// Initialize the DAC outputs
void DAC_Init(void);
// Send the output to the DAC ports
void DAC_Out(uint32_t output);
