	.arch armv8-a
	.file	"multiply.c"
	.text
	.align	2
	.global	mult_std
	.type	mult_std, %function
mult_std:
	cmp	w3, 0
	ble	.L1
	mov	x4, 0
.L3:
	ldr	s0, [x0, x4, lsl 2]
	ldr	s1, [x1, x4, lsl 2]
	fmul	s0, s0, s1
	str	s0, [x2, x4, lsl 2]
	add	x4, x4, 1
	cmp	w3, w4
	bgt	.L3
.L1:
	ret
	.size	mult_std, .-mult_std
	.align	2
	.global	mult_vect
	.type	mult_vect, %function
mult_vect:
	cmp	w3, 0
	ble	.L5
	mov	w4, 0
.L7:
	sbfiz	x5, x4, 2, 32
	ldr	q1, [x0, x5]
	ldr	q0, [x1, x5]
	fmul	v0.4s, v0.4s, v1.4s
	str	q0, [x2, x5]
	add	w4, w4, 4
	cmp	w3, w4
	bgt	.L7
.L5:
	ret
	.size	mult_vect, .-mult_vect
	.align	2
	.global	main
	.type	main, %function
main:
	stp	x29, x30, [sp, -128]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	str	d8, [sp, 48]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [x29, 120]
	mov	x1,0
	mov	x21, 33792
	movk	x21, 0x17d7, lsl 16
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x20, x0
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x19, x0
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x21, x0
	mov	x1, 0
	mov	w8, 1033
	movk	w8, 0x8102, lsl 16
	adrp	x0, .LC3
	ldr	s2, [x0, #:lo12:.LC3]
	mov	w7, 40193
	movk	w7, 0x317f, lsl 16
	mov	w6, 331
	adrp	x0, .LC4
	ldr	s1, [x0, #:lo12:.LC4]
	mov	x5, 57600
	movk	x5, 0x5f5, lsl 16
.L10:
	smull	x2, w1, w8
	lsr	x2, x2, 32
	add	w2, w2, w1
	asr	w2, w2, 6
	asr	w4, w1, 31
	sub	w2, w2, w4
	lsl	w3, w2, 7
	sub	w2, w3, w2
	sub	w2, w1, w2
	scvtf	s0, w2
	fmul	s0, s0, s2
	str	s0, [x20, x1, lsl 2]
	smull	x0, w1, w7
	asr	x0, x0, 38
	sub	w0, w0, w4
	msub	w0, w0, w6, w1
	scvtf	s0, w0
	fmul	s0, s0, s1
	str	s0, [x19, x1, lsl 2]
	add	x1, x1, 1
	cmp	x1, x5
	bne	.L10
	add	x1, x29, 72
	mov	w0, 1
	bl	clock_gettime
	mov	w22, 57600
	movk	w22, 0x5f5, lsl 16
	mov	w3, w22
	mov	x2, x21
	mov	x1, x19
	mov	x0, x20
	bl	mult_std
	add	x1, x29, 88
	mov	w0, 1
	bl	clock_gettime
	mov	w3, w22
	mov	x2, x21
	mov	x1, x19
	mov	x0, x20
	bl	mult_vect
	add	x1, x29, 104
	mov	w0, 1
	bl	clock_gettime
	ldr	x2, [x29, 88]
	ldr	x1, [x29, 96]
	ldr	x0, [x29, 112]
	sub	x0, x0, x1
	scvtf	d8, x0
	adrp	x0, .LC0
	ldr	d1, [x0, #:lo12:.LC0]
	fmul	d8, d8, d1
	ldr	x0, [x29, 104]
	sub	x0, x0, x2
	scvtf	d0, x0
	fadd	d8, d8, d0
	ldr	x0, [x29, 80]
	sub	x1, x1, x0
	scvtf	d0, x1
	fmul	d0, d0, d1
	ldr	x0, [x29, 72]
	sub	x2, x2, x0
	scvtf	d1, x2
	fadd	d0, d0, d1
	adrp	x1, .LC1
	add	x1, x1, :lo12:.LC1
	mov	w0, 1
	bl	__printf_chk
	fmov	d0, d8
	adrp	x1, .LC2
	add	x1, x1, :lo12:.LC2
	mov	w0, 1
	bl	__printf_chk
	mov	x0, x20
	bl	free
	mov	x0, x19
	bl	free
	mov	x0, x21
	bl	free
	mov	w0, 0
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, #:got_lo12:__stack_chk_guard]
	ldr	x2, [x29, 120]
	ldr	x1, [x1]
	eor	x1, x2, x1
	cbnz	x1, .L14
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	d8, [sp, 48]
	ldp	x29, x30, [sp], 128
	ret
.L14:
	bl	__stack_chk_fail
	.size	main, .-main
	.section	.rodata.cst8,"aM",@progbits,8
	.align	3
.LC0:
	.word	3894859413
	.word	1041313291
	.section	.rodata.cst4,"aM",@progbits,4
	.align	2
.LC3:
	.word	1041576545
	.align	2
.LC4:
	.word	1039932378
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC1:
	.string	"Elapsed time std: %f\n"
	.zero	2
.LC2:
	.string	"Elapsed time vec: %f\n"
	.ident	"GCC: (Ubuntu/Linaro 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
