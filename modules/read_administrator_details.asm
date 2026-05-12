section .data
    title    db 10, "Administrator Profiles (Type A)", 10, 0
    user_file db "user.txt", 0
    no_file  db "Error: Could not open user.txt", 10, 0

section .bss
    file_buf resb 4096
    line_tmp resb 256
    fd_in    resd 1

section .text
global read_administrator_details
extern print_string

read_administrator_details:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    ; Open for Reading
    mov eax, 5
    mov ebx, user_file
    mov ecx, 0
    int 0x80
    test eax, eax
    js .err_open
    mov [fd_in], eax

    ; Read bulk into buffer
    mov eax, 3
    mov ebx, [fd_in]
    mov ecx, file_buf
    mov edx, 4096
    int 0x80
    mov esi, eax

    ; Parsing Logic
    xor ebx, ebx            ; ebx = current buffer index
    
.next_line:
    lea edi, [line_tmp]     ; edi points to our temporary line holder
    xor edx, edx            ; edx = current line length counter

.copy_char:
    cmp ebx, esi
    jge .check_last_line
    mov al, [file_buf + ebx]
    mov [edi + edx], al
    inc ebx
    inc edx
    cmp al, 10
    jne .copy_char

    ; We have a full line in line_tmp. Check the type (character before 0xA)
    ; Format: ID,Name,Pass,A\n -> index [edx-2]
    cmp edx, 2
    jl .next_line
    mov al, [edi + edx - 2] 
    cmp al, 'A'
    jne .next_line          ; If not 'A', skip printing

    ; It is an Admin! Print it.
    push ebx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, line_tmp
    ; edx already contains length
    int 0x80
    pop edx
    pop ebx
    jmp .next_line

.check_last_line:
    ; (Add logic here if file doesn't end in newline, omitted for brevity)

    mov eax, 6
    mov ebx, [fd_in]
    int 0x80
    jmp .done

.err_open:
    mov edi, no_file
    call print_string

.done:
    pop ebp
    ret