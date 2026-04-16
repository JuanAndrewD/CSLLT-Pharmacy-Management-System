; read_administrator_details.asm
; Description: Module to read administrator account details and management profiles.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: user.txt (user_id, user_name, user_type)

section .data
title db 10, "Administrator Details", 10, 0
user_file db "user.txt", 0
no_file db "No administrator details found.", 10, 0

section .bss
file_buf resb 4096

section .text
global read_administrator_details
extern print_string

read_administrator_details:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    mov eax, 5
    mov ebx, user_file
    mov ecx, 0
    int 0x80
    cmp eax, 0
    jl .no_users
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

.no_users:
    mov edi, no_file
    call print_string

.done:
    pop ebp
    ret