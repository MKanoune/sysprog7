.section .data

num_string:

    .string "%d\n"

.section .text

    .globl _start

_start:

    pushl $5
    call factorial
    addl $4, %esp

    pushl %eax
    pushl $num_string
    call printf
    addl $8, %esp

    movl %eax, %ebx
    movl $1, %eax
    int $0x80

