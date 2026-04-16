; add_to_cart.asm
; Description: Customer module to add medicine to their cart, adjust inventory, and handle removals.
;              If selected medicine requires a prescription, transfers flow to request_prescription.asm.
; Platform: x86 32-bit, ELF32 assembly, elf_i386 linking.
; Dependencies: modules/request_prescription.asm, modules/check_stock_level.asm
; Data files: user.txt (user_id, user_name, user_type), medicine.txt (medicine_id, medicine_name, description, severity, quantity)

section .data
add_title db 10, "Add Medicine to Cart", 10, 0
prompt_med_id db "Enter medicine ID: ", 0
prompt_qty db "Enter quantity to add: ", 0
prompt_severity db "Enter severity [normal/needs prescription]: ", 0
cart_saved db "Item added to cart successfully.", 10, 0
need_prescription db "This medicine requires a prescription. Requesting approval...", 10, 0
out_of_stock db "Stock is insufficient for this quantity.", 10, 0
cart_suffix db "-cart.txt", 0
comma db ",", 0
newline db 10, 0

section .bss
med_id resb 32
qty_str resb 16
severity resb 32
cart_file resb 64

section .text
global add_to_cart
extern print_string
extern read_input
extern request_prescription
extern check_stock_level
extern update_medicine_stock
extern input_buf
extern current_user_id

add_to_cart:
    push ebp
    mov ebp, esp

    mov edi, add_title
    call print_string

    mov edi, prompt_med_id
    call print_string
    mov ecx, input_buf
    mov edx, 32
    call read_input
    mov esi, input_buf
    mov edi, med_id
    call copy_string

    mov edi, prompt_qty
    call print_string
    mov ecx, qty_str
    mov edx, 16
    call read_input
    mov esi, qty_str
    call parse_integer
    mov ebx, eax

    mov edi, prompt_severity
    call print_string
    mov ecx, severity
    mov edx, 32
    call read_input

    mov esi, severity
    mov edi, needs_prescription
    call compare_strings
    cmp eax, 1
    je request_flow

    mov ecx, ebx
    call check_stock_level
    cmp eax, 1
    jne out_stock
    mov eax, ebx
    call update_medicine_stock
    jmp save_cart

request_flow:
    mov edi, need_prescription
    call print_string
    call request_prescription
    mov ecx, ebx
    call check_stock_level
    cmp eax, 1
    jne out_stock
    mov eax, ebx
    call update_medicine_stock

save_cart:
    mov esi, current_user_id
    mov edi, cart_file
    call copy_string
    mov esi, cart_suffix
    call append_string
    mov eax, 5
    mov ebx, cart_file
    mov ecx, 0x601
    mov edx, 0644
    int 0x80
    mov edi, eax

    mov eax, 4
    mov ebx, edi
    mov ecx, med_id
    call string_length
    int 0x80

    mov eax, 4
    mov ebx, edi
    mov ecx, comma
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, edi
    mov ecx, qty_str
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

    mov edi, cart_saved
    call print_string
    pop ebp
    ret

out_stock:
    mov edi, out_of_stock
    call print_string
    pop ebp
    ret

copy_string:
    push ebp
    mov ebp, esp
.copy_loop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne .copy_loop
    pop ebp
    ret

append_string:
    push ebp
    mov ebp, esp
    call copy_string
    pop ebp
    ret

parse_integer:
    xor eax, eax
.parse_loop:
    mov bl, [esi]
    cmp bl, 0
    je .parse_done
    sub bl, '0'
    cmp bl, 9
    ja .parse_done
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp .parse_loop
.parse_done:
    ret

compare_strings:
    ; esi points to first string, edi to second string
    push ebp
    mov ebp, esp
.compare_loop2:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc esi
    inc edi
    jmp .compare_loop2
.equal:
    mov eax, 1
    pop ebp
    ret
.not_equal:
    xor eax, eax
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

needs_prescription db "needs prescription", 0