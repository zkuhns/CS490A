#include "dac.h"
#include "tm4c123gh6pm.h"

void DAC_Init(void) {
	GPIO_PORTB_DEN_R |= 0x03F;
	GPIO_PORTB_DIR_R |= 0x03F;
	GPIO_PORTB_DR8R_R |= 0x3F;
  GPIO_PORTB_AFSEL_R = 0;
  GPIO_PORTB_AMSEL_R = 0;
}

void DAC_Out(int output) {
	GPIO_PORTB_DATA_R = output;
}
