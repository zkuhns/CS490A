#include "tm4c123gh6pm.h"
#include "SysTickInts.h"
#include "dac.h"

unsigned int Index;

void Sound_Init(uint32_t period) {
	Index = 0;
	NVIC_ST_CTRL_R = 0;         // disable SysTick during setup
  NVIC_ST_RELOAD_R = period-1;// reload value
  NVIC_ST_CURRENT_R = 0;      // any write to current clears it
  NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R&0x00FFFFFF)|0x20000000; // priority 1
                              // enable SysTick with core clock and interrupts
  NVIC_ST_CTRL_R = 0x0F;
}

int wave[16] = {4,5,6,7,7,7,6,5,4,3,2,1,1,1,2,3};

void Sound_Play(int note) {
	Index = (Index+1)&0x0F;
	DAC_Out(wave[Index]);
}

void SysTick_Handler(void) {
	GPIO_PORTF_DATA_R |= 0x08;
	Index = (Index+1)&0x0F;
	DAC_Out(wave[Index]);
}
