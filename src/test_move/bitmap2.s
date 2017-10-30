###############################################
#  Programa de exemplo para bitmap display    #
#  Set 2017				      #
#  Marcus Vinicius			      #
###############################################
.eqv VGA 0xFF000000    #Primeiro endereço do Bitmap Display

.data 
SPRITE: .byte 92,49,0,0 #Altura da imagem, largura da imagem
BUFFER: .space 5300	#Endereço inicial do buffer
FILE2: .asciiz "parte1.bin"
FILE3: .asciiz "parte2.bin"
FILE4: .asciiz "parte3.bin"
FILE5: .asciiz "parte4.bin"
FILE6: .asciiz "invertido.bin"
FILE7: .asciiz "invertido2.bin"
FILE8: .asciiz "invertido3.bin"
FILE9: .asciiz "invertido4.bin"

.text
	addi $t8, $zero, 20  
	move $s0, $zero 	
LOOP3: 
	beq $t8, $s0, FORA3	#Loop para continuar a printar os personagens na tela
########################################################################################################################
# Abre o arquivo sprite
	la $a0,FILE2  	#pega o endereço da imagem
	li $a1,0 	#argumento para syscall
	li $a2,0 	#argumento para syscall
	li $v0,13 	#codigo para abrir o arquivo
	syscall

# Le o sprite para a memoria BUFFER
	move $a0,$v0 	#endereço da imagem 
	la $a1,BUFFER 	#endereço do buffer
	li $a2,5270 	#tamanho do buffer
	li $v0,14 	#codigo para ler oq esta no buffer
	syscall

#Fecha o arquivo
	li $v0,16	#Codigo para fechar arquivo	
	syscall		
	

	la $a0,SPRITE 	#pega o endereço do Sprite 
	li $a1,100	#Coordenada x, onde o sprite vai começar a ser printado
	li $a2,40	#Coordenada y, onde o sprite vai começar a ser printado
	jal PrintSprite	#Pula para a função que mostra o sprite
	
	j INVERTIDO	#Pula para a função que Printa o sprite adversario
	
	li $a0, 110	#Deley entre o print das imagens
	li $v0, 32	#Codigo para fazer o sistema para pelo gtempo indicado
	syscall

############################################################################################################################

Sprite1:			
# Abre o arquivo sprite
	la $a0,FILE3  #pega o endereço da imagem
	li $a1,0 #argumento para syscall
	li $a2,0 #argumento para syscall
	li $v0,13 #codigo para abrir a imagem
	syscall

# Le o sprite para a memoria BUFFER
	move $a0,$v0	#endereço da imagem 
	la $a1,BUFFER 	#endereço do buffer
	li $a2,5270 	#tamanho do buffer
	li $v0,14 	#codigo para ler do buffer
	syscall

#Fecha o arquivo
	li $v0,16
	syscall
	

	la $a0,SPRITE #pega o endereço do 
	li $a1,100
	li $a2,40
	jal PrintSprite
	
	j INVERTIDO2
	
	li $a0, 110
	li $v0, 32
	syscall
	
#################################################################################################################################	

Sprite2:	
	# Abre o arquivo sprite
	la $a0,FILE4  #pega o endereço da imagem
	li $a1,0 #argumento para syscall
	li $a2,0 #argumento para syscall
	li $v0,13 #codigo para ler
	syscall

# Le o sprite para a memoria BUFFER
	move $a0,$v0 #endereço da imagem 
	la $a1,BUFFER #endereço do buffer
	li $a2,5270 #tamanho do buffer
	li $v0,14
	syscall

#Fecha o arquivo
	li $v0,16
	syscall
	

	la $a0,SPRITE #pega o endereço do 
	li $a1,100
	li $a2,40
	jal PrintSprite
	
	j INVERTIDO3
	
	li $a0, 110
	li $v0, 32
	syscall
	
##################################################################################################################################

Sprite3:
# Abre o arquivo sprite
	la $a0,FILE5  #pega o endereço da imagem
	li $a1,0 #argumento para syscall
	li $a2,0 #argumento para syscall
	li $v0,13 #codigo para ler
	syscall

# Le o sprite para a memoria BUFFER
	move $a0,$v0 #endereço da imagem 
	la $a1,BUFFER #endereço do buffer
	li $a2,5270 #tamanho do buffer
	li $v0,14
	syscall

#Fecha o arquivo
	li $v0,16
	syscall
	

	la $a0,SPRITE #pega o endereço do 
	li $a1,100
	li $a2,40
	jal PrintSprite
	
	li $a0, 110
	li $v0, 32
	syscall
	
	j INVERTIDO4
	
	
FORA3:
	li $v0,10
	syscall
	
###########################################################################################################################

PrintSprite: 
# imprime o sprite na tela
	
	lb $t0,0($a0)		# Quantidade de linhas no sprite, TamX
	lb $t1,1($a0)		# Quantiadade de colunas no sprite, TamY
	la $s2, 0xFFFFFFFF	#Para printar branco na tela
	addi $a0,$a0,4		#Vai para a proxima word
	move $t2,$zero		#zerando os registradores, para usa-los com contadores
	move $t3,$zero
	
	li $t5,320		#Numeros de endereços em uma linha no bitmap display
	mul $t4,$a1,$t5		# 320*x, Calculando a linha inicial que o sprite deverá ser printado
	add $t4,$t4,$a2		# +y, calculando a coluna inicial que o sprite deverá ser printado
	la $t6,VGA		#Endereço inicial do bitmap display
	add $t6,$t6,$t4 	# endereço inicial de impressão do sprite
	move $t8,$t6		#Armazenando em T8 esse o endereço inial de impressão do sprite
LOOP1:	beq $t2,$t0,FORA1	#loop para contar quantas linhas ja foram printadas
LOOP2:	beq $t3,$t1,FORA2	#loop para contar quantas colunas ja foram printadas
	lb $t7,0($a0)		#lendo o conteudo que esta na memoria buffer
	sb $s2,0($t6)		#printando branco, para apagar o sprite anteiror
	sb $t7,0($t6)		#printando o conteudo lido da memoria buffer, no endereço inicial do sprite  
	addi $a0,$a0,1		#proximo endereço
	addi $t6,$t6,1		#proximo endereçe
	addi $t3,$t3,1		#proximo endereço
	j LOOP2			#volta para o loop
FORA2:	addi $t6,$t8,320	#Atualizando o registrador
	move $t8,$t6		#$t8 agora possui o endereço da proxima linha do bitmap, para continuar a imprimir na tela
	addi $t2,$t2,1		#Incrementar o contador de linhas
	move $t3,$zero		#zera o contador de colunas
	j LOOP1			#volta para o loop que printa as colunas
FORA1:	jr $ra

############################################################################################################################
INVERTIDO: 
	la $a0,FILE6  #pega o endereço da imagem
	li $a1,0 #argumento para syscall
	li $a2,0 #argumento para syscall
	li $v0,13 #codigo para ler
	syscall

# Le o sprite para a memoria BUFFER
	move $a0,$v0 #endereço da imagem 
	la $a1,BUFFER #endereço do buffer
	li $a2,5270 #tamanho do buffer
	li $v0,14
	syscall

#Fecha o arquivo
	li $v0,16
	syscall
	

	la $a0,SPRITE #pega o endereço do 
	li $a1,100
	li $a2,240
	jal PrintSpriteInvertido
		
	j Sprite1
	
	li $a0, 110
	li $v0, 32
	syscall

###########################################################################################################################
INVERTIDO2: 
	la $a0,FILE7  #pega o endereço da imagem
	li $a1,0 #argumento para syscall
	li $a2,0 #argumento para syscall
	li $v0,13 #codigo para ler
	syscall

# Le o sprite para a memoria BUFFER
	move $a0,$v0 #endereço da imagem 
	la $a1,BUFFER #endereço do buffer
	li $a2,5270 #tamanho do buffer
	li $v0,14
	syscall

#Fecha o arquivo
	li $v0,16
	syscall
	

	la $a0,SPRITE #pega o endereço do 
	li $a1,100
	li $a2,240
	jal PrintSpriteInvertido
	
	j Sprite2
	
	li $a0, 110
	li $v0, 32
	syscall

#####################################################################################################################
INVERTIDO3: 
	la $a0,FILE8  #pega o endereço da imagem
	li $a1,0 #argumento para syscall
	li $a2,0 #argumento para syscall
	li $v0,13 #codigo para ler
	syscall

# Le o sprite para a memoria BUFFER
	move $a0,$v0 #endereço da imagem 
	la $a1,BUFFER #endereço do buffer
	li $a2,5270 #tamanho do buffer
	li $v0,14
	syscall

#Fecha o arquivo
	li $v0,16
	syscall
	

	la $a0,SPRITE #pega o endereço do 
	li $a1,100
	li $a2,240
	jal PrintSpriteInvertido
	
	j Sprite3
	
	li $a0, 110
	li $v0, 32
	syscall
	
######################################################################################################################
INVERTIDO4: 
	la $a0,FILE9  #pega o endereço da imagem
	li $a1,0 #argumento para syscall
	li $a2,0 #argumento para syscall
	li $v0,13 #codigo para ler
	syscall

# Le o sprite para a memoria BUFFER
	move $a0,$v0 #endereço da imagem 
	la $a1,BUFFER #endereço do buffer
	li $a2,5270 #tamanho do buffer
	li $v0,14
	syscall

#Fecha o arquivo
	li $v0,16
	syscall
	

	la $a0,SPRITE #pega o endereço do 
	li $a1,100
	li $a2,240
	jal PrintSpriteInvertido
	
	li $a0, 110
	li $v0, 32
	syscall
	
	addi $s0, $s0, 1 
	j LOOP3
	
	
##############################################################################################################################	
PrintSpriteInvertido: 
# imprime o sprite na tela
	lb $t0,0($a0)		# Quantidade de linhas no sprite, TamX
	lb $t1,1($a0)		# Quantiadade de colunas no sprite, TamY
	la $s2, 0xFFFFFFFF	#Para printar branco na tela
	addi $a0,$a0,4		#Vai para a proxima word
	move $t2,$zero		#zerando os registradores, para usa-los com contadores
	move $t3,$zero
	
	li $t5,320		#Numeros de endereços em uma linha no bitmap display
	mul $t4,$a1,$t5		# 320*x, Calculando a linha inicial que o sprite deverá ser printado
	add $t4,$t4,$a2		# +y, calculando a coluna inicial que o sprite deverá ser printado
	la $t6,VGA		#Endereço inicial do bitmap display
	add $t6,$t6,$t4 	# endereço inicial de impressão do sprite
	move $t8,$t6		#Armazenando em T8 esse o endereço inial de impressão do sprite
LOOP4:	beq $t2,$t0,FORA4	#loop para contar quantas linhas ja foram printadas
LOOP5:	beq $t3,$t1,FORA5	#loop para contar quantas colunas ja foram printadas
	lb $t7,0($a0)		#lendo o conteudo que esta na memoria buffer
	sb $s2,0($t6)		#printando branco, para apagar o sprite anteiror
	sb $t7,0($t6)		#printando o conteudo lido da memoria buffer, no endereço inicial do sprite  
	addi $a0,$a0,1		#proximo endereço
	addi $t6,$t6,1		#proximo endereçe
	addi $t3,$t3,1		#proximo endereço
	j LOOP5			#volta para o loop
FORA5:	addi $t6,$t8,320	#Atualizando o registrador
	move $t8,$t6		#$t8 agora possui o endereço da proxima linha do bitmap, para continuar a imprimir na tela
	addi $t2,$t2,1		#Incrementar o contador de linhas
	move $t3,$zero		#zera o contador de colunas
	j LOOP4			#volta para o loop que printa as colunas
FORA4:	jr $ra

##########################################################################################################################
