; administrator_menu.asm
; Description: Administrator menu module. Provides access to user, customer, medicine, payment, and order management.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/add_medicine.asm, modules/create_order.asm, modules/read_administrator_details.asm,
;               modules/read_customer_details.asm, modules/read_medicine_details.asm,
;               modules/read_payment_details.asm, modules/read_pharmacist_details.asm

section .data
title db 10, "Administrator Menu", 10, 0
prompt db "1) Add Medicine", 10, "2) Read Administrator Details", 10, "3) Read Medicine Details", 10, "4) Read Pharmacist Details", 10, "5) Back", 10, 0
invalid db "Invalid option in administrator menu.", 10, 0

section .text
global administrator_menu
extern print_string
extern read_input
extern add_medicine
extern read_administrator_details
extern read_medicine_details
extern read_pharmacist_details
extern input_buf

administrator_menu:
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
    je do_add_medicine
    cmp al, '2'
    je do_read_admin
    cmp al, '3'
    je do_read_medicine
    cmp al, '4'
    je do_read_pharmacist
    cmp al, '5'
    je return

    mov edi, invalid
    call print_string
    jmp menu_loop

do_add_medicine:
    call add_medicine
    jmp menu_loop

do_read_admin:
    call read_administrator_details
    jmp menu_loop

do_read_medicine:
    call read_medicine_details
    jmp menu_loop

do_read_pharmacist:
    call read_pharmacist_details
    jmp menu_loop

return:
    pop ebp
    ret