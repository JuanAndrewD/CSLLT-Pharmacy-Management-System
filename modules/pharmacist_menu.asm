; pharmacist_menu.asm
; Description: Pharmacist menu module. Provides access to prescription verification and customer record review.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/verify_prescription.asm, modules/read_customer_record.asm

section .data
title db 10, "Pharmacist Menu", 10, 0
prompt db "1) Verify Prescription", 10, "2) View Customer Records", 10, "3) Back", 10, 0
invalid db "Invalid option.", 10, 0

section .text
global pharmacist_menu
extern print_string
extern read_input
extern verify_prescription
extern read_customer_record
extern input_buf

pharmacist_menu:
    push ebp
    mov ebp, esp

menu_loop:
    mov edi, title
    call print_string
    mov edi, prompt
    call print_string

    mov ecx, input_buf
    mov edx, 4
    call read_input

    mov al, [input_buf]
    cmp al, '1'
    je do_verify
    cmp al, '2'
    je do_read
    cmp al, '3'
    je return
    mov edi, invalid
    call print_string
    jmp menu_loop

do_verify:
    call verify_prescription
    jmp menu_loop

do_read:
    call read_customer_record
    jmp menu_loop

return:
    pop ebp
    ret