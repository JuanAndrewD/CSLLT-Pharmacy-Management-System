; create_payment.asm
; Description: Module to create payment records and calculate transaction totals.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/record_payment.asm

section .data
title db 10, "Create Payment", 10, 0
prompt_amount db "Enter payment amount: ", 0

section .text
global create_payment
extern print_string
extern read_input
extern record_payment
extern input_buf

create_payment:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    mov edi, prompt_amount
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input

    call record_payment

    pop ebp
    ret