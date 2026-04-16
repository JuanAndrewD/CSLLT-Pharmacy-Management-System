; login.asm
; Description: Module for user authentication and session initialization.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: user.txt (user_id, user_name, user_type)

section .data
login_title db 10, "Login", 10, 0
prompt_id db "Enter user ID: ", 0
prompt_type db "Enter user type [C/P/A]: ", 0
user_file db "user.txt", 0
not_found db "User not found or invalid credentials.", 10, 0

section .bss
login_id resb 32
login_type resb 4
file_buf resb 4096

section .text
global login_user
extern print_string
extern read_input
extern input_buf
extern current_user_id
extern current_user_type

login_user:
    push ebp
    mov ebp, esp

    mov edi, login_title
    call print_string

    mov edi, prompt_id
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input
    mov esi, input_buf
    mov edi, login_id
    call copy_string

    mov edi, prompt_type
    call print_string
    mov ecx, input_buf
    mov edx, 4
    call read_input
    mov al, [input_buf]
    mov [login_type], al
    mov byte [login_type + 1], 0

    mov eax, 5
    mov ebx, user_file
    mov ecx, 0
    int 0x80
    cmp eax, 0
    jl .login_fail
    mov ebx, eax

    mov eax, 3
    mov ecx, file_buf
    mov edx, 4096
    int 0x80
    mov esi, file_buf
    mov edi, login_id

.parse_loop:
    cmp byte [esi], 0
    je .login_fail
    push esi
    mov ebx, esi
    mov ecx, login_id
    call compare_token
    cmp eax, 1
    jne .skip_to_next_line

    mov esi, ebx
    call extract_type
    cmp al, [login_type]
    jne .skip_to_next_line

    mov esi, login_id
    mov edi, current_user_id
    call copy_string
    mov al, [login_type]
    mov [current_user_type], al
    mov eax, 1
    mov ebx, [ebp - 4]
    mov eax, 1
    pop esi
    mov ebx, 0
    int 0x80
    leave
    ret

.skip_to_next_line:
    pop esi
    call skip_line
    jmp .parse_loop

.login_fail:
    mov eax, 0
    leave
    ret

compare_token:
    ; esi = line start, ecx = token string
    push esi
    push ecx
.compare_loop:
    mov al, [esi]
    cmp al, ','
    je .check_done
    cmp al, 0
    je .not_equal
    mov bl, [ecx]
    cmp bl, 0
    je .not_equal
    cmp al, bl
    jne .not_equal
    inc esi
    inc ecx
    jmp .compare_loop
.check_done:
    mov al, [ecx]
    cmp al, 0
    jne .not_equal
    mov eax, 1
    pop ecx
    pop esi
    ret
.not_equal:
    xor eax, eax
    pop ecx
    pop esi
    ret

extract_type:
    ; ebx = line start after matching id, result in al
    mov ecx, ebx
.find_second_comma:
    cmp byte [ecx], 0
    je .bad
    cmp byte [ecx], ','
    jne .next_char
    inc ecx
    cmp byte [ecx], ','
    jne .next_char
    inc ecx
    mov al, [ecx]
    ret
.next_char:
    inc ecx
    jmp .find_second_comma
.bad:
    xor al, al
    ret

skip_line:
    ; esi points at line start
.skip:
    cmp byte [esi], 0
    je .done_skip
    cmp byte [esi], 10
    je .done_skip
    inc esi
    jmp .skip
.done_skip:
    inc esi
    mov esi, esi
    ret

copy_string:
    ; esi = source, edi = destination
    .copy_loop:
        mov al, [esi]
        mov [edi], al
        cmp al, 0
        je .copy_done
        inc esi
        inc edi
        jmp .copy_loop
    .copy_done:
        ret