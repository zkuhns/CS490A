;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section ***Tuesday 1-2***update this***
; Instructor: ***Ramesh Yerraballi**update this***
; Lab number: 2
; Brief description of the program
; The overall objective of this system an interactive alarm
; Hardware connections
;  PF4 is switch input  (1 means SW1 is not pressed, 0 means SW1 is pressed)
;  PF3 is LED output (1 activates green LED) 
; The specific operation of this system 
;    1) Make PF3 an output and make PF4 an input (enable PUR for PF4). 
;    2) The system starts with the LED OFF (make PF3 =0). 
;    3) Delay for about 100 ms
;    4) If the switch is pressed (PF4 is 0), then toggle the LED once, else turn the LED OFF. 
;    5) Repeat steps 3 and 4 over and over

GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_AFSEL_R      EQU   0x40025420
GPIO_PORTF_PUR_R        EQU   0x40025510
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_AMSEL_R      EQU   0x40025528
GPIO_PORTF_PCTL_R       EQU   0x4002552C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
	BL    PortF_Init
	B     loop

; PortF initializations
PortF_Init
	LDR    R0,    =SYSCTL_RCGCGPIO_R
	MOV    R1,    #0x20
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTF_DATA_R
	MOV    R1,    #0x00
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTF_DIR_R
	MOV    R1,    #0x08
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTF_AFSEL_R
	MOV    R1,    #0x00
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTF_PUR_R
	MOV    R1,    #0x10
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTF_DEN_R
	MOV    R1,    #0x18
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTF_AMSEL_R
	MOV    R1,    #0x00
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTF_PCTL_R
	MOV    R1,    #0x00
	STR    R1,    [R0]
	
	BX     LR

; R0 address to data
; R1 data register
; R2 state on/off
; R3 delay decrement value
loop
	LDR    R0,    =GPIO_PORTF_DATA_R      ; Read address of data into R0
	LDR    R1,    [R0]                    ; Copy data contents into R1
	AND    R2,    R1,    #0x10            ; Check if the switch is on
	CMP    R2,    #0x00                   ; Comparison to see if it is on
	BEQ    delay                          ; If it is on go to the delay tag
	BNE    turnoff                        ; If it is off go to the turnoff tag
delay
	LDR    R3,    =0x00061A80             ; Load 400000 into R3
wait
	SUBS   R3,    R3,    #1               ; Subtract one from R3 until 0
	BNE    wait                           ; Repeat decrement
switch
	AND    R2,    R1,    #0x08            ; Check if the light is on
	CMP    R2,    #0x08                   ; Comparison if the light is on
	SUBEQ  R1,    #8                      ; If it is on turn it off
	ADDNE  R1,    #8                      ; If it is off turn it on
	STR    R1,    [R0]                    ; Store contents of R1 back into data register
	B      loop                           ; Go back to loop tag
turnoff
	MOV    R1,    #0x10                   ; Turn the led off
	STR    R1,    [R0]                    ; Store contents of R1 into data register
	B      loop                           ; Go back to loop tag
	
	ALIGN      ; make sure the end of this section is aligned
	END        ; end of file
       