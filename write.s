.data
	ch_table: .asciz "0123456789%-"

# @Todo make this more efficient
get: # (memory andress)
     # returns the byte of the andress

	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	/*call printf*/
	/*movq $1, %rax			# 8 for 8 bits*/
	/*mulq %rsi			# 8bits * relative address stored in rsi*/
	/*addq %rax, %rdi			# go to the correct block*/
	/*addq $8, %rdi*/
	movq (%rdi), %rax		# contents of calculated address to rax

	shl $56, %rax			# chop off address + times
	shr $56, %rax			# shift right to compensate for the previous chopping

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

# params: memory_andress, relative_byte 
# ret: the byte 
get_byte:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq 	%r11
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	movq $1, %rax			# 8 for 8 bits
	mulq %rsi			# 8bits * relative address stored in rsi
	addq %rax, %rdi			# go to the correct block
	movq (%rdi), %rax		# contents of calculated address to rax

	shl $56, %rax			# chop off address + times
	shr $56, %rax			# shift right to compensate for the previous chopping

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq    %r11
	popq	%rbp			# restore base pointer location 
	ret


count: # (string to count)
# ret how many bytes a string is

	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx
	pushq 	%r11

	movq $0, %rsi
	call find			# find the 0 ( strings are 0 terminated )

	movq $-1, %r11
	mulq %r11

	# epilogue
	popq    %r11
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret

# ascii: | % - 32 | 0 - 0 | d - 64 | u - 32 | s - 74 |
find: # ( string andress to search, ascii to search )
# rets index, or -length of string if no match

	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%r11
	pushq	%r12			
	pushq	%r13
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq %rdi, %r11			# move the og thing to search to r12
	movq $0, %r12			# start scanning from the first byte			
	movq %rsi, %r13			# mov ascii character to find

	get_next_byte:

		movq %r11, %rdi		# address for stream byte			
		movq %r12, %rsi		# byte count as displacement
		call get_byte

		incq %r12		# incremenet byte_count

		cmpq $0, %rax 		# string is over and we dindt find shit 
		je did_not_find

		cmpq %rax, %r13
		jne get_next_byte

	return_index:
		movq %r12, %rax
		jmp find_epilogue

	did_not_find:
		movq $-1, %rax
		mulq %r12		# return -%r12, aka -length of string

	find_epilogue:
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%r13
	popq	%r12
	popq	%r11
	popq	%rbp			# restore base pointer location 
	ret


# WRITE

# params: string to print, how many bytes 
# ret: no
write_bytes:
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx
	pushq   %r11

	movq %rsi, %rdx			# bytes to write
	movq %rdi, %rsi
	movq $1, %rax			# sys_write
	movq $1, %rdi			# stdout
	syscall
	
	# epilogue
	popq 	%r11
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret
	
# params: string to print, ascii code of until, 0 if string doestn contain it
# ret:  until index (-1 if it doenst contain it)
write_until:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx
	pushq 	%r11

	pushq %rdi			# push string to print to the stack
	call find
	movq %rax, %r11			# hold find ret value to r11

	popq %rdi			# memory to print
	cmpq $0, %rax 			# string doesnt contain provided ascii
	jge write_until_bytes		# write string until the end

	# means that find returned negative 
	# inverse output of find and print 
	# length-n bytes
	movq $-1, %rax
	mulq %r11


	write_until_bytes:
	movq %rax, %rsi
	decq %rsi 			# write until (not including)

	pushq %r11
	call write_bytes
	popq %rax			# return the until index
	# epilogue
	popq 	%r11
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret


write_from_table: # ( index of character in table)

	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx
	pushq 	%r11

	pushq %rdi
	movq $ch_table, %rdi
	popq %rsi
	addq %rsi, %rdi
	movq $1, %rsi			# write 1 byte
	call write_bytes

	# epilogue
	popq %r11
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret

# params: string to print
# ret: no
write:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx

	pushq %rdi			# push string to print to the stack
	call count
	movq %rax, %rsi
	popq %rdi
	call write_bytes

	# epilogue
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret

