.section .data
	instructions: .ascii "pd+-*/%&|!isjelg;"
.section .bss
	code: .space 1024
	input: .byte 0
	file: .space 256
.section .text
.global _start
_start:
	mov $0, %rax
	mov $0, %rdi
	lea code(%rip), %rsi
	mov $1024, %rdx
	syscall
	mov $0, %r12
	lea code(%rip), %r15
interpret:
	movzbq (%r15, %r12), %r14
	add $1, %r12
        p:
		cmpb $'p', %r14b
		jne d
		movzbq (%r15, %r12), %rax
		add $1, %r12
		push %rax
		jmp end
	d:
		cmpb $'d', %r14b
		jne plus
		pop %rax
		jmp end
	plus:
		cmpb $'+',  %r14b
		jne minus
		mov 8(%rsp), %rax
		mov (%rsp), %rbx
		add %rbx, %rax
		push %rax
		jmp end
	minus:
		cmpb  $'-', %r14b
		jne multiply
		mov 8(%rsp), %rax
		mov (%rsp), %rbx
		sub %rbx, %rax
		push %rax
		jmp end
	multiply:
		cmpb $'*', %r14b
		jne divide
		mov 8(%rsp), %rax
		mov (%rsp), %rbx
		imul %rbx, %rax
		push %rax
		jmp end
	divide:
		cmpb $'/', %r14b
		jne modulo
		mov $0, %rdx
		mov 8(%rsp), %rax
		mov (%rsp), %rbx
		idiv %rbx
		push %rax
		jmp end
	modulo:
		cmpb $'%', %r14b
		jne bool_and
		mov $0, %rdx
		mov 8(%rsp), %rax
		mov (%rsp), %rbx
		idiv %rbx
		push %rdx
		jmp end
	bool_and:
		cmpb $'&', %r14b
		jne bool_or
		mov 8(%rsp), %rax
		mov (%rsp), %rbx
		and %rbx, %rax
		push %rax
		jmp end
	bool_or:
		cmpb $'|', %r14b
		jne bool_not
		mov 8(%rsp), %rax
		mov (%rsp), %rbx
		or %rbx, %rax
		push %rax
		jmp end
	bool_not:
		cmpb $'!', %r14b
		jne i
		mov (%rsp), %rax
		not %rax
		push %rax
		jmp end
	i:
		cmpb  $'i', %r14b
		jne s
		mov $0, %rax
		mov $0, %rdi
		lea input(%rip), %rsi
		mov $1, %rdx
		syscall
		movzbq input(%rip), %rax
		push %rax
		jmp end
	s:
		cmpb $'s', %r14b
		jne j
		mov %rsp, %rsi
	s_loop:
		movzbq (%rsi), %r14
		cmpb $0, %r14b
		je end
		mov $1, %rax
		mov $1, %rdi
		mov $1, %rdx
		syscall
		add $8, %rsi
		jmp s_loop
	j:
		cmpb $'j', %r14b
		jne e
		pop %rax
		sub %rax, %r12
		jmp end
	e:
		cmpb $'e', %r14b
		jne l
		pop %rax
		mov (%rsp), %rbx
		mov 8(%rsp), %rcx
		cmp %rcx, %rbx
		je yes_for_jmps
	l:
		cmpb  $'l', %r14b
		jne g
		pop %rax
		mov (%rsp), %rbx
		mov 8(%rsp), %rcx
		cmp %rcx, %rbx
		jl yes_for_jmps
	g:
		cmpb $'g', %r14b
		jne halt
		pop %rax
		mov (%rsp), %rbx
		mov 8(%rsp), %rcx
		cmp %rcx, %rbx
		jg yes_for_jmps
	halt:
		cmpb $';', %r14b
		jne end
		mov $60, %rax
		mov $0, %rdi
		syscall
end:
	jmp interpret
yes_for_jmps:
	sub %rax, %r12
	jmp end
