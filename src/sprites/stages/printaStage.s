.data 
STAGE: .asciiz "balrog.bin"
STAGE1: .asciiz "blanka.bin" 
STAGE2: .asciiz "chunli.bin"
STAGE3: .asciiz "dhalsim.bin"
STAGE4: .asciiz "ehonda.bin"
STAGE5: .asciiz "guile.bin"
STAGE6: .asciiz "ken.bin"
STAGE7: .asciiz "mbison.bin"
STAGE8: .asciiz "ryu.bin"
STAGE9: .asciiz "sagat.bin"
STAGE10: .asciiz "vega.bin"
STAGE11: .asciiz "zangief.bin"

.text
# Abre o arquivo
	la $a0,STAGE
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE1
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
	
# Abre o arquivo
	la $a0,STAGE2
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE3
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE4
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE5
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE6
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE7
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE8
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE9
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE10
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 
	
# Abre o arquivo
	la $a0,STAGE11
	li $a1,0
	li $a2,0
	li $v0,13
	syscall



# Le o arquivos para a memoria VGA
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall
	

#Fecha o arquivo
	move $a0,$s1
	li $v0,16
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall 