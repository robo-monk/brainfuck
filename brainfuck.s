#Lab bonus assignment 6
#27/10/2019
#
#Proudly written by:
#Panagiotis Papadopoulos (student number 5054443)
#Amir van Delft (student number 5020794)

.data
ArrayOfCells: .skip 50000	#Allocate space for the cells  

.text
input1: .asciz "%c"	#the inputs are just characters 
newline: .asciz "\n"	#print a new line after the result is being print

.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp	#initialize the base pointer
	movq %rsp, %rbp	#move the stack pointer where the base pointer is

	movq $0, %r15	#That's the counter for the nested loops   
	movq %rdi, %r14	#put the string with the commands in r14 in order to compute.
	decq %r14	#decrement the instructions pointer because we increment it in the loop wholeProgram (r14 basically is the string and (%r14) is the char of the array of chars where the pointer is)
	movq $0, %r13	#put the cell pointer to point to the first cell
	movq $1, %r12	#boolean variable that checks whether this is the first "["    ~assuming by default that yes it is

	movq %rdi, %rsi	#prints the message in format_str
	movq $format_str, %rdi
	call printf
	movq $0, %rax


wholeProgram:
	incq %r14 #move the pointer to the next char-command in the string	

	cmpb $62, (%r14) #1stCase is the command ">"
	je firstCase	#jump to the corresponding label
	cmpb $60, (%r14) #2ndCase is the command "<"
	je secondCase	#jump to the corresponding label
	cmpb $43, (%r14) #3rdCase is the command "+"
	je thirdCase	#jump to the corresponding label
	cmpb $45, (%r14) #4thCase is the command "-"
	je fourthCase	#jump to the corresponding label
	cmpb $46, (%r14) #5thCase is the command "."
	je fifthCase	#jump to the corresponding label
	cmpb $44, (%r14) #6thCase is the command ","
	je sixthCase	#jump to the corresponding label
	cmpb $91, (%r14) #7thCase is the command "["
	je seventhCase	#jump to the corresponding label
	cmpb $93, (%r14) #8thCase is the command "]"
	je eighthCase	#jump to the corresponding label
	
	cmpb $0, (%r14)	#if the command is a 0 that means the program has ended 
	je endOfBF	#jump to the end of this subroutine

	jmp wholeProgram	#if none of the above was satisfied, jump to the start of the loop (so basically move to the next command)

firstCase: 
	incq %r13	#increment the cell pointer
	jmp wholeProgram	#go to the next instruction

secondCase:
	decq %r13	#increment the cell pointer
	jmp wholeProgram	#go to the next instruction

thirdCase:
	
	incq ArrayOfCells(%r13)	#increment the value in the cell where the cell pointer points	
	jmp wholeProgram	#go to the next instruction
	
fourthCase:
	decq ArrayOfCells(%r13)	#decrement the value in the cell where the cell pointer points
	jmp wholeProgram	#go to the next instruction

fifthCase:
	movq $input1, %rdi	#move the type of the output in rdi	
	movq ArrayOfCells(%r13), %rsi	#move the result from r13 to rsi in order to print
	movq $0, %rax			#no vector arguments
	call printf
	jmp wholeProgram	#go to the next instruction

sixthCase:
	pushq %rbp	#initialize a new stack frame to put the value the user entered
	movq %rsp, %rbp
	
	subq $8, %rsp		#allocate 8 bytes to the stack frame
	leaq -8(%rbp), %rsi	#make rsi point 8 bytes above the base pointer
	movq $input1, %rdi	#copy the character to rdi
	movq $0, %rax		#no vector arguments
	call scanf
	movq -8(%rbp), %r12	#take the entered value and put it to r12
	movq %r12, ArrayOfCells(%r13)	#copy the character that the user entered to the cell at the pointer
	
	movq %rbp, %rsp	#deinitialize a new stack frame
	popq %rbp

	jmp wholeProgram	#go to the next instruction

seventhCase: 
	cmpb $0, ArrayOfCells(%r13)	#if the value of the cell just before the loop (r13) is NOT 0, that means the loop has NOT ended yet, so we need to continue doing the instructions between [ ]
	je elseBranch1	

#so this is the if branch
	pushq %r14	#push the address of that "["	
	incq %r15	#increment the loop counter
	jmp wholeProgram

elseBranch1:	#if the cell is 0
	movq %r15, %r11	#putting the counter in r11 in order to implement the while
	incq %r11	#decrement r11 (the counter) because we want to end up with r11 == r15

whileNotReachedMatchingEnd:
	cmpq %r11, %r15	#while the counters are not equal, continue looking for the next "]"
	je wholeProgram		
	
	incq %r14	#move to the next command
	
	cmpb $91, (%r14)	#if the command is [ we are going "deeper" in nested loops so we increment r11
	je foundOpenBracket
	
	cmpb $93, (%r14)	#if the command is ] we are going "upper" in nested loops so we decrement r11
	je foundCloseBracket

	jmp whileNotReachedMatchingEnd	
	
foundOpenBracket:
	incq %r11
	jmp whileNotReachedMatchingEnd

foundCloseBracket:
	decq %r11
	jmp whileNotReachedMatchingEnd
 
	
eighthCase:
	cmpb $0, ArrayOfCells(%r13)	#if the value of the cell just before the loop (r13) is 0, that means that the loop has ended so we want to continue with the next instruction
	jne elseBranch2
	
	popq %r10			#just throwing away the [ because we don't need it anymore
	decq %r15			#decrement the loop counter
	movq $1, %r12			#next loop we want to first execute the firstOpenBracket instructions
	jmp wholeProgram	

elseBranch2:	#if the value of the cell just before the loop (r13) is NOT 0, that means that the loop has not ended yet so we want to the next instruction after the corresponding "["
	movq (%rsp), %r14	#fetch the address of the corresponding "[" and move the instruction pointer there
	jmp wholeProgram	

endOfBF:
	movq $newline, %rdi		#copy the string "newline" to rdi
	movq $0, %rax			#no vector arguments
	call printf	 

	movq %rbp, %rsp	#deinitialize the stack frame
	popq %rbp
	ret
