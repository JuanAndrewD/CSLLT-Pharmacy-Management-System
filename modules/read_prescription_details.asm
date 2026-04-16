; read_prescription_details.asm
; Description: Module to read and display prescription request details for customers or pharmacists.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: prescription.txt (prescription_id, medicine_id, status)

section .data
title db 10, "Prescription Requests", 10, 0
prescription_file db "prescription.txt", 0
no_file db "No prescription records found.", 10, 0

section .bss
file_buf resb 4096

section .text
global read_prescription_details
extern print_string

read_prescription_details:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    mov eax, 5
    mov ebx, prescription_file
    mov ecx, 0
    int 0x80
    cmp eax, 0
    jl .no_records
    mov ebx, eax

    mov eax, 3
    mov ecx, file_buf
    mov edx, 4096
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, file_buf
    int 0x80

    mov eax, 6
    mov ebx, eax
    int 0x80
    jmp .done

.no_records:
    mov edi, no_file
    call print_string

.done:
    pop ebp
    ret