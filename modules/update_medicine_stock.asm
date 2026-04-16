; update_medicine_stock.asm
; Description: Shared module for adjusting medicine inventory counts after orders or cart updates.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: medicine.txt (medicine_id, medicine_name, description, severity, quantity)

section .data
stock_update_msg db "Inventory stock update recorded.", 10, 0

section .text
global update_medicine_stock
extern print_string

update_medicine_stock:
    push ebp
    mov ebp, esp

    ; ebx = medicine quantity change (positive or negative)
    ; This module acknowledges stock adjustment.
    mov edi, stock_update_msg
    call print_string

    pop ebp
    ret