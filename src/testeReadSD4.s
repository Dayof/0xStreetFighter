#################################################################################
#                       Teste Syscall SD Card Read                              #
#                                                                               #
#  - $a0    =    Origem Addr          [Argumento]                               #
#  - $a1    =    Destino Addr         [Argumento]                               #
#  - $a2    =    Quantidade de Bytes  [Argumento]                               #
#  - $v0    ?    Falha : Sucesso      [Retorno]                                 #
#                                                                               #
#################################################################################
#                           OBSERVA��ES                                         #
#                                                                               #
#  - O programa de teste l� sequencialmente "VGA_QTD_BYTE" bytes do cart�o SD a #
#     partir do endere�o "SD_DATA_ADDR" e grava os bytes lidos sequencialmente  #
#     a partir do endere�o de destino "VGA_INI_ADDR", exibindo na tela a imagem #
#     salva no cart�o SD.                                                       #
#                                                                               #
#  - O endere�o de in�cio dos dados desejados deve ser obtido para cada cart�o  #
#     SD usado com o uso de um Hex Editor. Para o Windows, recomendo o programa #
#     WinHex [ver. de avalia��o ou Melhores Lojas]. Lembrar de desconsiderar    #
#     os bytes de cabe�alho do arquivo a ser lido.                              #
#                                                                               #
#  - H� um offset de setores entre o endere�o l�gico (mostrado pelo Hex Editor) #
#     e o endere�o f�sico da mem�ria do cart�o SD. O offset deve ser adicionado #
#     ao endere�o do dado que se deseja obter.                                  #
#                                                                               #
#  - O hardware e o software de leitura de dados de cart�es SD n�o funciona para#
#     cart�es SDHC e SDXC, sendo limitado a cart�es SD de no m�ximo 2 Gb.       #
#                                                                               #
#  - O programa deve funcionar independente da formata��o do cart�o desde que   #
#     os dados sejam escritos na mem�ria do cart�o de maneira sequencial.       #
#                                                                               #
#   - Para converter as imagens .jpg, .png, etc foi utilizado o programa        #
#    Paint.net passando os arquivos para bmp de 24bits. Ent�o deve-se converter #
#    de bmp para um arquivo bin�rio .mif ou .txt utilizando o bmp2oacv2 (n�o    #
#    gera cabe�alho)                                                            #
#################################################################################

.eqv SD_DATA_ADDR 0x00413E00		# ARQUIVO.txt sem header. Addr = Offset.[Caso tenha header Addr = Offset + (137 * 512) = Offset + 0x00011200 (defasagem de setores l�gicos/f�sicos * tamanho do setor)]. Olhe pelo WinHex o offset do seu cart�o SD
.eqv VGA_INI_ADDR 0xFF000000		# FF000000 - C0   # Endere�o inicial da VGA, mas existe um BUG, que pode ser concertado ao subtrair um offest no endere�o da VGA
.eqv USER_DATA    0x10012000		# Endere�o da SRAM
.eqv VGA_QTD_BYTE 76800			# VGA Bytes
	.data
	
	.text
	
Main:
	la	$a0, SD_DATA_ADDR	# CARREGA O ENDERENCO INICIAL DO SD CARD
	la	$a1, USER_DATA		# DESTINO DA LEITURA DO CARTAO
 	la	$a2, VGA_QTD_BYTE	# TAMANHO DE BYTES LIDOS , BASICAMENTE O TAMANHO DE UMA IMAGEM 320*240
 	
	li	$v0, 49			# SYSCALL 49 - LEITURA DO SD CARD 
	syscall				#################################
	
	# Usado para verificar os dados lidos usando o In System Memory Content Editor
	
	la	$t0, VGA_INI_ADDR	#################################
	la	$t1, USER_DATA		######### Verifica os dados lidos
	li	$t3, VGA_QTD_BYTE	#################################
	
	li $t5, 12			#### Para loop de print dos mapas
	li $t6, 0			#################################
	
	li $t7, 0X004D4000		########### Endereco segundo mapa
   Maps:		
	WriteVGA:			#################################
 		lw	$t2, ($t1)	#################################
		sw	$t2, ($t0)	#################################
		addi	$t0, $t0, 4	#################################
		addi	$t1, $t1, 4	#################################
		addi 	$t3, $t3, -4	#################################
					#####################  Print Tela
	slti $t4, $t3, 1		#################################
	beq	$t4, $zero, WriteVGA	#################################
	
	add $t8, $zero, $t7		# T9 = ENDERECO DA SEGUNDA IMAGEM DO CARTAO
	add $t8, $t8, 0x00010E00	# ADICIONA A DEFASAGEM FISICA DO CARTAO SD, VARIA DE CARTAO PARA CARTAO
	
	sub $t7, $t7, 0x00013000	# ESPACO ENTRE OS ENDERECOS DAS IMAGENS
	 
	
	add	$a0, $zero, $t8		# CARREGA O ENDERENCO CORRETO DO SD PARA LER A IMAGEM ATUAL
	la	$a1, USER_DATA		# DESTINO DA LEITURA DO CARTAO
 	la	$a2, VGA_QTD_BYTE	# TAMANHO DE BYTES LIDOS , BASICAMENTE O TAMANHO DE UMA IMAGEM 320*240
 	
	li	$v0, 49			# SYSCALL 49 - LEITURA DO SD CARD 
	syscall				#################################
	
	la	$t0, VGA_INI_ADDR	#################################
	la	$t1, USER_DATA		######### Verifica os dados lidos
	li	$t3, VGA_QTD_BYTE	#################################
	
	addi $t6, $t6, 1		#################################	
	slt $t7, $t6, $t5		#################################
	beq $t7, $zero, fim		#################################
	j Maps				#################################
     
     fim:			
End:	j End
