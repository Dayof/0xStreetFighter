.eqv VGA_INI_ADDR 0xFF000000
.eqv SD_DATA_ADDR 0x00475000
.eqv USER_DATA    0x10012000
.eqv VGA_QTD_BYTE 76800	
.eqv KEN_STAGE	0x00475000
.eqv KEN1	0x004ED000
.eqv KEN2	0x004EF000
.eqv KEN3	0x004E9000
.eqv KEN4	0x004EB000

.data

	lutador: .byte 92,49,0,0
	buf: .space 5300
	bufe:	.byte 92,49,0,0
	salvo: .space 5300
	
.text

.macro VGA_INIT
	la	$a1, USER_DATA		# Destiny of the address to read SD card 
 	la	$a2, VGA_QTD_BYTE	# Bytes size to read, image size 320*240
 	
	li	$v0, 49			# SYSCALL 49 - read from sd card 
	syscall				#
	
	la	$t0, VGA_INI_ADDR	# Reset vga and sram addresses
	la	$t1, USER_DATA		#
	li	$t3, VGA_QTD_BYTE	#
.end_macro

	main:	
		la	$a0, SD_DATA_ADDR
		add 	$a0, $a0, 0x00010E00
		VGA_INIT
		
		WRITE_VGA:			#	
			lw	$t2, ($t1)	#
			sw	$t2, ($t0)	#
			addi	$t0, $t0, 4	#
			addi	$t1, $t1, 4	#
			addi 	$t3, $t3, -4	#
						#
		slti 	$t4, $t3, 1		#
		beq 	$t4, $zero, WRITE_VGA	#
		
		add $t8, $zero, $t7		# T9 = ENDERECO DA SEGUNDA IMAGEM DO CARTAO
		add $t8, $t8, 0x00010E00	# ADICIONA A DEFASAGEM FISICA DO CARTAO SD, VARIA DE CARTAO PARA CARTAO
	
		add $t7, $t7, 0x0002000	# ESPACO ENTRE OS ENDERECOS DAS IMAGENS
		
		add	$a0, $zero, $t8		# Read the correct address to read the image from SD card 

	    mov:
	    	# FIRST KEN
	    	la	$a0, KEN1
	    	add 	$a0, $a0, 0x00010E00
		la	$a1, USER_DATA		# Destiny of the address to read SD card 
 		li	$a2, 5270		# Bytes size to read, image size 320*240
 	
		li	$v0, 49			# SYSCALL 49 - read from sd card 
		syscall				#

		# Le o sprite para a memoria BUFFER
		la $a0, USER_DATA
		la $a1, buf
		li $a2, 5270
		li $v0, 14
		syscall

		la $a0, lutador
		li $a1, 100
		li $a2, 100
		la $s1, salvo
		jal PrintLutador
	
	li $v0, 10 	################# exit ################
	syscall		#################      ################
	

		
PrintLutador: 
# imprime o sprite na tela
	lb $t0, 0($a0)		# TamX
	lb $t1, 1($a0)		# TamY
	
	addi $a0, $a0, 4		
	move $t2, $zero
	move $t3, $zero

	li $t5, 320
	mult $a1, $t5		# 320*x
	mflo $t4
	add $t4, $t4, $a2		# +y
	la $t6, VGA_INI_ADDR
	add $t6, $t6, $t4    # endere�o inicial de impress�o do sprite
	move $t8, $t6
	
for1:	beq $t2, $t0, out1

for2:	beq $t3, $t1, out2
	lb $t7, 0($a0)
	lb $s2, 0($t6)#
	sb $s2, 0($s1)#
	sb $t7, 0($t6)
	addi $s1, $s1, 1
	addi $a0 ,$a0, 1 
	addi $t6, $t6, 1
	addi $t3, $t3, 1
	j for2
	
out2:	addi $t6, $t8, 320
	move $t8, $t6
	addi $t2, $t2, 1
	move $t3, $zero
	j for1
	
out1:	jr $ra


