; check_stock_level.asm
; Description: Module to verify medicine stock levels before adding to cart or creating orders.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/update_medicine_stock.asm

section .data
prompt_available db "Enter current available stock for this medicine: ", 0
stock_ok db "Stock is sufficient.", 10, 0
stock_low db "Not enough stock available.", 10, 0

section .text
global check_stock_level
extern print_string
extern read_input
extern input_buf

check_stock_level:
    push ebp
    mov ebp, esp

    mov edi, prompt_available
    call print_string

    mov ecx, input_buf
    mov edx, 16
    call read_input
    mov esi, input_buf
    call parse_integer
    mov edi, eax

    mov eax, [ebp + 8]
    cmp edi, eax
    jl .low_stock

    mov edi, stock_ok
    call print_string
    mov eax, 1
    pop ebp
    ret

.low_stock:
    mov edi, stock_low
    call print_string
    xor eax, eax
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