#include "piano.h"
#include "tm4c123gh6pm.h"

void Piano_Init(void) {
	GPIO_PORTE_DEN_R |= 0x0F;
	GPIO_PORTE_DIR_R &= 0x0F;
  GPIO_PORTE_AFSEL_R = 0;
  GPIO_PORTE_AMSEL_R = 0;
}

int Piano_In(void) {
	return GPIO_PORTE_DATA_R;
}
