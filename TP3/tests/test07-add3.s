	.data
	.eqv PrintChar, 11
	.eqv Exit, 10

e:	.string "."
o:	.string "---"
t:	.string "-"
s:	.string "..."
i:	.string ".."
vide:	.string ""

	.text
	# gère deux codes morses en parallèle qui ne doivent pas se mélanger

	la s0, miniMorse

	call newMorse
	mv s1, a0

	# ajoute la chaine vide aux deux
	mv a0, s0
	la a1, vide
	li a2, '@'
	call addMorse

	mv a0, s1
	la a1, vide
	li a2, '%'
	call addMorse

	# ajoute i aux deux
	mv a0, s0
	la a1, i
	li a2, 'I'
	call addMorse

	mv a0, s1
	la a1, i
	li a2, 'i'
	call addMorse

	mv a0, s0
	la a1, i
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s1
	la a1, i
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, vide
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s1
	la a1, vide
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, e
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s1
	la a1, e
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, t
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s1
	la a1, t
	call decMorse
	li a7, PrintChar
	ecall

	li a0, ' '
	ecall

	mv a0, s0
	call printMorse

	li a7, PrintChar
	li a0, ' '
	ecall

	mv a0, s1
	call printMorse

	li a7, Exit
	ecall

#stdout:Ii@%E?T? @EISTO %i
