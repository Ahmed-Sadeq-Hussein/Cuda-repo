	.arch armv8-a
	.file	"multiply.c"
	.text
	.align	2
	.global	mult_std
	.type	mult_std, %function
mult_std:
	sub	sp, sp, #48
	str	x0, [sp, 24]
	str	x1, [sp, 16]
	str	x2, [sp, 8]
	str	w3, [sp, 4]
	str	wzr, [sp, 44]
	b	.L2
.L3:
	ldrsw	x0, [sp, 44]
	lsl	x0, x0, 2
	ldr	x1, [sp, 24]
	add	x0, x1, x0
	ldr	s1, [x0]
	ldrsw	x0, [sp, 44]
	lsl	x0, x0, 2
	ldr	x1, [sp, 16]
	add	x0, x1, x0
	ldr	s0, [x0]
	ldrsw	x0, [sp, 44]
	lsl	x0, x0, 2
	ldr	x1, [sp, 8]
	add	x0, x1, x0
	fmul	s0, s1, s0
	str	s0, [x0]
	ldr	w0, [sp, 44]
	add	w0, w0, 1
	str	w0, [sp, 44]
.L2:
	ldr	w1, [sp, 44]
	ldr	w0, [sp, 4]
	cmp	w1, w0
	blt	.L3
	nop
	add	sp, sp, 48
	ret
	.size	mult_std, .-mult_std
	.align	2
	.global	mult_vect
	.type	mult_vect, %function
mult_vect:
	sub	sp, sp, #160
	str	x0, [sp, 24]
	str	x1, [sp, 16]
	str	x2, [sp, 8]
	str	w3, [sp, 4]
	str	wzr, [sp, 36]
	b	.L5
.L9:
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 2
	ldr	x1, [sp, 24]
	add	x0, x1, x0
	str	x0, [sp, 56]
	ldr	x0, [sp, 56]
	ldr	q0, [x0]
	str	q0, [sp, 64]
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 2
	ldr	x1, [sp, 16]
	add	x0, x1, x0
	str	x0, [sp, 48]
	ldr	x0, [sp, 48]
	ldr	q0, [x0]
	str	q0, [sp, 80]
	ldr	q0, [sp, 64]
	str	q0, [sp, 128]
	ldr	q0, [sp, 80]
	str	q0, [sp, 144]
	ldr	q1, [sp, 128]
	ldr	q0, [sp, 144]
	fmul	v0.4s, v1.4s, v0.4s
	str	q0, [sp, 96]
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 2
	ldr	x1, [sp, 8]
	add	x0, x1, x0
	str	x0, [sp, 40]
	ldr	q0, [sp, 96]
	str	q0, [sp, 112]
	ldr	x0, [sp, 40]
	ldr	q0, [sp, 112]
	str	q0, [x0]
	ldr	w0, [sp, 36]
	add	w0, w0, 4
	str	w0, [sp, 36]
.L5:
	ldr	w1, [sp, 36]
	ldr	w0, [sp, 4]
	cmp	w1, w0
	blt	.L9
	nop
	add	sp, sp, 160
	ret
	.size	mult_vect, .-mult_vect
	.section	.rodata
	.align	3
.LC1:
	.string	"Elapsed time std: %f\n"
	.align	3
.LC2:
	.string	"Elapsed time vec: %f\n"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
	stp	x29, x30, [sp, -144]!
	add	x29, sp, 0
	str	w0, [x29, 28]
	str	x1, [x29, 16]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [x29, 136]
	mov	x1,0
	mov	w0, 57600
	movk	w0, 0x5f5, lsl 16
	str	w0, [x29, 44]
	ldrsw	x0, [x29, 44]
	lsl	x0, x0, 2
	mov	x1, x0
	mov	x0, 16
	bl	aligned_alloc
	str	x0, [x29, 48]
	ldrsw	x0, [x29, 44]
	lsl	x0, x0, 2
	mov	x1, x0
	mov	x0, 16
	bl	aligned_alloc
	str	x0, [x29, 56]
	ldrsw	x0, [x29, 44]
	lsl	x0, x0, 2
	mov	x1, x0
	mov	x0, 16
	bl	aligned_alloc
	str	x0, [x29, 64]
	str	wzr, [x29, 40]
	b	.L11
.L12:
	ldr	w0, [x29, 40]
	mov	w1, 1033
	movk	w1, 0x8102, lsl 16
	smull	x1, w0, w1
	lsr	x1, x1, 32
	add	w1, w0, w1
	asr	w2, w1, 6
	asr	w1, w0, 31
	sub	w2, w2, w1
	mov	w1, w2
	lsl	w1, w1, 7
	sub	w1, w1, w2
	sub	w2, w0, w1
	scvtf	s0, w2
	ldrsw	x0, [x29, 40]
	lsl	x0, x0, 2
	ldr	x1, [x29, 48]
	add	x0, x1, x0
	mov	w1, 12897
	movk	w1, 0x3e15, lsl 16
	fmov	s1, w1
	fmul	s0, s0, s1
	str	s0, [x0]
	ldr	w1, [x29, 40]
	mov	w0, 40193
	movk	w0, 0x317f, lsl 16
	smull	x0, w1, w0
	lsr	x0, x0, 32
	asr	w2, w0, 6
	asr	w0, w1, 31
	sub	w0, w2, w0
	mov	w2, 331
	mul	w0, w0, w2
	sub	w0, w1, w0
	scvtf	s0, w0
	ldrsw	x0, [x29, 40]
	lsl	x0, x0, 2
	ldr	x1, [x29, 56]
	add	x0, x1, x0
	mov	w1, 7130
	movk	w1, 0x3dfc, lsl 16
	fmov	s1, w1
	fmul	s0, s0, s1
	str	s0, [x0]
	ldr	w0, [x29, 40]
	add	w0, w0, 1
	str	w0, [x29, 40]
.L11:
	ldr	w1, [x29, 40]
	ldr	w0, [x29, 44]
	cmp	w1, w0
	blt	.L12
	add	x0, x29, 88
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	ldr	w3, [x29, 44]
	ldr	x2, [x29, 64]
	ldr	x1, [x29, 56]
	ldr	x0, [x29, 48]
	bl	mult_std
	add	x0, x29, 104
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	ldr	w3, [x29, 44]
	ldr	x2, [x29, 64]
	ldr	x1, [x29, 56]
	ldr	x0, [x29, 48]
	bl	mult_vect
	add	x0, x29, 120
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	ldr	x1, [x29, 104]
	ldr	x0, [x29, 88]
	sub	x0, x1, x0
	scvtf	d1, x0
	ldr	x1, [x29, 112]
	ldr	x0, [x29, 96]
	sub	x0, x1, x0
	scvtf	d2, x0
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	ldr	d0, [x0]
	fmul	d0, d2, d0
	fadd	d0, d1, d0
	str	d0, [x29, 72]
	ldr	x1, [x29, 120]
	ldr	x0, [x29, 104]
	sub	x0, x1, x0
	scvtf	d1, x0
	ldr	x1, [x29, 128]
	ldr	x0, [x29, 112]
	sub	x0, x1, x0
	scvtf	d2, x0
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	ldr	d0, [x0]
	fmul	d0, d2, d0
	fadd	d0, d1, d0
	str	d0, [x29, 80]
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	ldr	d0, [x29, 72]
	bl	printf
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	ldr	d0, [x29, 80]
	bl	printf
	ldr	x0, [x29, 48]
	bl	free
	ldr	x0, [x29, 56]
	bl	free
	ldr	x0, [x29, 64]
	bl	free
	mov	w0, 0
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, #:got_lo12:__stack_chk_guard]
	ldr	x2, [x29, 136]
	ldr	x1, [x1]
	eor	x1, x2, x1
	cmp	x1, 0
	beq	.L14
	bl	__stack_chk_fail
.L14:
	ldp	x29, x30, [sp], 144
	ret
	.size	main, .-main
	.section	.rodata
	.align	3
.LC0:
	.word	3894859413
	.word	1041313291
	.text
	.ident	"GCC: (Ubuntu/Linaro 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
