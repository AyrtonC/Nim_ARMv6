/*
MIT License

Copyright (c) 2017 Ayrton Cavalieri de Almeida

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

	.data
msn0:	.ascii	"There is not enough stones.\n"	@28 bytes long
msn1:	.ascii	"Type the number of stones (0 - ABORT): "	@39 bytes long
msn2:	.ascii	"Player 1 turn.\n"	@15 bytes long
msn3:	.ascii	"Player 2 turn.\n"	@15 bytes long
msn4:	.asciz	"Stones left: %d\nAction:\n1 - Remove 1 stone;\n2 - Remove 2 stones;\n3 - Remove 3 stones.\n"
msn5:	.ascii	"Unknown command.\n"	@17 bytes long
msn6:	.ascii	"Player 1 WINS!\n"	@15 bytes long
msn7:	.ascii	"Player 2 WINS!\n"	@15 bytes long
sint:	.asciz	"%d"
cls:	.asciz	"clear"

	.global main
	.text
	.align 2

notEnough:
	STMFD SP!, {FP, LR}
	LDR R0, =msn0
	MOV R1, #28
	BL myPuts	@Display message msn0
	LDR R0, time
	BL usleep	@Wait 1.5 seconds
	LDMFD SP!, {FP, PC}

main:
	STMFD SP!, {FP, LR}
	SUB SP, SP, #4	@Memory area for read the keyboard using scanf
	/*
		R4 - noOfStones
		R5 - action
		R6 - turnFlag
	*/

	LDR R0, =msn1
	MOV R1, #39
	BL myPuts	@Print message
	LDR R0, =sint
	MOV R1, SP
	BL scanf	@Read an integer
	LDR R4, [SP]	@Load number of stones

	CMP R4, #0
	BEQ EndProg
	EOR R6, R6, R6  @Zero turnFlag

Loop:
	LDR R0, =cls
	BL system	@Clear screen (bash)
	CMP R6, #0	@Compare to show player turn
	LDREQ R0, =msn2
	LDRNE R0, =msn3
	MOV R1, #15
	BL myPuts	@Print message
	LDR R0, =msn4
	MOV R1, R4
	BL printf	@Print stones left and options

	LDR R0, =sint
	MOV R1, SP
	BL scanf	@Read an integer
	LDR R5, [SP]	@Load user option

	CMP R5, #1
	BEQ case1
	CMP R5, #2
	BEQ case2
	CMP R5, #3
	BEQ case3
	BAL default

case1:
	SUB R4, R4, #1	@Subtract 1 stone
	BAL aftSwitch
case2:
	CMP R4, #2	@Compare number of stones...
	SUBGE R4, R4, #2	@If greater or equal, subtract...
	BGE aftSwitch	@And continue
	BL notEnough
	BAL Loop	@Error otherwise
case3:
	CMP R4, #3	@Compare number of stones...
	SUBGE R4, R4, #3	@If greater or equal, subtract...
	BGE aftSwitch	@And continue
	BL notEnough
	BAL Loop	@Error otherwise
default:
	LDR R0, =msn5
	MOV R1, #17
	BL myPuts	@Show Unknown command message
	LDR R0, time
        BL usleep	@Wait 1.5 seconds
	BAL Loop
aftSwitch:
	CMP R4, #0	@Compare the number of stones
	MVNNE R6, R6	@Negate turn flag if not-0
	BNE Loop	@Branch if not-0

	CMP R6, #0	@Compare to display the winner
	LDREQ R0, =msn6
	LDRNE R0, =msn7
	MOV R1, #15
	BL myPuts
EndProg:
	ADD SP, SP, #4
	LDMFD SP!, {FP, PC}

myPuts:	@Writes a string to screen using syscall
	@Params: R0 - String address, R1 - Size of the string
	@Return: void
	STMFD SP!, {R7, LR}

	MOV R2, R1	@Moves the size of the string
	MOV R1, R0	@Moves the address of the string
	MOV R0, #1	@Determine screen output
	MOV R7, #4	@Write syscall
	SWI 0

	LDMFD SP!, {R7, PC}

time:   .word 1500000
