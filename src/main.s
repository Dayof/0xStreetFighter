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
#	s0 : Ps2 Buffer 0					#
#	s1 : PS2 Key 1, 2, 3 or 4				#
#	s3 : Index counter of stages				#
#	a0 : SD card data					#
#	a1 : SD card						#
#	a2 : Image size						#
#	t0 : VGA 						#
#	t1 : SRAM						#
#	t2-t4 : Loop to print on screen				#
#	t5 : Number of stages					#
#	t7 : Addresses calculated from second stage		#
#################################################################

#################### LIBRARIES ################### 
#.include "vga.s"

#################### MARS INTERFACE ADDRESSES ################### 
# KEYBOARD AND DISPLAY MMIO SIMULATOR
.eqv READ_M	0xFF100004		# Address to get char typed from keyboard
.eqv PRINT_M	0xFF10000C		# Address to display char typed from keyboard

#################### FPGA INTERFACE ADDRESSES ################### 
### LCD INTERFACE ### 
.eqv LCD	0xFFFF0130		# LCD address

### SD AND SRAM INTERFACE ### 
.eqv SD_DATA_ADDR 0x413E00		# ARQUIVO.txt sem header
					# Addr = Offset, Offset = 0x10E00
					# [Caso tenha header Addr = Offset + (137 * 512) = Offset + 0x00011200 
					# (defasagem de setores logicos/fisicos * tamanho do setor)]
					# Olhe pelo WinHex o offset do seu cartao SD
					
.eqv USER_DATA    0x10012000		# Endereco da SRAM
					
### VGA INTERFACE ### 
.eqv VGA_INI_ADDR 0xFF000000		# FF000000 - C0   
					# Endereco inicial da VGA, mas existe um BUG, 
					# que pode ser concertado ao subtrair um offest no endereco da VGA
					
.eqv VGA_QTD_BYTE 76800			# VGA Bytes

### CHARACTERS INFORMATION
.eqv RYU_QTD	  29400			# Ryu's bytes size
.eqv RYU	  0x502E00		# Ryu's SD address

### PS2 INTERFACE ###  
.eqv KB1	0xFFFF0100		# PS2 Keyboard Buffer0
.eqv KB2	0xFFFF0104		# PS2 Keyboard Buffer1
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

.text

.macro _VGA_INIT_ (%adr, %qtd)
	la 	$a0, %adr		# Type can be stages or characters address
	la	$a1, USER_DATA		# Destiny of the address to read SD card 
 	la	$a2, %qtd		# Bytes size to read

	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	
	la	$t0, VGA_INI_ADDR	# Reset vga and sram addresses
	la	$t1, USER_DATA		#
.end_macro

INIT:
	jal 	KEYBOARD		# Keyboard setup
	jal 	VGA			# VGA setup
	jal	PRINT_RYU
	j 	MAIN			# Main logic

PRINT_RYU:
	li 	$s4, 100		# X coordinate
	li 	$s5, 120		# Y coordinate
		
	li 	$s6, 92			# Ryu height (y)
	li 	$s7, 49			# Ryu width (x)
	
PRINT_CHAR_VGA:
	_VGA_INIT_ RYU RYU_QTD 		# Map first Ryu sprite 
	
	move 	$t2, $zero		# First counter to print Ryu
	move 	$t3, $zero		# Second counter to print Ryu
	li 	$t4, 320		# Size of the screen
	
	FOR1:	
		beq 	$t2, $s6, OUT1	# If all the lines was print then exit ryu print (92)

	FOR2:	
		beq 	$t3, $s7, OUT2	# If all the columns was print then continue the outer loop (49)
		
		# sd (c1 * 320) + c2 -> lb
		mult 	$t2, $t4
		mflo	$t6
		add	$t6, $t6, $t3
		add	$t6, $t6, $t1	# Add on Ryu's address
		lb	$t8, 0($t6)
		
		# vga (y + c1)*320 + (x + c2) -> sb
		add	$t6, $s5, $t2
		mult	$t6, $t4
		mflo	$t6
		add	$t6, $t6, $s4
		add	$t6, $t6, $t3
		add	$t6, $t6, $t0	# Add on VGA's address
		sb	$t8, 0($t6)

		addi 	$t3, $t3, 1
		
		j 	FOR2
		
	OUT2:	
		addi 	$t2, $t2, 1
		move 	$t3, $zero
		
		j 	FOR1
	OUT1:
		jr $ra
	
VGA:
	_VGA_INIT_ SD_DATA_ADDR VGA_QTD_BYTE 	# Start initial address of SD card with the first stage 
	
	li 	$t5, 12				# Maxinum number of stages
	li 	$s3, 1				# Init stage index with the first stage
	li	$t7, 0x4D4000			# Second stage (unique address diff from the main logic)
	
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
	
	jr 	$ra

KEYBOARD:
	la 	$s0, 0xFF100100  	# PS2 Keyboard Buffer0
	
	jr 	$ra

UPDATE_BUFFER:
	lw 	$s2, 0($s0)		# get key from buffer
	
	sll 	$s2, $s2, 24		# shift 24 bits left on the buffer
					# in case the buffer is full

CONTROL:
	beq 	$s2, LEFT, 	MOVE_L	# test if 'a' was pressed
	beq 	$s2, DOWN, 	EXIT	# test if 's' was pressed
	beq 	$s2, RIGHT, 	MOVE_R	# test if 'd' was pressed
	beq 	$s2, UP, 	EXIT	# test if 'w' was pressed
	beq 	$s2, L_PUNCH, 	EXIT	# test if 'g' was pressed
	beq 	$s2, L_KICK, 	EXIT	# test if 'b' was pressed
	beq 	$s2, ENTER, 	EXIT	# test if 'o' was pressed
	beq 	$s2, BACK, 	EXIT	# test if 'p' was pressed
	
MAIN:
	la	$s1, K1				# PS2 Keyboard Key1 
	lw	$s2, 0($s1)			# get keymap 1
	andi	$t6, $s2, LEFT_K		# check if 'a' was pressed
	beq	$t6, LEFT_K, UPDATE_BUFFER	# if 'a' was pressed than get key from buffer
	
	la	$s1, K2				# PS2 Keyboard Key2 
	lw	$s2, 0($s1)			# get keymap 2
	andi	$t6, $s2, RIGHT_K		# check if 'd' was pressed
	beq	$t6, RIGHT_K, UPDATE_BUFFER	# if 'd' was pressed than get key from buffer
				
	j MAIN

MOVE_R:
	addi 	$s4, $s4, 20			# Add 20 steps when Ryu move to right
	
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	jal	PRINT_CHAR_VGA
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	j	MAIN

MOVE_L:
	addi 	$s4, $s4, -20			# Add 20 steps when Ryu move to right
	
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	jal	PRINT_CHAR_VGA
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	j	MAIN
	
MAPR:
	addi 	$s3, $s3, 1
	beq 	$s3, 2, SECOND_STAGE_FRONT
	
	sub 	$t7, $t7, 0x00013000	# Gap between the stages 
	add	$t8, $zero, $t7
	
	add 	$t8, $t8, 0x00010E00	# Add physical gap of SD card (it depends from each SD card)
	
	j PRINT_LOGIC

MAPL:
	sgt 	$t9, $s3, $zero
	beq 	$t9, $zero, EXIT
	
	addi 	$s3, $s3, -1
	beq 	$s3, 1, SECOND_STAGE_BACK
	
	add 	$t7, $t7, 0x00013000	# Gap between the stages 
	add	$t8, $zero, $t7
	
	add 	$t8, $t8, 0x00010E00	# Add physical gap of SD card (it depends from each SD card)
	
	j PRINT_LOGIC

SECOND_STAGE_FRONT:
	li	$t8, 0X004D4000		# Second map address
	add 	$t8, $t8, 0x00010E00	# Add physical gap of SD card (it depends from each SD card)
	
	j PRINT_LOGIC
	
SECOND_STAGE_BACK:
	li 	$t8, SD_DATA_ADDR
	
PRINT_LOGIC:
	_VGA_INIT_ SD_DATA_ADDR VGA_QTD_BYTE
	add	$a0, $zero, $t8		# Read the correct address to read the image from SD card 
	
	jal 	PRINT_VGA		# Print on VGA
	
	slt 	$t9, $s3, $t5		# Check if counter is less than the max number of stages
	beq 	$t9, $zero, EXIT	# If pass due 12 stages then exit the program	
	
	j MAIN
	
EXIT:
	la $s4, 0x0ACEF0DA
	j EXIT
