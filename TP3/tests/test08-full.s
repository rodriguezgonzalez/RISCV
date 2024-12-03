	.data
	.eqv PrintChar, 11
	.eqv Exit, 10

code_A:	.string ".-"	# caractère 'A'
code_B:	.string "-..."	# caractère 'B'
code_C:	.string "-.-."	# caractère 'C'
code_D:	.string "-.."	# caractère 'D'
code_E:	.string "."	# caractère 'E'
code_F:	.string "..-."	# caractère 'F'
code_G:	.string "--."	# caractère 'G'
code_H:	.string "...."	# caractère 'H'
code_I:	.string ".."	# caractère 'I'
code_J:	.string ".---"	# caractère 'J'
code_K:	.string "-.-"	# caractère 'K'
code_L:	.string ".-.."	# caractère 'L'
code_M:	.string "--"	# caractère 'M'
code_N:	.string "-."	# caractère 'N'
code_O:	.string "---"	# caractère 'O'
code_P:	.string ".--."	# caractère 'P'
code_Q:	.string "--.-"	# caractère 'Q'
code_R:	.string ".-."	# caractère 'R'
code_S:	.string "..."	# caractère 'S'
code_T:	.string "-"	# caractère 'T'
code_U:	.string "..-"	# caractère 'U'
code_V:	.string "...-"	# caractère 'V'
code_W:	.string ".--"	# caractère 'W'
code_X:	.string "-..-"	# caractère 'X'
code_Y:	.string "-.--"	# caractère 'Y'
code_Z:	.string "--.."	# caractère 'Z'
code_x20:	.string "-.-.-.-"	# caractère ' '
code_x2c:	.string "--..--"	# caractère ','
code_x3a:	.string "---..."	# caractère ':'
code_x3b:	.string "-.-.-."	# caractère ';'
code_x2e:	.string ".-.-.-"	# caractère '.'
code_x22:	.string ".-..-."	# caractère '"'
code_x28:	.string "-----."	# caractère '('
code_x29:	.string ".-----"	# caractère ')'
code_x27:	.string "-.--.-"	# caractère '\''
code_1:	.string ".----"	# caractère '1'
code_2:	.string "..---"	# caractère '2'
code_3:	.string "...--"	# caractère '3'
code_4:	.string "....-"	# caractère '4'
code_5:	.string "....."	# caractère '5'
code_6:	.string "-...."	# caractère '6'
code_7:	.string "--..."	# caractère '7'
code_8:	.string "---.."	# caractère '8'
code_9:	.string "----."	# caractère '9'
code_0:	.string "-----"	# caractère '0'

	.text
	la s0, miniMorse
	mv a0, s0
	la a1, code_A
	li a2, 'A'
	call addMorse
	mv a0, s0
	la a1, code_B
	li a2, 'B'
	call addMorse
	mv a0, s0
	la a1, code_C
	li a2, 'C'
	call addMorse
	mv a0, s0
	la a1, code_D
	li a2, 'D'
	call addMorse
	mv a0, s0
	la a1, code_E
	li a2, 'E'
	call addMorse
	mv a0, s0
	la a1, code_F
	li a2, 'F'
	call addMorse
	mv a0, s0
	la a1, code_G
	li a2, 'G'
	call addMorse
	mv a0, s0
	la a1, code_H
	li a2, 'H'
	call addMorse
	mv a0, s0
	la a1, code_I
	li a2, 'I'
	call addMorse
	mv a0, s0
	la a1, code_J
	li a2, 'J'
	call addMorse
	mv a0, s0
	la a1, code_K
	li a2, 'K'
	call addMorse
	mv a0, s0
	la a1, code_L
	li a2, 'L'
	call addMorse
	mv a0, s0
	la a1, code_M
	li a2, 'M'
	call addMorse
	mv a0, s0
	la a1, code_N
	li a2, 'N'
	call addMorse
	mv a0, s0
	la a1, code_O
	li a2, 'O'
	call addMorse
	mv a0, s0
	la a1, code_P
	li a2, 'P'
	call addMorse
	mv a0, s0
	la a1, code_Q
	li a2, 'Q'
	call addMorse
	mv a0, s0
	la a1, code_R
	li a2, 'R'
	call addMorse
	mv a0, s0
	la a1, code_S
	li a2, 'S'
	call addMorse
	mv a0, s0
	la a1, code_T
	li a2, 'T'
	call addMorse
	mv a0, s0
	la a1, code_U
	li a2, 'U'
	call addMorse
	mv a0, s0
	la a1, code_V
	li a2, 'V'
	call addMorse
	mv a0, s0
	la a1, code_W
	li a2, 'W'
	call addMorse
	mv a0, s0
	la a1, code_X
	li a2, 'X'
	call addMorse
	mv a0, s0
	la a1, code_Y
	li a2, 'Y'
	call addMorse
	mv a0, s0
	la a1, code_Z
	li a2, 'Z'
	call addMorse
	mv a0, s0
	la a1, code_x20
	li a2, ' '
	call addMorse
	mv a0, s0
	la a1, code_x2c
	li a2, ','
	call addMorse
	mv a0, s0
	la a1, code_x3a
	li a2, ':'
	call addMorse
	mv a0, s0
	la a1, code_x3b
	li a2, ';'
	call addMorse
	mv a0, s0
	la a1, code_x2e
	li a2, '.'
	call addMorse
	mv a0, s0
	la a1, code_x22
	li a2, '"'
	call addMorse
	mv a0, s0
	la a1, code_x28
	li a2, '('
	call addMorse
	mv a0, s0
	la a1, code_x29
	li a2, ')'
	call addMorse
	mv a0, s0
	la a1, code_x27
	li a2, '\''
	call addMorse
	mv a0, s0
	la a1, code_1
	li a2, '1'
	call addMorse
	mv a0, s0
	la a1, code_2
	li a2, '2'
	call addMorse
	mv a0, s0
	la a1, code_3
	li a2, '3'
	call addMorse
	mv a0, s0
	la a1, code_4
	li a2, '4'
	call addMorse
	mv a0, s0
	la a1, code_5
	li a2, '5'
	call addMorse
	mv a0, s0
	la a1, code_6
	li a2, '6'
	call addMorse
	mv a0, s0
	la a1, code_7
	li a2, '7'
	call addMorse
	mv a0, s0
	la a1, code_8
	li a2, '8'
	call addMorse
	mv a0, s0
	la a1, code_9
	li a2, '9'
	call addMorse
	mv a0, s0
	la a1, code_0
	li a2, '0'
	call addMorse

	# décodage
	mv a0, s0
	la a1, code_A
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_B
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_C
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_D
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_E
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_F
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_G
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_H
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_I
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_J
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_K
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_L
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_M
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_N
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_O
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_P
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_Q
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_R
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_S
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_T
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_U
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_V
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_W
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_X
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_Y
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_Z
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x20
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x2c
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x3a
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x3b
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x2e
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x22
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x28
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x29
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_x27
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_1
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_2
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_3
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_4
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_5
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_6
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_7
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_8
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_9
	call decMorse
	li a7, PrintChar
	ecall
	mv a0, s0
	la a1, code_0
	call decMorse
	li a7, PrintChar
	ecall
	li a7, PrintChar
	li a0, '\n'
	ecall

	# affichage
	mv a0, s0
	call printMorse

	li a7, Exit
	ecall

#stdout:ABCDEFGHIJKLMNOPQRSTUVWXYZ ,:;."()'1234567890\nEISH54V3UF2ARL".WPJ1)TNDB6XKC; Y'MGZ7,QO8:90(
