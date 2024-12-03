	.eqv Exit, 10

	la a0, miniMorse
	jal printMorseLong

	li a7, Exit
	ecall

#stdout:E .\nS ...\nT -\nO ---
