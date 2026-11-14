/* Start.s
 *	Assembly language assist for user programs running on top of Nachos.
 *
 *	Since we don't want to pull in the entire C library, we define
 *	what we need for a user program here, namely Start and the system
 *	calls.
 */

#define IN_ASM
#include "syscall.h"

        .text
        .align  2

/* -------------------------------------------------------------
 * __start
 *	Initialize running a C program, by calling "main".
 *
 * 	NOTE: This has to be first, so that it gets loaded at location 0.
 *	The Nachos kernel always starts a program by jumping to location 0.
 * -------------------------------------------------------------
 */

	.globl __start
	.ent	__start
__start:
	jal	main
	move	$4,$0
	jal	Exit	 /* if we return from main, exit(0) */
	.end __start

/* -------------------------------------------------------------
 * System call stubs:
 *	Assembly language assist to make system calls to the Nachos kernel.
 *	There is one stub per system call, that places the code for the
 *	system call into register r2, and leaves the arguments to the
 *	system call alone (in other words, arg1 is in r4, arg2 is
 *	in r5, arg3 is in r6, arg4 is in r7)
 *
 * 	The return value is in r2. This follows the standard C calling
 * 	convention on the MIPS.
 * -------------------------------------------------------------
 */

	.globl Halt
	.ent	Halt
Halt:
	addiu $2,$0,SC_Halt
	syscall
	j	$31
	.end Halt

        .globl  PrintInt
        .ent     PrintInt
PrintInt:
        addiu $2,$0,SC_PrintInt
        syscall
        j       $31
        .end  PrintInt

	.globl MSG
	.ent   MSG
MSG:
	addiu $2,$0,SC_MSG
	syscall
	j	$31
	.end MSG

	.globl Add
	.ent	Add
Add:
	addiu $2,$0,SC_Add
	syscall
	j 	$31
	.end Add

	.globl Exit
	.ent	Exit
Exit:
	addiu $2,$0,SC_Exit
	syscall
	j	$31
	.end Exit

	.globl Exec
	.ent	Exec
Exec:
	addiu $2,$0,SC_Exec
	syscall
	j	$31
	.end Exec

	.globl ExecV
	.ent	ExecV
ExecV:
	addiu $2,$0,SC_ExecV
	syscall
	j	$31
	.end ExecV

	.globl Join
	.ent	Join
Join:
	addiu $2,$0,SC_Join
	syscall
	j	$31
	.end Join

	.globl Create
	.ent	Create
Create:
	addiu $2,$0,SC_Create
	syscall
	j	$31
	.end Create

	.globl Remove
	.ent	Remove
Remove:
	addiu $2,$0,SC_Remove
	syscall
	j	$31
	.end Remove

	.globl Seek
	.ent	Seek
Seek:
	addiu $2,$0,SC_Seek
	syscall
	j	$31
	.end Seek

        .globl ThreadFork
        .ent    ThreadFork
ThreadFork:
        addiu $2,$0,SC_ThreadFork
        syscall
        j       $31
        .end ThreadFork

        .globl ThreadYield
        .ent    ThreadYield
ThreadYield:
        addiu $2,$0,SC_ThreadYield
        syscall
        j       $31
        .end ThreadYield

	.globl ThreadExit
	.ent    ThreadExit
ThreadExit:
	addiu $2, $0, SC_ThreadExit
	syscall
	j 	$31
	.end ThreadExit

	.globl ThreadJoin
	.ent    ThreadJoin
ThreadJoin:
	addiu $2, $0, SC_ThreadJoin
	syscall
	j 	$31
	.end ThreadJoin




	/* addiu : Add Immediate Unsigned（無號立即值加法）*/
	/* $2：目標暫存器（在 MIPS 慣例中即為 $v0，專門用來存放 System Call 編號與函式回傳值）*/
	/* $0：MIPS 內建的硬體暫存器（$zero），其數值永遠硬體鎖定為 0 */
	/* SC_Open：常數（即之前在 syscall.h 定義的數字 6）*/

	.globl Open             /* 宣告為全域符號 / Declare "Open" as a global symbol */
	.ent	Open            /* 標記函式起點 (供除錯用) / Mark entry point for debuggers */
Open:                       /* 函式進入點標籤 / Entry label of Open */
	addiu	$2, $0, SC_Open /* 載入系統呼叫編號至 $2 ($v0) / Load "SC_Open" ID into register $2[cite: 14] */
	syscall                 /* 觸發軟體中斷切換至核心 / Trap to kernel via software interrupt[cite: 11] */
	j	$31                 /* 跳回呼叫者 (返回位址存於 $31/$ra) / Jump back to caller ($31 is return address) */
	.end	Open            /* 標記函式結束 / Mark end of Open function */

	.globl Write
	.ent	Write
Write:
	addiu	$2, $0, SC_Write
	syscall
	j	$31
	.end	Write

	.globl Read
	.ent	Read
Read:
	addiu	$2, $0, SC_Read
	syscall
	j	$31
	.end	Read

	.globl Close
	.ent	Close
Close:
	addiu	$2, $0, SC_Close
	syscall
	j	$31
	.end	Close




/* dummy function to keep gcc happy */
        .globl  __main
        .ent    __main
__main:
        j       $31
        .end    __main
