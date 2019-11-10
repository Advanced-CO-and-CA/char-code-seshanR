.EQU SWI_EXIT, 0x11

@@ Input and Output
@@ Data segment begins
.DATA
@@ Input STRING - ascii value stream
STRING: .asciz "CS6620"
@@ Input SUBSTR - ascii value stream
SUBSTR: .asciz "S5"
@SUBSTR: .asciz "620"
@SUBSTR: .asciz "6"
@@ align the data segment to overcome misaligned issues
.align
@@ Output PRESENT - if substring is present store its position
PRESENT: .word 0x0

@@ Code segment begins
.TEXT
.global MAIN

MAIN:
    @@ Find length of the input strings to run through limited loop iteration

    @@ Find length of STRING and store its value in register R8
    LDR R1, =STRING
    BL STRING_LENGTH
    MOV R8, R0

    @@ Find length of SUBSTR and store its value in register R9
    LDR R1, =SUBSTR
    BL STRING_LENGTH
    MOV R9, R0

    @@ Store starting address of STRING to register R2
    LDR R2, =STRING
    @@ Initialize condition set R5 and R4 to 0
    MOV R5, #0
    MOV R4, R5
    
    @@ Iterate the loop till position(STRING) - len(SUBSTR) >= len(SUBSTR)
    @@ If substring is found store its position else store 0x0 in PRESENT
LOOP:
    @@ Compare register R9 (SUBSTR) with R8 (position(STRING))
    CMP R9, R8
    @@ If substring length is greater branch to EXIT
    BGT EXIT
    @@ Call for subroutine IS_SUBSTR
    BL IS_SUBSTR
    @@ Increament register R5 value by 1 for position
    ADD R5, R5, #1
    @@ Increament register R2 value by 1 for next position in STRING
    ADD R2, R2, #1
    @@ Decrement length of STRING by 1 to match the looping condition
    SUB R8, R8, #1
    @@ Compare content of register R0 if the substring is found or not
    @@ If not found branch to loop else break the loop
    CMP R0, #0
    BNE LOOP
    @@ Move the contents of register R5 to R4 which current position where substring is found else it will hold 0x0
    MOV R4, R5
EXIT:
    @@ Load the address of PRESENT to register R0
    LDR R0, =PRESENT
    @@ Store the contents of register R4 to address pointed by register R0
    STR R4, [R0]
    swi SWI_EXIT

@@ IS_SUBSTR subroutine
@@ If substring if found in STRING from indexed position then store 0x0 in register R0 else store 0xFFFFFFFF
IS_SUBSTR:
    @@ Store contents of register R1-R5 and link register in stack
    STMFD SP!, {R1-R5, LR}
    @@ Store the SUBSTR starting location in register R1
    LDR R1, [SP]
    @@ Store the STRING starting location in register R2
    LDR R2, [SP, #4]

    @@ Initialize condition
    @@ Set the length of SUBSTR to R5 for loop iteration
    @@ Set register R0 to 0xFFFFFFFF
    MOV R5, R9
    MOV R0, #-1
    @@ SUBSTR_LOOP to check if SUBSTR match with STRING indexes
SUBSTR_LOOP:
    @@ Load bytes pointed by register R1 and R2 to R3 and R4 repectively and increament R1 and R2 by 1
    LDRB R3, [R1], #1
    LDRB R4, [R2], #1
    @@ Compare R3 and R4 whether they are same or different
    CMP R3, R4
    @@ If Z flag is not set then they are different and branch to NOT_SUBSTR
    BNE NOT_SUBSTR
    @@ Decrement the size of SUBSTR and set the condition flags
    SUBS R5, R5, #1
    @@ If Z flag is set skip the loop else go for next iteration with different bytes
    BNE SUBSTR_LOOP
    @@ Move 0x0 to register R0
    MOV R0, #0x0
NOT_SUBSTR:
    @@ Store the contents of register R0 to stack
    STMFD SP!, {R0}
    @@ Pop the contents of stack and store it in register R0-R5 and update the PC for next instruction after branch
    LDMFD SP!, {R0-R5, PC}

@@ STRING_LENGTH subroutine
@@ Find the length of ascii strings
STRING_LENGTH:
    @@ Store contents of register R1-R3 and link register to stack
    STMFD SP!, {R1-R3, LR}
    @@ Initialize register R1 to 0x0 to store the length of the string
    MOV R1, #0
    @@ Load the start address of string from top of stack to register R2
    LDR R2, [SP]
    @@ Iterate the loop to till 0x0 if found in memory space
LENGTH_LOOP:
    @@ Load the byte referred by register R2 to R3 and increment register R2 by 1
    LDRB R3, [R2], #1
    @@ Compare if register R3 contains 0x0 i.e., end of string is reached
    CMP R3, #0
    @@ If condition fails then increament register R1
    ADDNE R1, R1, #1
    BNE LENGTH_LOOP
    @@ Store the result in register R1 to stack
    STMFD SP!, {R1}
    @@ Pop the result and the stack content to register R0-R3 and update PC to next instruction after branch
    LDMFD SP!, {R0-R3, PC}