section .data
    file_name db "medicine.txt", 0
    temp_file db "medicine.tmp", 0
    prompt_id db "Enter Medicine ID to update: ", 0
    prompt_add db "Enter quantity to ADD: ", 0
    msg_success db "Stock updated successfully.", 10, 0
    comma db ",", 0
    newline db 10, 0

section .bss
    target_id resb 16
    add_val_str resb 16
    file_buf resb 4096
    temp_field resb 64
    fd_in resd 1
    fd_out resd 1

section .text
global update_stock_quantity
extern print_string
extern read_input

update_stock_quantity:
    push ebp
    mov ebp, esp

    ; 1. Collect user input
    mov edi, prompt_id
    call print_string
    mov ecx, target_id
    mov edx, 16
    call read_input

    mov edi, prompt_add
    call print_string
    mov ecx, add_val_str
    mov edx, 16
    call read_input

    ; 2. Open Files
    mov eax, 5              ; sys_open
    mov ebx, file_name
    mov ecx, 0              ; O_RDONLY
    int 0x80
    mov [fd_in], eax

    mov eax, 5              ; sys_open
    mov ebx, temp_file
    mov ecx, 577
    mov edx, 0644h          ; Permissions: rw-r--r--
    int 0x80
    mov [fd_out], eax

    ; 3. Read entire file
    mov eax, 3              ; sys_read
    mov ebx, [fd_in]
    mov ecx, file_buf
    mov edx, 4096
    int 0x80
    
    mov esi, file_buf
    lea edx, [file_buf + eax]

.line_loop:
    cmp esi, edx            ; Compare current pointer to end pointer
    jge .finalize

    ; Extract ID to check
    call .get_field
    
    ; Compare temp_field (ID from file) with target_id
    push esi
    mov esi, temp_field
    mov edi, target_id
    call .strcmp
    pop esi
    jne .not_the_one

    ; TARGET FOUND: Perform Addition
    call .write_temp_field  ; Write ID
    call .write_comma
    
    call .get_field         ; Get Name
    call .write_temp_field
    call .write_comma
    
    call .get_field         ; Get current Qty string
    mov eax, temp_field
    call .atoi              ; EAX = current
    push eax
    mov eax, add_val_str
    call .atoi              ; EAX = to add
    pop ebx
    add eax, ebx            ; EAX = NEW TOTAL
    
    call .itoa              ; Result into temp_field
    call .write_temp_field
    call .write_newline
    jmp .line_loop

.not_the_one:
    ; Not our target, just copy the line parts to the temp file
    call .write_temp_field  ; Write ID
    call .write_comma
    call .get_field         ; Get Name
    call .write_temp_field
    call .write_comma
    call .get_field         ; Get Qty
    call .write_temp_field
    call .write_newline
    jmp .line_loop

.finalize:
    ; Close descriptors
    mov eax, 6
    mov ebx, [fd_in]
    int 0x80
    mov eax, 6
    mov ebx, [fd_out]
    int 0x80

    ; Overwrite original file with temp file (sys_rename)
    mov eax, 38             ; sys_rename
    mov ebx, temp_file
    mov ecx, file_name
    int 0x80

    mov edi, msg_success
    call print_string
    pop ebp
    ret

; --- Helper Functions (Now with Register Preservation) ---

.write_temp_field:
    ; NOTE: ESI is intentionally NOT saved/restored here.
    ; ESI holds the global file-read cursor and must survive across calls.
    ; This routine only reads from temp_field via a local pointer (EAX),
    ; so touching ESI would corrupt the read position.
    push eax
    push ebx
    push ecx
    push edx
    mov eax, temp_field     ; Use EAX as the local scan pointer
    xor edx, edx
.w_len:
    cmp byte [eax+edx], 0
    je .w_exec
    inc edx
    jmp .w_len
.w_exec:
    test edx, edx
    jz .w_done
    mov eax, 4              ; sys_write
    mov ebx, [fd_out]
    mov ecx, temp_field
    int 0x80
.w_done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

.write_comma:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, comma
    mov edx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

.write_newline:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

.get_field:
    ; Uses EAX, EDI, ESI. Does not touch EDX.
    mov edi, temp_field
.g_loop:
    cmp esi, edx            ; Compare ESI to the saved EDX end-pointer
    jge .g_done
    lodsb
    cmp al, ','
    je .g_done
    cmp al, 10
    je .g_done
    cmp al, 13              ; Skip Carriage Return
    je .g_loop
    stosb
    jmp .g_loop
.g_done:
    mov byte [edi], 0
    ret

.strcmp:
    push esi
    push edi
.s_loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .s_diff
    cmp al, 0
    je .s_same
    inc esi
    inc edi
    jmp .s_loop
.s_diff:
    mov al, 1
    test al, al             ; Set non-zero flag
    pop edi
    pop esi
    ret
.s_same:
    xor eax, eax            ; Set zero flag
    pop edi
    pop esi
    ret

.atoi:
    xor ecx, ecx
.a_loop:
    movzx ebx, byte [eax]
    cmp bl, '0'
    jb .a_done
    cmp bl, '9'
    ja .a_done
    sub bl, '0'
    imul ecx, ecx, 10
    add ecx, ebx
    inc eax
    jmp .a_loop
.a_done:
    mov eax, ecx
    ret

.itoa:
    ; ESI is the global file-read cursor -- save and restore it,
    ; because this routine temporarily hijacks ESI for the digit-copy loop.
    push esi
    push edx
    push ebx
    mov edi, temp_field
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10
.i_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .i_loop
    ; Copy result to start of temp_field
    mov esi, edi
    mov edi, temp_field
.i_copy:
    lodsb
    stosb
    test al, al
    jnz .i_copy
    pop ebx
    pop edx
    pop esi             ; Restore file cursor
    ret