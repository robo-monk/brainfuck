.include "write.s"
.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s"
digit: .asciz "%d "
char: .asciz "%c"
charn: .asciz "%c "
string: .asciz "%s"


# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	# rdi holds code pointer (cp)
	# r13 holds values pointer (vp) - tape
	# r12 holds andresses pointer (ap)

	movq %rbp, %r12
	movq %rbp, %r13
	subq $80000, %r13 # space for recursion

	movq %r13, %r14 # holds max tape value
	/*movq %r13, %rbx # holds min tape value*/

	movq $0, %rbx	# holds skip values

	/*movq -16(%r13), %rsi*/

	/*movq $digit, %rdi*/
	/*movq $0, %rax*/
	/*call printf*/

	jmp new_tape # reset first block in the stack value
	next_code_block:
		call get
		cmpq $0, %rax
		je end_of_code

		addq $1, %rdi

		movq %r14, %rsp
		/*subq $16, %rsp*/
		/*pushq %rdi*/
		/*pushq %rax*/

		/*movq $charn, %rdi*/
		/*movq %rax, %rsi*/
		/*movq $0, %rax*/
		/*call printf*/

		/*popq %rax*/
		/*popq %rdi*/

		cmpq $0, %rbx
		jg skip_code_block
		
		do_code_block:
			cmpq $60, %rax # <
			je min_vp
			cmpq $62, %rax # >
			je plus_vp
			cmpq $43, %rax # +
			je plus_val
			cmpq $45, %rax # -
			je minus_val
			cmpq $91, %rax
			je loop_inject
			cmpq $93, %rax 
			je loop_eject
			cmpq $46, %rax # .
			je write_val

			cmpq $44, %rax # ,
			je ask_val

			/*if none of the above*/
			jmp next_code_block
			
			min_vp:
				addq $8, %r13
				/*cmpq %r13, %rbx*/
				/*jl new_prev_tape*/

				jmp next_code_block
				new_prev_tape:
					/*movq $0, (%r13) # reset tape value, as its a new andress*/
					movq %r13, %rsp
					popq %r15
					push $0
					/*movq %r13, %rbx*/
					jmp next_code_block
				

			plus_vp:
				subq $8, %r13
				cmpq %r13, %r14
				jg new_tape

				jmp next_code_block
				new_tape:
					/*movq $0, (%r13) # reset tape value, as its a new andress*/
					movq %r13, %rsp
					popq %r15
					push $0
					movq %r13, %r14
					jmp next_code_block
				
			plus_val:
				incq (%r13)
				jmp next_code_block

			minus_val:
				decq (%r13)
				jmp next_code_block

			loop_inject:
				cmpq $0, (%r13) 	# compare 0 to value currently pointed at
				je feed_skip

				subq $8, %r12
				movq %rdi, (%r12)
				/*movq %rsp, %r12*/
				jmp next_code_block
						
					

			loop_eject:
				cmpq $0, (%r13) 	# compare 0 to value currently pointed at
				je eject

				movq (%r12), %rdi 	# jmp to code block last pushed on andr. stack 	
				/*decq %rdi*/
				/*movq $0, %rdi*/
				jmp next_code_block

				eject:
					/*addq $8, %r12 	# essentially pop last andress*/
					movq %r12, %rsp
					popq %r15
					movq %rsp, %r12
					jmp next_code_block
			write_val:

				movq %rdi, %r15
				movq $54, %rsi
				movq (%r13), %rsi
				movq $char, %rdi
				movq $0, %rax
				call printf

				movq %r15, %rdi
				jmp next_code_block
			ask_val:
				movq %rdi, %r15
				movq $0, %rax
				movq $char, %rdi
				leaq (%r13), %rsi
				call scanf
				movq %r15, %rdi


			jmp next_code_block	

		skip_code_block:
			cmpq $91, %rax
			je feed_skip

			cmpq $93, %rax 
			je eat_skip
			jmp next_code_block	

			feed_skip:
				incq %rbx
				jmp next_code_block
			eat_skip:
				decq %rbx
				jmp next_code_block



	end_of_code:
			
	movq %rbp, %rsp
	popq %rbp
	ret
