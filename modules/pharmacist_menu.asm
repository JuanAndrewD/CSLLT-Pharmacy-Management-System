; pharmacist_menu.asm
; Description: Pharmacist menu module. Provides access to stock management and medicine details.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/check_stock_level.asm, modules/update_medicine_stock.asm, modules/read_medicine_details.asm

section .data
title db 10, "Pharmacist Menu", 10, 0
prompt db "1) Check Stock Level", 10, "2) Update Medicine Stock", 10, "3) Read Medicine Details", 10, "4) Back", 10, 0
invalid db "Invalid option.", 10, 0

section .text
global pharmacist_menu
extern print_string
extern read_input
extern check_stock_level
extern update_medicine_stock
extern read_medicine_details
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
    je do_check_stock
    cmp al, '2'
    je do_update_stock
    cmp al, '3'
    je do_read_medicine
    cmp al, '4'
    je return
    mov edi, invalid
    call print_string
    jmp menu_loop

do_check_stock:
    call check_stock_level
    jmp menu_loop

do_update_stock:
    call update_medicine_stock
    jmp menu_loop

do_read_medicine:
    call read_medicine_details
    jmp menu_loop

return:
    pop ebp
    ret