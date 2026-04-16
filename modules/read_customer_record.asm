; read_customer_record.asm
; Description: Module to read detailed customer records for administrators or pharmacists.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.

section .data
title db 10, "Customer Records", 10, 0
no_file db "No customer records are available.", 10, 0
record_file db "customer_records.txt", 0

section .bss
file_buf resb 4096

section .text
global read_customer_record
extern print_string

read_customer_record:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    mov eax, 5
    mov ebx, record_file
    mov ecx, 0
    int 0x80
    cmp eax, 0
    jl .no_records
    mov ebx, eax

    mov eax, 3
    mov ecx, file_buf
    mov edx, 4096
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, file_buf
    int 0x80

    mov eax, 6
    mov ebx, eax
    int 0x80
    jmp .done

.no_records:
    mov edi, no_file
    call print_string

.done:
    pop ebp
    ret