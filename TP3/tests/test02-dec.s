	.data
	.eqv PrintChar, 11
	.eqv Exit, 10

e:	.string "."
o:	.string "---"
t:	.string "-"
s:	.string "..."
err1:	.string ".."
err2:	.string ".-."
err3:	.string ""

	.text
	la s0, miniMorse

	mv a0, s0
	la a1, s
	call decMorse
	li a7, PrintChar
	ecall   # Affiche 'S'

	mv a0, s0
	la a1, o
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, s
	call decMorse
	li a7, PrintChar
	ecall

	li a7, PrintChar
	li a0, ' '
	ecall

	mv a0, s0
	la a1, t
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, e
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, s
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, t
	call decMorse
	li a7, PrintChar
	ecall

	li a7, PrintChar
	li a0, ' '
	ecall

	mv a0, s0
	la a1, err1
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, err2
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, err3
	call decMorse
	li a7, PrintChar
	ecall

	li a7, Exit
	ecall

#stdout:SOS TEST ???
