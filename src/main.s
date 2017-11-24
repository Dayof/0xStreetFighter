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
#################################################################

#################### MARS INTERFACE ADDRESSES ################### 
# KEYBOARD AND DISPLAY MMIO SIMULATOR
.eqv READ_M	0xFF100004		# Address to get char typed from keyboard
.eqv PRINT_M	0xFF10000C		# Address to display char typed from keyboard

#################### FPGA INTERFACE ADDRESSES ################### 
# LCD INTERFACE 
.eqv LCD	0xFFFF0130		# LCD address

# VGA INTERFACE 
.eqv VGA	0xFF000000		# VGA init address

# PS2 INTERFACE 
.eqv KB1	0xFFFF0100		# PS2 Keyboard Buffer0
.eqv KB2	0xFFFF0104		# PS2 Keyboard Buffer1
.eqv K1		0xFF100520		# PS2 Keyboard KEY0
.eqv K2		0xFF100524		# PS2 Keyboard KEY1
.eqv K3		0xFF100528		# PS2 Keyboard KEY2
.eqv K4		0xFF10052C		# PS2 Keyboard KEY3

# KEYBOARD MAP
.eqv LEFT	0x1C000000		# 'a' LEFT
.eqv DOWN	0x1B000000		# 's' DOWN
.eqv RIGHT	0x23000000		# 'd' RIGHT
.eqv UP		0x1D000000		# 'w' UP
.eqv L_PUNCH	0x34000000		# 'g' LIGHT PUNCH
.eqv M_PUNCH	0x33000000		# 'h' MEDIUM PUNCH
.eqv H_PUNCH	0x3B000000		# 'j' HEAVY PUNCH
.eqv L_KICK	0x32000000		# 'b' LIGHT KICK
.eqv M_KICK	0x31000000		# 'n' MEDIUM KICK
.eqv H_KICK	0x3A000000		# 'm' HEAVY KICK
.eqv THROW	0x42000000		# 'k' THROW
.eqv ENTER	0x44000000		# 'o' ENTER
.eqv BACK	0x4D000000		# 'p' BACK

.text

INIT:
	jal KEYBOARD
	j MAIN

KEYBOARD:
	la $s0, 0xFF100100  		# PS2 Keyboard Buffer0
	jr $ra

MAIN:
	lw $t0,0($s0)			# get key from buffer
	
	sll $t2, $t0, 24		# shift 24 bits left on the buffer
					# in case the buffer is full
					
	beq $t2, LEFT, 		EXIT		# test if 'a' was pressed
	beq $t2, DOWN, 		EXIT		# test if 's' was pressed
	beq $t2, RIGHT, 	EXIT		# test if 'd' was pressed
	beq $t2, UP, 		EXIT		# test if 'w' was pressed
	beq $t2, L_PUNCH, 	EXIT		# test if 'g' was pressed
	beq $t2, L_KICK, 	EXIT		# test if 'b' was pressed
	beq $t2, ENTER, 	EXIT		# test if 'o' was pressed
	beq $t2, BACK, 		EXIT		# test if 'p' was pressed
	
	j MAIN

EXIT:
	# TODO: ADD STAGE PART
	nop