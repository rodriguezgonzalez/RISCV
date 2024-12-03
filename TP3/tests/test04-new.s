	.data
	.eqv Exit, 10
	.eqv PrintString, 4
	.eqv PrintChar, 11

s:	.string "..."
okmsg:	.string "ok"
failmsg:.string "fail"

	.text
	call newMorse
	mv s0, a0	# Noeud morse vide

	mv a0, s0
	la a1, s
	call decMorse	# trouve rien, car le noeud est vide
	li a7, PrintChar
	ecall # Donc affiche '?'

	mv a0, s0
	call printMorse # affiche rien, car le noeud est vide

	# Organisation mémoire RARS par défaut
	li s10, 0x10040000	# début du tas
	li s11, 0x10100000	# fin raisonnable du tas

	blt s0, s10, fail
	bge s0, s11, fail

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

#stdout:?ok
