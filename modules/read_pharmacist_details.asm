section .data
    title    db 10, "Pharmacist Profiles (Type P)", 10, 0
    user_file db "user.txt", 0
    no_file  db "Error: Could not open user.txt", 10, 0

section .bss
    file_buf resb 4096
    line_tmp resb 256
    fd_in    resd 1

section .text
global read_pharmacist_details
extern print_string

read_pharmacist_details:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    ; --- Open file for Reading ---
    mov eax, 5
    mov ebx, user_file
    mov ecx, 0              ; O_RDONLY
    int 0x80
    test eax, eax
    js .err_open
    mov [fd_in], eax

    ; --- Read content into buffer ---
    mov eax, 3
    mov ebx, [fd_in]
    mov ecx, file_buf
    mov edx, 4096
    int 0x80
    
    ; If bytes read <= 0, exit
    cmp eax, 0
    jle .close_exit
    mov esi, eax            ; ESI = total bytes read from file

    ; --- Parsing Logic ---
    xor ebx, ebx            ; EBX = current index in file_buf
    
.next_line:
    cmp ebx, esi            ; Have we processed all bytes?
    jge .close_exit

    lea edi, [line_tmp]     ; EDI = destination for current line
    xor edx, edx            ; EDX = length of current line

.copy_char:
    mov al, [file_buf + ebx]
    mov [edi + edx], al
    inc ebx
    inc edx
    
    cmp al, 10              ; Check if character is Newline (LF)
    je .analyze_line
    
    cmp ebx, esi            ; Safety check for end of buffer
    jl .copy_char

.analyze_line:
    ; The user type is the character before the newline (\n)
    ; Line format: U001,Name,Pass,P\n
    ; EDX is total length including \n. The 'P' is at [edi + edx - 2]
    cmp edx, 2
    jl .next_line           ; Skip empty or too-short lines

    mov al, [edi + edx - 2] 
    cmp al, 'P'             ; Filter for Pharmacist
    jne .next_line          ; If not 'P', don't print, go to next line

    ; --- Print the Pharmacist line ---
    push ebx
    push edx
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, line_tmp
    ; edx already holds the correct line length
    int 0x80
    pop edx
    pop ebx
    jmp .next_line

.close_exit:
    mov eax, 6              ; sys_close
    mov ebx, [fd_in]
    int 0x80
    jmp .done

.err_open:
    mov edi, no_file
    call print_string

.done:
    pop ebp
    ret