#################################################################
#			Street Figther II			#
#################################################################
# Developers: Group 6						#
#	Dayanne Fernandes da Cunha, 13/0107191			#
#       Lucas Mafra Chagas, 12/0126443				#
#       Marcelo Giordano Martins Costa de Oliveira, 12/0037301	#
#       Lucas Junior Ribas, 16/0052289				#
#	Diego Vaz Fernandes, 16/0117925				#
#################################################################
# Tools used:  							#
# FPGA:		                                 		#
# 	Keyboard, VGA, SD  					#
#								#
# MARS:		                                 		#
# 	Bitmap Display                         			#
#	Keyboard and Display MMIO Simulator     		#
#                                               		#
# Bitmap Display Settings:				  	#
#	Unit Width: 1 byte                		 	#
#	Unit Height: 1 byte          			  	#
# 	Display Width: 320                                  	#
# 	Display Height: 240      				#                           	
#								#
# Registers mapped:						#
#	0($sp) : Player 1 X Coordinate				#
#	4($sp) : Player 1 Y Coordinate				#
#	8($sp) : First char background buffer			#
#	12($sp): Second char background buffer			#
#	16($sp) : Player 2 X Coordinate				#
#	20($sp) : Player 2 Y Coordinate				#
#################################################################

#################### MARS INTERFACE ADDRESSES ################### 
### PS2 INTERFACE ###  
.eqv KB1	0xFF100100		# PS2 Keyboard Buffer0
.eqv K1		0xFF100520		# PS2 Keyboard KEY0
.eqv K2		0xFF100524		# PS2 Keyboard KEY1
.eqv K3		0xFF100528		# PS2 Keyboard KEY2
.eqv K4		0xFF10052C		# PS2 Keyboard KEY3

### KEYBOARD MAP ### 
.eqv LEFT1	0x1C000000		# 'a' LEFT
.eqv LEFT1_K	0x10000000		# 'a' LEFT KEY
.eqv RIGHT1	0x23000000		# 'd' RIGHT
.eqv RIGHT1_K	0x00000008		# 'd' RIGHT KEY

.eqv LEFT2	0x69000000		# '1' LEFT
.eqv LEFT2_K	0x00000200		# '1' LEFT KEY
.eqv RIGHT2	0x7A000000		# '3' RIGHT
.eqv RIGHT2_K	0x04000000		# '3' RIGHT KEY

.eqv DOWN	0x1B000000		# 's' DOWN
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

### VGA MAP ### 
.eqv VGA_INI_ADDR 0xFF000000		# VGA initial address
.eqv VGA_QTD_BYTE 76800			# Maximum size of the screen

### SD AND SRAM MAP ### 
# ARQUIVO.txt sem header
# Addr = Offset, Offset = 0x10E00
# [Caso tenha header Addr = Offset + (137 * 512) = Offset + 0x00011200 
# (defasagem de setores logicos/fisicos * tamanho do setor)]
# Olhe pelo WinHex o offset do seu cartao SD
					
.eqv USER_DATA     0x10012000		# SRAM address to load char from SD 
.eqv CHAR1_BUFFER  0x1003B400		# SRAM address to keep the first char's buffer
.eqv CHAR2_BUFFER  0x10064800		# SRAM address to keep the second char's buffer

### CHARACTERS MAP ### 
.eqv RYU_STAGE	  0x00088E00		# Ryu's stage sd address
.eqv RYU	  0x0009CE00		# Ryu's char sd address
.eqv RYU_QTD	  29400			# Ryu's bytes size

.text

INIT:
	addi	$sp, $sp, -24 		# Init stack
	
	jal 	SETUP_STAGE			# Stage setup
	nop	
	
	jal	SETUP_CHAR1		# Print char 1
	nop	
	
	jal	SETUP_CHAR2		# Print char 2
	nop	
	
	j 	MAIN			# Main logic
	nop		
	
	j 	EXIT
	nop

SETUP_CHAR2:	
	li 	$t0, 210		# X coordinate
	sw	$t0, 16($sp)		#
	li 	$t1, 130		# Y coordinate
	sw	$t1, 20($sp)		#
	
	la	$a0, RYU
	la	$a1, USER_DATA		# SRAM address
	li	$a2, RYU_QTD
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
PRINT_CHAR2:
	la	$t0, VGA_INI_ADDR	# VGA initial address
	la	$t1, USER_DATA		# SRAM address to collect char
	la	$s7, CHAR2_BUFFER	# SRAM address to collet buffer
	sw	$s7, 12($sp)		#
	
	move 	$t2, $zero		# First counter (c1) to print char
	move 	$t3, $zero		# Second counter (c2) to print char
	
	li 	$t4, 320		# Size of the screen
	
	lw	$s5, 16($sp)		# X coordinate
	lw	$s6, 20($sp)		# Y coordinate
	
	li 	$t5, 90			# Char height (y)
	move 	$t6, $zero		# Char width (x)
	
	FOR0C2:
		beq 	$t6, 240, OUT0C2	# If ends sequence exit the loop
	
	FOR1C2:	
		beq 	$t2, $t5, OUT1C2	# If all the lines was print then exit ryu print (90)

	FOR2C2:	
		beq 	$t3, 60, OUT2C2		# If all the columns was print then continue the outer loop (60)
		
		# sd (c1 * 320) + ((59-c2) + x) -> lb
		mult 	$t2, $t4	# (c1 * 320)
		mflo	$t9		#
		addi	$s0, $t9, 59	# (c1 * 320) + 59
		sub	$s0, $s0, $t3	# (c1 * 320) + 59 - c2
		add	$s0, $s0, $t6	# (c1 * 320) + (60 - c2 + x)
		add	$s1, $s0, $t1	# Add on Ryu's address on SSRAM
		lb	$s2, 0($s1)
		
		# vga (y + c1)*320 + (x + c2) -> sb
		add	$t9, $s6, $t2	# y + c1
		mult	$t9, $t4	# (y + c1)*320
		mflo	$s1		#
		add	$s1, $s1, $s5	# (y + c1)*320 + x
		add	$s3, $s1, $t3	# (y + c1)*320 + (x + c2)
		add	$s4, $s3, $t0	# Add on VGA's address
		
		slti	$t9, $t6, 60
		beq	$t9, $zero, GO_VGAC2
		
		GET_BUFFC2:
			lb	$t7, 0($s4)	# Collect buffer behind character
			sb	$t7, 0($s7)	# Save buffer on SRAM
			add	$s7, $s7, 1 	# Increase SRAM's index
		
		GO_VGAC2:
			sb	$s2, 0($s4)	# Print char on VGA

		addi 	$t3, $t3, 1
		
		j 	FOR2C2
		nop	
		
	OUT2C2:	
		addi 	$t2, $t2, 1
		move 	$t3, $zero
		
		j 	FOR1C2
		nop	
	OUT1C2:	
		move 	$t2, $zero
		addi 	$t6, $t6, 60	# Next char sequence
				
		j 	FOR0C2
		nop
	
	OUT0C2:	
		jr	$ra
		nop
		
SETUP_CHAR1:	
	li 	$t0, 60			# X coordinate
	sw	$t0, 0($sp)		#
	li 	$t1, 130		# Y coordinate
	sw	$t1, 4($sp)		#
	
	la	$a0, RYU
	la	$a1, USER_DATA		# SRAM address
	li	$a2, RYU_QTD
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
PRINT_CHAR1:
	la	$t0, VGA_INI_ADDR	# VGA initial address
	la	$t1, USER_DATA		# SRAM address to collect char
	la	$s7, CHAR1_BUFFER	# SRAM address to collet buffer
	sw	$s7, 8($sp)		#
	
	move 	$t2, $zero		# First counter (c1) to print char
	move 	$t3, $zero		# Second counter (c2) to print char
	
	li 	$t4, 320		# Size of the screen
	
	lw	$s5, 0($sp)		# X coordinate
	lw	$s6, 4($sp)		# Y coordinate
	
	li 	$t5, 90			# Char height (y)
	move 	$t6, $zero		# Char width (x)
	
	FOR0C1:
		beq 	$t6, 240, OUT0C1	# If ends sequence exit the loop
	
	FOR1C1:	
		beq 	$t2, $t5, OUT1C1	# If all the lines was print then exit ryu print (90)

	FOR2C1:	
		beq 	$t3, 60, OUT2C1		# If all the columns was print then continue the outer loop (60)
		
		# sd (c1 * 320) + (c2 + x) -> lb
		mult 	$t2, $t4	# (c1 * 320)
		mflo	$t9		#
		add	$s0, $t9, $t3	# (c1 * 320) + c2
		add	$s0, $s0, $t6	# (c1 * 320) + (c2 + x)
		add	$s1, $s0, $t1	# Add on char1's address on SSRAM
		lb	$s2, 0($s1)
		
		# vga (y + c1)*320 + (x + c2) -> sb
		add	$t9, $s6, $t2	# y + c1
		mult	$t9, $t4	# (y + c1)*320
		mflo	$s1		#
		add	$s1, $s1, $s5	# (y + c1)*320 + x
		add	$s3, $s1, $t3	# (y + c1)*320 + (x + c2)
		add	$s4, $s3, $t0	# Add on VGA's address
		
		slti	$t9, $t6, 60
		beq	$t9, $zero, GO_VGAC1
		
		GET_BUFFC1:
			lb	$t7, 0($s4)	# Collect buffer behind character
			sb	$t7, 0($s7)	# Save buffer on SRAM
			add	$s7, $s7, 1 	# Increase SRAM's index
		
		GO_VGAC1:
			sb	$s2, 0($s4)	# Print char on VGA

		addi 	$t3, $t3, 1
		
		j 	FOR2C1
		nop	
		
	OUT2C1:	
		addi 	$t2, $t2, 1
		move 	$t3, $zero
		
		j 	FOR1C1
		nop	
	OUT1C1:	
		move 	$t2, $zero
		addi 	$t6, $t6, 60	# Next char sequence
				
		j 	FOR0C1
		nop
	
	OUT0C1:	
		jr	$ra
		nop

SETUP_STAGE:		 
	la	$a0, RYU_STAGE		# Stages address
	la	$a1, USER_DATA		# Destiny of the address to read SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$t0, VGA_INI_ADDR	# Reset vga and sram addresses
	la	$t1, USER_DATA		#
	
PRINT_STAGE:				# Loop to print on screen
	WRITE_VGA:			#
 		lw	$t2, ($t1)	#
		sw	$t2, ($t0)	#
		addi	$t0, $t0, 4	#
		addi	$t1, $t1, 4	#
		addi 	$a2, $a2, -4	#
					#
	slti 	$t4, $a2, 1		#
	beq 	$t4, $zero, WRITE_VGA	#

	jr	$ra
	nop

UPDATE_BUFFER:
	la 	$t0, KB1		# get key from buffer
	lw	$t1, 0($t0)		#
	
	sll 	$a0, $t1, 24		# shift 24 bits left on the buffer
					# in case the buffer is full

CONTROL:
	beq 	$a0, LEFT1, 	MOVE1_L	# test if 'a' was pressed
	beq 	$a0, LEFT2, 	MOVE2_L	# test if '1' was pressed
	beq 	$a0, DOWN, 	EXIT	# test if 's' was pressed
	beq 	$a0, RIGHT1, 	MOVE1_R	# test if 'd' was pressed
	beq 	$a0, RIGHT2, 	MOVE2_R	# test if 'd' was pressed
	beq 	$a0, UP, 	EXIT	# test if 'w' was pressed
	beq 	$a0, L_PUNCH, 	EXIT	# test if 'g' was pressed
	beq 	$a0, L_KICK, 	EXIT	# test if 'b' was pressed
	beq 	$a0, ENTER, 	EXIT	# test if 'o' was pressed
	beq 	$a0, BACK, 	EXIT	# test if 'p' was pressed
	
MAIN:
	la	$t0, K1				# PS2 Keyboard Key1 
	lw	$t1, 0($t0)			# get keymap 1
	andi	$t2, $t1, LEFT1_K		# check if 'a' was pressed
	beq	$t2, LEFT1_K, UPDATE_BUFFER	# if 'a' was pressed than get key from buffer
	
	la	$t0, K2				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 2
	andi	$t2, $t1, RIGHT1_K		# check if 'd' was pressed
	beq	$t2, RIGHT1_K, UPDATE_BUFFER	# if 'd' was pressed than get key from buffer
	
	la	$t0, K4				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 4
	andi	$t2, $t1, LEFT2_K		# check if '1' was pressed
	beq	$t2, LEFT2_K, UPDATE_BUFFER	# if '1' was pressed than get key from buffer
	
	la	$t0, K4				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 4
	andi	$t2, $t1, RIGHT2_K		# check if '3' was pressed
	beq	$t2, RIGHT2_K, UPDATE_BUFFER	# if '3' was pressed than get key from buffer
		
	la	$t1, CHAR1_BUFFER		# SRAM buffer address
	lw	$s5, 0($sp)			# X coordinate
	lw	$s6, 4($sp)			# Y coordinate
	jal	CLEAN_PATH
	nop
			
	jal 	PRINT_CHAR1
	nop
	
	la	$t1, CHAR2_BUFFER		# SRAM buffer address
	lw	$s5, 16($sp)			# X coordinate
	lw	$s6, 20($sp)			# Y coordinate
	jal 	CLEAN_PATH
	nop
			
	jal 	PRINT_CHAR2
	nop
	
	j MAIN
	nop

MOVE1_R:
	la	$t1, CHAR1_BUFFER		# SRAM buffer address
	lw	$s5, 0($sp)			# X coordinate
	lw	$s6, 4($sp)			# Y coordinate
	jal	CLEAN_PATH
	nop
	
	lw	$t0, 0($sp)		# X coordinate
	addi 	$t1, $t0, 5		# Add 20 steps when Ryu move to right
	sw	$t1, 0($sp)		# X updated

	jal	PRINT_CHAR1
	nop	
	
	j	MAIN
	nop

MOVE1_L:
	la	$t1, CHAR1_BUFFER		# SRAM buffer address
	lw	$s5, 0($sp)			# X coordinate
	lw	$s6, 4($sp)			# Y coordinate
	jal	CLEAN_PATH
	nop
	
	lw	$t0, 0($sp)		# X coordinate
	addi 	$t1, $t0, -5		# Sub 20 steps when Ryu move to left
	sw	$t1, 0($sp)		# X updated

	jal	PRINT_CHAR1
	nop	
	
	j	MAIN
	nop
	
MOVE2_R:
	la	$t1, CHAR2_BUFFER		# SRAM buffer address
	lw	$s5, 16($sp)			# X coordinate
	lw	$s6, 20($sp)			# Y coordinate
	jal	CLEAN_PATH
	nop
	
	lw	$t0, 16($sp)		# X coordinate
	addi 	$t1, $t0, 5		# Add 20 steps when Ryu move to right
	sw	$t1, 16($sp)		# X updated

	jal	PRINT_CHAR2
	nop	
	
	j	MAIN
	nop

MOVE2_L:
	la	$t1, CHAR2_BUFFER		# SRAM buffer address
	lw	$s5, 16($sp)			# X coordinate
	lw	$s6, 20($sp)			# Y coordinate
	jal	CLEAN_PATH
	nop
	
	lw	$t0, 16($sp)		# X coordinate
	addi 	$t1, $t0, -5		# Sub 20 steps when Ryu move to left
	sw	$t1, 16($sp)		# X updated

	jal	PRINT_CHAR2
	nop	
	
	j	MAIN
	nop
	
CLEAN_PATH:
	la	$t0, VGA_INI_ADDR	# VGA initial address
	
	move 	$t2, $zero		# First counter (c1) to print char
	move 	$t3, $zero		# Second counter (c2) to print char
	li 	$t4, 320		# Size of the screen
	
	li 	$t5, 90			# Ryu height (y)
	li 	$t6, 60			# Ryu width (x)
	
	FOR11:	
		beq 	$t2, $t5, OUT11	# If all the lines was print then exit ryu print (92)

	FOR22:	
		beq 	$t3, $t6, OUT22	# If all the columns was print then continue the outer loop (49)
		
		# sd (c1 * 49) + c2 -> lb
		mult 	$t2, $t6	# (c1 * 49)
		mflo	$t9		#
		add	$s0, $t9, $t3	# (c1 * 49) + c2
		add	$s1, $s0, $t1	# Add on Ryu's address on SD card
		lb	$s2, 0($s1)
		
		# vga (y + c1)*320 + (x + c2) -> sb
		add	$t9, $s6, $t2	# y + c1
		mult	$t9, $t4	# (y + c1)*320
		mflo	$s0		#
		add	$s1, $s0, $s5	# (y + c1)*320 + x
		add	$s3, $s1, $t3	# (y + c1)*320 + (x + c2)
		add	$s4, $s3, $t0	# Add on VGA's address
		
		sb	$s2, 0($s4)

		addi 	$t3, $t3, 1
		
		j 	FOR22
		nop	
		
	OUT22:	
		addi 	$t2, $t2, 1
		move 	$t3, $zero
		
		j 	FOR11
		nop	
	OUT11:	
		jr	$ra
		nop	
	
EXIT:
	la $s4, 0x0ACEF0DA
	j EXIT
	nop
