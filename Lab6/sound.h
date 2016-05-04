/*
 * Authors: Zach Kuhns Luke Hopkins
 * Lab 6 Analog to Digital Conversion
 */

#include "stdint.h"
#include "tm4c123gh6pm.h"

void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
long StartCritical (void);    // previous I bit, disable interrupts
void EndCritical(long sr);    // restore I bit to previous value
void WaitForInterrupt(void);  // low power mode

// Change the SysTick interrupt frequency
void Sound_Play(uint32_t period);
// Interrupt service routine
// Executed every 12.5ns*(period)
// Update the DAC during SysTick interrupts
void SysTick_Handler(void);
