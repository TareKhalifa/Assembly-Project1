.data
in: .space 200					#Input string
outbuf: .space 200				#output string	
symb: .ascii ")abcde%dubxXoscn"			#The string we use 			
msg: .asciiz "This is a message :)"
msg2: .ascii "The number of characters is: "
enter: .space 1					#the string we use to insert a new line
.align 2
gap: .word					#this is where we store by how much we jump because we put the numbers in the opposite way
.text
main:
li $t0,10					#10 is the ascii code for a new line
sb $t0,enter($0)				#Now enter is just a new line
li $t9,-48					#initializing our a b c d e variables
la $t8,msg
li $t7,735
li $t6,15
li $t5,70
la $a0,in					#taking the input string from the user		
li $a1,200					#Limit is 200 characters
li $v0,8
syscall
move $a1,$sp					#we save the address of the current place in the stack in a1 and pass it to the function
move $t0,$a0						#because this is from where we will get our variables because they are stored upside down
la $a2,outbuf					#load the address of the output string to a2
L1:    			#Look for the first "
lb $t1,0($t0)		#t0 for the address, t1 for the value
addi $t1,$t1,-34	#if you found " go to L2
beqz $t1,L2		
addi  $t0,$t0,1		#else move to the next character
j L1

L2:
move $a0,$t0		#here we just move the address of the place where we first found the " to a0 to pass to the function 
addi  $t0,$t0,1
L3:			#find the second quote
lb $t1,0($t0)		#we look for the second " then move to L4 where we save the variables in the stack
addi $t1,$t1,-34
beqz $t1,L4
addi  $t0,$t0,1
j L3

L4:			#find abcde
addi  $t0,$t0,1
la $s0,symb		#symb is the string containing the letters we need
lb $s1,0($s0)   	#S1 is )
lb $s2,1($s0)   	#S2 is a
lb $s3,2($s0)   	#S3 is b
lb $s4,3($s0)   	#S4 is c
lb $s5,4($s0)   	#S5 is d
lb $s6,5($s0)   	#S6 is e
L5:
lb $t1,0($t0)
beq $t1,$s1,Program	#if you found ) then you should start the function
beq $t1,$s2,L6		#else save the variable in the satck
beq $t1,$s3,L6
beq $t1,$s4,L6
beq $t1,$s5,L6
beq $t1,$s6,L6
j L4
Program:
jal sprintf			#go to the function
move $t0,$v0
move $t1,$v1			#after returning we just move the resulting string to t0
la $a0,msg2
li $v0,4			#print a0
syscall
move $a0,$t1			#and move the number of characters to a0
li $v0,1			#print a0
syscall	
la $a0,enter			#print a new line
li $v0,4			
syscall				
move $a0,$t0			#print the new string
li $v0,4
syscall
li $v0,10			#end the program
syscall

#####################################################################################
#start of function
sprintf:		
move $t0,$a0             #move address of input string into $t0
move $t3,$a1             #move the position of the elements in the stack to t3
move $t2,$a2		 #move the address of outbuf to t2
addi $sp,$sp,-32	 #save s0-s7 to the stack
sw $s0,0($sp)  
sw $s1,4($sp)
sw $s2,8($sp) 
sw $s3,12($sp) 
sw $s4,16($sp) 
sw $s5,20($sp)
sw $s6,24($sp)
sw $s7,28($sp)
L7:			#L7 is the start of our function
addi $t0,$t0,1		#we have the adress of the first " so we add one to get the first letter
lb $t1,0($t0)		#we load the character to t1
addi $t1,$t1,-34	#if it's " then it's the second " so we exit the program
beqz $t1,ExitProgram	#Exit program calculates the number of caharcters and returns it to main along with the outbuf string
lb $t1,0($t0)		#else load the byte again and check if it's any of the symbols below
la $s0,symb
lb $s7,6($s0)   	#S7 is %
li $s0,92 		#S0 is \
beq $t1,$s0,enterProbably	#if it's  a backslash then go to this label to check if it's followed by an n
beq $t1,$s7,replace	#if it's a % check if it's followed by a letter  u b x etc..
sb $t1,0($t2)		#else save the character to the outbuf
addi $t2,$t2,1		#advance in the output string
j L7
enterProbably:		#if you found a \n enter a new line else go back to the previous letter and print it normally
la $s0,symb
addi $t0,$t0,1		#\n = new line \anything else = normal characters
lb $t1,0($t0)
lb $s0,15($s0)   	#S0 is n
beq $s0,$t1,nIndeed
addi $t0,$t0,-1
lb $t1,0($t0)
sb $t1,0($t2)
addi $t2,$t2,1
j L7
nIndeed:
lb $t1,enter($0)		#replace the \n with a new line
sb $t1,0($t2)
addi $t2,$t2,1
j L7
replace:		#here we replace %b %u %s etc with the appropriate values
la $s0,symb
lb $s1,7($s0)   	#S1 is d
lb $s2,8($s0)   	#S2 is u
lb $s3,9($s0)   	#S3 is b
lb $s4,10($s0)   	#S4 is x
lb $s5,11($s0)   	#S5 is X
lb $s6,12($s0)   	#S6 is o
lb $s7,13($s0)   	#S7 is s
lb $s0,14($s0)   	#S0 is c
addi $t0,$t0,1
lb $t1,0($t0)		#if you find the appropriate value go to the designated label
beq $t1,$s3,binary
beq $t1,$s5,HEX
beq $t1,$s6,octal
beq $t1,$s4,hex
beq $t1,$s2,Unsigned_Decimal
beq $t1,$s0,character
beq $t1,$s1,signed
beq $t1,$s7,string
addi $t0,$t0,-1		#else then just print % and advance like with \
lb $t1,0($t0)
sb $t1,0($t2)
addi $t2,$t2,1
j L7
##############################
string:			#here we take the address of the string and print it character by character
la $s0,symb
lb $t4,13($s0)   	#t4 is s
j Choose		#choose is a label that loads letters a through e to choose the appropriate value
string2:
lb $t1,0($a0)		#here we put the string at that address in the outbuf string
beqz $t1,L7
sb $t1, 0($t2)
addi $t2,$t2,1
addi $a0,$a0,1
j string2
#############################
#a general note: we duplicate the number in all these labels because we need the number twice, one to account for
#its length in the output string and one to convert it to its appropriate form so we will always move a0 to a1 to have two 
#copies where we will use a1 to account for the length of the number/string and a0 to calculate its value
signed:			
la $s0,symb		
lb $t4,7($s0)   	#t4 is d
j Choose
sign:
move $a1,$a0		
andi $a1,$a1,0x80000000	#here we check if the most significant bit
beqz $a1,decimalu	#if it's zero then treat it as an unsigned number
xori $a0,0xffffffff	#else xor it with 32 1s to invert it and add 1 to get its two's compliment
addi $a0,$a0,1
li $t4,45
sb $t4,0($t2)		#then print a - sign in the string
addi $t2,$t2,1		#then advance in the string
j decimalu		#then treat it as an unsigned number
####################################
binary:	
la $s0,symb		
lb $t4,9($s0)   	#t4 is b
j Choose		#go and choose the appropriate value a b c e d
bin:
li $t4,0		
move $a1,$a0
beqz $a1,zero		#if the number is zero print 0
B_loop:			# account for space
beqz $a1,end_B_loop
srl $a1,$a1,1
addi $t4,$t4,1
j B_loop
end_B_loop:		#adjust the output string addresses
sw $t4,gap
add $t2,$t2,$t4
addi $t2,$t2,-1
B_loop2:
beqz $a0,L77            	  #if the number is empty, end
andi $t4,$a0,1               	  #bitwise and with 1 to get the least significant bit
add  $t4,$t4,48            	  #adding the ascii equivlanet of '0' to the bit
sb   $t4,0($t2)                 #store the value in the reserved space
sub  $t2,$t2,1                  #decrement the array address 
srl $a0,$a0,1                  #shift the value right by 1 to get the next bit
j B_loop2

##################################################################################################################
#Octal
octal:
la $s0,symb
lb $t4,12($s0)   	#t4 is o
j Choose
oct:			#exactly the same as binary except that we shift 3 bits instead of 1 because 2^3 = 8
li $t4,0
move $a1,$a0
beqz $a1,zero
octLoop:
beqz $a1,endOct                          
srl $a1,$a1,3    
addi $t4,$t4,1             
j octLoop
endOct:
sw $t4,gap
add $t2,$t2,$t4
addi $t2,$t2,-1
oct2:
beqz $a0,L77            	  #if the number is empty, end
andi $t4,$a0,7	        	  #bitwise and with 7 to get the least significant 3 bits
add  $t4,$t4,48            	  #adding the ascii equivlanet of '0' to the bit
sb   $t4,0($t2)                 #store the value in the reserved space
sub  $t2,$t2,1                  #decrement the array address 
srl $a0,$a0,3                  #shift the value right by 3 to get the next 3 bits
j oct2
############################################################################################################
#Upper Hexadecimal
HEX:			#Everything is the same as binary and octal except 4 bits instead of 1 and 3
la $s0,symb
lb $t4,11($s0)   	#t4 is X
j Choose
Upper_Hexadecimal:
li $t4,0
move $a1,$a0
beqz $a1,zero
HexLoop:
beqz $a1,endHex                          
srl $a1,$a1,4    
addi $t4,$t4,1             
j HexLoop
endHex:
sw $t4,gap
add $t2,$t2,$t4
addi $t2,$t2,-1
HU_loop:
beqz $a0,L77              #if the number is empty, end
andi $t4,$a0,15                 #bitwise and with 15 to get the least significant 4 bits
addi $a2,$0,9                  #%=9
bgt  $t4,$a2,HL1          
add  $t4,$t4,48                #adding the ascii equivlanet of '0' to the 4 bits  
sb   $t4,0($t2)                 #store the value in the reserved space
sub  $t2,$t2,1                  #decrment the array address
srl $a0,$a0,4                   #shift the value right by 4 to get the next 4 bits
j HU_loop
HL1:
add  $t4,$t4,55                #adding the ascii equivlanet
sb   $t4,0($t2)                 #store the value in the reserved space
sub  $t2,$t2,1                  #decrment the array address
srl $a0,$a0,4                   #shift the value right by 4 to get the next 4 bits
j HU_loop
############################################################################################################
Unsigned_Decimal:
la $s0,symb
lb $t4,8($s0)   	#t4 is u
j Choose
decimalu:
li $t1,10
li $t4,0
move $a1,$a0
beqz $a1,zero
udeci:
beqz $a1,enddeciu
addi $t4,$t4,1
divu $a1,$t1    #to divide the input by 10
mflo $a1	#to store the remainder in $t1        
j udeci
enddeciu:
sw $t4,gap
add $t2,$t2,$t4
addi $t2,$t2,-1
decu_loop:
	beqz $a0,L77
	li $t1,10
	divu $a0,$t1    #to divide the input by 10
	mfhi $t4 	#to store the remainder in $t1
	add $t4,$t4,48 #ascii of '0' is 48
	sb $t4,0($t2)
	sub $t2,$t2,1
	mflo $a0 #to store the result of the division in $a0
	j decu_loop
############################################################################################################
#Lower Hexadecimal
hex:
la $s0,symb
lb $t4,10($s0)   	#t4 is x
j Choose
Lower_Hexadecimal:
li $t4,0
move $a1,$a0
beqz $a1,zero
hexLoop:
beqz $a1,endhex                          
srl $a1,$a1,4    
addi $t4,$t4,1             
j hexLoop
endhex:
sw $t4,gap
add $t2,$t2,$t4
addi $t2,$t2,-1
hU_loop:
beqz $a0,L77              #if the number is empty, end
andi $t4,$a0,15                 #bitwise and with 15 to get the least significant 4 bits
addi $a2,$0,9                  #%=9
bgt  $t4,$a2,hL1          
add  $t4,$t4,48                #adding the ascii equivlanet of '0' to the 4 bits  
sb   $t4,0($t2)                 #store the value in the reserved space
sub  $t2,$t2,1                  #decrment the array address
srl $a0,$a0,4                   #shift the value right by 4 to get the next 4 bits
j hU_loop
hL1:
add  $t4,$t4,87                #adding the ascii equivlanet
sb   $t4,0($t2)                 #store the value in the reserved space
sub  $t2,$t2,1                  #decrment the array address
srl $a0,$a0,4                   #shift the value right by 4 to get the next 4 bits
j hU_loop
#######################################################################################################
#character
character:
la $s0,symb
lb $t4,14($s0)   	#t4 is c
j Choose
char:
sb $a0,0($t2)
addi $t2,$t2,1
j L7
Choose:			#Here we load a b c d e and compare them to the value we have from the stack and go to the appropriate label
addi $t3,$t3,-4
lb $a0,0($t3)
la $s0,symb
lb $s2,1($s0)   	#S2 is a
lb $s3,2($s0)   	#S3 is b
lb $s4,3($s0)   	#S4 is c
lb $s5,4($s0)   	#S5 is d
lb $s6,5($s0)   	#S6 is e
beq $a0,$s2,A
beq $a0,$s3,B
beq $a0,$s4,C
beq $a0,$s5,D
beq $a0,$s6,E
A:
lb $s1,7($s0)   	#S1 is d
lb $s2,8($s0)   	#S2 is u
lb $s3,9($s0)   	#S3 is b
lb $s4,10($s0)   	#S4 is x
lb $s5,11($s0)   	#S5 is X
lb $s6,12($s0)   	#S6 is o
lb $s7,13($s0)   	#S7 is s
lb $s0,14($s0)   	#S0 is c
move $a0,$t5
beqz $a0,zero
beq $t4,$s3,bin
beq $t4,$s5,Upper_Hexadecimal
beq $t4,$s6,oct
beq $t4,$s4,Lower_Hexadecimal
beq $t4,$s2,decimalu
beq $t4,$s0,char
beq $t4,$s1,sign
beq $t4,$s7,string2
B:
lb $s1,7($s0)   	#S1 is d
lb $s2,8($s0)   	#S2 is u
lb $s3,9($s0)   	#S3 is b
lb $s4,10($s0)   	#S4 is x
lb $s5,11($s0)   	#S5 is X
lb $s6,12($s0)   	#S6 is o
lb $s7,13($s0)   	#S7 is s
lb $s0,14($s0)   	#S0 is c

move $a0,$t6
beqz $a0,zero
beq $t4,$s3,bin
beq $t4,$s5,Upper_Hexadecimal
beq $t4,$s6,oct
beq $t4,$s4,Lower_Hexadecimal
beq $t4,$s2,decimalu
beq $t4,$s0,char
beq $t4,$s1,sign
beq $t4,$s7,string2
C:
lb $s1,7($s0)   	#S1 is d
lb $s2,8($s0)   	#S2 is u
lb $s3,9($s0)   	#S3 is b
lb $s4,10($s0)   	#S4 is x
lb $s5,11($s0)   	#S5 is X
lb $s6,12($s0)   	#S6 is o
lb $s7,13($s0)   	#S7 is s
lb $s0,14($s0)   	#S0 is c
move $a0,$t7
beqz $a0,zero
beq $t4,$s3,bin
beq $t4,$s5,Upper_Hexadecimal
beq $t4,$s6,oct
beq $t4,$s4,Lower_Hexadecimal
beq $t4,$s2,decimalu
beq $t4,$s0,char
beq $t4,$s1,sign
beq $t4,$s7,string2
D:
lb $s1,7($s0)   	#S1 is d
lb $s2,8($s0)   	#S2 is u
lb $s3,9($s0)   	#S3 is b
lb $s4,10($s0)   	#S4 is x
lb $s5,11($s0)   	#S5 is X
lb $s6,12($s0)   	#S6 is o
lb $s7,13($s0)   	#S7 is s
lb $s0,14($s0)   	#S0 is c
move $a0,$t8
beqz $a0,zero
beq $t4,$s3,bin
beq $t4,$s5,Upper_Hexadecimal
beq $t4,$s6,oct
beq $t4,$s4,Lower_Hexadecimal
beq $t4,$s2,decimalu
beq $t4,$s0,char
beq $t4,$s1,sign
beq $t4,$s7,string2
E:
lb $s1,7($s0)   	#S1 is d
lb $s2,8($s0)   	#S2 is u
lb $s3,9($s0)   	#S3 is b
lb $s4,10($s0)   	#S4 is x
lb $s5,11($s0)   	#S5 is X
lb $s6,12($s0)   	#S6 is o
lb $s7,13($s0)   	#S7 is s
lb $s0,14($s0)   	#S0 is c
move $a0,$t9
beqz $a0,zero
beq $t4,$s3,bin
beq $t4,$s5,Upper_Hexadecimal
beq $t4,$s6,oct
beq $t4,$s4,Lower_Hexadecimal
beq $t4,$s2,decimalu
beq $t4,$s0,char
beq $t4,$s1,sign
beq $t4,$s7,string2
zero:			#if the number is zero print zero and goto the next value
li $a0,48
sb $a0,0($t2)
addi $t2,$t2,1
j L7

L77:			#L77 accounts for how we insert numbers in an inverse manner so we add to the address of outbuf
lw $t4,gap		#the amount of bytes it needs to advance to continue counting correctly
addi $t2,$t2,1
add $t2,$t2,$t4
j L7

L6:			#here we save the variables in the stack
addi $sp,$sp,-4
sw $t1,0($sp)
j LL

LL:			#LL just adds 1 and continues looking for variables
addi $t0,$t0,1
j L5
ExitProgram:		#here is the end of the function
lw $s0,0($sp)  		#restore s0-s7 from the stack
lw $s1,4($sp)
lw $s2,8($s0) 
lw $s3,12($s0) 
lw $s4,16($s0) 
lw $s5,20($s0)
lw $s6,24($s0)
lw $s7,28($s0)
addi $sp,$sp,32
la $t2,outbuf	#load the output base address to t2 to start counting from the start
Count:
lb $t3,0($t2)		#count the number of characters
beqz $t3,endCount
addi $v1,$v1,1
addi $t2,$t2,1
j Count			#v1 holds the number of charcters in the string
endCount:		#loads the base address of outbuf to v0 and the number of characters in v1 and returns to main
la $v0,outbuf
jr $ra			#return 
