// PeriodicSysTickInts.c
// Runs on LM4F120
// Use the SysTick timer to request interrupts at a particular period.
// Daniel Valvano
// October 11, 2012

/* This example accompanies the book
   "Embedded Systems: Real Time Interfacing to Arm Cortex M Microcontrollers",
   ISBN: 978-1463590154, Jonathan Valvano, copyright (c) 2014

   Program 5.12, section 5.7

 Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu
    You may use, edit, run or distribute this file
    as long as the above copyright notice remains
 THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
 OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
 VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
 OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 For more information about my classes, my research, and my books, see
 http://users.ece.utexas.edu/~valvano/
 */

// oscilloscope or LED connected to PF2 for period measurement
#include <stdint.h>
#include "tm4c123gh6pm.h"
#include "PLL.h"
#include "SysTickInts.h"
#include "dac.h"
#include "sound.h"
#include "piano.h"

#define PF2     (*((volatile uint32_t *)0x40025010))

void PortF_Init() {
	GPIO_PORTF_DEN_R |= 0x04;   // enable digital I/O on PF2
	GPIO_PORTF_DIR_R |= 0x04;   // make PF2 output (PF2 built-in LED)
  GPIO_PORTF_AFSEL_R &= ~0x04;// disable alt funct on PF2
                              // configure PF2 as GPIO
  GPIO_PORTF_PCTL_R = (GPIO_PORTF_PCTL_R&0xFFFFF0FF)+0x00000000;
  GPIO_PORTF_AMSEL_R = 0;     // disable analog functionality on PF
}

int main(void){
  PLL_Init();                   // bus clock at 80 MHz
  SYSCTL_RCGCGPIO_R |= 0x32;  // activate port B E F
	Piano_Init();
	DAC_Init();
	SysTick_Init(80000);
	PortF_Init();
	
	unsigned int Data;
	while (1) {
		Data = Piano_In();
		if (Data == 0) {
			DisableInterrupts();
		}
		if (Data > 7) {
			EnableInterrupts();
			Sound_Init(6378);
		}
		if (Data > 3) {
			EnableInterrupts();
			Sound_Init(7587);
		}
		if (Data > 1) {
			EnableInterrupts();
			Sound_Init(8518);
		}
		if (Data > 0) {
			EnableInterrupts();
			Sound_Init(9524);
		}
	}
}
