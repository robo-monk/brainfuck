.global brainfuck

char: .asciz "%c"

# lets
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	# rdi holds code pointer (cp)
	# r13 holds values pointer (vp) - tape
	# r12 holds andresses pointer (ap)

	movq %rbp, %r12 # holds value pointer

	movq %rbp, %r13
	subq $8000, %r13 # space for holding nested loops
	movq %r13, %r14 # holds max tape value

	movq $0, %rbx	# holds skip values

	jmp new_tape # reset first block in the stack value

	next_code_block:
		movq %r14, %rsp
		# write after the max value so we dont mess up the code

		/* 56(%rdi) is the code block */

		cmpb $0, 56(%rdi)
		je end_of_code	# if code block zero, end

		addq $1, %rdi 	# add 1 to code block counter

		cmpq $0, %rbx
		jg skip_code_block
		
		do_code_block:
			cmpb $62, 56(%rdi) # >
			je plus_vp

			cmpb $60, 56(%rdi) # <
			je min_vp

			cmpb $43, 56(%rdi) # +
			je plus_val

			cmpb $45, 56(%rdi) # -
			je minus_val

			cmpb $46, 56(%rdi) # .
			je write_val

			cmpb $91, 56(%rdi)
			je loop_inject

			cmpb $93, 56(%rdi) 
			je loop_eject

			cmpb $44, 56(%rdi) # ,
			je ask_val

			/*if none of the above*/
			jmp next_code_block
			
			min_vp:
				addq $8, %r13
				jmp next_code_block

			plus_vp:
				subq $8, %r13
				cmpq %r13, %r14
				jg new_tape

				jmp next_code_block
				new_tape:
					movq $0, (%r13) # reset tape value, as its a new andress
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
				jmp next_code_block
						
			loop_eject:
				cmpq $0, (%r13) 	# compare 0 to value currently pointed at
				je eject

				movq (%r12), %rdi 	# jmp to code block last pushed on andr. stack 	
				jmp next_code_block

				eject:
					addq $8, %r12 	# essentially pop last andress
					jmp next_code_block
			write_val:

				movq %rdi, %r15

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
			cmpb $91, 56(%rdi)
			je feed_skip

			cmpb $93, 56(%rdi) 
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
