/*
 * Authors: Zach Kuhns Luke Hopkins
 * Lab 6 Analog to Digital Conversion
 */

#include "stdint.h"
#include "tm4c123gh6pm.h"

// Initialize the piano keys
void Piano_Init() {
	GPIO_PORTE_DEN_R = 0x0F;
	GPIO_PORTE_DIR_R = 0x00;
	GPIO_PORTE_AFSEL_R = 0x00;
	GPIO_PORTE_AMSEL_R = 0x00;
}

// Get the input from the piano keys
uint32_t Piano_In() {
	switch(GPIO_PORTE_DATA_R) {
		case 0: return 0;
		case 1: return 1;
		case 2: return 2;
		case 3: return 2;
		case 4: return 4;
		case 5: return 4;
		case 6: return 4;
		case 7: return 4;
		case 8: return 8;
		case 9: return 8;
		case 10: return 8;
		case 11: return 8;
		case 12: return 8;
		case 13: return 8;
		case 14: return 8;
		case 15: return 8;
	}
	return 0;
}
