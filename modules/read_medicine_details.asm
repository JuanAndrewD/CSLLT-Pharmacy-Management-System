section .data
title db 10, "Medicine Inventory", 10, 0
medicine_file db "medicine.txt", 0
no_file db "No medicine inventory found.", 10, 0

section .bss
file_buf resb 4096

section .text
global read_medicine_details
extern print_string

read_medicine_details:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    mov eax, 5
    mov ebx, medicine_file
    mov ecx, 0
    int 0x80
    cmp eax, 0
    jl .no_inventory
    mov ebx, eax

    mov eax, 3
    mov ecx, file_buf
    mov edx, 4096
    int 0x80
    mov esi, eax
    mov eax, 4
    mov ebx, 1
    mov ecx, file_buf
    int 0x80

    mov eax, 6
    mov ebx, [ebp - 4] ; placeholder maybe not needed
    int 0x80
    jmp .done

.no_inventory:
    mov edi, no_file
    call print_string

.done:
    pop ebp
    ret