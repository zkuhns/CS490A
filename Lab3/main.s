;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section ***Tuesday 1-2***update this***
; Instructor: ***Ramesh Yerraballi**update this***
; Lab number: 3
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 2, with six changes:
;1-  the pin to which we connect the switch is moved to PE1, 
;2-  you will have to remove the PUR initialization because pull up is no longer needed. 
;3-  the pin to which we connect the LED is moved to PE0, 
;4-  the switch is changed from negative to positive logic, and 
;5-  you should increase the delay so it flashes about 8 Hz.
;6-  the LED should be on when the switch is not pressed
; Operation
;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section ***Tuesday 1-2***update this***
; Instructor: ***Ramesh Yerraballi**update this***
; Lab number: 3
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 2, with six changes:
;1-  the pin to which we connect the switch is moved to PE1, 
;2-  you will have to remove the PUR initialization because pull up is no longer needed. 
;3-  the pin to which we connect the LED is moved to PE0, 
;4-  the switch is changed from negative to positive logic, and 
;5-  you should increase the delay so it flashes about 8 Hz.
;6-  the LED should be on when the switch is not pressed
; Operation
;   1) Make PE0 an output and make PE1 an input. 
;   2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over

GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608

       IMPORT  TExaS_Init
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
 ; TExaS_Init sets bus clock at 80 MHz
      BL  TExaS_Init ; voltmeter, scope on PD3
; you initialize PE1 PE0
      CPSIE  I    ; TExaS voltmeter, scope runs on interrupts
	  
	  BL    PortE_Init
	  B     loop
	  
PortE_Init
	LDR    R0,    =SYSCTL_RCGCGPIO_R
	MOV    R1,    #0x10
	STR    R1,    [R0]

    LDR    R0,    =GPIO_PORTE_DATA_R
	MOV    R1,    #0x01
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTE_DIR_R
	MOV    R1,    #0x01
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTE_AFSEL_R
	MOV    R1,    #0x00
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTE_DEN_R
	MOV    R1,    #0x03
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTE_AMSEL_R
	MOV    R1,    #0x00
	STR    R1,    [R0]
	
	LDR    R0,    =GPIO_PORTE_PCTL_R
	MOV    R1,    #0x00
	STR    R1,    [R0]
	
    BX    LR
	
; R0 address to data
; R1 data register
; R2 state on/off
; R3 delay decrement value
loop
	LDR    R0,    =GPIO_PORTE_DATA_R      ; Read address of data into R0
	LDR    R1,    [R0]                    ; Copy data contents into R1
	AND    R2,    R1,    #0x02            ; Check if the switch is on
	CMP    R2,    #0x02                   ; Comparison to see if it is on
	BEQ    delay                          ; If it is on go to the delay tag
	BNE    turnoff                        ; If it is off go to the turnoff tag
delay
	LDR    R3,    =0x0014C080             ; Load 272000 into R3
wait
	SUBS   R3,    R3,    #1               ; Subtract one from R3 until 0
	BNE    wait                           ; Repeat decrement
switch
	AND    R2,    R1,    #0x01            ; Check if the light is on
	CMP    R2,    #0x01                   ; Comparison if the light is on
	SUBEQ  R1,    #1                      ; If it is on turn it off
	ADDNE  R1,    #1                      ; If it is off turn it on
	STR    R1,    [R0]                    ; Store contents of R1 back into data register
	B      loop                           ; Go back to loop tag
turnoff
	MOV    R1,    #0x01                   ; Turn the led on
	STR    R1,    [R0]                    ; Store contents of R1 into data register
	B      loop                           ; Go back to loop tag

      ALIGN      ; make sure the end of this section is aligned
      END        ; end of file
       