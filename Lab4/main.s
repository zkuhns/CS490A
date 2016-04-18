;****************** main.s ***************
; Program written by: Zach Kuhns, Luke Hopkins
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016
; Lab number: 4
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 3, with three changes:
;1-  initialize SysTick with RELOAD 0x00FFFFFF 
;2-  add a heartbeat to PF2 that toggles every time through loop 
;3-  add debugging dump of input, output, and time
; Operation
;   1) Make PE0 an output and make PE1 an input. 
;   2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over

SYSCTL_RCGCGPIO_R       EQU 0x400FE608
SYSCTL_RCGC2_GPIOE      EQU 0x00000010   ; port E Clock Gating Control
SYSCTL_RCGC2_GPIOF      EQU 0x00000020   ; port F Clock Gating Control
GPIO_PORTE_DATA_R       EQU 0x400243FC
GPIO_PORTE_DIR_R        EQU 0x40024400
GPIO_PORTE_AFSEL_R      EQU 0x40024420
GPIO_PORTE_PUR_R        EQU 0x40024510
GPIO_PORTE_DEN_R        EQU 0x4002451C
GPIO_PORTF_DATA_R       EQU 0x400253FC
GPIO_PORTF_DIR_R        EQU 0x40025400
GPIO_PORTF_AFSEL_R      EQU 0x40025420
GPIO_PORTF_DEN_R        EQU 0x4002551C
NVIC_ST_CTRL_R          EQU 0xE000E010
NVIC_ST_RELOAD_R        EQU 0xE000E014
NVIC_ST_CURRENT_R       EQU 0xE000E018
	
DELAY62MS				EQU	1240000
           THUMB
           AREA    DATA, ALIGN=4
SIZE       EQU    50
;You MUST use these two buffers and two variables
;You MUST not change their names
;These names MUST be exported
           EXPORT DataBuffer  
           EXPORT TimeBuffer  
           EXPORT DataPt [DATA,SIZE=4]
           EXPORT TimePt [DATA,SIZE=4]
DataBuffer SPACE  SIZE*4
TimeBuffer SPACE  SIZE*4
DataPt     SPACE  4
TimePt     SPACE  4
    
      ALIGN          
      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
      IMPORT  TExaS_Init


Start
	BL	TExaS_Init  ; running at 80 MHz, scope voltmeter on PD3
	; initialize Port E
	BL	PortE_Init
	; initialize Port F
	BL	PortF_Init
	; initialize debugging dump
	BL  Debug_Init
	; initialize SysTick
	BL	SysTick_Init
	CPSIE  I    ; TExaS voltmeter, scope runs on interrupts
	
	B	loop
	
;------------PortE_Init------------
PortE_Init
	LDR	R0, =SYSCTL_RCGCGPIO_R
	LDR	R1,	[R0]
	ORR	R1,	#0x10
	STR	R1,	[R0]
	
	LDR	R0,	=GPIO_PORTE_DIR_R
	MOV	R1,	#0x01
	STR	R1, [R0]
	
	LDR	R0,	=GPIO_PORTE_DEN_R
	MOV	R1,	#0x03
	STR	R1,	[R0]
	
	LDR	R0,	=GPIO_PORTE_DATA_R
	MOV	R1,	#0x01
	STR	R1,	[R0]
	
	BX	LR
	
;------------PortF_Init------------
PortF_Init
	LDR	R0, =SYSCTL_RCGCGPIO_R
	LDR	R1,	[R0]
	ORR	R1,	#0x20
	STR	R1,	[R0]
	
	LDR	R0,	=GPIO_PORTF_DIR_R
	MOV	R1,	#0x04
	STR	R1, [R0]
	
	LDR	R0,	=GPIO_PORTF_DEN_R
	MOV	R1,	#0x04
	STR	R1,	[R0]
	
	BX	LR
	
;------------Debug_Init------------
; Initializes the debugging instrument
; Input: none
; Output: none
; Modifies: none
; Note: push/pop an even number of registers so C compiler is happy
Debug_Init
	LDR	R0,	=DataBuffer	; Load address of Databuffer into R0
	LDR	R1, =DataPt		; Load address of DataBuffer pointer into R0
	STR	R0,	[R1]		; 
	LDR	R1,	=TimeBuffer ; Load address of TimeBuffer into R0
	LDR	R2, =TimePt		; Load address of TimeBuffer pointer into R0
	STR	R1,	[R2]		; 
	
	MOV	R3,	#0
	MOV	R4, #0xFFFFFFFF
Debug_Init_For_200
	STR	R4, [R0, R3]
	STR	R4, [R1, R3]
	ADD	R3, R3, #4
	CMP	R3, #SIZE*4
	BLT	Debug_Init_For_200
	
	BX	LR
	
;------------SysTick_Init----------
SysTick_Init
	; disable SysTick during setup
    LDR R1, =NVIC_ST_CTRL_R	
    MOV R0, #0	; Clear Enable         
    STR R0, [R1]	
	; set reload to maximum reload value
    LDR R1, =NVIC_ST_RELOAD_R	
    LDR R0, =0x00FFFFFF	; Specify RELOAD value
    STR R0, [R1]	; reload at maximum       
	; writing any value to CURRENT clears it
    LDR R1, =NVIC_ST_CURRENT_R	
    MOV R0, #0	
    STR R0, [R1]	; clear counter
	; enable SysTick with core clock
    LDR R1, =NVIC_ST_CTRL_R	
    MOV R0, #0x0005	; Enable but no interrupts (later)
    STR R0, [R1]	; ENABLE and CLK_SRC bits set
    BX  LR	

	BX	LR

;------------Loop---------------------	  
loop
	; Heartbeat
	BL	Toggle_PF2
	; Delay
	BL	Delay62ms
	
	LDR	R0,    =GPIO_PORTE_DATA_R      ; Read address of data into R0
	LDR	R1,    [R0]                    ; Copy data contents into R1
	AND	R2,    R1,    #0x02            ; Check if the switch is on
	CMP	R2,    #0x02                   ; Comparison to see if it is on
	BLEQ	Toggle_PE0
	BLNE	Turnon_PE0
	
	BL	Debug_Capture
	
	B    loop

;------------Delay62ms----------------
Delay62ms
	LDR	R0,	=DELAY62MS
	B	Wait
;------------Wait---------------------
Wait
	SUBS	R0,	R0,	#1	; Subtract one from R0 until 0
	BNE	Wait	; Repeat decrement
	BX	LR
	
;------------Turnon_PE0---------------
Turnon_PE0
	LDR	R0,	=GPIO_PORTE_DATA_R
	MOV	R1,	#0x01
	STR	R1,	[R0]
	
	BX	LR

;------------Toggle_PE0---------------
Toggle_PE0
	LDR	   R0,	  =GPIO_PORTE_DATA_R
	LDR    R1,    [R0]
	AND    R2,    R1,    #0x01            ; Check if the light is on
	CMP    R2,    #0x01                   ; Comparison if the light is on
	SUBEQ  R1,    #1                      ; If it is on turn it off
	ADDNE  R1,    #1                      ; If it is off turn it on
	STR    R1,    [R0]                    ; Store contents of R1 back into data register
	
	BX	LR
	
;------------Toggle_PF2---------------
Toggle_PF2
	LDR	R0, =GPIO_PORTF_DATA_R
	LDR	R1,	[R0]
	AND	R1, R1, #0x04
	CMP	R1,	#0x00
	ADDEQ	R1,	#0x04
	SUBNE	R1,	#0x04
	STR	R1,	[R0]
	
	BX	LR
	
;------------Debug_Capture------------
; Dump Port E and time into buffers
; Input: none
; Output: none
; Modifies: none
; Note: push/pop an even number of registers so C compiler is happy
Debug_Capture
	LDR	R0, =DataPt
	LDR	R1,	[R0]
	
	LDR	R5, =TimeBuffer
	CMP	R1, R5
	BXEQ LR
	
	LDR	R2, =GPIO_PORTE_DATA_R
	LDR	R2,	[R2]
	AND	R3,	R2,	#0x01
	AND	R4,	R2,	#0x02
	LSL	R4,	#3
	AND	R2,	R3
	ORR	R2,	R4
	STR	R2,	[R1]
	ADD	R1,	R1, #4
	STR	R1, [R0]
	
	LDR	R0,	=TimePt
	LDR	R1, [R0]
	LDR	R2,	=NVIC_ST_CURRENT_R
	LDR	R2,	[R2]
	STR	R2,	[R1]
	ADD	R1,	R1, #4
	STR	R1, [R0]
	
	BX LR


    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
        