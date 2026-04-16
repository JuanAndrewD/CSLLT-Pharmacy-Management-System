; request_prescription.asm
; Description: Customer module for submitting prescription requests when medicine severity requires it.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: prescription.txt (prescription_id, medicine_id, status)

section .data
request_title db 10, "Prescription Request", 10, 0
prompt_med_id db "Enter medicine ID for prescription request: ", 0
prescription_file db "prescription.txt", 0
newline db 10, 0
pending db ",PENDING", 0
success_msg db "Prescription request submitted. Await pharmacist approval.", 10, 0

section .text
global request_prescription
extern print_string
extern read_input
extern input_buf

request_prescription:
    push ebp
    mov ebp, esp

    mov edi, request_title
    call print_string

    mov edi, prompt_med_id
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input

    mov eax, 5
    mov ebx, prescription_file
    mov ecx, 0x601
    mov edx, 0644
    int 0x80
    mov esi, eax

    mov eax, 4
    mov ebx, esi
    mov ecx, input_buf
    call string_length
    int 0x80

    mov eax, 4
    mov ebx, esi
    mov ecx, pending
    call string_length
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
    xor eax, eax
.strlen_loop:
    cmp byte [ecx + eax], 0
    je .strlen_done
    inc eax
    jmp .strlen_loop
.strlen_done:
    pop ebp
    ret