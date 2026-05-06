; registration.asm
; Description: Module for new user registration and storing user credentials/profile info.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: user.txt (user_id, user_name, password, user_type)

section .data
reg_title db 10, "Register New User", 10, 0
prompt_id db "Enter new user ID: ", 0
prompt_name db "Enter user name: ", 0
prompt_pwd db "Enter password: ", 0
prompt_type db "Enter user type [P/A]: ", 0
success_msg db "Registration completed successfully.", 10, 0
invalid_type db "Invalid user type. Only P (Pharmacist) or A (Administrator) allowed.", 10, 0
user_file db "user.txt", 0
comma db ",", 0
newline db 10, 0

section .text
global register_user
extern print_string
extern read_input
extern input_buf

register_user:
    push ebp
    mov ebp, esp

    mov edi, reg_title
    call print_string

    mov edi, prompt_id
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input

    mov eax, 5
    mov ebx, user_file
    mov ecx, 0x441
    mov edx, 0644
    int 0x80
    mov esi, eax

    mov ecx, input_buf
    call string_length
    mov edx, eax
    mov eax, 4
    mov ebx, esi
    int 0x80

    mov eax, 4
    mov ebx, esi
    mov ecx, comma
    mov edx, 1
    int 0x80

    mov edi, prompt_name
    call print_string
    mov ecx, input_buf
    mov edx, 64
    call read_input

    mov ecx, input_buf
    call string_length
    mov edx, eax
    mov eax, 4
    mov ebx, esi
    int 0x80

    mov eax, 4
    mov ebx, esi
    mov ecx, comma
    mov edx, 1
    int 0x80

    mov edi, prompt_pwd
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input

    mov ecx, input_buf
    call string_length
    mov edx, eax
    mov eax, 4
    mov ebx, esi
    int 0x80

    mov eax, 4
    mov ebx, esi
    mov ecx, comma
    mov edx, 1
    int 0x80

    mov edi, prompt_type
    call print_string
    mov ecx, input_buf
    mov edx, 4
    call read_input

    mov al, [input_buf]
    cmp al, 'P'
    je .valid_type
    cmp al, 'A'
    je .valid_type
    mov edi, invalid_type
    call print_string
    jmp register_user

.valid_type:
    mov ecx, input_buf
    call string_length
    mov edx, eax
    mov eax, 4
    mov ebx, esi
    int 0x80

    mov eax, 4
    mov ebx, esi
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 6
    mov ebx, esi
    int 0x80

    mov edi, success_msg
    call print_string

    pop ebp
    ret

string_length:
    push ebp
    mov ebp, esp
    push ecx
    push edx
    xor eax, eax
.strlen_loop:
    cmp byte [ecx + eax], 0
    je .strlen_done
    inc eax
    jmp .strlen_loop
.strlen_done:
    pop edx
    pop ecx
    pop ebp
    ret