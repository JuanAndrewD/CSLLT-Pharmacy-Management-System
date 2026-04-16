; record_payment.asm
; Description: Module for recording payment details after an order is created by a customer.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: payment.txt or equivalent payment record storage

section .data
payment_file db "payment.txt", 0
newline db 10, 0
recorded db "Payment recorded.", 10, 0

section .text
global record_payment
extern print_string
extern input_buf

record_payment:
    push ebp
    mov ebp, esp

    mov eax, 5
    mov ebx, payment_file
    mov ecx, 0x601
    mov edx, 0644
    int 0x80
    mov esi, eax

    mov eax, 4
    mov ebx, esi
    mov ecx, input_buf
    call string_length
    int 0x80

    mov eax, 4
    mov ebx, esi
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 6
    mov ebx, esi
    int 0x80

    mov edi, recorded
    call print_string

    pop ebp
    ret

string_length:
    push ebp
    mov ebp, esp
    xor eax, eax
.len_loop:
    cmp byte [ecx + eax], 0
    je .len_done
    inc eax
    jmp .len_loop
.len_done:
    pop ebp
    ret