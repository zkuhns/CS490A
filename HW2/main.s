; main.s
; Runs on any Cortex M processor
; A very simple first project implementing a random number generator
; Daniel Valvano
; May 4, 2012

;  This example accompanies the book
;  "Embedded Systems: Introduction to Arm Cortex M Microcontrollers",
;  ISBN: 978-1469998749, Jonathan Valvano, copyright (c) 2014
;  Section 3.3.10, Program 3.12
;
;Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu
;   You may use, edit, run or distribute this file
;   as long as the above copyright notice remains
;THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
;OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
;MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
;VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
;OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;For more information about my classes, my research, and my books, see
;http://users.ece.utexas.edu/~valvano/


; we align 32 bit variables to 32-bits
; we align op codes to 16 bits
       THUMB
       AREA    DATA, ALIGN=4 
       EXPORT  M [DATA,SIZE=4]
M      SPACE   4
PARAMS SPACE   16
                 
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start
Start  
    BL Random_Init
loop
    BL    Generate_Numbers
	BL    add64
	
	BL    Generate_Numbers
	BL    sub64
	
	BL    Generate_Number
	BL    endian
	
	B   loop
	
;-------------add64------------
; Adds two 64 bits numbers
; with saturation
; [R0,R1] + [R2,R3]
; Return the result in [R0,R1]
add64
    STMIA  sp!, {r4-r12,lr} ; Push last scope to stack
    ADDS   R1, R1, R3        ; ADD R1 and R3 and store the result in R1
	ADCS   R0, R0, R2        ; ADD R0 and R2
	MOVVS  R0, #0x7FFFFFFF   ; If overflow saturate to the maximum value
	MOVVS  R1, #0xFFFFFFFF   ; If overflow saturate to the maximum value
	MVNCS  R0, R0            ; If carry flip the bits to the lowest value
	MVNCS  R1, R1            ; If carry flip the bits to the lowest value
	LDMDB  sp!, {r4-r12,lr} ; Pop last scope from stack
	BX     LR
	
;-------------sub64------------
; Subtracts two 64 bits numbers
; with saturation
; [R0,R1] - [R2,R3]
; Return the result in [R0,R1]
sub64
    STMIA  sp!, {r4-r12,lr} ; Push last scope to stack
    SUBS   R1, R1, R3        ; SUB R1 and R3 and store the result in R1
	SBCS   R0, R0, R2        ; SUB R0 and R2
	MOVVS  R0, #0x7FFFFFFF   ; If overflow saturate to the maximum value
	MOVVS  R1, #0xFFFFFFFF   ; If overflow saturate to the maximum value
	MVNCS  R0, R0            ; If carry flip the bits to the lowest value
	MVNCS  R1, R1            ; If carry flip the bits to the lowest value
	LDMDB  sp!, {r4-r12,lr} ; Pop last scope from stack
	BX     LR

;-------------endian-----------
; Converts a number from big endian
; to little endian or vice versa
; [R0] input [R0] output
endian
    STMIA  sp!, {r4-r12,lr}     ; Push last scope to stack
    MOV    R1,    #0x00000000     ; Clear R1
	AND    R4,    R0, #0x000000FF ; Place first 8 bits of R0 into R1
	LSL    R4,    #24             ;
	AND    R5,    R0, #0x0000FF00 ;
	LSL    R5,    #8              ;
	AND    R6,    R0, #0x00FF0000 ;
	LSR    R6,    #8              ;
	AND    R7,    R0, #0xFF000000 ;
	LSR    R7,    #24             ;
	ORR    R0,    R4,    R5       ;
	ORR    R0,    R0,    R6       ;
	ORR    R0,    R0,    R7       ;
	LDMDB  sp!, {r4-r12,lr}     ; Pop last scope from stack
    BX     LR

;------Generate_Number---------
; Generate one 32 bit number
; Placed in R0
Generate_Number
    STMIA  sp!, {r4-r12,lr} ; Push last scope to stack
    BL     Random             ; Generate a random number in R0
	LDMDB  sp!, {r4-r12,lr} ; Pop last scope from stack
	BX     LR
	
;------Generate_Numbers--------
; Generate four 32 bit numbers
; Placed in R0-R3
Generate_Numbers
    STMIA sp!, {r4-r12,lr} ; Push last scope to stack
    LDR   R3,=PARAMS         ; Get the address of our parameters
    BL    Random             ; Generate a random number in R0
	STR   R0,[R3]            ; Store it to the first slot in PARAMS
	BL    Random             ; Generate a random number in R0
	STR   R0,[R3,#4]         ; Store it to the second slot in PARAMS
	BL    Random             ; Generate a random number in R0
	STR   R0,[R3,#8]         ; Store it to the third slot in PARAMS
	BL    Random             ; Generate a random number in R0
	STR   R0,[R3,#12]        ; Store it to the fourth slot in PARAMS
	LDR   R0,[R3]            ; Load first index of PARAMS into R0
	LDR   R1,[R3,#4]         ; Load second index of PARAMS into R1
	LDR   R2,[R3,#8]         ; Load third index of PARAMS into R2
	LDR   R3,[R3,#12]        ; Load fourth index of PARAMS into R3
	LDMDB sp!, {r4-r12,lr} ; Pop last scope from stack
	BX    LR
	   
;---------Random_Init----------
; Initialize Random seed
Random_Init
       LDR R2,=M       ; R2 = &M, R2 points to M
       MOV R0,#1       ; Initial seed
       STR R0,[R2]     ; M=1
	   BX  LR
;------------Random------------
; Return R0= random number
; Linear congruential generator 
; from Numerical Recipes by Press et al.
Random 
       LDR R2,=M    ; R2 = &M, R2 points to M
       LDR R0,[R2]  ; R0=M
       LDR R1,=1664525
       MUL R0,R0,R1 ; R0 = 1664525*M
       LDR R1,=1013904223
       ADD R0,R1    ; 1664525*M+1013904223 
       STR R0,[R2]  ; store M
       BX  LR
       ALIGN      
       END  
           