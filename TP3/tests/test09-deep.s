	.data
	.eqv PrintChar, 11
	.eqv Exit, 10

x:	.string "...-..-.--.--...--.--.---.-...-.-..-.-.-.-."
y:	.string "...-..-.--.--...--.--.---.-..."
z:	.string "...-..-.--.--...--.--.---.-...-.--.-.-.-.-."
err1:	.string "...-..-.--.--...--.--.---.-"
err2:	.string "...-..-.--.--...--.--.---.-...-.----.-.-.-."

	.text
	la s0, miniMorse

	# ajoute x y et z

	mv a0, s0
	la a1, x
	li a2, 'X'
	call addMorse

	mv a0, s0
	la a1, y
	li a2, 'Y'
	call addMorse

	mv a0, s0
	la a1, z
	li a2, 'Z'
	call addMorse

	# cherche
	mv a0, s0
	la a1, x
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, y
	call decMorse
	li a7, PrintChar
	ecall

	mv a0, s0
	la a1, z
	call decMorse
	li a7, PrintChar
	ecall

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

	li a0, ' '
	ecall

	mv a0, s0
	call printMorse

	li a7, Exit
	ecall

#stdout:XYZ ?? ESYXZTO
