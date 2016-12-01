.section .data

    .equ SYS_OPEN, 5
    .equ SYS_WRITE, 4
    .equ SYS_READ, 3
    .equ SYS_CLOSE, 6
    .equ SYS_EXIT, 1

    .equ O_RDONLY, 0
    .equ O_CREAT_WRONLY_TRUNC, 03101

    .equ STDIN, 0
    .equ STDOUT, 1
    .equ STDERR, 2

    .equ LINUX_SYSCALL, 0x80

    .equ END_OF_FILE, 0
    .equ NUMBER_ARGUMENTS, 2

read_mode:

    .string "r"

write_mode:

    .string "w"

.section .bss

    .equ BUFFER_SIZE, 500

    .lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

    .equ ST_SIZE_RESERVE, 8
    .equ ST_FD_IN, -4
    .equ ST_FD_OUT, -8
    .equ ST_ARGC, 0
    .equ ST_ARGV_0, 4
    .equ ST_ARGV_1, 8
    .equ ST_ARGV_2, 12

    .globl _start

_start:

    movl %esp, %ebp

    subl $ST_SIZE_RESERVE, %esp

open_files:
open_fd_in:

    pushl $read_mode
    pushl ST_ARGV_1(%ebp)
    call fopen
    addl $8, %esp

store_fd_in:

    movl %eax, ST_FD_IN(%ebp)

open_fd_out:

    pushl $write_mode
    pushl ST_ARGV_2(%ebp)
    call fopen
    addl $8, %esp

store_fd_out:

    movl %eax, ST_FD_OUT(%ebp)

read_loop_begin:

    pushl ST_FD_IN(%ebp)
    pushl $BUFFER_SIZE
    pushl $BUFFER_DATA
    call fgets
    addl $12, %esp

    cmpl $END_OF_FILE, %eax
    jle end_loop

continue_read_loop:

    pushl $BUFFER_DATA
    call convert_to_upper
    addl $4, %esp

    pushl ST_FD_OUT(%ebp)
    pushl $BUFFER_DATA
    call fputs
    addl $8, %esp

    jmp read_loop_begin

end_loop:

    pushl ST_FD_IN(%ebp)
    call fclose
    addl $4, %esp

    pushl ST_FD_OUT(%ebp)
    call fclose
    addl $4, %esp

    pushl $0
    call exit

    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL


    .equ LOWERCASE_A, 'a'
    .equ LOWERCASE_Z, 'z'
    .equ UPPER_CONVERSION, 'A' - 'a'

    .equ ST_BUFFER, 8

convert_to_upper:

    pushl %ebp
    movl %esp, %ebp

    movl ST_BUFFER(%ebp), %eax
    movl $0, %edi

convert_loop:

    movb (%eax, %edi, 1), %cl

    cmpb $0, %cl
    je end_convert_loop

    cmpb $LOWERCASE_A, %cl
    jl next_byte

    cmpb $LOWERCASE_Z, %cl
    jg next_byte

    addb $UPPER_CONVERSION, %cl
    movb %cl, (%eax, %edi, 1)

next_byte:

    incl %edi
    jmp convert_loop

end_convert_loop:
    
    movl %ebp, %esp
    popl %ebp
    ret


