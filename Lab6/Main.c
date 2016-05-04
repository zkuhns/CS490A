/*
 * Authors: Zach Kuhns Luke Hopkins
 * Lab 6 Analog to Digital Conversion
 */

#include <stdint.h>
#include "tm4c123gh6pm.h"
#include "SysTickInts.h"
#include "PLL.h"
#include "dac.h"
#include "piano.h"
#include "sound.h"


#define PF2     (*((volatile uint32_t *)0x40025010))

// Initialize port F
void PortF_Init() {
  GPIO_PORTF_DIR_R |= 0x04;   // make PF2 output (PF2 built-in LED)
  GPIO_PORTF_AFSEL_R &= ~0x04;// disable alt funct on PF2
  GPIO_PORTF_DEN_R |= 0x04;   // enable digital I/O on PF2
                              // configure PF2 as GPIO
  GPIO_PORTF_PCTL_R = (GPIO_PORTF_PCTL_R&0xFFFFF0FF)+0x00000000;
  GPIO_PORTF_AMSEL_R = 0;     // disable analog functionality on PF	
}

int main() {
	PLL_Init();                 // bus clock at 80 MHz
  SYSCTL_RCGCGPIO_R |= 0x32;  // activate port F E B
	PortF_Init();               // Initialize heartbeat
	SysTick_Init(80000);        // initialize SysTick timer
	Piano_Init();
	DAC_Init();
	EnableInterrupts();
	uint32_t Data = 0;
  while(1){ // interrupts every 1ms, 500 Hz flash
		Data = Piano_In();
		switch (Data) {
			case 0:
				DisableInterrupts();
				break;
			case 1:
				EnableInterrupts();
				Sound_Play(2390);
				break;
			case 2:
				EnableInterrupts();
				Sound_Play(2129);
				break;
			case 4:
				EnableInterrupts();
				Sound_Play(1897);
				break;
			case 8:
				EnableInterrupts();
				Sound_Play(1594);
				break;
		}
  }
}
