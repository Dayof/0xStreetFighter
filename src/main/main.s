#################################################################
#			Street Figther II			#
#################################################################
# Developers: Dayanne Fernandes					#
#################################################################
# Tools used:                                   		#
# 	Bitmap Display                         			#
#	Keyboard and Display MMIO Simulator     		#
#                                               		#
# Bitmap Display Settings:				  	#
#	Unit Width: ?                 			  	#
#	Unit Height: ?               			  	#
# 	Display Width: ?                                  	#
# 	Display Height: ?                                 	#
#	Base Address for Display: 0xFF000000 (Memory map) 	#
#################################################################

# MARS KEYBOARD AND DISPLAY MMIO SIMULATOR
.eqv READ_M	0xFF100004		# address to get char typed from keyboard
.eqv PRINT_M	0xFF10000C		# address to display char typed from keyboard

# FPGA PS2 INTERFACE 
.eqv KB1	0xFFFF0100		# PS2 Keyboard Buffer0
.eqv KB2	0xFFFF0104		# PS2 Keyboard Buffer1

.eqv K1		0xFF100520		# PS2 Keyboard KEY0
.eqv K2		0xFF100524		# PS2 Keyboard KEY1
.eqv K3		0xFF100528		# PS2 Keyboard KEY2
.eqv K4		0xFF10052C		# PS2 Keyboard KEY3

#.eqv LCD	0xFFFF0130		# LCD address

# KEYBOARD MAP
.eqv LEFT	0x1C000000		# 'a'
.eqv DOWN	0x1B000000		# 's'
.eqv RIGHT	0x23000000		# 'd'
.eqv UP		0x1D000000		# 'w'

.text

INIT:
	jal KEYBOARD
	j MAIN

KEYBOARD:
	la $s0,0xFF100100  	#BUFFER1
	la $s1,0xFF100104	#BUFFER2
	
	jr $ra

MAIN:
	lw $t0,0($s0)
	lw $t1,0($s1)
	
	sll $t2, $t0, 24
	sll $t3, $t1, 24

	# TEST TWO BUFFERS FROM KEYBOARD
	beq $t2, LEFT, 	EXIT		# wait for a 'a' character
	beq $t2, DOWN, 	EXIT		# wait for a 's' character
	beq $t2, RIGHT, EXIT		# wait for a 'd' character
	beq $t2, UP, 	EXIT		# wait for a 'w' character
	
	beq $t3, LEFT, 	EXIT		# wait for a 'a' character
	beq $t3, DOWN, 	EXIT		# wait for a 's' character
	beq $t3, RIGHT, EXIT		# wait for a 'd' character
	beq $t3, UP, 	EXIT		# wait for a 'w' character
	
	j MAIN

EXIT:
	nop
