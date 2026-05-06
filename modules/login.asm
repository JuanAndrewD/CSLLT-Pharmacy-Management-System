; login.asm - Corrected Module for user authentication
; Platform: x86 32-bit, ELF32 assembly

section .data
    login_title    db 10, "--- Login System ---", 10, 0
    prompt_name    db "Enter user name: ", 0
    prompt_pwd     db "Enter password: ", 0
    not_found      db 10, "Error: User not found or invalid credentials.", 10, 0
    user_file      db "user.txt", 0

section .bss
    login_name           resb 32
    login_pwd            resb 32
    file_buf             resb 8192  ; Increased buffer size
    file_desc            resd 1
    login_id             resb 32
    login_type           resb 1
    login_pwd_extracted  resb 32

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
    sub esp, 4          ; Local variable to store current line pointer

    ; --- 1. UI: Get Credentials ---
    mov edi, login_title
    call print_string

    mov edi, prompt_name
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input
    mov esi, input_buf
    mov edi, login_name
    call copy_and_trim

    mov edi, prompt_pwd
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input
    mov esi, input_buf
    mov edi, login_pwd
    call copy_and_trim

    ; --- 2. File I/O: Read user.txt ---
    mov eax, 5          ; sys_open
    mov ebx, user_file
    mov ecx, 0          ; O_RDONLY
    int 0x80
    cmp eax, 0
    jl .io_error
    mov [file_desc], eax

    mov ebx, [file_desc]
    mov eax, 3          ; sys_read
    mov ecx, file_buf
    mov edx, 8192
    int 0x80
    
    ; Close file immediately after reading
    push eax            ; Save bytes read
    mov eax, 6          ; sys_close
    mov ebx, [file_desc]
    int 0x80
    pop eax             ; Restore bytes read
    
    mov byte [file_buf + eax], 0 ; Null terminate the buffer
    mov esi, file_buf

.parse_loop:
    cmp byte [esi], 0
    je .login_fail
    mov [ebp-4], esi    ; Save start of current line

    ; A. Check Username (Field 2)
    call compare_username
    cmp eax, 1
    jne .skip_to_next_line

    ; B. Check Password (Field 3)
    mov ebx, [ebp-4]
    mov edi, login_pwd_extracted
    call extract_password
    mov esi, login_pwd
    mov edi, login_pwd_extracted
    call compare_strings
    cmp eax, 1
    jne .skip_to_next_line

    ; C. Success: Extract ID (Field 1) and Type (Field 4)
    mov esi, [ebp-4]
    mov edi, login_id
    call extract_id
    
    mov ebx, [ebp-4]
    call extract_type
    mov [login_type], al

    ; --- 3. Finalize Session ---
    mov esi, login_id
    mov edi, current_user_id
    call copy_string
    
    mov al, [login_type]
    mov [current_user_type], al

    mov eax, 1          ; Return status: Success
    add esp, 4
    leave
    ret

.skip_to_next_line:
    mov esi, [ebp-4]
    call skip_line
    jmp .parse_loop

.io_error:
.login_fail:
    mov edi, not_found
    call print_string
    mov eax, 0          ; Return status: Fail
    add esp, 4
    leave
    ret

; --- Helper Functions ---

copy_and_trim:
    ; Copy from esi to edi and replace newline with null
    .c_loop:
        lodsb
        cmp al, 10
        je .c_done
        cmp al, 13
        je .c_done
        cmp al, 0
        je .c_done
        stosb
        jmp .c_loop
    .c_done:
        mov byte [edi], 0
        ret

compare_username:
    ; Finds second field in CSV and compares to login_name
    mov esi, [ebp-4]
    .find_comma:
        lodsb
        cmp al, ','
        jne .find_comma
    ; ESI now points to second field
    mov edi, login_name
    .comp_loop:
        lodsb
        mov bl, [edi]
        cmp al, ','
        je .check_match
        cmp al, bl
        jne .no_match
        inc edi
        jmp .comp_loop
    .check_match:
        cmp byte [edi], 0
        jne .no_match
        mov eax, 1
        ret
    .no_match:
        xor eax, eax
        ret

extract_password:
    ; ebx = line start, edi = destination
    xor ecx, ecx
    .seek:
        mov al, [ebx]
        cmp al, ','
        jne .next
        inc ecx
        cmp ecx, 2
        je .copy_start
    .next:
        inc ebx
        jmp .seek
    .copy_start:
        inc ebx
    .copy_loop:
        mov al, [ebx]
        cmp al, ','
        je .done
        cmp al, 10
        je .done
        mov [edi], al
        inc edi
        inc ebx
        jmp .copy_loop
    .done:
        mov byte [edi], 0
        ret

extract_id:
    ; esi = line start, edi = dest
    .loop:
        lodsb
        cmp al, ','
        je .done
        stosb
        jmp .loop
    .done:
        mov byte [edi], 0
        ret

extract_type:
    ; Returns char in AL from 4th field
    xor ecx, ecx
    .loop:
        mov al, [ebx]
        cmp al, ','
        jne .next
        inc ecx
        cmp ecx, 3
        je .found
    .next:
        inc ebx
        jmp .loop
    .found:
        mov al, [ebx+1]
        ret

skip_line:
    .loop:
        lodsb
        cmp al, 10
        je .done
        cmp al, 0
        je .done
        jmp .loop
    .done:
        ret

compare_strings:
    .loop:
        mov al, [esi]
        mov bl, [edi]
        cmp al, bl
        jne .not_eq
        cmp al, 0
        je .eq
        inc esi
        inc edi
        jmp .loop
    .not_eq: xor eax, eax
        ret
    .eq:     mov eax, 1
        ret

copy_string:
    .loop:
        lodsb
        stosb
        test al, al
        jnz .loop
    ret