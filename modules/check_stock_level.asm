section .data
    filename db "medicine.txt", 0
    header db 10, "ID   | Name           | Qty | Status", 10, "------------------------------------------", 10, 0
    separator db " | ", 0
    status_ok db "Sufficient", 10, 0
    status_low db "Need Restock", 10, 0
    err_file db "Error: Could not open medicine.txt", 10, 0
    threshold dd 20

section .bss
    file_buf resb 4096  ; Larger buffer for multiple records
    fd_in resd 1
    temp_field resb 64

section .text
global check_stock_level
extern print_string

check_stock_level:
    push ebp
    mov ebp, esp

    ; 1. Open file
    mov eax, 5
    mov ebx, filename
    mov ecx, 0          
    int 0x80
    test eax, eax
    js .open_error
    mov [fd_in], eax

    ; 2. Read entire file into buffer
    mov eax, 3
    mov ebx, [fd_in]
    mov ecx, file_buf
    mov edx, 4096
    int 0x80
    
    ; Save the number of bytes read to determine the end of buffer
    mov ecx, eax        ; ECX = total bytes read
    mov esi, file_buf   ; ESI = current position in buffer
    lea edx, [esi + ecx] ; EDX = end of data pointer

    ; 3. Print Table Header
    push edx
    mov edi, header
    call print_string
    pop edx

.main_loop:
    cmp esi, edx        ; Check if current pointer (ESI) >= end pointer (EDX)
    jge .close_file

    ; --- Process ID ---
    call .get_field
    mov edi, temp_field
    call print_string
    mov edi, separator
    call print_string

    ; --- Process Name ---
    call .get_field
    mov edi, temp_field
    call print_string
    mov edi, separator
    call print_string

    ; --- Process Quantity ---
    call .get_field
    mov edi, temp_field
    call print_string
    mov edi, separator
    call print_string

    ; --- Logic: Calculate Status ---
    mov eax, temp_field
    call .atoi
    cmp eax, [threshold]
    jl .print_low
    mov edi, status_ok
    call print_string
    jmp .check_next

.print_low:
    mov edi, status_low
    call print_string

.check_next:
    ; The .get_field logic already advanced ESI past the newline/comma.
    ; Check if we are pointing at a null or end of buffer.
    cmp esi, edx
    jl .main_loop

.close_file:
    mov eax, 6
    mov ebx, [fd_in]
    int 0x80
    pop ebp
    ret

.open_error:
    mov edi, err_file
    call print_string
    pop ebp
    ret

; --- Helper: Extract field into temp_field ---
.get_field:
    push eax
    mov edi, temp_field
.field_char_loop:
    cmp esi, edx        ; Don't read past buffer end
    jge .field_done
    mov al, [esi]
    cmp al, ','         ; Field delimiter
    je .found_delimiter
    cmp al, 10          ; Line delimiter (LF)
    je .found_delimiter
    cmp al, 13          ; Carriage Return (for Windows-style files)
    je .skip_char
    
    mov [edi], al       ; Copy char to temp buffer
    inc edi
    inc esi
    jmp .field_char_loop

.skip_char:
    inc esi
    jmp .field_char_loop

.found_delimiter:
    inc esi             ; Advance ESI past the delimiter for next call

.field_done:
    mov byte [edi], 0   ; Null-terminate the string in temp_field
    pop eax
    ret

; --- Helper: String to Integer ---
.atoi:
    xor ecx, ecx
.atoi_loop:
    movzx ebx, byte [eax]
    cmp bl, '0'
    jb .atoi_exit
    cmp bl, '9'
    ja .atoi_exit
    sub bl, '0'
    imul ecx, ecx, 10
    add ecx, ebx
    inc eax
    jmp .atoi_loop
.atoi_exit:
    mov eax, ecx
    ret