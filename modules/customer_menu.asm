; customer_menu.asm
; Description: Customer menu module. Provides access for Customer to add medicine to {user_id}-cart, create payment,
;               and read {user_id} own personal order, prescription, and profile records.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/add_to_cart.asm, modules/create_payment.asm, modules/read_own_records.asm

section .data
customer_title db 10, "Customer Menu", 10, 0
customer_prompt db "1) Add to Cart", 10, "2) Create Payment", 10, "3) View My Records", 10, "4) Back", 10, 0
invalid_sel db "Invalid option. Please choose again.", 10, 0

section .text
global customer_menu
extern print_string
extern read_input
extern add_to_cart
extern create_payment
extern read_own_records
extern input_buf

customer_menu:
    push ebp
    mov ebp, esp

.customer_loop:
    mov edi, customer_title
    call print_string
    mov edi, customer_prompt
    call print_string

    mov ecx, input_buf
    mov edx, 4
    call read_input

    mov al, [input_buf]
    cmp al, '1'
    je do_add_to_cart
    cmp al, '2'
    je do_create_payment
    cmp al, '3'
    je do_read_records
    cmp al, '4'
    je .return
    mov edi, invalid_sel
    call print_string
    jmp .customer_loop

do_add_to_cart:
    call add_to_cart
    jmp .customer_loop

do_create_payment:
    call create_payment
    jmp .customer_loop

do_read_records:
    call read_own_records
    jmp .customer_loop

.return:
    pop ebp
    ret