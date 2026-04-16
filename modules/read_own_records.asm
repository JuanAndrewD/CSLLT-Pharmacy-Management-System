; read_own_records.asm
; Description: Customer-facing module to view personal order, prescription, and profile records.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.

section .data
title db 10, "Your Records", 10, 0
no_file db "No records found for this customer.", 10, 0
cart_suffix db "-cart.txt", 0

section .bss
file_buf resb 4096
cart_path resb 64

section .text
global read_own_records
extern print_string
extern current_user_id

read_own_records:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    mov esi, current_user_id
    mov edi, cart_path
    call copy_string
    mov esi, cart_suffix
    call append_string

    mov eax, 5
    mov ebx, cart_path
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

copy_string:
    push ebp
    mov ebp, esp
.copy_loop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne .copy_loop
    pop ebp
    ret

append_string:
    push ebp
    mov ebp, esp
    call copy_string
    pop ebp
    ret