; add_medicine.asm
; Description: Administrator module to add more variance of medicine including its details into medicine.txt.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: medicine.txt (medicine_id, medicine_name, description, severity, quantity)

section .data
add_title db 10, "Add New Medicine", 10, 0
prompt_id db "Enter medicine ID: ", 0
prompt_name db "Enter medicine name: ", 0
prompt_desc db "Enter medicine description: ", 0
prompt_severity db "Enter severity [normal/needs prescription]: ", 0
prompt_qty db "Enter quantity available: ", 0
success_msg db "Medicine added to inventory.", 10, 0
medicine_file db "medicine.txt", 0
comma db ",", 0
newline db 10, 0

section .bss
line_buf resb 128

section .text
global add_medicine
extern print_string
extern read_input
extern input_buf

add_medicine:
    push ebp
    mov ebp, esp

    mov edi, add_title
    call print_string

    mov edi, prompt_id
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input
    mov esi, input_buf

    mov eax, 5
    mov ebx, medicine_file
    mov ecx, 0x601
    mov edx, 0644
    int 0x80
    mov edi, eax

    mov eax, 4
    mov ebx, edi
    mov ecx, esi
    call string_length
    int 0x80
    mov eax, 4
    mov ebx, edi
    mov ecx, comma
    mov edx, 1
    int 0x80

    mov edi, prompt_name
    call print_string
    mov ecx, input_buf
    mov edx, 64
    call read_input
    mov eax, 4
    mov ebx, edi
    mov ecx, input_buf
    call string_length
    int 0x80
    mov eax, 4
    mov ebx, edi
    mov ecx, comma
    mov edx, 1
    int 0x80

    mov edi, prompt_desc
    call print_string
    mov ecx, input_buf
    mov edx, 96
    call read_input
    mov eax, 4
    mov ebx, edi
    mov ecx, input_buf
    call string_length
    int 0x80
    mov eax, 4
    mov ebx, edi
    mov ecx, comma
    mov edx, 1
    int 0x80

    mov edi, prompt_severity
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input
    mov eax, 4
    mov ebx, edi
    mov ecx, input_buf
    call string_length
    int 0x80
    mov eax, 4
    mov ebx, edi
    mov ecx, comma
    mov edx, 1
    int 0x80

    mov edi, prompt_qty
    call print_string
    mov ecx, input_buf
    mov edx, 16
    call read_input
    mov eax, 4
    mov ebx, edi
    mov ecx, input_buf
    call string_length
    int 0x80

    mov eax, 4
    mov ebx, edi
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 6
    mov ebx, edi
    int 0x80

    mov edi, success_msg
    call print_string

    pop ebp
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