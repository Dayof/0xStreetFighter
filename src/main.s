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
#	0($sp) : Ryu X Coordinate				#
#	4($sp) : Ryu Y Coordinate				#
#	8($sp) : First char background buffer			#
#	12($sp): Second char background buffer			#
#################################################################

#################### MARS INTERFACE ADDRESSES ################### 
### PS2 INTERFACE ###  
.eqv KB1	0xFF100100		# PS2 Keyboard Buffer0
.eqv K1		0xFF100520		# PS2 Keyboard KEY0
.eqv K2		0xFF100524		# PS2 Keyboard KEY1
.eqv K3		0xFF100528		# PS2 Keyboard KEY2
.eqv K4		0xFF10052C		# PS2 Keyboard KEY3

### KEYBOARD MAP ### 
.eqv LEFT	0x1C000000		# 'a' LEFT
.eqv LEFT_K	0x10000000		# 'a' KEY
.eqv DOWN	0x1B000000		# 's' DOWN
.eqv RIGHT	0x23000000		# 'd' RIGHT
.eqv RIGHT_K	0x00000008		# 'd' KEY
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
					
.eqv USER_DATA    0x10012000		# SRAM address to load char from SD 
.eqv CHAR1_BUFFER  0x1003B400		# SRAM address to keep the first char's buffer
.eqv CHAR2_BUFFER  0x10064800		# SRAM address to keep the second char's buffer

### CHARACTERS MAP ### 
.eqv RYU_STAGE	  0x00088E00		# Ryu's stage sd address
.eqv RYU	  0x0009CE00		# Ryu's char sd address
.eqv RYU_QTD	  29400			# Ryu's bytes size

.text

INIT:
	addi	$sp, $sp, -20 		# Init stack
	
	jal 	VGA			# VGA setup
	nop	
	
	jal	SETUP_CHAR		# Print Ryu
	nop	
	
	jal	PRINT_CHAR_INV		# Print Ryu
	nop	
	
	j 	MAIN			# Main logic
	nop		
	
	j 	EXIT
	nop

PRINT_CHAR_INV:
	la	$t0, VGA_INI_ADDR	# VGA initial address
	la	$t1, USER_DATA		# SRAM address to collect char
	la	$s7, CHAR2_BUFFER	# SRAM address to collet buffer
	sw	$s7, 12($sp)		#
	
	move 	$t2, $zero		# First counter (c1) to print char
	move 	$t3, $zero		# Second counter (c2) to print char
	
	li 	$t4, 320		# Size of the screen
	
	lw	$s5, 0($sp)		# X coordinate
	lw	$s6, 4($sp)		# Y coordinate
	addi	$s5, $s5, 150
	
	li 	$t5, 90			# Char height (y)
	move 	$t6, $zero		# Char width (x)
	
	FOR0:
		beq 	$t6, 240, OUT0	# If ends sequence exit the loop
	
	FOR1:	
		beq 	$t2, $t5, OUT1	# If all the lines was print then exit ryu print (90)

	FOR2:	
		beq 	$t3, 60, OUT2	# If all the columns was print then continue the outer loop (60)
		
		# sd (c1 * 320) + ((60-c2) + x) -> lb
		mult 	$t2, $t4	# (c1 * 320)
		mflo	$t9		#
		addi	$s0, $t9, 60	# (c1 * 320) + 60
		sub	$s0, $s0, $t3	# (c1 * 320) + 60 - c2
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
		beq	$t9, $zero, GO_VGA
		
		GET_BUFF:
			lb	$t7, 0($s4)	# Collect buffer behind character
			sb	$t7, 0($s7)	# Save buffer on SRAM
			add	$s7, $s7, 1 	# Increase SRAM's index
		
		GO_VGA:
			sb	$s2, 0($s4)	# Print char on VGA

		addi 	$t3, $t3, 1
		
		j 	FOR2
		nop	
		
	OUT2:	
		addi 	$t2, $t2, 1
		move 	$t3, $zero
		
		j 	FOR1
		nop	
	OUT1:	
		move 	$t2, $zero
		addi 	$t6, $t6, 60	# Next char sequence
				
		j 	FOR0
		nop
	
	OUT0:	
		jr	$ra
		nop
		
SETUP_CHAR:	
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
	
PRINT_CHAR_VGA:
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
	
	FORINV0:
		beq 	$t6, 240, OUTINV0	# If ends sequence exit the loop
	
	FORINV1:	
		beq 	$t2, $t5, OUTINV1	# If all the lines was print then exit ryu print (90)

	FORINV2:	
		beq 	$t3, 60, OUTINV2	# If all the columns was print then continue the outer loop (60)
		
		# sd (c1 * 320) + (c2 + x) -> lb
		mult 	$t2, $t4	# (c1 * 320)
		mflo	$t9		#
		add	$s0, $t9, $t3	# (c1 * 320) + c2
		add	$s0, $s0, $t6	# (c1 * 320) + (c2 + x)
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
		beq	$t9, $zero, GO_VGA2
		
		GET_BUFF2:
			lb	$t7, 0($s4)	# Collect buffer behind character
			sb	$t7, 0($s7)	# Save buffer on SRAM
			add	$s7, $s7, 1 	# Increase SRAM's index
		
		GO_VGA2:
			sb	$s2, 0($s4)	# Print char on VGA

		addi 	$t3, $t3, 1
		
		j 	FORINV2
		nop	
		
	OUTINV2:	
		addi 	$t2, $t2, 1
		move 	$t3, $zero
		
		j 	FORINV1
		nop	
	OUTINV1:	
		move 	$t2, $zero
		addi 	$t6, $t6, 60	# Next char sequence
				
		j 	FORINV0
		nop
	
	OUTINV0:	
		jr	$ra
		nop

VGA:		 
	la	$a0, RYU_STAGE		# Stages address
	la	$a1, USER_DATA		# Destiny of the address to read SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$t0, VGA_INI_ADDR	# Reset vga and sram addresses
	la	$t1, USER_DATA		#
	
PRINT_VGA:				# Loop to print on screen
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
	beq 	$a0, LEFT, 	MOVE_L	# test if 'a' was pressed
	beq 	$a0, DOWN, 	EXIT	# test if 's' was pressed
	beq 	$a0, RIGHT, 	MOVE_R	# test if 'd' was pressed
	beq 	$a0, UP, 	EXIT	# test if 'w' was pressed
	beq 	$a0, L_PUNCH, 	EXIT	# test if 'g' was pressed
	beq 	$a0, L_KICK, 	EXIT	# test if 'b' was pressed
	beq 	$a0, ENTER, 	EXIT	# test if 'o' was pressed
	beq 	$a0, BACK, 	EXIT	# test if 'p' was pressed
	
MAIN:
	la	$t0, K1				# PS2 Keyboard Key1 
	lw	$t1, 0($t0)			# get keymap 1
	andi	$t2, $t1, LEFT_K		# check if 'a' was pressed
	beq	$t2, LEFT_K, UPDATE_BUFFER	# if 'a' was pressed than get key from buffer
	
	la	$t0, K2				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 2
	andi	$t2, $t1, RIGHT_K		# check if 'd' was pressed
	beq	$t2, RIGHT_K, UPDATE_BUFFER	# if 'd' was pressed than get key from buffer
		
	jal	CLEAN_PATH_CHAR1
	nop
			
	jal 	PRINT_CHAR_VGA
	nop
	
	jal 	CLEAN_PATH_CHAR2
	nop
			
	jal 	PRINT_CHAR_INV
	nop
	
	j MAIN
	nop

MOVE_R:
	jal	CLEAN_PATH_CHAR1
	nop
	
	lw	$t0, 0($sp)		# X coordinate
	addi 	$t1, $t0, 5		# Add 20 steps when Ryu move to right
	sw	$t1, 0($sp)		# X updated

	jal	PRINT_CHAR_VGA
	nop	
	
	j	MAIN
	nop

MOVE_L:
	jal	CLEAN_PATH_CHAR1
	nop
	
	lw	$t0, 0($sp)		# X coordinate
	addi 	$t1, $t0, -5		# Sub 20 steps when Ryu move to left
	sw	$t1, 0($sp)		# X updated

	jal	PRINT_CHAR_VGA
	nop	
	
	j	MAIN
	nop
	
CLEAN_PATH_CHAR2:
	la	$t0, VGA_INI_ADDR	# VGA initial address
	la	$t1, CHAR2_BUFFER	# SRAM address
	
	move 	$t2, $zero		# First counter (c1) to print char
	move 	$t3, $zero		# Second counter (c2) to print char
	li 	$t4, 320		# Size of the screen
	
	lw	$s5, 0($sp)		# X coordinate
	lw	$s6, 4($sp)		# Y coordinate
	addi	$s5, $s5, 150
	
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
	
CLEAN_PATH_CHAR1:
	la	$t0, VGA_INI_ADDR	# VGA initial address
	la	$t1, CHAR1_BUFFER	# SRAM address
	
	move 	$t2, $zero		# First counter (c1) to print char
	move 	$t3, $zero		# Second counter (c2) to print char
	li 	$t4, 320		# Size of the screen
	
	lw	$s5, 0($sp)		# X coordinate
	lw	$s6, 4($sp)		# Y coordinate
	
	li 	$t5, 90			# Ryu height (y)
	li 	$t6, 60			# Ryu width (x)
	
	FOR111:	
		beq 	$t2, $t5, OUT111	# If all the lines was print then exit ryu print (92)

	FOR222:	
		beq 	$t3, $t6, OUT222	# If all the columns was print then continue the outer loop (49)
		
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
		
		j 	FOR222
		nop	
		
	OUT222:	
		addi 	$t2, $t2, 1
		move 	$t3, $zero
		
		j 	FOR111
		nop	
	OUT111:	
		jr	$ra
		nop	
	
EXIT:
	la $s4, 0x0ACEF0DA
	j EXIT
	nop
