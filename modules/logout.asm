; logout.asm
; Description: Module to handle user logout and session termination.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.

section .data
logout_msg db "You have been logged out.", 10, 0

section .text
global logout_user
extern print_string

logout_user:
    push ebp
    mov ebp, esp

    mov edi, logout_msg
    call print_string

    pop ebp
    ret