#include <asm/macros/function.inc>	
	.text

bswap_const:
	.word 0x00FF00FF

round1_const:
	.word 0x5A827999

round2_const:
	.word 0x6ED9EBA1

round3_const:
	.word 0x8F1BBCDC

round4_const:
	.word 0xCA62C1D6


	// r0 = DGTHash2Context ctx
	// r1 = message data pointer, 4-aligned
	// r2 = number of blocks, multiple of 64
	arm_func_start DGTi_hash2_arm4_small
DGTi_hash2_arm4_small:
	stmdb sp!, {r4, r5, r6, r7, r8, r9, sl, fp, ip, lr}
	
	// State variables from ctx
	ldmia r0, {r3, r9, sl, fp, ip}
	
	// Stack space used for message expansion and block count
	sub sp, sp, #132
	str r2, [sp, #128]
	
block_loop:
	// Magic round constant 1 (for rounds 1-20)
	ldr r8, round1_const
	
	// Value for executing byteswaps (data words must be in Big-Endian)
	ldr r7, bswap_const
	mov r6, sp
	
	// First 16 rounds use the original data words
	// Data is read from r1, then byte swapped
	// Rounds 17-80 use values derived from these data words, so save them on the stack
	mov r5, #0
round_1_16_loop:
	ldr r4, [r1], #4
	add r2, r8, ip
	add r2, r2, r3, ror #27
	and lr, r4, r7
	and r4, r7, r4, ror #24
	orr r4, r4, lr, ror #8
	str r4, [r6, #64]
	str r4, [r6], #4
	add r2, r2, r4
	eor r4, sl, fp
	and r4, r4, r9
	eor r4, r4, fp
	add r2, r2, r4
	mov r9, r9, ror #2
	
	mov ip, fp
	mov fp, sl
	mov sl, r9
	mov r9, r3
	mov r3, r2
	add r5, r5, #4
	cmp r5, #64
	blt round_1_16_loop
	
	// Rounds 17-20 are the same procedure as rounds 1-16, but we must use the expanded words
	// Four words are loaded off the stack, xor-ed together, and rotated
	mov r7, #0
	mov r6, sp
round_17_20_loop:
	ldr r2, [r6]
	ldr r5, [r6, #8]
	ldr r4, [r6, #32]
	ldr lr, [r6, #52]
	eor r2, r2, r5
	eor r4, r4, lr
	eor r2, r2, r4
	mov r2, r2, ror #31
	str r2, [r6, #64]
	str r2, [r6], #4
	add r2, r2, ip
	add r2, r2, r8
	add r2, r2, r3, ror #27
	eor r4, sl, fp
	and r4, r4, r9
	eor r4, r4, fp
	add r2, r2, r4
	mov r9, r9, ror #2
	
	mov ip, fp
	mov fp, sl
	mov sl, r9
	mov r9, r3
	mov r3, r2
	
	add r7, r7, #4
	cmp r7, #16
	blt round_17_20_loop
	
	// Rounds 21-40
	ldr r8, round2_const
	mov r7, #0
round_21_40_loop:
	ldr r2, [r6]
	ldr r4, [r6, #8]
	ldr lr, [r6, #32]
	ldr r5, [r6, #52]
	eor r2, r2, r4
	eor lr, lr, r5
	eor r2, r2, lr
	mov r2, r2, ror #31
	str r2, [r6, #64]
	str r2, [r6], #4
	add r2, r2, ip
	add r2, r2, r8
	add r2, r2, r3, ror #27
	eor lr, r9, sl
	eor lr, lr, fp
	add r2, r2, lr
	mov r9, r9, ror #2
	
	mov ip, fp
	mov fp, sl
	mov sl, r9
	mov r9, r3
	mov r3, r2
	
	add r7, r7, #1
	cmp r7, #12
	moveq r6, sp
	cmp r7, #20
	blt round_21_40_loop
	
	// Rounds 41-60
	ldr r8, round3_const
	mov r7, #0
round_41_60_loop:
	ldr r2, [r6]
	ldr lr, [r6, #8]
	ldr r5, [r6, #32]
	ldr r4, [r6, #52]
	eor r2, r2, lr
	eor r5, r5, r4
	eor r2, r2, r5
	mov r2, r2, ror #31
	str r2, [r6, #64]
	str r2, [r6], #4
	add r2, r2, ip
	add r2, r2, r8
	add r2, r2, r3, ror #27
	orr r5, r9, sl
	and r5, r5, fp
	and r4, r9, sl
	orr r5, r5, r4
	add r2, r2, r5
	mov r9, r9, ror #2
	
	mov ip, fp
	mov fp, sl
	mov sl, r9
	mov r9, r3
	mov r3, r2
	
	add r7, r7, #1
	cmp r7, #8
	moveq r6, sp
	cmp r7, #20
	blt round_41_60_loop
	
	// rounds 61-80
	ldr r8, round4_const
	mov r7, #0
round_61_80_loop:
	ldr r2, [r6]
	ldr r5, [r6, #8]
	ldr r4, [r6, #32]
	ldr lr, [r6, #52]
	eor r2, r2, r5
	eor r4, r4, lr
	eor r2, r2, r4
	mov r2, r2, ror #31
	str r2, [r6, #64]
	str r2, [r6], #4
	add r2, r2, ip
	add r2, r2, r8
	add r2, r2, r3, ror #27
	eor r4, r9, sl
	eor r4, r4, fp
	add r2, r2, r4
	mov r9, r9, ror #2
	
	mov ip, fp
	mov fp, sl
	mov sl, r9
	mov r9, r3
	mov r3, r2
	
	add r7, r7, #1
	cmp r7, #4
	moveq r6, sp
	cmp r7, #20
	blt round_61_80_loop
	
	// Reload original values from ctx
	ldmia r0, {r2, r4, r6, r7, lr}
	
	// Add current values to original
	add r3, r3, r2
	add r9, r9, r4
	add sl, sl, r6
	add fp, fp, r7
	add ip, ip, lr
	
	// Write back to ctx
	stmia r0, {r3, r9, sl, fp, ip}
	
	// Decrement data length, loop again if we have more blocks
	ldr lr, [sp, #128]
	subs lr, lr, #64
	str lr, [sp, #128]
	bgt block_loop
	
	add sp, sp, #132
	ldmia sp!,  {r4, r5, r6, r7, r8, r9, sl, fp, ip, pc}
	
	.pool
	arm_func_end DGTi_hash2_arm4_small
