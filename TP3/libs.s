# LibS: useful io functions and system call wrappers

.global exit
.weak exit	# Allow to compile with gcc and --static
.global readInt
.global printInt
.global readChar
.global printChar
.global readString
.global printString
.global strlen
.global printf

# Linux syscall numbers
.eqv Read, 63
.eqv Write, 64
.eqv Exit, 93

.text
# exit #######################################################
li a0, 127 # Put exit here, so if PC reach this part from above, the program will exit(127)
exit:
li a7, Exit
ecall


# readInt ####################################################
	# IN: nothing
	# OUT: a0 number read from the standard input
readInt:
	# Stack pushes
	addi sp, sp, -24
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	# 
	li a0, 0 # numeric value
	li s1, 0 # negative sign
	li s0, 0 # current number
	jal readChar
	li t0, '-'
	bne a0, t0, riLoop
	li s1, 1
	jal readChar
riLoop:
	addi a0, a0, -0x30 # '0'
	li t0, 9
	bgtu a0, t0, riEnd
	li t0, 10
	mul s0, s0, t0
	add s0, s0, a0
	jal readChar
	j riLoop
riEnd:
	# note: last non digit character read is lost.
	mv a0, s0
	beqz s1, riRet
	neg a0, a0
riRet:	
	# Stack pops
	ld s1, 16(sp)
	ld s0, 8(sp)
	ld ra, 0(sp)
	addi sp, sp, 24
	ret
	
	

# printInt ######################################################
	# IN: a0 integer number to print
	# OUT: nothing
.data
	.space 24 # Enough space for longest string "-9223372036854775808" (assume 64bits)
wiStr: # Lablel is put after as we go backward
.text
printInt:
	# Prepare output buffer
	la a1, wiStr # Current buffer cursor
	mv a2, a1 # Original buffer (to compite length)
	mv a3, a0 # Current value (keep original a0 for sign prepend)
	li t0, 10 # Radix
	# Need absolute value (assume unsigned result to avoid overflow)
	bgez a3, wiLoop
	neg a3, a3
	
wiLoop: # Main loop that divide by radix each step
	remu t2, a3, t0
	divu a3, a3, t0
	addi t2, t2, '0' # Compute character
	addi a1, a1, -1 # Update the output buffer
	sb t2, (a1)
	bnez a3, wiLoop # Manage next. Note: it's a 'do-until' loop to handle the 0 valu
	# Prepend sign if needed (check original number)
	bgez a0, wiOutput
	li t2, '-'
	addi a1, a1, -1
	sb t2, (a1)

wiOutput: # Output the buffer
	li a7, Write
	li a0, 1 # stdout
	# a1 is already correct
	sub a2, a2, a1 # Compute used buffer length
	ecall
	ret

.data
cBuffer: .space 1 # 1 char needed
.text

# readChar ##################################################################
	# IN: nothing
	# OUT: a0 read char, or -1 if end of file or error
readChar:
	li a7, Read
	li a0, 0 # Stdin
	la a1, cBuffer
	li a2, 1
	ecall
	blez a0, rcEof
	lb a0, (a1)
	ret
rcEof:
	li a0, -1
	ret

# printChar #################################################################
	# IN: a0 char to print
	# OUT: nothing
printChar:
	la a1, cBuffer
	sb a0, (a1)
	li a7, Write
	li a0, 1 # Stdout
	# a1 is good
	li a2, 1
	ecall
	ret

# readString ################################################################
	# IN: a0 address of a buffer
	#     a1 size of a buffer (unsigned)
	# read up to a1-1 bytes in a0. Stops on '\n' (included) or EOF or error.
	# add a '\0' at the end
readString:
	# Stack pushes
	addi sp, sp, -32
	sd s2, 24(sp)
	sd s1, 16(sp)
	sd s0, 8(sp)
	sd ra, 0(sp)
	mv s0, a0 # current pointer
	mv s2, a0 # initial pointer
	add s1, a0, a1 # stop pointer
	addi s1, s1, -1 # account room for '\0'
rlLoop:
	bge s0, s1, rlEnd # break if not enough space
	jal readChar
	bltz a0, rlEnd # break if EOF
	sb a0, 0(s0) # Store next character
	addi s0, s0, 1
	li t0, '\n'
	bne a0, t0, rlLoop # break if '\n'
rlEnd:
	sb zero, 0(s0) # append '\0'
	sub a0, s0, s2 # size used (including '\0')
	# Stack pops
	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	addi sp, sp, 32
	ret

# strlen ##################################################################
	# IN: a0 address of a nul-terminated string
	# OUT: number (unsigned) of bytes before '\0' (excluded)
strlen:
	mv a1, a0 # Remember original pointer
slLoop:
	lb a3, (a0) # while *a0 != '\0' { a0++ }
	beqz a3, slEnd
	addi a0, a0, 1
	j slLoop
slEnd:
	sub a0, a0, a1 # Compute length
	ret

# printString ##############################################################
	# IN: a0 address of a nul-terminated string
printString:
	# Stack pushes
	addi sp, sp, -16
	sd s0, 8(sp)
	sd ra, 0(sp)
	#
	mv s0, a0
	jal strlen
	mv a2, a0
	li a7, Write
	li a0, 1 # stdout
	mv a1, s0
	# a2 is good
	ecall
	mv a0, a1 # Restore a0
	# Stack pops
	ld ra, 0(sp)
	ld s0, 8(sp)
	addi sp, sp, 16
	ret

# printf ####################################################################
	# IN: a0 string format
	#     a1 to a7 variable argument
	# OUT: nothing
	# Currently only handle %d and %s for now
	# Note: use unbuffered printChar, that could be improved
printf:
	# Stack pushes
	addi sp, sp, -72
	sd s7, 64(sp)
	sd s6, 56(sp)
	sd s5, 48(sp)
	sd s4, 40(sp)
	sd s3, 32(sp)
	sd s2, 24(sp)
	sd s1, 16(sp)
	sd s0, 8(sp)
	sd ra, 0(sp)
	# Save all potential arguents
	mv s0, a0
	mv s1, a1
	mv s2, a2
	mv s3, a3
	mv s4, a4
	mv s5, a5
	mv s6, a6
	mv s7, a7
pfLoop:
	lb a0, (s0) # Next char
	addi s0, s0, 1
	beqz a0, pfEnd # break if '\0'
	li t0, '%' # Special if '%'
	beq a0, t0, pfPercent
	jal printChar # Just display the character otherwise
	j pfLoop
pfPercent:
	lb a0, (s0) # Next char (format expected)
	addi s0, s0, 1
	beqz a0, pfEnd # break if '\0' (% is lost)
	li t0, 'd'
	beq a0, t0, pfDecimal
	li t0, 's'
	beq a0, t0, pfString
	# Ignore format character and display single %
	li a0, '%'
	jal printChar
	j pfShift
pfDecimal:
	mv a0, s1
	jal printInt
	j pfShift
pfString:
	mv a0, s1
	jal printString
	j pfShift
pfShift: # Consume s1 and shift all the other ones
	mv s1, s2
	mv s2, s3
	mv s3, s4
	mv s4, s5
	mv s5, s6
	mv s6, s7
	li s7, 0
	j pfLoop
pfEnd:
	# Stack pops
	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	ld s3, 32(sp)
	ld s4, 40(sp)
	ld s5, 48(sp)
	ld s6, 56(sp)
	ld s7, 64(sp)
	addi sp, sp, 72
	ret
