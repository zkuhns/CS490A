/*
 * Authors: Zach Kuhns Luke Hopkins
 * Lab 6 Analog to Digital Conversion
 */

#include "stdint.h"
#include "tm4c123gh6pm.h"

// Initialize the piano keys
void Piano_Init(void);
// Get the input from the piano keys
uint32_t Piano_In(void);
