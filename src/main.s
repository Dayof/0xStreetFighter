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
#	24($sp) : Select box 1 X Coordinate			#
#	28($sp) : Select box 1 Y Coordinate			#
#	32($sp) : Select box 2 X Coordinate			#
#	36($sp) : Select box 2 Y Coordinate			#
#	40($sp) : P1 stage address				#
#	44($sp) : P1 char address				#
#	48($sp) : P2 char address				#
#	52-72($sp) : Music logic				#
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

.eqv DOWN1	0x1B000000		# 's' DOWN
.eqv DOWN1_K	0x08000000		# 's' DOWN
.eqv UP1	0x1D000000		# 'w' UP
.eqv UP1_K	0x20000000		# 'w' UP

.eqv DOWN2	0x72000000		# '2' DOWN
.eqv DOWN2_K	0x00040000		# '2' DOWN
.eqv UP2	0x73000000		# '5' UP
.eqv UP2_K	0x00080000		# '5' UP

.eqv ENTER	0x5A000000		# 'enter' 
.eqv ENTER_K	0x04000000		# 'enter' key

.eqv ENTER2	0x70000000		# '0' enter
.eqv ENTER2_K	0x00010000		# '0' enter key

.eqv L_PUNCH	0x34000000		# 'g' LIGHT PUNCH
.eqv M_PUNCH	0x33000000		# 'h' MEDIUM PUNCH
.eqv H_PUNCH	0x3B000000		# 'j' HEAVY PUNCH
.eqv L_KICK	0x32000000		# 'b' LIGHT KICK
.eqv M_KICK	0x31000000		# 'n' MEDIUM KICK
.eqv H_KICK	0x3A000000		# 'm' HEAVY KICK
.eqv THROW	0x42000000		# 'k' THROW
.eqv BACK	0x4D000000		# 'p' BACK

### VGA MAP ### 
.eqv VGA_INI_ADDR 0xFF000000		# VGA initial address
.eqv VGA_QTD_BYTE 76800			# Maximum size of the screen (12C00)

### SD AND SRAM MAP ### 
# ARQUIVO.txt sem header
# Addr = Offset, Offset = 0x10E00
# [Caso tenha header Addr = Offset + (137 * 512) = Offset + 0x00011200 
# (defasagem de setores logicos/fisicos * tamanho do setor)]
# Olhe pelo WinHex o offset do seu cartao SD
					
.eqv USER_DATA     0x10012000		# SRAM address to load char from SD 
.eqv CHAR1_BUFFER  0x100192D8		# SRAM address to keep the first char's buffer
.eqv CHAR2_BUFFER  0x100205B0		# SRAM address to keep the second char's buffer
.eqv START1_BUFFER 0x10027888		# SRAM address to keep the insert coin first image's buffer
.eqv START2_BUFFER 0x1003A488		# SRAM address to keep the insert coin second image's buffer
.eqv ARCADE_BUFFER 0x1004D088		# SRAM address to keep the arcade menu's buffer
.eqv VERSUS_BUFFER 0x1005FC88		# SRAM address to keep the versus menu's buffer
.eqv SELECT_BUFFER 0x10072888		# SRAM address to keep the select char image's buffer
.eqv S1_BACK_BUFF  0x10085488		
.eqv S2_BACK_BUFF  0x10089AD8		
.eqv S12_BUFFER	   0x1008E128	
.eqv RYU_S_BUFFER  0x10092778	
.eqv RYU_C_BUFFER  0x100A5378
.eqv KEN_S_BUFFER  0x100AC650	
.eqv KEN_C_BUFFER  0x100BF250

### MENU MAP ### 
.eqv START1	  0x000A4000		# Insert coin menu 1
.eqv START2	  0x00090000		# Insert coin menu 2
.eqv ARCADE	  0x0022C000		# Arcade menu
.eqv VERSUS	  0x00240000		# Versus menu
.eqv SELECT	  0x0037C000		# Select menu

.eqv S12	  0x00368000		# Select box 1 and 2
.eqv SELECT_QTD	  18000			# Select box image bytes size (4650)

### CHARACTERS MAP ### 
.eqv RYU_STAGE	  0x0045C000		# Ryu's stage sd address
.eqv RYU	  0x00284000		# Ryu's char sd address

.eqv KEN_STAGE    0x00434000	
.eqv KEN	  0x00214000		# Ken's char sd address

.eqv HONDA_STAGE  0x0045C000	
.eqv HONDA	  0x0009CE00		# Honda's char sd address

.eqv BLANKA_STAGE 0x0045C000	
.eqv BLANKA	  0x0009CE00		# Blanka's char sd address

.eqv GUILE_STAGE  0x0045C000	
.eqv GUILE	  0x0009CE00		# Guile's char sd address

.eqv CHUN_STAGE   0x0045C000	
.eqv CHUN	  0x0009CE00		# Chun-li's char sd address

.eqv ZANG_STAGE   0x0045C000
.eqv ZANG	  0x0009CE00		# Zangief's char sd address
	
.eqv DHAL_STAGE   0x0045C000
.eqv DHAL	  0x0009CE00		# Dhalsim's char sd address	

.eqv CHAR_QTD 	  29400			# Ryu's bytes size (72D8)

## MUSIC ##
.data

	QTDNOTAS:	.word 130
	DELAY:		.word 96, 96, 96, 960, 192, 192, 192, 576, 96, 96, 384, 384, 960, 192, 192, 192, 384, 672, 96, 192, 192, 96, 192, 864, 192, 192, 96, 192, 864, 384, 960, 192, 192, 192, 384, 576, 384, 192, 960, 192, 192, 192, 960, 192, 96, 384, 288, 192, 192, 288, 480, 960, 192, 192, 192, 960, 192, 96, 288, 288, 288, 192, 288, 288, 192, 1920, 384, 288, 96, 96, 192, 480, 384, 288, 96, 96, 192, 192, 96, 960, 192, 192, 96, 96, 96, 1632, 384, 288, 96, 96, 192, 480, 384, 288, 96, 96, 192, 192, 96, 768, 192, 192, 192, 384, 576, 192, 192, 192, 96, 192, 5664, 96, 96, 960, 192, 192, 192, 576, 96, 96, 384, 384, 960, 192, 192, 192, 384, 672, 96, 192,

	NOTAS:		.word 71, 74, 76, 76, 78, 79, 81, 79, 78, 79, 76, 78, 79, 81, 76, 74, 84, 83, 81, 79, 78, 76, 76, 78, 79, 83, 81, 81, 79, 78, 79, 81, 83, 84, 83, 81, 83, 79, 76, 78, 79, 81, 79, 78, 71, 76, 78, 79, 81, 83, 79, 76, 78, 79, 81, 83, 84, 83, 83, 81, 79, 78, 77, 76, 75, 71, 78, 79, 81, 83, 79, 71, 78, 79, 81, 83, 79, 78, 76, 78, 79, 81, 79, 78, 71, 71, 78, 79, 81, 83, 79, 71, 78, 79, 81, 83, 79, 78, 76, 78, 79, 81, 72, 83, 81, 79, 78, 78, 76, 76, 71, 74, 76, 76, 78, 79, 81, 79, 78, 79, 76, 78, 79, 81, 76, 74, 84, 83, 81, 79

	DURACAO:	.word 96, 96, 960, 192, 192, 192, 576, 96, 96, 384, 384, 960, 192, 192, 192, 384, 576, 96, 192, 192, 96, 96, 864, 192, 192, 96, 96, 864, 384, 960, 192, 192, 192, 384, 576, 384, 192, 960, 192, 192, 192, 960, 192, 96, 96, 192, 192, 192, 288, 480, 960, 192, 192, 192, 960, 192, 96, 96, 288, 288, 192, 288, 288, 192, 1536, 384, 288, 96, 96, 96, 480, 384, 288, 96, 96, 96, 192, 96, 960, 192, 192, 96, 96, 96, 1248, 384, 288, 96, 96, 96, 480, 384, 288, 96, 96, 96, 192, 96, 768, 192, 192, 192, 384, 576, 192, 192, 192, 96, 96, 864, 96, 96, 960, 192, 192, 192, 576, 96, 96, 384, 384, 960, 192, 192, 192, 384, 576, 96, 192, 192

.text

INIT:
	addi	$sp, $sp, -76 		# Init stack
	
	jal 	LOAD_SD
	nop

	jal 	PRIMEIRA_NOTA
	nop
	
	j 	MAIN_COIN		# Main logic
	nop		
	
	j 	EXIT
	nop
	
PRIMEIRA_NOTA:

	la $t0, DELAY				#bota delay na pilha
	nop
	lw $t1, 0 ($t0)
	nop
	sw $t1, 52($sp) 		#valor do delay na pilha
	nop
	sw $t0, 56($sp)			#endereço do delay na pilha

	la $t1, NOTAS				#le a NOTA
	nop
	lw $a0, 0 ($t1)
	nop
	sw $t1, 60($sp)			#endereço da NOTA na pos 32

	la $t2, DURACAO			#lea a duracao
	nop
	lw $a1, 0 ($t2)
	nop
	sw $t2, 64($sp)			#endereço de DURACAO na pos 36

	li $t0, 4
	sw $t0, 68($sp)

	li $a2, 24					# instrumento (parece que a placa não diferencia esses valores)
	li $a3, 50					# volume

	li $v0, 31					# toca a nota
	syscall
	nop

	jr $ra
	nop

LOAD_SD:
	la	$a0, START1
	addi	$a0, $a0, 0x10E00
	la	$a1, START1_BUFFER	# Destiny of the address to read from SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$a0, START2
	addi	$a0, $a0, 0x10E00
	la	$a1, START2_BUFFER	# Destiny of the address to read from SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$a0, ARCADE
	addi	$a0, $a0, 0x10E00
	la	$a1, ARCADE_BUFFER	# Destiny of the address to read from SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$a0, VERSUS
	addi	$a0, $a0, 0x10E00
	la	$a1, VERSUS_BUFFER	# Destiny of the address to read from SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$a0, SELECT
	addi	$a0, $a0, 0x10E00
	la	$a1, SELECT_BUFFER	# Destiny of the address to read from SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$a0, S12
	addi	$a0, $a0, 0x10E00
	la	$a1, S12_BUFFER		# Destiny of the address to read from SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$a0, RYU_STAGE
	addi	$a0, $a0, 0x10E00
	la	$a1, RYU_S_BUFFER	# Destiny of the address to read from SD card 
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$a0, RYU
	addi	$a0, $a0, 0x10E00
	la	$a1, RYU_C_BUFFER	
	li	$a2, CHAR_QTD
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop

	la	$a0, KEN_STAGE
	addi	$a0, $a0, 0x10E00
	la	$a1, KEN_S_BUFFER	
	li	$a2, VGA_QTD_BYTE
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	la	$a0, KEN
	addi	$a0, $a0, 0x10E00
	la	$a1, KEN_C_BUFFER	
	li	$a2, CHAR_QTD
	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	nop
	
	jr $ra
	nop
	
PRINT_CHAR2:
	la	$t0, VGA_INI_ADDR	# VGA initial address
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
		
PRINT_VGA:
	la	$t0, VGA_INI_ADDR	# Reset vga and sram addresses
					# Loop to print on screen
	li	$a2, VGA_QTD_BYTE	# Bytes size to read
	
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
	
MAIN_COIN:
	la	$t0, K3				# PS2 Keyboard Key3 
	lw	$t1, 0($t0)			# get keymap 3
	andi	$t2, $t1, ENTER_K		# check if 'enter' was pressed
	beq	$t2, ENTER_K, SETUP_ARCADE	#
	
	la	$t1, START1_BUFFER		# Insert coin 1 address
	jal 	PRINT_VGA			#
	nop
	
	la	$t1, START2_BUFFER		# Insert coin 2 address
	jal 	PRINT_VGA			# 
	nop
	
	j MAIN_COIN
	nop
	
SETUP_ARCADE:
	la	$t1, ARCADE_BUFFER		# Arcade menu address
	jal 	PRINT_VGA			# 
	nop
	
ARCADE_OPT:
	la	$t0, K1				# PS2 Keyboard Key1 
	lw	$t1, 0($t0)			# get keymap 1
	andi	$t2, $t1, DOWN1_K		# check if 's' was pressed
	beq	$t2, DOWN1_K, SETUP_VERSUS	#
	
	la	$t0, K3				# PS2 Keyboard Key3 
	lw	$t1, 0($t0)			# get keymap 3
	andi	$t2, $t1, ENTER_K		# check if 'enter' was pressed
	beq	$t2, ENTER_K, SELECT_SETUP	#
	
	j ARCADE_OPT
	nop

SETUP_VERSUS:
	la	$t1, VERSUS_BUFFER		# Arcade menu address
	jal 	PRINT_VGA			# 
	nop
	
VERSUS_OPT:
	la	$t0, K1				# PS2 Keyboard Key1 
	lw	$t1, 0($t0)			# get keymap 1
	andi	$t2, $t1, UP1_K			# check if 'w' was pressed
	beq	$t2, UP1_K, SETUP_ARCADE	#
	
	la	$t0, K3				# PS2 Keyboard Key3 
	lw	$t1, 0($t0)			# get keymap 3
	andi	$t2, $t1, ENTER_K		# check if 'enter' was pressed
	beq	$t2, ENTER_K, SELECT_SETUP	#
	
	j VERSUS_OPT
	nop
	
SELECT_SETUP:
	la	$t1, SELECT_BUFFER	# Select menu address
	jal 	PRINT_VGA		# 
	nop	
	
	la	$t1, S12_BUFFER	
		
	la	$s7, S1_BACK_BUFF	
	li 	$s5, 80			# X coordinate
	sw	$s5, 24($sp)	
	li 	$s6, 145		# Y coordinate
	sw	$s6, 28($sp)
	li 	$t5, 50			# Select height (y)
	li 	$t6, 0			# Select width (x)
	jal 	PRINT_SELECT		
	nop	
		
	la	$s7, S2_BACK_BUFF
	li 	$s5, 180		# X coordinate
	sw	$s5, 32($sp)	
	li 	$s6, 145		# Y coordinate	
	sw	$s6, 36($sp)	
	li 	$t5, 50			# Select height (y)
	li 	$t6, 58			# Select width (x)
	jal 	PRINT_SELECT			
	nop
	
	li	$a2, 1			# char 1 counter
	li	$a1, 4			# char 2 counter
	
MAIN_SELECT:
	la	$t0, K1				# PS2 Keyboard Key1 
	lw	$t1, 0($t0)			# get keymap 1
	andi	$t2, $t1, LEFT1_K		# check if 'a' was pressed
	beq	$t2, LEFT1_K, UPDATE_BOX_L1	#
	
	la	$t0, K2				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 2
	andi	$t2, $t1, RIGHT1_K		# check if 'd' was pressed
	beq	$t2, RIGHT1_K, UPDATE_BOX_R1	# 
	
	la	$t0, K1				# PS2 Keyboard Key1 
	lw	$t1, 0($t0)			# get keymap 1
	andi	$t2, $t1, UP1_K			# check if 'w' was pressed
	beq	$t2, UP1_K, UPDATE_BOX_U1	#
	
	la	$t0, K1				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 2
	andi	$t2, $t1, DOWN1_K		# check if 's' was pressed
	beq	$t2, DOWN1_K, UPDATE_BOX_D1	# 
	
	la	$t0, K4				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 4
	andi	$t2, $t1, LEFT2_K		# check if '1' was pressed
	beq	$t2, LEFT2_K, UPDATE_BOX_L2	# 
	
	la	$t0, K4				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 4
	andi	$t2, $t1, RIGHT2_K		# check if '3' was pressed
	beq	$t2, RIGHT2_K, UPDATE_BOX_R2	# 
	
	la	$t0, K4				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 4
	andi	$t2, $t1, UP2_K			# check if '5' was pressed
	beq	$t2, UP2_K, UPDATE_BOX_U2	# 
		
	la	$t0, K4				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 4
	andi	$t2, $t1, DOWN2_K		# check if '2' was pressed
	beq	$t2, DOWN2_K, UPDATE_BOX_D2	# 

	la	$t0, K3				# PS2 Keyboard Key3 
	lw	$t1, 0($t0)			# get keymap 3
	andi	$t2, $t1, ENTER_K		# check if 'enter' was pressed
	beq	$t2, ENTER_K, STAGE1_SETUP	#
	
	la	$t0, K4				# PS2 Keyboard Key3 
	lw	$t1, 0($t0)			# get keymap 3
	andi	$t2, $t1, ENTER2_K		# check if '0' was pressed
	beq	$t2, ENTER2_K, STAGE2_SETUP	#
		
	j MAIN_SELECT
	nop

STAGE2_SETUP:
	li 	$t0, 210		# X coordinate
	sw	$t0, 16($sp)		#
	li 	$t1, 130		# Y coordinate
	sw	$t1, 20($sp)		#
	
	beq	$a1, 1, LOAD2_RYU
	beq	$a1, 5, LOAD2_KEN
	
	j MAIN_SELECT
	nop
	
STAGE1_SETUP:
	li 	$t0, 60			# X coordinate
	sw	$t0, 0($sp)		#
	li 	$t1, 130		# Y coordinate
	sw	$t1, 4($sp)		#
	
	beq	$a2, 1, LOAD1_RYU
	beq	$a2, 5, LOAD1_KEN

	j MAIN_SELECT
	nop

LOAD1_KEN:
	la	$t1, KEN_S_BUFFER	# Ken stage address
	sw	$t1, 44($sp)	
	
	la	$t1, KEN_C_BUFFER	
	sw	$t1, 40($sp)	
	
	addi	$a2, $a2, 10
	sgt	$t8, $a1, 10
	beq	$t8, 1, SETUP_STAGE_LOOP	
	
	j MAIN_SELECT
	nop
	
LOAD1_RYU:
	la	$t1, RYU_S_BUFFER	# Ryu stage address
	sw	$t1, 44($sp)
	
	la	$t1, RYU_C_BUFFER	
	sw	$t1, 40($sp)	

	addi	$a2, $a2, 10
	sgt	$t8, $a1, 10
	beq	$t8, 1, SETUP_STAGE_LOOP	
	
	j MAIN_SELECT
	nop
	
LOAD2_KEN:
	la	$t1, KEN_C_BUFFER	
	sw	$t1, 48($sp)	
	
	addi	$a1, $a1, 10
	sgt	$t8, $a2, 10
	beq	$t8, 1, SETUP_STAGE_LOOP	
	
	j MAIN_SELECT
	nop
	
LOAD2_RYU:
	la	$t1, RYU_C_BUFFER	
	sw	$t1, 48($sp)
	
	addi	$a1, $a1, 10
	sgt	$t8, $a2, 10
	beq	$t8, 1, SETUP_STAGE_LOOP		
	
	j MAIN_SELECT
	nop
		
SETUP_STAGE_LOOP:
	lw	$t1, 44($sp)
	jal	PRINT_VGA	
	nop
	nop
	nop

	lw	$t1, 40($sp)
	jal 	PRINT_CHAR1
	nop

	lw	$t1, 48($sp)
	jal 	PRINT_CHAR2
	nop
	
	move 	$t8, $zero
	
STAGE_LOOP:
	addi 	$t8,$t8, 1
	
	la	$t0, K1				# PS2 Keyboard Key1 
	lw	$t1, 0($t0)			# get keymap 1
	andi	$t2, $t1, LEFT1_K		# check if 'a' was pressed
	beq	$t2, LEFT1_K, MOVE1_L		#
	
	la	$t0, K2				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 2
	andi	$t2, $t1, RIGHT1_K		# check if 'd' was pressed
	beq	$t2, RIGHT1_K, MOVE1_R		# 
	
	la	$t0, K4				# PS2 Keyboard Key1 
	lw	$t1, 0($t0)			# get keymap 1
	andi	$t2, $t1, LEFT2_K		# check if '1' was pressed
	beq	$t2, LEFT2_K, MOVE2_L		#
	
	la	$t0, K4				# PS2 Keyboard Key2 
	lw	$t1, 0($t0)			# get keymap 2
	andi	$t2, $t1, RIGHT2_K		# check if '3' was pressed
	beq	$t2, RIGHT2_K, MOVE2_R		# 
	
	la	$t1, CHAR1_BUFFER		# SRAM buffer address
	lw	$s5, 0($sp)			# X coordinate
	lw	$s6, 4($sp)			# Y coordinate
	li 	$t5, 90				# Ryu height (y)
	li 	$t6, 60				# Ryu height (x)
	jal	CLEAN_PATH
	nop

	lw	$t1, 40($sp)				
	jal 	PRINT_CHAR1
	nop
	
	la	$t1, CHAR2_BUFFER		# SRAM buffer address
	lw	$s5, 16($sp)			# X coordinate
	lw	$s6, 20($sp)			# Y coordinate
	li 	$t5, 90				# Ryu height (y)
	li 	$t6, 60				# Ryu height (x)
	jal 	CLEAN_PATH
	nop

	lw	$t1, 48($sp)	
	jal 	PRINT_CHAR2
	nop
	
	lw 	$t3, 52($sp)
	nop

	jal 	MUSICA
	nop
	li 	$t8, 0

PULA:
	j 	STAGE_LOOP
	nop

MUSICA:
	sw 	$ra, 72($sp)		# salva endereco de retorno da musica #retorno de RA

    	lw 	$t2, 68($sp)		# carrega o contador em bytes do vetor de notas # flag

	lw 	$t0, 56($sp)   		#le o endereço do delay
	add 	$t0, $t0, 4		#soma 4 ao endereço
	lw 	$t1, 0($t0)		#pega na memoria o valor do proximo endereço
	sw 	$t1, 52($sp)		#sobrescreve o delay antigo
	sw 	$t0, 56($sp)		# salvou o proximo endereço do delay

	lw 	$t0, 60($sp)		#endereço da nota
	add 	$t0, $t0, 4		#soma 4 ao end da NOTA
	lw 	$a0, 0($t0)		#carrega o valor da nota p/ o syscall
	sw 	$t0, 60($sp)		# salvou o proximo endereço do delay

	lw 	$t0, 64($sp)		#endereço da ducaracao
	add 	$t0, $t0, 4		#soma 4 ao end da ducaracao
	lw 	$a1, 0($t0)		#carrega o valor da nota p/ o syscall
	sw 	$t0, 64($sp)		# salvou o proximo endereço do delay

	li 	$a2, 24			# instrumento (parece que a placa não diferencia esses valores)
	li 	$a3, 50			# volume

	li 	$v0, 31			# toca a nota
	syscall
	nop

	add 	$t2, $t2, 4		# adiciona 4 bytes ao contador do vetor de notas
	beq 	$t2, 516, faz		# if ( t2 == 516) faz
	sw 	$t2, 68($sp)		# else -- salva t2 "o valor atualizado do contador do vetor de notas"
	j 	fimFaz
	nop
	
    faz:
	jal 	PRIMEIRA_NOTA  		# reseta a musica
	nop
 	
 	fimFaz:
		lw 	$ra, 72($sp)	# devolve o endereco de retorno da musica
		jr 	$ra
		nop
	
UPDATE_BOX_L2:

	lw	$s5, 32($sp)		# X coordinate
	lw	$s6, 36($sp)		# Y coordinate

	slti	$t8, $s5, 90
	beq	$t8, 1, MAIN_SELECT
	
	addi	$a1, $a1, -1

	la	$t1, S2_BACK_BUFF	# SRAM buffer address
	li 	$t5, 50			# Ryu height (y)
	li 	$t6, 58			# Ryu height (y)
	jal CLEAN_PATH
	nop
	
	la	$t1, S12_BUFFER		
	la	$s7, S2_BACK_BUFF		
	lw	$s5, 32($sp)		# X coordinate
	addi	$s5, $s5, -33
	sw	$s5, 32($sp)		# X coordinate
	lw	$s6, 36($sp)		# Y coordinate
	li 	$t5, 50			# Select height (y)
	li 	$t6, 58			# Select width (x)
	jal 	PRINT_SELECT		
	nop	

	j MAIN_SELECT
	nop

	
UPDATE_BOX_R2:

	lw	$s5, 32($sp)		# X coordinate
	lw	$s6, 36($sp)		# Y coordinate
	
	sgt	$t8, $s5, 170
	beq	$t8, 1, MAIN_SELECT
	
	addi	$a1, $a1, 1

	la	$t1, S2_BACK_BUFF	# SRAM buffer address
	li 	$t5, 50			# Ryu height (y)
	li 	$t6, 58			# Ryu height (y)
	jal CLEAN_PATH
	nop
	
	la	$t1, S12_BUFFER		
	la	$s7, S2_BACK_BUFF		
	lw	$s5, 32($sp)		# X coordinate
	addi	$s5, $s5, 33
	sw	$s5, 32($sp)		# X coordinate
	lw	$s6, 36($sp)		# Y coordinate
	li 	$t5, 50			# Select height (y)
	li 	$t6, 58			# Select width (x)
	jal 	PRINT_SELECT		
	nop	

	j MAIN_SELECT
	nop
	
UPDATE_BOX_U2:

	lw	$s5, 32($sp)		# X coordinate
	lw	$s6, 36($sp)		# Y coordinate
	
	slti	$t8, $s6, 160
	beq	$t8, 1, MAIN_SELECT
	
	addi	$a1, $a1, -4
	
	la	$t1, S2_BACK_BUFF	# SRAM buffer address
	li 	$t5, 50			# Ryu height (y)
	li 	$t6, 58			# Ryu height (y)
	jal CLEAN_PATH
	nop
	
	la	$t1, S12_BUFFER		
	la	$s7, S2_BACK_BUFF		
	lw	$s5, 32($sp)		# X coordinate
	lw	$s6, 36($sp)		# Y coordinate
	addi	$s6, $s6, -33
	sw	$s6, 36($sp)	
	li 	$t5, 50			# Select height (y)
	li 	$t6, 58			# Select width (x)
	jal 	PRINT_SELECT		
	nop	

	j MAIN_SELECT
	nop

	
UPDATE_BOX_D2:

	lw	$s5, 32($sp)		# X coordinate
	lw	$s6, 36($sp)		# Y coordinate
	
	sgt	$t8, $s6, 170
	beq	$t8, 1, MAIN_SELECT
	
	addi	$a1, $a1, 4
	
	la	$t1, S2_BACK_BUFF	# SRAM buffer address
	li 	$t5, 50			# Ryu height (y)
	li 	$t6, 58			# Ryu height (y)
	jal CLEAN_PATH
	nop
	
	la	$t1, S12_BUFFER		
	la	$s7, S2_BACK_BUFF		
	lw	$s5, 32($sp)		# X coordinate
	lw	$s6, 36($sp)		# Y coordinate
	addi	$s6, $s6, 33
	sw	$s6, 36($sp)		# X coordinate
	li 	$t5, 50			# Select height (y)
	li 	$t6, 58			# Select width (x)
	jal 	PRINT_SELECT		
	nop	

	j MAIN_SELECT
	nop

UPDATE_BOX_L1:
		
	lw	$s5, 24($sp)		# X coordinate
	lw	$s6, 28($sp)		# Y coordinate
	
	slti	$t8, $s5, 81
	beq	$t8, 1, MAIN_SELECT
	
	addi	$a2, $a2, -1
	
	la	$t1, S1_BACK_BUFF	# SRAM buffer address
	li 	$t5, 50			# Ryu height (y)
	li 	$t6, 58			# Ryu height (y)
	jal CLEAN_PATH
	nop
	
	la	$t1, S12_BUFFER		
	la	$s7, S1_BACK_BUFF		
	lw	$s5, 24($sp)		# X coordinate
	addi	$s5, $s5, -33
	sw	$s5, 24($sp)	
	lw	$s6, 28($sp)		# Y coordinate
	li 	$t5, 50			# Select height (y)
	li 	$t6, 0			# Select width (x)
	jal 	PRINT_SELECT		
	nop	

	j MAIN_SELECT
	nop

	
UPDATE_BOX_R1:
	
	lw	$s5, 24($sp)		# X coordinate
	lw	$s6, 28($sp)		# Y coordinate
	
	sgt	$t8, $s5, 170
	beq	$t8, 1, MAIN_SELECT
	
	addi	$a2, $a2, 1
	
	la	$t1, S1_BACK_BUFF	# SRAM buffer address
	li 	$t5, 50			# Ryu height (y)
	li 	$t6, 58			# Ryu height (y)
	jal CLEAN_PATH
	nop
	
	la	$t1, S12_BUFFER		
	la	$s7, S1_BACK_BUFF		
	lw	$s5, 24($sp)		# X coordinate
	addi	$s5, $s5, 33
	sw	$s5, 24($sp)		# X coordinate
	lw	$s6, 28($sp)		# Y coordinate
	li 	$t5, 50			# Select height (y)
	li 	$t6, 0			# Select width (x)
	jal 	PRINT_SELECT		
	nop	

	j MAIN_SELECT
	nop
	
UPDATE_BOX_U1:

	lw	$s5, 24($sp)		# X coordinate
	lw	$s6, 28($sp)		# Y coordinate
	
	slti	$t8, $s6, 160
	beq	$t8, 1, MAIN_SELECT
	
	addi	$a2, $a2, -4
	
	la	$t1, S1_BACK_BUFF	# SRAM buffer address
	li 	$t5, 50			# Ryu height (y)
	li 	$t6, 58			# Ryu height (y)
	jal CLEAN_PATH
	nop
	
	la	$t1, S12_BUFFER		
	la	$s7, S1_BACK_BUFF		
	lw	$s5, 24($sp)		# X coordinate
	lw	$s6, 28($sp)		# Y coordinate
	addi	$s6, $s6, -33
	sw	$s6, 28($sp)	
	li 	$t5, 50			# Select height (y)
	li 	$t6, 0			# Select width (x)
	jal 	PRINT_SELECT		
	nop	

	j MAIN_SELECT
	nop

	
UPDATE_BOX_D1:

	lw	$s5, 24($sp)		# X coordinate
	lw	$s6, 28($sp)		# Y coordinate
	
	sgt	$t8, $s6, 170
	beq	$t8, 1, MAIN_SELECT
	
	addi	$a2, $a2, 4
	
	la	$t1, S1_BACK_BUFF	# SRAM buffer address
	li 	$t5, 50			# Ryu height (y)
	li 	$t6, 58			# Ryu height (y)
	jal CLEAN_PATH
	nop
	
	la	$t1, S12_BUFFER		
	la	$s7, S1_BACK_BUFF		
	lw	$s5, 24($sp)		# X coordinate
	lw	$s6, 28($sp)		# Y coordinate
	addi	$s6, $s6, 33
	sw	$s6, 28($sp)		# X coordinate
	li 	$t5, 50			# Select height (y)
	li 	$t6, 0			# Select width (x)
	jal 	PRINT_SELECT		
	nop	

	j MAIN_SELECT
	nop

MOVE1_R:
	la	$t1, CHAR1_BUFFER		# SRAM buffer address
	lw	$s5, 0($sp)			# X coordinate
	lw	$s6, 4($sp)			# Y coordinate
	li 	$t5, 90				# Ryu height (y)
	li 	$t6, 60				# Ryu height (x)
	jal	CLEAN_PATH
	nop
	
	lw	$t0, 0($sp)		# X coordinate
	addi 	$t1, $t0, 5		# Add 20 steps when Ryu move to right
	sw	$t1, 0($sp)		# X updated

	lw	$t1, 40($sp)
	jal	PRINT_CHAR1
	nop	
	
	j	STAGE_LOOP
	nop

MOVE1_L:
	la	$t1, CHAR1_BUFFER		# SRAM buffer address
	lw	$s5, 0($sp)			# X coordinate
	lw	$s6, 4($sp)			# Y coordinate
	li 	$t5, 90				# Ryu height (y)
	li 	$t6, 60				# Ryu height (x)
	jal	CLEAN_PATH
	nop
	
	lw	$t0, 0($sp)		# X coordinate
	addi 	$t1, $t0, -5		# Sub 20 steps when Ryu move to left
	sw	$t1, 0($sp)		# X updated

	lw	$t1, 40($sp)
	jal	PRINT_CHAR1
	nop	
	
	j	STAGE_LOOP
	nop
	
MOVE2_R:
	la	$t1, CHAR2_BUFFER		# SRAM buffer address
	lw	$s5, 16($sp)			# X coordinate
	lw	$s6, 20($sp)			# Y coordinate
	li 	$t5, 90				# Ryu height (y)
	li 	$t6, 60				# Ryu height (x)
	jal	CLEAN_PATH
	nop
	
	lw	$t0, 16($sp)		# X coordinate
	addi 	$t1, $t0, 5		# Add 20 steps when Ryu move to right
	sw	$t1, 16($sp)		# X updated

	lw	$t1, 48($sp)
	jal	PRINT_CHAR2
	nop	
	
	j	STAGE_LOOP
	nop

MOVE2_L:
	la	$t1, CHAR2_BUFFER		# SRAM buffer address
	lw	$s5, 16($sp)			# X coordinate
	lw	$s6, 20($sp)			# Y coordinate
	li 	$t5, 90				# Ryu height (y)
	li 	$t6, 60				# Ryu height (x)
	jal	CLEAN_PATH
	nop
	
	lw	$t0, 16($sp)		# X coordinate
	addi 	$t1, $t0, -5		# Sub 20 steps when Ryu move to left
	sw	$t1, 16($sp)		# X updated

	lw	$t1, 48($sp)
	jal	PRINT_CHAR2
	nop	
	
	j	STAGE_LOOP
	nop
	
CLEAN_PATH:
	la	$t0, VGA_INI_ADDR	# VGA initial address
	
	move 	$t2, $zero		# First counter (c1) to print char
	move 	$t3, $zero		# Second counter (c2) to print char
	li 	$t4, 320		# Size of the screen
	
	FOR11:	
		beq 	$t2, $t5, OUT11	# If all the lines was print then exit ryu print (92)

	FOR22:	
		beq 	$t3, $t6, OUT22	# If all the columns was print then continue the outer loop (49)
		
		# sd (c1 * 49) + c2 -> lb
		mult 	$t2, $t6	# (c1 * 49)
		mflo	$t9		#
		add	$s0, $t9, $t3	# (c1 * 49) + c2
		add	$s1, $s0, $t1	# Add on char's address on SD card
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
	
PRINT_SELECT:
	la	$t0, VGA_INI_ADDR	# VGA initial address
	
	move 	$t2, $zero		# First counter (c1) to print char
	move 	$t3, $zero		# Second counter (c2) to print char
	
	li 	$t4, 320		# Size of the screen

	FOR1S1:	
		beq 	$t2, $t5, OUT1S1		# If all the lines was print then exit ryu print (50)

	FOR2S1:	
		beq 	$t3, 58, OUT2S1		# If all the columns was print then continue the outer loop (58)
		
		# sd (c1 * 320) + (c2 + x) -> lb
		mult 	$t2, $t4	# (c1 * 320)
		mflo	$t9		#
		add	$s0, $t9, $t3	# (c1 * 320) + c2
		add	$s0, $s0, $t6	# (c1 * 320) + (c2 + x)
		add	$s1, $s0, $t1	# Add on select address on SSRAM
		lb	$s2, 0($s1)
		
		# vga (y + c1)*320 + (x + c2) -> sb
		add	$t9, $s6, $t2	# y + c1
		mult	$t9, $t4	# (y + c1)*320
		mflo	$s1		#
		add	$s1, $s1, $s5	# (y + c1)*320 + x
		add	$s3, $s1, $t3	# (y + c1)*320 + (x + c2)
		add	$s4, $s3, $t0	# Add on VGA's address
		
		lb	$t7, 0($s4)	# Collect buffer behind character
		sb	$t7, 0($s7)	# Save buffer on SRAM
		add	$s7, $s7, 1 	# Increase SRAM's index
		
		sb	$s2, 0($s4)	# Print char on VGA

		addi 	$t3, $t3, 1
		
		j 	FOR2S1
		nop	
		
	OUT2S1:	
		addi 	$t2, $t2, 1
		move 	$t3, $zero
		
		j 	FOR1S1
		nop	
	OUT1S1:	
		jr	$ra
		nop
	
PRINT_CHAR1:
	la	$t0, VGA_INI_ADDR	# VGA initial address
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
		addi 	$t6, $t6, 60		# Next char sequence
				
		j 	FOR0C1
		nop
	
	OUT0C1:	
		jr	$ra
		nop
	
EXIT:
	la $s4, 0x0ACEF0DA
	j EXIT
	nop
