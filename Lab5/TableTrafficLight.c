// ******TableTrafficLight.c***************
// Program written by: Zach Kuhns, Luke Hopkins
// Lab 5

// TableTrafficLight.c
// Runs on LM4F120 or TM4C123
// Index implementation of a Moore finite state machine to operate
// a traffic light.
// Daniel Valvano, Jonathan Valvano
// July 20, 2013

/* This example accompanies the book
   "Embedded Systems: Introduction to ARM Cortex M Microcontrollers",
   ISBN: 978-1469998749, Jonathan Valvano, copyright (c) 2013
   Volume 1 Program 6.8, Example 6.4
   "Embedded Systems: Real Time Interfacing to ARM Cortex M Microcontrollers",
   ISBN: 978-1463590154, Jonathan Valvano, copyright (c) 2013
   Volume 2 Program 3.1, Example 3.1

 Copyright 2013 by Jonathan W. Valvano, valvano@mail.utexas.edu
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

// east facing red light connected to PB5
// east facing yellow light connected to PB4
// east facing green light connected to PB3
// north facing red light connected to PB2
// north facing yellow light connected to PB1
// north facing green light connected to PB0
// north facing car detector connected to PE1 (1=car present)
// east facing car detector connected to PE0 (1=car present)

#include "PLL.h"
#include "SysTick.h"
#include "tm4c123gh6pm.h"

#define GPIO_PORTB_OUT          (*((volatile unsigned long *)0x400050FC)) // bits 5-0
#define GPIO_PORTE_IN           (*((volatile unsigned long *)0x4002401C)) // bits 2-0
#define GPIO_PORTF_OUT          (*((volatile unsigned long *)0x40025028)) // bits 3+1
#define SYSCTL_RCGC2_GPIOB      0x00000002  // port B Clock Gating Control
#define SYSCTL_RCGC2_GPIOE      0x00000010  // port E Clock Gating Control
#define SYSCTL_RCGC2_GPIOF      0x00000020  // port F Clock Gating Control

// Linked data structure
struct State {
  unsigned long DriveLight;
	unsigned long WalkLight;
  unsigned long Time;  
  unsigned long Next[8];}; 
typedef const struct State STyp;

#define goN     0
#define waitNE  1
#define waitNW  2
#define goE     3
#define waitEN  4
#define waitEW  5
#define goN0    6
#define goN1    7
#define goN2    8
#define goN3    9
#define goE0    10
#define goE1    11
#define goE2    12
#define goE3    13
#define walk    14
#define on0     15
#define off0    16
#define on1     17
#define off1    18
#define on2     19
#define off2    20
#define on3     21
#define off3    22
#define on4     23
#define off4    24

STyp FSM[25]={
 /* goN */
 {0x21,0x02,3000,{goN0,goN0,goN0,goN0,goN0,goN0,goN0,goN0}},
 /* waitNE */
 {0x22,0x02,500,{goE,goE,goE,goE,goE,goE,goE,goE}},
 /* waitNW */
 {0x22,0x02,500,{walk,walk,walk,walk,walk,walk,walk,walk}},
 /* goE */
 {0x0C,0x02,3000,{goE0,goE0,goE0,goE0,goE0,goE0,goE0,goE0}},
 /* waitEN */
 {0x14,0x02,500,{goN,goN,goN,goN,goN,goN,goN,goN}},
 /* waitEW */
 {0x14,0x02,500,{walk,walk,walk,walk,walk,walk,walk,walk}},
 /* goN0 */
 {0x21,0x02,500,{goN0,waitNE,goN0,waitNE,goN1,goN1,goN1,goN1}},
 /* goN1 */
 {0x21,0x02,500,{goN0,waitNE,goN0,waitNE,goN2,goN2,goN2,goN2}},
 /* goN2 */
 {0x21,0x02,500,{goN0,waitNE,goN0,waitNE,goN3,goN3,goN3,goN3}},
 /* goN3 */
 {0x21,0x02,500,{goN0,waitNE,goN0,waitNE,waitNW,waitNW,waitNW,waitNW}},
 /* goE0 */
 {0x0C,0x02,500,{goE0,goE0,waitEN,waitEN,goE1,goE1,goE1,goE1}},
 /* goE1 */
 {0x0C,0x02,500,{goE0,goE0,waitEN,waitEN,goE2,goE2,goE2,goE2}},
 /* goE2 */
 {0x0C,0x02,500,{goE0,goE0,waitEN,waitEN,goE3,goE3,goE3,goE3}},
 /* goE3 */
 {0x0C,0x02,500,{goE0,goE0,waitEN,waitEN,waitEW,waitEW,waitEW,waitEW}},
 /* walk */
 {0x24,0x08,1500,{on0,on0,on0,on0,on0,on0,on0,on0}},
 /* on0 */
 {0x24,0x02,150,{off0,off0,off0,off0,off0,off0,off0,off0}},
 /* off0 */
 {0x24,0x00,150,{on1,on1,on1,on1,on1,on1,on1,on1}},
 /* on1 */
 {0x24,0x02,150,{off1,off1,off1,off1,off1,off1,off1,off1}},
 /* off1 */
 {0x24,0x00,150,{on2,on2,on2,on2,on2,on2,on2,on2}},
 /* on2 */
 {0x24,0x02,150,{off2,off2,off2,off2,off2,off2,off2,off2}},
 /* off2 */
 {0x24,0x00,150,{on3,on3,on3,on3,on3,on3,on3,on3}},
 /* on3 */
 {0x24,0x02,150,{off3,off3,off3,off3,off3,off3,off3,off3}},
 /* off3 */
 {0x24,0x00,150,{on4,on4,on4,on4,on4,on4,on4,on4}},
 /* on4 */
 {0x24,0x02,150,{off4,off4,off4,off4,off4,off4,off4,off4}},
 /* off4 */
 {0x24,0x00,150,{goN,goE,goN,goE,goN,goE,goN,goE}},
};

unsigned long S;  // index to the current state 
unsigned long Input; 

void PortB_Init() {
  GPIO_PORTB_AMSEL_R &= ~0x3F; // 3) disable analog function on PB5-0
  GPIO_PORTB_PCTL_R &= ~0x00FFFFFF; // 4) enable regular GPIO
  GPIO_PORTB_DIR_R |= 0x3F;    // 5) outputs on PB5-0
  GPIO_PORTB_AFSEL_R &= ~0x3F; // 6) regular function on PB5-0
  GPIO_PORTB_DEN_R |= 0x3F;    // 7) enable digital on PB5-0	
}

void PortE_Init() {
  GPIO_PORTE_AMSEL_R &= ~0x07; // 3) disable analog function on PE2-0
  GPIO_PORTE_PCTL_R &= ~0x00000FFF; // 4) enable regular GPIO
  GPIO_PORTE_DIR_R &= ~0x07;   // 5) inputs on PE2-0
  GPIO_PORTE_AFSEL_R &= ~0x07; // 6) regular function on PE2-0
  GPIO_PORTE_DEN_R |= 0x07;    // 7) enable digital on PE2-0	
}

void PortF_Init() {
  GPIO_PORTF_AMSEL_R &= ~0x0A; // 3) disable analog function on PF3 + PF1
  GPIO_PORTF_PCTL_R &= ~0x0000F0F0; // 4) enable regular GPIO
  GPIO_PORTF_DIR_R |= 0x0A;   // 5) inputs on PF3 + PF1
  GPIO_PORTF_AFSEL_R &= ~0x0A; // 6) regular function on PF3 + PF1
  GPIO_PORTF_DEN_R |= 0x0A;    // 7) enable digital on PF3 + PF1		
}

int main(void){ volatile unsigned long delay;
  PLL_Init();       // 80 MHz, Program 10.1
  SysTick_Init();   // Program 10.2
  SYSCTL_RCGC2_R |= 0x32;      // 1) B E
  delay = SYSCTL_RCGC2_R;      // 2) no need to unlock
	PortB_Init();
	PortE_Init();
	PortF_Init();
	
  S = 4;  
  while(1){
    GPIO_PORTB_OUT = FSM[S].DriveLight; // set drive lights
		GPIO_PORTF_OUT = FSM[S].WalkLight; // set walk lights
    //SysTick_Wait10ms(10);
    Input = GPIO_PORTE_IN;     // read sensors
    S = FSM[S].Next[Input];  
  }
}

