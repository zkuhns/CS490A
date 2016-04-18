;****************** main.s ***************
; Program written by: Zach Kuhns, Luke Hopkins
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Lab number: 1
; Brief description of the program
; The overall objective of this system is a digital lock
; Hardware connections
;  PE3 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE4 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE5 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE2 is LED output (0 means door is locked, 1 means door is unlocked) 
; The specific operation of this system is to 
;   unlock if all three switches are pressed

SYSCTL_RCGCGPIO_R       EQU   0x400FE608    ; PORT E clock
GPIO_PORTE_DATA_BITS_R  EQU   0x40024000   
GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_IS_R         EQU   0x40024404
GPIO_PORTE_IBE_R        EQU   0x40024408
GPIO_PORTE_IEV_R        EQU   0x4002440C
GPIO_PORTE_IM_R         EQU   0x40024410
GPIO_PORTE_RIS_R        EQU   0x40024414
GPIO_PORTE_MIS_R        EQU   0x40024418
GPIO_PORTE_ICR_R        EQU   0x4002441C
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DR2R_R       EQU   0x40024500
GPIO_PORTE_DR4R_R       EQU   0x40024504
GPIO_PORTE_DR8R_R       EQU   0x40024508
GPIO_PORTE_ODR_R        EQU   0x4002450C
GPIO_PORTE_PUR_R        EQU   0x40024510
GPIO_PORTE_PDR_R        EQU   0x40024514
GPIO_PORTE_SLR_R        EQU   0x40024518
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_LOCK_R       EQU   0x40024520
GPIO_PORTE_CR_R         EQU   0x40024524
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
GPIO_PORTE_ADCCTL_R     EQU   0x40024530
GPIO_PORTE_DMACTL_R     EQU   0x40024534
GPIO_PORTE_SI_R         EQU   0x40024538

      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
Start
	BL    PortE_Init
	B     loop
	
PortE_Init
	LDR    R1,    =SYSCTL_RCGCGPIO_R    ; Port E clock
	LDR    R0,    [R1]
	ORR    R0,    R0,    #0x10
	STR    R0,    [R1]
	NOP
	NOP
	NOP
	
	LDR    R1,    =GPIO_PORTE_LOCK_R    ; Port E unlock
	LDR    R0,    =0x4C4F434B
	STR    R0,    [R1]
	
	; This breaks the program for some reason
	;LDR    R1,    =GPIO_PORTE_CR_R    ; Allow changes to PE2-5
	;MOV    R0,    #0x3C
	;STR    R0,    [R1]
	
	LDR    R1,    =GPIO_PORTE_AMSEL_R    ; Disable GPIO
	MOV    R0,    #0x00
	STR    R0,    [R1]
	
	LDR    R1,    =GPIO_PORTE_PCTL_R    ; GPIO configure
	MOV    R0,    #0x00
	STR    R0,    [R1]
	
	LDR    R1,    =GPIO_PORTE_AFSEL_R    ; Disable alternate function
	MOV    R0,    #0x00
	STR    R0,    [R1]
	
	LDR    R1,    =GPIO_PORTE_DEN_R    ; Enable pins PE2-5
	MOV    R0,    #0x3C
	STR    R0,    [R1]
	
	LDR    R1,    =GPIO_PORTE_DIR_R    ; Output register
	MOV    R0,    #0x04
	STR    R0,    [R1]
	
	LDR    R1,    =GPIO_PORTE_PUR_R    ; Pullup register
	MOV    R0,    #0x38
	STR    R0,    [R1]
	BX     LR
	
PortE_Input
	LDR    R1,    =GPIO_PORTE_DATA_R    ; Load Data address into R1
	LDR    R0,    [R1]    ; Load Data contents into R0
	BX     LR
PortE_Output
	LDR    R1,    =GPIO_PORTE_DATA_R    ; Load Data address into R1
	ORR    R0,    #0x04    ; Set the LED bit to 1 without changing switch bits
	CMP    R0,    #0x04    ; Are all inputs on?
	SUBNE  R0,    R0,    #0x04    ; Turn the LED off
	STR    R0,    [R1]    ; Update the data register
	BX     LR

loop
	BL    PortE_Input
	BL    PortE_Output
	B     loop


      ALIGN        ; make sure the end of this section is aligned
      END          ; end of file