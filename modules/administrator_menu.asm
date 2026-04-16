; administrator_menu.asm
; Description: Administrator menu module. Provides access to user, customer, medicine, payment, and order management.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/add_medicine.asm, modules/create_order.asm, modules/read_administrator_details.asm,
;               modules/read_customer_details.asm, modules/read_medicine_details.asm,
;               modules/read_payment_details.asm, modules/read_pharmacist_details.asm,
;               modules/update_customer_record.asm, modules/update_medicine.asm, modules/update_user_details.asm

section .data
title db 10, "Administrator Menu", 10, 0
prompt db "1) Add Medicine", 10, "2) Create Order", 10, "3) Read Administrator Details", 10, "4) Read Customer Details", 10, "5) Read Medicine Details", 10, "6) Read Payment Details", 10, "7) Read Pharmacist Details", 10, "8) Update Customer Record", 10, "9) Update Medicine", 10, "A) Update User Details", 10, "B) Back", 10, 0
invalid db "Invalid option in administrator menu.", 10, 0

section .text
global administrator_menu
extern print_string
extern read_input
extern add_medicine
extern create_order
extern read_administrator_details
extern read_customer_details
extern read_medicine_details
extern read_payment_details
extern read_pharmacist_details
extern update_customer_record
extern update_medicine
extern update_user_details
extern input_buf

administrator_menu:
    push ebp
    mov ebp, esp

.menu_loop:
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
    je do_create_order
    cmp al, '3'
    je do_read_admin
    cmp al, '4'
    je do_read_customer
    cmp al, '5'
    je do_read_medicine
    cmp al, '6'
    je do_read_payment
    cmp al, '7'
    je do_read_pharmacist
    cmp al, '8'
    je do_update_customer
    cmp al, '9'
    je do_update_medicine
    cmp al, 'A'
    je do_update_user
    cmp al, 'a'
    je do_update_user
    cmp al, 'B'
    je .return
    cmp al, 'b'
    je .return

    mov edi, invalid
    call print_string
    jmp .menu_loop

do_add_medicine:
    call add_medicine
    jmp .menu_loop

do_create_order:
    call create_order
    jmp .menu_loop

do_read_admin:
    call read_administrator_details
    jmp .menu_loop

do_read_customer:
    call read_customer_details
    jmp .menu_loop

do_read_medicine:
    call read_medicine_details
    jmp .menu_loop

do_read_payment:
    call read_payment_details
    jmp .menu_loop

do_read_pharmacist:
    call read_pharmacist_details
    jmp .menu_loop

do_update_customer:
    call update_customer_record
    jmp .menu_loop

do_update_medicine:
    call update_medicine
    jmp .menu_loop

do_update_user:
    call update_user_details
    jmp .menu_loop

.return:
    pop ebp
    ret