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
#	Base Address for Display: 0xFF000000 (Memory map) 	#
#################################################################

.eqv READ	0xFF100004		# address to get char typed from keyboard 
.eqv PRINT	0xFF10000C		# address to display char typed from keyboard
.eqv LEFT	0x00000061		# 'a'
.eqv DOWN	0x00000073		# 's'
.eqv RIGHT	0x00000064		# 'd'
.eqv UP		0x00000077		# 'w'

.data
	END: .asciiz "\nEND"
.text

INIT:
	j MAIN
	
FINISH: 
	li $v0, 11
	la $a0, 0($t0)
	syscall
	
	li $v0, 4
	la $a0, END
	syscall
	
	j EXIT
	
MAIN:	
	lw $t0, READ			# read char
	
	beq $t0, LEFT, 	FINISH		# wait for a 'a' character
	beq $t0, DOWN, 	FINISH		# wait for a 's' character
	beq $t0, RIGHT, FINISH		# wait for a 'd' character
	beq $t0, UP, 	FINISH		# wait for a 'w' character
	
	li $a0, 250			#
	li $v0, 32			# pause for 500 ms
	syscall				#
	
	sw $t0, PRINT			# print char
	
	j MAIN

EXIT:
	li $v0, 10			# exit program
	syscall 
	
	
