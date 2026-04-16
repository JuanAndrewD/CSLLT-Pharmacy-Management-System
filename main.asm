; main.asm
; Description: Top-level entry point for the Pharmacy Management System.
;              Coordinates registration, login, logout, and role-based menus.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/registration.asm, modules/login.asm, modules/logout.asm,
;               modules/customer_menu.asm, modules/guest_menu.asm,
;               modules/pharmacist_menu.asm, modules/administrator_menu.asm.

; registration.asm
; login.asm
; logout.asm
; customer_menu.asm
; guest_menu.asm
; pharmacist_menu.asm
; administrator_menu.asm

; Top-level entry point. References major modules: registration, login, logout, customer/guest/pharmacist/administrator menus.

section .data
welcome_msg db 10, "Pharmacy Management System", 10, 0
main_menu db "1) Register", 10, "2) Login", 10, "3) Continue as Guest", 10, "4) Exit", 10, 0
invalid_option db "Invalid option. Try again.", 10, 0
login_failed db "Login failed. Press Enter to continue.", 10, 0
exit_msg db "Goodbye.", 10, 0

section .bss
input_buf resb 128
current_user_id resb 32
current_user_type resb 16

section .text
global _start
global print_string
global read_input

extern register_user
extern login_user
extern guest_menu
extern customer_menu
extern pharmacist_menu
extern administrator_menu
extern logout_user

_start:
    mov edi, welcome_msg
    call print_string

main_loop:
    mov edi, main_menu
    call print_string

    mov ecx, input_buf
    mov edx, 4
    call read_input

    mov al, [input_buf]
    cmp al, '1'
    je do_register
    cmp al, '2'
    je do_login
    cmp al, '3'
    je do_guest
    cmp al, '4'
    je do_exit

    mov edi, invalid_option
    call print_string
    jmp main_loop

do_register:
    call register_user
    jmp main_loop

do_login:
    call login_user
    cmp eax, 1
    jne login_fail

    mov al, [current_user_type]
    cmp al, 'C'
    je customer_mode
    cmp al, 'P'
    je pharmacist_mode
    cmp al, 'A'
    je admin_mode

guest_mode:
    call guest_menu
    jmp main_loop

customer_mode:
    call customer_menu
    jmp main_loop

pharmacist_mode:
    call pharmacist_menu
    jmp main_loop

admin_mode:
    call administrator_menu
    jmp main_loop

login_fail:
    mov edi, login_failed
    call print_string
    jmp main_loop

do_guest:
    call guest_menu
    jmp main_loop

do_exit:
    mov eax, 1
    mov ebx, 0
    int 0x80

print_string:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    xor edx, edx
.print_strlen:
    cmp byte [ecx + edx], 0
    je .print_done
    inc edx
    jmp .print_strlen
.print_done:
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret

read_input:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push esi

    mov eax, 3
    mov ebx, 0
    int 0x80
    cmp eax, 0
    jle .end_read

    mov esi, eax
    mov ebx, ecx
    dec esi
    mov al, [ebx + esi]
    cmp al, 10
    jne .skip_newline
    mov byte [ebx + esi], 0
    jmp .end_read

.skip_newline:
    mov byte [ebx + esi + 1], 0

.end_read:
    pop esi
    pop ebx
    pop eax
    pop ebp
    ret