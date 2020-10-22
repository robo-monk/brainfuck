.global brainfuck

char: .asciz "%c"

brainfuck:
	pushq %rbp
	movq %rsp, %rbp

/*
 *
 *                     STACK LAYOUT SETUP
 *
 *    	   rbp				         r14
 *          | <-- andresses ---> | <--- tape ---> |
 *        	   .5kb      	       1kb
 *                 r12      	       r13
 *
 */
	movq %rbp, %r12 # holds andresses pointer

	movq %rbp, %r13
	subq $4000, %r13 # space for holding nested loops in bits

	movq $1000, %r15 # tape length in bytes
	movq %r13, %r14 

	init_tape:
		movq $0, (%r14) # reset tape value, as its a new andress
		subq $8, %r14
		decq %r15
		cmpq $0, %r15
		jne init_tape

	movq $0, %rbx	# holds skip values



	next_code_block:
		movq %r14, %rsp 	# write after the tape so we dont mess up the values
		
		incq %rdi 		# incq code pointer

		cmpq $0, %rbx		# rbx holds skip value
		jg skip_code_block	# if positive, skip this code block
		
		do_code_block:
			movb (%rdi), %r15b
			
			cmpb $43, %r15b # +
			je plus_val
			cmpb $45, %r15b # -
			je minus_val
			
			cmpb $60, %r15b # <
			je min_vp
			cmpb $62, %r15b	# >
			je plus_vp
			
			cmpb $91, %r15b # [
			je loop_inject
			cmpb $93, %r15b  # ]
			je loop_eject

			cmpb $46, %r15b # .
			je write_val
			cmpb $44, %r15b # ,
			je ask_val

			cmpb $0, %r15b
			je end_of_code	# if code block zero, end
 
			/* if none of the above */
			jmp next_code_block

			min_vp:
			        # comment below to activate turbo	
				/*addq $8, %r13*/
				/*jmp next_code_block*/

				addq $8, %r13		# point to previous location in tape
				incq %rdi

				cmpb $60, (%rdi) 	# probably next one will be <
				je min_vp

				jmp do_code_block 	# bad luck

			plus_vp:
			        # comment below to activate turbo	
				/*subq $8, %r13*/
				/*jmp next_code_block*/

				subq $8, %r13		# point to next location in tape
				incq %rdi

				cmpb $62, (%rdi)	# turbocharge
				je plus_vp

				jmp do_code_block

			plus_val:
				# comment below to activate turbo
				/*incq (%r13)*/
				/*jmp next_code_block*/

				xorq %r8, %r8			# reset r8
				do_plus_val:
					incq %r8		# r8 serves as an accumulator	

					incq %rdi
					cmpb $43, (%rdi)
					je do_plus_val		# redo if next is +

					addq %r8, (%r13)	# if not add the accumulator to the tape
					jmp do_code_block

			minus_val:
				# comment below to activate turbo
				/*decq (%r13)*/
				/*jmp next_code_block*/

				xorq %r8, %r8
				do_minus_val:
					incq %r8

					incq %rdi
					cmpb $45, (%rdi)
					je do_minus_val

					subq %r8, (%r13)
					jmp do_code_block


			loop_inject:
				cmpq $0, (%r13) 	# compare 0 to value currently pointed at
				je feed_skip

				subq $8, %r12
				movq %rdi, (%r12)	# push current code location to the andresses stack
				
				incq %rdi	

				# comment below to disable [-] boost
				cmpb $45, (%rdi)
				je try_sink_value

				jmp do_code_block
				
				try_sink_value: # optimizes for [-] sequences which set current tape value to zero
					incq %rdi
					cmpb $93, (%rdi)
					je sink_value

					// if not go back to the '-' and execute it
					decq %rdi
					jmp minus_val
				sink_value:
					movq $0, (%r13)
					jmp do_code_block
						
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
				xorq %rax, %rax
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

		skip_next_code_block:
			# rbx holds the skip value

			incq %rdi
			skip_code_block:
				cmpb $91, (%rdi)
				je feed_skip

				cmpb $93, (%rdi) 
				je eat_skip

				jmp skip_next_code_block

				feed_skip:
					incq %rbx	# if we increment it theres no way its zero, so skiiiiip
					jmp skip_next_code_block

				eat_skip:
					decq %rbx
					jmp next_code_block

	end_of_code:
			
	movq %rbp, %rsp
	popq %rbp
	ret
