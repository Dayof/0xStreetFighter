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
#	Unit Width: ?                 			  	#
#	Unit Height: ?               			  	#
# 	Display Width: ?                                  	#
# 	Display Height: ?                                 	#
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
.eqv SD_DATA_ADDR 0x00413E00		# ARQUIVO.txt sem header.
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

### PS2 INTERFACE ###  
.eqv KB1	0xFFFF0100		# PS2 Keyboard Buffer0
.eqv KB2	0xFFFF0104		# PS2 Keyboard Buffer1
.eqv K1		0xFF100520		# PS2 Keyboard KEY0
.eqv K2		0xFF100524		# PS2 Keyboard KEY1
.eqv K3		0xFF100528		# PS2 Keyboard KEY2
.eqv K4		0xFF10052C		# PS2 Keyboard KEY3

### KEYBOARD MAP ### 
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
	jal 	KEYBOARD
	jal 	VGA
	move 	$s3, $zero 		# init stage index count
	j 	MAIN

VGA:
	la	$a0, SD_DATA_ADDR	# CARREGA O ENDERENCO INICIAL DO SD CARD E PRIMEIRO MAPA
	la	$a1, USER_DATA		# DESTINO DA LEITURA DO CARTAO
 	la	$a2, VGA_QTD_BYTE	# TAMANHO DE BYTES LIDOS , BASICAMENTE O TAMANHO DE UMA IMAGEM 320*240
 	
	li	$v0, 49			# SYSCALL 49 - LEITURA DO SD CARD 
	syscall				#################################
	
	# Usado para verificar os dados lidos usando o In System Memory Content Editor
	
	la	$t0, VGA_INI_ADDR	#################################
	la	$t1, USER_DATA		######### Verifica os dados lidos
	li	$t3, VGA_QTD_BYTE	#################################
	
	li 	$t5, 12			#### Para loop de print dos mapas
	li 	$t6, 0			#################################
	
	addi 	$s3, $s3, 1		# stage index count to 1
	
PRINT_VGA:	
	WRITE_VGA:			
 		lw	$t2, ($t1)	
		sw	$t2, ($t0)	
		addi	$t0, $t0, 4	
		addi	$t1, $t1, 4	
		addi 	$t3, $t3, -4	
					
	slti 	$t4, $t3, 1		
	beq 	$t4, $zero, WRITE_VGA	
	
	jr 	$ra

KEYBOARD:
	la 	$s0, 0xFF100100  	# PS2 Keyboard Buffer0
	jr 	$ra

MAIN:
	lw 	$s1,0($s0)		# get key from buffer
	
	sll 	$s2, $s1, 24		# shift 24 bits left on the buffer
					# in case the buffer is full
					
	beq 	$s2, LEFT, 	EXIT	# test if 'a' was pressed
	beq 	$s2, DOWN, 	EXIT	# test if 's' was pressed
	beq 	$s2, RIGHT, 	MAPR	# test if 'd' was pressed
	beq 	$s2, UP, 	EXIT	# test if 'w' was pressed
	beq 	$s2, L_PUNCH, 	EXIT	# test if 'g' was pressed
	beq 	$s2, L_KICK, 	EXIT	# test if 'b' was pressed
	beq 	$s2, ENTER, 	EXIT	# test if 'o' was pressed
	beq 	$s2, BACK, 	EXIT	# test if 'p' was pressed
	
	j 	MAIN

SECOND_STAGE:
	li 	$t7, 0X004D4000		########### Endereco segundo mapa
	add	$t8, $zero, $t7		# T9 = ENDERECO DA SEGUNDA IMAGEM DO CARTAO
	add 	$t8, $t8, 0x00010E00	# ADICIONA A DEFASAGEM FISICA DO CARTAO SD, VARIA DE CARTAO PARA CARTAO

PRINT_LOGIC:
	sub 	$t7, $t7, 0x00013000	# ESPACO ENTRE OS ENDERECOS DAS IMAGENS
	
	add	$a0, $zero, $t8		# CARREGA O ENDERENCO CORRETO DO SD PARA LER A IMAGEM ATUAL
	la	$a1, USER_DATA		# DESTINO DA LEITURA DO CARTAO
 	la	$a2, VGA_QTD_BYTE	# TAMANHO DE BYTES LIDOS , BASICAMENTE O TAMANHO DE UMA IMAGEM 320*240
 	
	li	$v0, 49			# SYSCALL 49 - LEITURA DO SD CARD 
	syscall				#################################
	
	la	$t0, VGA_INI_ADDR	#################################
	la	$t1, USER_DATA		######### Verifica os dados lidos
	li	$t3, VGA_QTD_BYTE	#################################
	
	jal 	PRINT_VGA
	
	j	EXIT
	
MAPR:
	addi 	$s3, $s3, 1
	beq 	$s3, 2, SECOND_STAGE
	
	slt 	$t7, $t6, $t5		#################################
	bne 	$t7, $zero, MAIN	#################################

EXIT:
	la $s4, 0x0ACEF0DA
	j EXIT
