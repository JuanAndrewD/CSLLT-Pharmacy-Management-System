section .data
add_title db 10, "Add New Medicine", 10, 0
prompt_id db "Enter medicine ID: ", 0
prompt_name db "Enter medicine name: ", 0
prompt_qty db "Enter quantity available: ", 0
success_msg db "Medicine added to inventory.", 10, 0
medicine_file db "medicine.txt", 0
comma db ",", 0
newline db 10, 0

section .bss
line_buf resb 128
fd_out resd 1

section .text
global add_medicine
extern print_string
extern read_input
extern input_buf

add_medicine:
    push ebp
    mov ebp, esp

    ; 1. Open the file first or later, but keep the FD safe
    mov eax, 5              ; sys_open
    mov ebx, medicine_file
    mov ecx, 0x441          ; O_WRONLY | O_CREAT | O_APPEND
    mov edx, 0644o         ; Permissions
    int 0x80
    
    test eax, eax           ; Check if open failed
    js .error_exit
    mov [fd_out], eax       ; Save FD to memory

    ; 2. Add Title
    mov edi, add_title
    call print_string

    ; 3. Handle ID
    mov edi, prompt_id
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input
    call write_to_file      ; Helper to write input_buf to file
    call write_comma

    ; 4. Handle Name
    mov edi, prompt_name
    call print_string
    mov ecx, input_buf
    mov edx, 64
    call read_input
    call write_to_file
    call write_comma

    ; ... Repeat for Desc and Severity ...

    ; Final Quantity and Newline
    mov edi, prompt_qty
    call print_string
    mov ecx, input_buf
    mov edx, 16
    call read_input
    call write_to_file
    
    ; Write Newline
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Close File
    mov eax, 6
    mov ebx, [fd_out]
    int 0x80

    mov edi, success_msg
    call print_string

.error_exit:
    pop ebp
    ret

; --- Helper Functions to keep code clean ---

write_to_file:
    ; Expects string in input_buf
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, input_buf
    call string_length  ; Result in EAX
    mov edx, eax        ; Length to EDX
    mov eax, 4          ; sys_write
    mov ebx, [fd_out]   ; Get FD from memory
    mov ecx, input_buf
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

write_comma:
    push eax
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, comma
    mov edx, 1
    int 0x80
    pop eax
    ret

string_length:
    push ebp
    mov ebp, esp
    xor eax, eax
.len_loop:
    cmp byte [ecx + eax], 0
    je .len_done
    inc eax
    jmp .len_loop
.len_done:
    pop ebp
    ret