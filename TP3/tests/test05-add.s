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
	call newMorse
	mv s0, a0	# nouveau noeud vide

	mv a0, s0
	la a1, s
	li a2, 'S'
	call addMorse	# ajoute S

	mv a0, s0
	la a1, s
	call decMorse	# trouve S
	li a7, PrintChar
	ecall		# affiche S

	# fabrique le reste de ESTO, puis finis les tests 2 et 3

	mv a0, s0
	la a1, e
	li a2, 'E'
	call addMorse

	mv a0, s0
	la a1, o
	li a2, 'O'
	call addMorse

	mv a0, s0
	la a1, t
	li a2, 'T'
	call addMorse

	# test2

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

	li a7, PrintChar
	li a0, ' '
	ecall

	# test 3
	mv a0, s0
	call printMorse

	li a7, Exit
	ecall

#stdout:SOS TEST ??? ESTO
