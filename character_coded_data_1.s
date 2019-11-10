.EQU SWI_EXIT, 0x11

@@ Input and output
@@ Data segment begins
.DATA
@@ Input LENGTH - length of both STRING1 and STRING2
LENGTH: .word 3
@@ Input STRING1 and STRING2 - ascii streams
STRING1: .ascii "CAT"
STRING2: .ascii "BAT"
@STRING2: .ascii "CAT"
@STRING2: .ascii "CUT"
@@ align the data segment to overcome misaligned issues
.align
@@ Output GREATER - if STRING1 > STRING2 set GREATER to 0x0 else to 0xFFFFFFFF
GREATER: .word 0x0

@@ Code segment begins
.TEXT
.global MAIN

MAIN:
    @@ Load the address of STRING1, STRING2 and LENGTH to registers R5, R6 and R7 respectively
    LDR R5, =STRING1
    LDR R6, =STRING2
    LDR R7, =LENGTH
    @@ Load the length of strings to register R4 for loop exit condition
    LDR R4, [R7]
    @@ Initialization of register R0
    MOV R0, #0

    @@ Loop till either (R4) length reaches to 0 or if the byte differs
LOOP:
    @@ Load the byte pointed by register R5 and R6 to register R1 and R2
    LDRB R1, [R5], #1
    LDRB R2, [R6], #1
    @@ Compare register R1 and R2 if not equal exit the loop or continue
    CMP R1, R2
    BNE EXIT
    @@ Decrement the length by 1 and also set the condition flag
    SUBS R4, R4, #1
    @@ Branch if Z flag is not set
    BNE LOOP
EXIT:
    @@ Move 0xFFFFFFFF to register R0 iff N flag is set is possible only if R2 is large
    MOVMI R0, #-1
    LDR R7, =GREATER
    @@ Store the content of R0 to address location pointed by R7
    STR R0, [R7]
    SWI SWI_EXIT