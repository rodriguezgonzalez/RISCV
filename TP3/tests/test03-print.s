	.eqv Exit, 10

	la a0, miniMorse
	call printMorse # affiche "ESTO"

	li a7, Exit
	ecall

#stdout:ESTO
