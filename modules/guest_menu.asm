; guest_menu.asm
; Description: Guest menu module. Provides read-only access to pharmacist details and general info.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/read_pharmacist_details.asm

section .data
guest_title db 10, "Guest Menu", 10, 0
guest_prompt db "1) View Pharmacist Details", 10, "2) Back to Main Menu", 10, 0
invalid_option db "Invalid selection.", 10, 0

section .text
global guest_menu
extern print_string
extern read_input
extern read_pharmacist_details
extern input_buf

guest_menu:
    push ebp
    mov ebp, esp

guest_loop:
    mov edi, guest_title
    call print_string
    mov edi, guest_prompt
    call print_string

    mov ecx, input_buf
    mov edx, 4
    call read_input

    mov al, [input_buf]
    cmp al, '1'
    je do_pharmacist_details
    cmp al, '2'
    je return
    mov edi, invalid_option
    call print_string
    jmp guest_loop

do_pharmacist_details:
    call read_pharmacist_details
    jmp guest_loop

return:
    pop ebp
    ret