/*
 * Authors: Zach Kuhns Luke Hopkins
 * Lab 6 Analog to Digital Conversion
 */

#include "stdint.h"
#include "tm4c123gh6pm.h"
#include "SysTickInts.h"
#include "dac.h"

uint32_t Input = 0;

// Change the SysTick interrupt frequency
void Sound_Play(uint32_t period) {
	NVIC_ST_RELOAD_R = period;
}

// 6 bits
uint32_t wave[64] = {
16,17,19,20,21,23,24,25,
26,27,28,29,30,30,31,31,
31,31,31,30,30,29,28,27,
26,25,24,23,21,20,19,17,
16,14,12,11,10,8,7,6,
5,4,3,2,1,1,0,0,
0,0,0,1,1,2,3,4,
5,6,7,8,10,11,12,14,};

// 5 bits
/*uint32_t wave[32] = {8,9,10,11,12,13,14,15,
										 15,15,14,13,12,11,10,9,
										 8,7,6,5,4,3,2,1,
										 1,1,2,3,4,5,6,7};*/
// 4 bits
/*uint32_t wave[16] = {4,6,7,8,8,8,7,6,
                     4,2,1,0,0,0,1,2,};*/

// Interrupt service routine
// Executed every 12.5ns*(period)
// Update the DAC during SysTick interrupts
void SysTick_Handler(void){
  Input = (Input+1)&0x3F;
	DAC_Out(wave[Input]);
}
