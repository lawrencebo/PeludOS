[ bits 16 ]

print_string:
    pusha
    mov ah, 0x0e
print_loop:
    mov al, [bx]
    cmp al, 0
    je print_exit
    int 0x10
    inc bx
    jmp print_loop
print_exit:
    popa
    ret

; print_hex:
;     pusha

;     mov bx, HEX_OUT + 2
; print_hex_loop:
;     mov ax, dx
;     and ax, 0xf000
;     shr ax, 12
;     cmp ax, 9
;     jle step_2
;     add ax, 7
; step_2:
;     add ax, 0x30
;     mov [bx], al
;     inc bx
;     shl dx, 4
;     cmp [bx], byte 0
;     jne print_hex_loop

;     mov ax, HEX_OUT
;     call print_string

;     popa
;     ret

; ; global variables
; HEX_OUT:
;     db '0x0000',0
