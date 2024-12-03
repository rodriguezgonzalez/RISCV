	.data
	.eqv Exit, 10
	.eqv PrintString, 4

okmsg:	.string "ok"
failmsg:.string "fail"

	.text
	# Organisation mémoire RARS par défaut
	li s10, 0x10010000	# début de DATA
	li s11, 0x10040000	# début du tas

	la s1, miniMorse # noeud 1 (racine)

	lbu a0, 0(s1)	# doit être '\0'
	bnez a0, fail

	ld s2, 8(s1)	# noeud 2
	lbu a0, 0(s2)	# doit être 'E'
	li t0, 'E'
	bne a0, t0, fail

	ld a0, 16(s2)	# doit être 0 (null)
	bnez a0, fail

	# s1 doit être dans DATA
	blt s1, s10, fail
	bge s1, s11, fail

	# s2 aussi
	blt s2, s10, fail
	bge s2, s11, fail

	li a7, PrintString
	la a0, okmsg
	ecall
	j fin

fail:
	li a7, PrintString
	la a0, failmsg
	ecall

fin:
	li a7, Exit
	ecall

#stdout:ok

