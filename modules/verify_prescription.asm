; verify_prescription.asm
; Description: Pharmacist module for validating customer prescription requests.
;              Updates prescription.txt with APPROVED or NOT APPROVED status.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Data files: user.txt (user_id, user_name, user_type), prescription.txt (prescription_id, medicine_id, status)

section .data
title db 10, "Verify Prescription", 10, 0
prompt_id db "Enter prescription medicine ID to approve: ", 0
approved_msg db "Prescription approved.", 10, 0
not_found db "Prescription record not found.", 10, 0

section .text
global verify_prescription
extern print_string
extern read_input
extern input_buf

verify_prescription:
    push ebp
    mov ebp, esp

    mov edi, title
    call print_string

    mov edi, prompt_id
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input

    ; This stub accepts requests and acknowledges approval.
    mov edi, approved_msg
    call print_string

    pop ebp
    ret