	.data
	.eqv PrintChar, 11
	.eqv Exit, 10

e:	.string "."
o:	.string "---"
t:	.string "-"
s:	.string "..."
i:	.string ".."
r:	.string ".-."
err3:	.string ""
err4:	.string ".-"
err5:	.string ".-.."

	.text
	# étend le miniMorse, puis fais l'équivalent des tests 2 et 3
	la s0, miniMorse

	# ajoute R
	mv a0, s0
	la a1, r
	li a2, 'R'
	call addMorse

	# remplace E par 3, parce qu'on est 1337
	mv a0, s0
	la a1, e
	li a2, '3'
	call addMorse

	# supprime O
	mv a0, s0
	la a1, o
	li a2, '\0'
	call addMorse

	# ajoute I (1337)
	mv a0, s0
	la a1, i
	li a2, '1'
	call addMorse

	# test2
	mv a0, s0
	la a1, o
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, r
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, t
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, i
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

	li a7, PrintChar
	li a0, ' '
	ecall

	mv a0, s0
	la a1, err3
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, err4
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, err5
	call decMorse
	li a7, PrintChar
	ecall

	li a7, PrintChar
	li a0, ' '
	ecall

	# test 3
	mv a0, s0
	call printMorse

	li a7, Exit
	ecall

#stdout:?RT13S ??? 31SRT
