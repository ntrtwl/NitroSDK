#include <asm/macros/function.inc>
	.text

bswap_const:
	.word 0x00FF00FF

round1_const:
	.word 0x5A827999

round2_const:
	.word 0x6ED9EBA1


	// r0 = DGTHash2Context ctx
	// r1 = message data pointer, 4-aligned
	// r2 = number of blocks, multiple of 64
	arm_func_start DGTi_hash2_arm4_fast
DGTi_hash2_arm4_fast:
	stmdb sp!, {r4, r5, r6, r7, r8, r9, sl, fp, ip, lr}
	
	// State variables from ctx
	ldmia r0, { r3, r9, sl, fp, ip }
	
block_loop:
	// These first two loads are before the function because the next pool is out of range
	
	// Magic round constant 1 (for rounds 1-20)
	ldr r7, round1_const
	
	// Value for executing byteswaps (data words must be in Big-Endian)
	ldr r6, bswap_const
	
	// First 16 rounds use the original data words
	// Data is read from r1, then byte swapped
	// Rounds 17-80 use values derived from these data words, so save them on the stack
	ldr r5, [r1], #4
	
	// Round 1
	add r8, r7, ip;
	add r8, r8, r3, ror #27
	eor r4, sl, fp
	and r4, r4, r9
	eor r4, r4, fp
	and lr, r5, r6
	and r5, r6, r5, ror #24
	orr r5, r5, lr, ror #8
	str r5, [sp, #-4]!
	add r8, r8, r5
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 2
	ldr r4, [r1], #4
	add ip, r7, fp
	add ip, ip, r8, ror #27
	eor r5, r9, sl
	and r5, r5, r3
	eor r5, r5, sl
	and lr, r4, r6
	and r4, r6, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [sp, #-4]!
	add ip, ip, r4
	add ip, ip, r5
	mov r3, r3, ror #2
	
	// Round 3
	ldr r5, [r1], #4
	add fp, r7, sl
	add fp, fp, ip, ror #27
	eor r4, r3, r9
	and r4, r4, r8
	eor r4, r4, r9
	and lr, r5, r6
	and r5, r6, r5, ror #24
	orr r5, r5, lr, ror #8
	str r5, [sp, #-4]!
	add fp, fp, r5
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 4
	ldr r4, [r1], #4
	add sl, r7, r9
	add sl, sl, fp, ror #27
	eor r5, r8, r3
	and r5, r5, ip
	eor r5, r5, r3
	and lr, r4, r6
	and r4, r6, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [sp, #-4]!
	add sl, sl, r4
	add sl, sl, r5
	mov ip, ip, ror #2
	
	// Round 5
	ldr r5, [r1], #4
	add r9, r7, r3
	add r9, r9, sl, ror #27
	eor r4, ip, r8
	and r4, r4, fp
	eor r4, r4, r8
	and lr, r5, r6
	and r5, r6, r5, ror #24
	orr r5, r5, lr, ror #8
	str r5, [sp, #-4]!
	add r9, r9, r5
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 6
	ldr r4, [r1], #4
	add r3, r7, r8
	add r3, r3, r9, ror #27
	eor r5, fp, ip
	and r5, r5, sl
	eor r5, r5, ip
	and lr, r4, r6
	and r4, r6, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [sp, #-4]!
	add r3, r3, r4
	add r3, r3, r5
	mov sl, sl, ror #2
	
	// Round 7
	ldr r5, [r1], #4
	add r8, r7, ip
	add r8, r8, r3, ror #27
	eor r4, sl, fp
	and r4, r4, r9
	eor r4, r4, fp
	and lr, r5, r6
	and r5, r6, r5, ror #24
	orr r5, r5, lr, ror #8
	str r5, [sp, #-4]!
	add r8, r8, r5
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 8
	ldr r4, [r1], #4
	add ip, r7, fp
	add ip, ip, r8, ror #27
	eor r5, r9, sl
	and r5, r5, r3
	eor r5, r5, sl
	and lr, r4, r6
	and r4, r6, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [sp, #-4]!
	add ip, ip, r4
	add ip, ip, r5
	mov r3, r3, ror #2
	
	// Round 9
	ldr r5, [r1], #4
	add fp, r7, sl
	add fp, fp, ip, ror #27
	eor r4, r3, r9
	and r4, r4, r8
	eor r4, r4, r9
	and lr, r5, r6
	and r5, r6, r5, ror #24
	orr r5, r5, lr, ror #8
	str r5, [sp, #-4]!
	add fp, fp, r5
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 10
	ldr r4, [r1], #4
	add sl, r7, r9
	add sl, sl, fp, ror #27
	eor r5, r8, r3
	and r5, r5, ip
	eor r5, r5, r3
	and lr, r4, r6
	and r4, r6, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [sp, #-4]!
	add sl, sl, r4
	add sl, sl, r5
	mov ip, ip, ror #2
	
	// Round 11
	ldr r5, [r1], #4
	add r9, r7, r3
	add r9, r9, sl, ror #27
	eor r4, ip, r8
	and r4, r4, fp
	eor r4, r4, r8
	and lr, r5, r6
	and r5, r6, r5, ror #24
	orr r5, r5, lr, ror #8
	str r5, [sp, #-4]!
	add r9, r9, r5
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 12
	ldr r4, [r1], #4
	add r3, r7, r8
	add r3, r3, r9, ror #27
	eor r5, fp, ip
	and r5, r5, sl
	eor r5, r5, ip
	and lr, r4, r6
	and r4, r6, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [sp, #-4]!
	add r3, r3, r4
	add r3, r3, r5
	mov sl, sl, ror #2
	
	// Round 13
	ldr r5, [r1], #4
	add r8, r7, ip
	add r8, r8, r3, ror #27
	eor r4, sl, fp
	and r4, r4, r9
	eor r4, r4, fp
	and lr, r5, r6
	and r5, r6, r5, ror #24
	orr r5, r5, lr, ror #8
	str r5, [sp, #-4]!
	add r8, r8, r5
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 14
	ldr r4, [r1], #4
	add ip, r7, fp
	add ip, ip, r8, ror #27
	eor r5, r9, sl
	and r5, r5, r3
	eor r5, r5, sl
	and lr, r4, r6
	and r4, r6, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [sp, #-4]!
	add ip, ip, r4
	add ip, ip, r5
	mov r3, r3, ror #2
	
	// Round 15
	ldr r5, [r1], #4
	add fp, r7, sl
	add fp, fp, ip, ror #27
	eor r4, r3, r9
	and r4, r4, r8
	eor r4, r4, r9
	and lr, r5, r6
	and r5, r6, r5, ror #24
	orr r5, r5, lr, ror #8
	str r5, [sp, #-4]!
	add fp, fp, r5
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 16
	ldr r4, [r1], #4
	add sl, r7, r9
	add sl, sl, fp, ror #27
	eor r5, r8, r3
	and r5, r5, ip
	eor r5, r5, r3
	and lr, r4, r6
	and r4, r6, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [sp, #-4]!
	add sl, sl, r4
	add sl, sl, r5
	mov ip, ip, ror #2
	
	// Round 17
	ldr r6, [sp, #60]
	ldr r5, [sp, #52]
	ldr r4, [sp, #28]
	ldr lr, [sp, #8]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r5
	eor r4, r4, lr
	eor r6, r6, r4
	mov r6, r6, ror #31
	str r6, [sp, #60]
	eor r4, ip, r8
	and r4, r4, fp
	eor r4, r4, r8
	add r9, r9, r4
	add r9, r9, r6
	mov fp, fp, ror #2
	
	// Round 18
	ldr r6, [sp, #56]
	ldr r4, [sp, #48]
	ldr lr, [sp, #24]
	ldr r5, [sp, #4]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r6, r6, r4
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #56]
	eor lr, fp, ip
	and lr, lr, sl
	eor lr, lr, ip
	add r3, r3, lr
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Round 19
	ldr r6, [sp, #52]
	ldr lr, [sp, #44]
	ldr r5, [sp, #20]
	ldr r4, [sp]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, lr
	eor r5, r5, r4
	eor r6, r6, r5
	mov r6, r6, ror #31
	str r6, [sp, #52]
	eor r5, sl, fp
	and r5, r5, r9
	eor r5, r5, fp
	add r8, r8, r5
	add r8, r8, r6
	mov r9, r9, ror #2
	
	// Round 20
	ldr r6, [sp, #48]
	ldr r5, [sp, #40]
	ldr r4, [sp, #16]
	ldr lr, [sp, #60]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r6, r6, r5
	eor r4, r4, lr
	eor r6, r6, r4
	mov r6, r6, ror #31
	str r6, [sp, #48]
	eor r4, r9, sl
	and r4, r4, r3
	eor r4, r4, sl
	add ip, ip, r4
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Magic round constant 2 (for rounds 21-40)
	ldr r7, round2_const
	
	// Round 21
	ldr r6, [sp, #44]
	ldr r4, [sp, #36]
	ldr lr, [sp, #12]
	ldr r5, [sp, #56]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor r4, r8, r3
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #44]
	add fp, fp, r6
	eor r4, r4, r9
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 22
	ldr r4, [sp, #40]
	ldr r6, [sp, #32]
	ldr lr, [sp, #8]
	ldr r5, [sp, #52]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor r4, r4, r6
	eor r6, ip, r8
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #40]
	add sl, sl, r4
	eor r6, r6, r3
	add sl, sl, r6
	mov ip, ip, ror #2
	
	// Round 23
	ldr r6, [sp, #36]
	ldr r4, [sp, #28]
	ldr lr, [sp, #4]
	ldr r5, [sp, #48]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r4
	eor r4, fp, ip
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #36]
	add r9, r9, r6
	eor r4, r4, r8
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 24
	ldr r4, [sp, #32]
	ldr r6, [sp, #24]
	ldr lr, [sp]
	ldr r5, [sp, #44]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r4, r4, r6
	eor r6, sl, fp
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #32]
	add r3, r3, r4
	eor r6, r6, ip
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Round 25
	ldr r6, [sp, #28]
	ldr r4, [sp, #20]
	ldr lr, [sp, #60]
	ldr r5, [sp, #40]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, r4
	eor r4, r9, sl
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #28]
	add r8, r8, r6
	eor r4, r4, fp
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 26
	ldr r4, [sp, #24]
	ldr r6, [sp, #16]
	ldr lr, [sp, #56]
	ldr r5, [sp, #36]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r6
	eor r6, r3, r9
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #24]
	add ip, ip, r4
	eor r6, r6, sl
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Round 27
	ldr r6, [sp, #20]
	ldr r4, [sp, #12]
	ldr lr, [sp, #52]
	ldr r5, [sp, #32]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor r4, r8, r3
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #20]
	add fp, fp, r6
	eor r4, r4, r9
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 28
	ldr r4, [sp, #16]
	ldr r6, [sp, #8]
	ldr lr, [sp, #48]
	ldr r5, [sp, #28]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor r4, r4, r6
	eor r6, ip, r8
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #16]
	add sl, sl, r4
	eor r6, r6, r3
	add sl, sl, r6
	mov ip, ip, ror #2
	
	// Round 29
	ldr r6, [sp, #12]
	ldr r4, [sp, #4]
	ldr lr, [sp, #44]
	ldr r5, [sp, #24]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r4
	eor r4, fp, ip
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #12]
	add r9, r9, r6
	eor r4, r4, r8
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 30
	ldr r4, [sp, #8]
	ldr r6, [sp]
	ldr lr, [sp, #40]
	ldr r5, [sp, #20]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r4, r4, r6
	eor r6, sl, fp
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #8]
	add r3, r3, r4
	eor r6, r6, ip
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Round 31
	ldr r6, [sp, #4]
	ldr r4, [sp, #60]
	ldr lr, [sp, #36]
	ldr r5, [sp, #16]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, r4
	eor r4, r9, sl
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #4]
	add r8, r8, r6
	eor r4, r4, fp
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 32
	ldr r4, [sp]
	ldr r6, [sp, #56]
	ldr lr, [sp, #32]
	ldr r5, [sp, #12]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r6
	eor r6, r3, r9
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp]
	add ip, ip, r4
	eor r6, r6, sl
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Round 33
	ldr r6, [sp, #60]
	ldr r4, [sp, #52]
	ldr lr, [sp, #28]
	ldr r5, [sp, #8]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor r4, r8, r3
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #60]
	add fp, fp, r6
	eor r4, r4, r9
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 34
	ldr r4, [sp, #56]
	ldr r6, [sp, #48]
	ldr lr, [sp, #24]
	ldr r5, [sp, #4]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor r4, r4, r6
	eor r6, ip, r8
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #56]
	add sl, sl, r4
	eor r6, r6, r3
	add sl, sl, r6
	mov ip, ip, ror #2
	
	// Round 35
	ldr r6, [sp, #52]
	ldr r4, [sp, #44]
	ldr lr, [sp, #20]
	ldr r5, [sp]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r4
	eor r4, fp, ip
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #52]
	add r9, r9, r6
	eor r4, r4, r8
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 36
	ldr r4, [sp, #48]
	ldr r6, [sp, #40]
	ldr lr, [sp, #16]
	ldr r5, [sp, #60]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r4, r4, r6
	eor r6, sl, fp
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #48]
	add r3, r3, r4
	eor r6, r6, ip
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Round 37
	ldr r6, [sp, #44]
	ldr r4, [sp, #36]
	ldr lr, [sp, #12]
	ldr r5, [sp, #56]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, r4
	eor r4, r9, sl
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #44]
	add r8, r8, r6
	eor r4, r4, fp
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 38
	ldr r4, [sp, #40]
	ldr r6, [sp, #32]
	ldr lr, [sp, #8]
	ldr r5, [sp, #52]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r6
	eor r6, r3, r9
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #40]
	add ip, ip, r4
	eor r6, r6, sl
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Round 39
	ldr r6, [sp, #36]
	ldr r4, [sp, #28]
	ldr lr, [sp, #4]
	ldr r5, [sp, #48]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor r4, r8, r3
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #36]
	add fp, fp, r6
	eor r4, r4, r9
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 40
	ldr r4, [sp, #32]
	ldr r6, [sp, #24]
	ldr lr, [sp]
	ldr r5, [sp, #44]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor r4, r4, r6
	eor r6, ip, r8
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #32]
	add sl, sl, r4
	eor r6, r6, r3
	add sl, sl, r6
	mov ip, ip, ror #2
	
	// Magic round constant 3 (for rounds 41-60)
	ldr r7, =0x8F1BBCDC
	
	// Round 41
	ldr r6, [sp, #28]
	ldr r4, [sp, #20]
	ldr lr, [sp, #60]
	ldr r5, [sp, #40]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r4
	eor lr, lr, r5
	eor r6, r6, lr
	orr lr, fp, ip
	and lr, lr, r8
	and r5, fp, ip
	orr lr, lr, r5
	mov r6, r6, ror #31
	str r6, [sp, #28]
	add r9, r9, r6
	add r9, r9, lr
	mov fp, fp, ror #2
	
	// Round 42
	ldr lr, [sp, #24]
	ldr r6, [sp, #16]
	ldr r5, [sp, #56]
	ldr r4, [sp, #36]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor lr, lr, r6
	eor r5, r5, r4
	eor lr, lr, r5
	orr r5, sl, fp
	and r5, r5, ip
	and r4, sl, fp
	orr r5, r5, r4
	mov lr, lr, ror #31
	str lr, [sp, #24]
	add r3, r3, lr
	add r3, r3, r5
	mov sl, sl, ror #2
	
	// Round 43
	ldr r5, [sp, #20]
	ldr lr, [sp, #12]
	ldr r4, [sp, #52]
	ldr r6, [sp, #32]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r5, r5, lr
	eor r4, r4, r6
	eor r5, r5, r4
	orr r4, r9, sl
	and r4, r4, fp
	and r6, r9, sl
	orr r4, r4, r6
	mov r5, r5, ror #31
	str r5, [sp, #20]
	add r8, r8, r5
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 44
	ldr r4, [sp, #16]
	ldr r5, [sp, #8]
	ldr r6, [sp, #48]
	ldr lr, [sp, #28]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r5
	eor r6, r6, lr
	eor r4, r4, r6
	orr r6, r3, r9
	and r6, r6, sl
	and lr, r3, r9
	orr r6, r6, lr
	mov r4, r4, ror #31
	str r4, [sp, #16]
	add ip, ip, r4
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Round 45
	ldr r6, [sp, #12]
	ldr r4, [sp, #4]
	ldr lr, [sp, #44]
	ldr r5, [sp, #24]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor lr, lr, r5
	eor r6, r6, lr
	orr lr, r8, r3
	and lr, lr, r9
	and r5, r8, r3
	orr lr, lr, r5
	mov r6, r6, ror #31
	str r6, [sp, #12]
	add fp, fp, r6
	add fp, fp, lr
	mov r8, r8, ror #2
	
	// Round 46
	ldr lr, [sp, #8]
	ldr r6, [sp]
	ldr r5, [sp, #40]
	ldr r4, [sp, #20]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor lr, lr, r6
	eor r5, r5, r4
	eor lr, lr, r5
	orr r5, ip, r8
	and r5, r5, r3
	and r4, ip, r8
	orr r5, r5, r4
	mov lr, lr, ror #31
	str lr, [sp, #8]
	add sl, sl, lr
	add sl, sl, r5
	mov ip, ip, ror #2
	
	// Round 47
	ldr r5, [sp, #4]
	ldr lr, [sp, #60]
	ldr r4, [sp, #36]
	ldr r6, [sp, #16]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r5, r5, lr
	eor r4, r4, r6
	eor r5, r5, r4
	orr r4, fp, ip
	and r4, r4, r8
	and r6, fp, ip
	orr r4, r4, r6
	mov r5, r5, ror #31
	str r5, [sp, #4]
	add r9, r9, r5
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 48
	ldr r4, [sp]
	ldr r5, [sp, #56]
	ldr r6, [sp, #32]
	ldr lr, [sp, #12]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r4, r4, r5
	eor r6, r6, lr
	eor r4, r4, r6
	orr r6, sl, fp
	and r6, r6, ip
	and lr, sl, fp
	orr r6, r6, lr
	mov r4, r4, ror #31
	str r4, [sp]
	add r3, r3, r4
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Round 49
	ldr r6, [sp, #60]
	ldr r4, [sp, #52]
	ldr lr, [sp, #28]
	ldr r5, [sp, #8]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, r4
	eor lr, lr, r5
	eor r6, r6, lr
	orr lr, r9, sl
	and lr, lr, fp
	and r5, r9, sl
	orr lr, lr, r5
	mov r6, r6, ror #31
	str r6, [sp, #60]
	add r8, r8, r6
	add r8, r8, lr
	mov r9, r9, ror #2
	
	// Round 50
	ldr lr, [sp, #56]
	ldr r6, [sp, #48]
	ldr r5, [sp, #24]
	ldr r4, [sp, #4]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor lr, lr, r6
	eor r5, r5, r4
	eor lr, lr, r5
	orr r5, r3, r9
	and r5, r5, sl
	and r4, r3, r9
	orr r5, r5, r4
	mov lr, lr, ror #31
	str lr, [sp, #56]
	add ip, ip, lr
	add ip, ip, r5
	mov r3, r3, ror #2
	
	// Round 51
	ldr r5, [sp, #52]
	ldr lr, [sp, #44]
	ldr r4, [sp, #20]
	ldr r6, [sp]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r5, r5, lr
	eor r4, r4, r6
	eor r5, r5, r4
	orr r4, r8, r3
	and r4, r4, r9
	and r6, r8, r3
	orr r4, r4, r6
	mov r5, r5, ror #31
	str r5, [sp, #52]
	add fp, fp, r5
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 52
	ldr r4, [sp, #48]
	ldr r5, [sp, #40]
	ldr r6, [sp, #16]
	ldr lr, [sp, #60]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor r4, r4, r5
	eor r6, r6, lr
	eor r4, r4, r6
	orr r6, ip, r8
	and r6, r6, r3
	and lr, ip, r8
	orr r6, r6, lr
	mov r4, r4, ror #31
	str r4, [sp, #48]
	add sl, sl, r4
	add sl, sl, r6
	mov ip, ip, ror #2
	
	// Round 53
	ldr r6, [sp, #44]
	ldr r4, [sp, #36]
	ldr lr, [sp, #12]
	ldr r5, [sp, #56]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r4
	eor lr, lr, r5
	eor r6, r6, lr
	orr lr, fp, ip
	and lr, lr, r8
	and r5, fp, ip
	orr lr, lr, r5
	mov r6, r6, ror #31
	str r6, [sp, #44]
	add r9, r9, r6
	add r9, r9, lr
	mov fp, fp, ror #2
	
	// Round 54
	ldr lr, [sp, #40]
	ldr r6, [sp, #32]
	ldr r5, [sp, #8]
	ldr r4, [sp, #52]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor lr, lr, r6
	eor r5, r5, r4
	eor lr, lr, r5
	orr r5, sl, fp
	and r5, r5, ip
	and r4, sl, fp
	orr r5, r5, r4
	mov lr, lr, ror #31
	str lr, [sp, #40]
	add r3, r3, lr
	add r3, r3, r5
	mov sl, sl, ror #2
	
	// Round 55
	ldr r5, [sp, #36]
	ldr lr, [sp, #28]
	ldr r4, [sp, #4]
	ldr r6, [sp, #48]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r5, r5, lr
	eor r4, r4, r6
	eor r5, r5, r4
	orr r4, r9, sl
	and r4, r4, fp
	and r6, r9, sl
	orr r4, r4, r6
	mov r5, r5, ror #31
	str r5, [sp, #36]
	add r8, r8, r5
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 56
	ldr r4, [sp, #32]
	ldr r5, [sp, #24]
	ldr r6, [sp]
	ldr lr, [sp, #44]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r5
	eor r6, r6, lr
	eor r4, r4, r6
	orr r6, r3, r9
	and r6, r6, sl
	and lr, r3, r9
	orr r6, r6, lr
	mov r4, r4, ror #31
	str r4, [sp, #32]
	add ip, ip, r4
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Round 57
	ldr r6, [sp, #28]
	ldr r4, [sp, #20]
	ldr lr, [sp, #60]
	ldr r5, [sp, #40]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor lr, lr, r5
	eor r6, r6, lr
	orr lr, r8, r3
	and lr, lr, r9
	and r5, r8, r3
	orr lr, lr, r5
	mov r6, r6, ror #31
	str r6, [sp, #28]
	add fp, fp, r6
	add fp, fp, lr
	mov r8, r8, ror #2
	
	// Round 58
	ldr lr, [sp, #24]
	ldr r6, [sp, #16]
	ldr r5, [sp, #56]
	ldr r4, [sp, #36]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor lr, lr, r6
	eor r5, r5, r4
	eor lr, lr, r5
	orr r5, ip, r8
	and r5, r5, r3
	and r4, ip, r8
	orr r5, r5, r4
	mov lr, lr, ror #31
	str lr, [sp, #24]
	add sl, sl, lr
	add sl, sl, r5
	mov ip, ip, ror #2
	
	// Round 59
	ldr r5, [sp, #20]
	ldr lr, [sp, #12]
	ldr r4, [sp, #52]
	ldr r6, [sp, #32]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r5, r5, lr
	eor r4, r4, r6
	eor r5, r5, r4
	orr r4, fp, ip
	and r4, r4, r8
	and r6, fp, ip
	orr r4, r4, r6
	mov r5, r5, ror #31
	str r5, [sp, #20]
	add r9, r9, r5
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 60
	ldr r4, [sp, #16]
	ldr r5, [sp, #8]
	ldr r6, [sp, #48]
	ldr lr, [sp, #28]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r4, r4, r5
	eor r6, r6, lr
	eor r4, r4, r6
	orr r6, sl, fp
	and r6, r6, ip
	and lr, sl, fp
	orr r6, r6, lr
	mov r4, r4, ror #31
	str r4, [sp, #16]
	add r3, r3, r4
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Magic round constant 4 (for rounds 61-80)
	ldr r7, =0xCA62C1D6
	
	// Round 61
	ldr r6, [sp, #12]
	ldr r4, [sp, #4]
	ldr lr, [sp, #44]
	ldr r5, [sp, #24]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, r4
	eor r4, r9, sl
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #12]
	add r8, r8, r6
	eor r4, r4, fp
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 62
	ldr r4, [sp, #8]
	ldr r6, [sp]
	ldr lr, [sp, #40]
	ldr r5, [sp, #20]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r6
	eor r6, r3, r9
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #8]
	add ip, ip, r4
	eor r6, r6, sl
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Round 63
	ldr r6, [sp, #4]
	ldr r4, [sp, #60]
	ldr lr, [sp, #36]
	ldr r5, [sp, #16]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor r4, r8, r3
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #4]
	add fp, fp, r6
	eor r4, r4, r9
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 64
	ldr r4, [sp]
	ldr r6, [sp, #56]
	ldr lr, [sp, #32]
	ldr r5, [sp, #12]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor r4, r4, r6
	eor r6, ip, r8
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp]
	add sl, sl, r4
	eor r6, r6, r3
	add sl, sl, r6
	mov ip, ip, ror #2
	
	// Round 65
	ldr r6, [sp, #60]
	ldr r4, [sp, #52]
	ldr lr, [sp, #28]
	ldr r5, [sp, #8]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r4
	eor r4, fp, ip
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #60]
	add r9, r9, r6
	eor r4, r4, r8
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 66
	ldr r4, [sp, #56]
	ldr r6, [sp, #48]
	ldr lr, [sp, #24]
	ldr r5, [sp, #4]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r4, r4, r6
	eor r6, sl, fp
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #56]
	add r3, r3, r4
	eor r6, r6, ip
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Round 67
	ldr r6, [sp, #52]
	ldr r4, [sp, #44]
	ldr lr, [sp, #20]
	ldr r5, [sp]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, r4
	eor r4, r9, sl
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #52]
	add r8, r8, r6
	eor r4, r4, fp
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 68
	ldr r4, [sp, #48]
	ldr r6, [sp, #40]
	ldr lr, [sp, #16]
	ldr r5, [sp, #60]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r6
	eor r6, r3, r9
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #48]
	add ip, ip, r4
	eor r6, r6, sl
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Round 69
	ldr r6, [sp, #44]
	ldr r4, [sp, #36]
	ldr lr, [sp, #12]
	ldr r5, [sp, #56]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor r4, r8, r3
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #44]
	add fp, fp, r6
	eor r4, r4, r9
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 70
	ldr r4, [sp, #40]
	ldr r6, [sp, #32]
	ldr lr, [sp, #8]
	ldr r5, [sp, #52]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor r4, r4, r6
	eor r6, ip, r8
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #40]
	add sl, sl, r4
	eor r6, r6, r3
	add sl, sl, r6
	mov ip, ip, ror #2
	
	// Round 71
	ldr r6, [sp, #36]
	ldr r4, [sp, #28]
	ldr lr, [sp, #4]
	ldr r5, [sp, #48]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r4
	eor r4, fp, ip
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #36]
	add r9, r9, r6
	eor r4, r4, r8
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 72
	ldr r4, [sp, #32]
	ldr r6, [sp, #24]
	ldr lr, [sp]
	ldr r5, [sp, #44]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r4, r4, r6
	eor r6, sl, fp
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #32]
	add r3, r3, r4
	eor r6, r6, ip
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Round 73
	ldr r6, [sp, #28]
	ldr r4, [sp, #20]
	ldr lr, [sp, #60]
	ldr r5, [sp, #40]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, r4
	eor r4, r9, sl
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #28]
	add r8, r8, r6
	eor r4, r4, fp
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 74
	ldr r4, [sp, #24]
	ldr r6, [sp, #16]
	ldr lr, [sp, #56]
	ldr r5, [sp, #36]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r6
	eor r6, r3, r9
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #24]
	add ip, ip, r4
	eor r6, r6, sl
	add ip, ip, r6
	mov r3, r3, ror #2
	
	// Round 75
	ldr r6, [sp, #20]
	ldr r4, [sp, #12]
	ldr lr, [sp, #52]
	ldr r5, [sp, #32]
	add fp, sl, r7
	add fp, fp, ip, ror #27
	eor r6, r6, r4
	eor r4, r8, r3
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #20]
	add fp, fp, r6
	eor r4, r4, r9
	add fp, fp, r4
	mov r8, r8, ror #2
	
	// Round 76
	ldr r4, [sp, #16]
	ldr r6, [sp, #8]
	ldr lr, [sp, #48]
	ldr r5, [sp, #28]
	add sl, r9, r7
	add sl, sl, fp, ror #27
	eor r4, r4, r6
	eor r6, ip, r8
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #16]
	add sl, sl, r4
	eor r6, r6, r3
	add sl, sl, r6
	mov ip, ip, ror #2
	
	// Round 77
	ldr r6, [sp, #12]
	ldr r4, [sp, #4]
	ldr lr, [sp, #44]
	ldr r5, [sp, #24]
	add r9, r3, r7
	add r9, r9, sl, ror #27
	eor r6, r6, r4
	eor r4, fp, ip
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #12]
	add r9, r9, r6
	eor r4, r4, r8
	add r9, r9, r4
	mov fp, fp, ror #2
	
	// Round 78
	ldr r4, [sp, #8]
	ldr r6, [sp]
	ldr lr, [sp, #40]
	ldr r5, [sp, #20]
	add r3, r8, r7
	add r3, r3, r9, ror #27
	eor r4, r4, r6
	eor r6, sl, fp
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp, #8]
	add r3, r3, r4
	eor r6, r6, ip
	add r3, r3, r6
	mov sl, sl, ror #2
	
	// Round 79
	ldr r6, [sp, #4]
	ldr r4, [sp, #60]
	ldr lr, [sp, #36]
	ldr r5, [sp, #16]
	add r8, ip, r7
	add r8, r8, r3, ror #27
	eor r6, r6, r4
	eor r4, r9, sl
	eor lr, lr, r5
	eor r6, r6, lr
	mov r6, r6, ror #31
	str r6, [sp, #4]
	add r8, r8, r6
	eor r4, r4, fp
	add r8, r8, r4
	mov r9, r9, ror #2
	
	// Round 80
	ldr r4, [sp]
	ldr r6, [sp, #56]
	ldr lr, [sp, #32]
	ldr r5, [sp, #12]
	add ip, fp, r7
	add ip, ip, r8, ror #27
	eor r4, r4, r6
	eor r6, r3, r9
	eor lr, lr, r5
	eor r4, r4, lr
	mov r4, r4, ror #31
	str r4, [sp]
	add ip, ip, r4
	eor r6, r6, sl
	add ip, ip, r6
	// Reload original values from ctx
	ldmia r0, {r4, r5, r6, fp, lr}
	mov r3, r3, ror #2
	
	// Add current values to original
	add fp, fp, r9
	add r9, r5, r8
	add r8, r4, ip
	add ip, lr, sl
	add sl, r6, r3
	mov r3, r8
	
	// Write back to ctx
	stmia r0, {r3, r9, sl, fp, ip}
	
	add sp, sp, #64
	
	// Decrement data length, loop again if we have more blocks
	subs r2, r2, #64
	bgt block_loop
	
	ldmia sp!, {r4, r5, r6, r7, r8, r9, sl, fp, ip, pc}
	
	.pool
	arm_func_end DGTi_hash2_arm4_fast
