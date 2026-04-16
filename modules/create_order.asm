; create_order.asm
; Description: Module to create medicine orders and update inventory counts.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/update_medicine_stock.asm

section .data
title db 10, "Create Order", 10, 0
prompt_med_id db "Enter medicine ID for order: ", 0
prompt_qty db "Enter order quantity: ", 0
order_ok db "Order created successfully and inventory updated.", 10, 0
order_no db "Order cannot be created due to insufficient stock.", 10, 0

section .bss
order_qty resb 16
order_med resb 32

section .text
global create_order
extern print_string
extern read_input
extern check_stock_level
extern update_medicine_stock
extern input_buf

create_order:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    mov edi, prompt_med_id
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input
    mov esi, input_buf
    mov edi, order_med
    call copy_string

    mov edi, prompt_qty
    call print_string
    mov ecx, order_qty
    mov edx, 16
    call read_input
    mov esi, order_qty
    call parse_integer
    mov ecx, eax
    call check_stock_level
    cmp eax, 1
    jne .fail

    mov eax, ecx
    call update_medicine_stock
    mov edi, order_ok
    call print_string
    jmp .done

.fail:
    mov edi, order_no
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

parse_integer:
    xor eax, eax
.parse_loop:
    mov bl, [esi]
    cmp bl, 0
    je .done
    sub bl, '0'
    cmp bl, 9
    ja .done
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp .parse_loop
.done:
    ret