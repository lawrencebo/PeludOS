[bits 32]
; Define some constants
INITIAL_VIDEO_MEMORY equ 0xb8000
MIDDLE_SCREEN equ INITIAL_VIDEO_MEMORY + 2 * (12 * 80 + 16)
WHITE_ON_BLACK equ 0xf0

; prints a null - terminated string pointed to by EDX
print_string_pm:
    pusha
    mov edx, MIDDLE_SCREEN ; Set edx to the start of vid mem.
print_string_pm_loop:
    mov al, [ebx] ; Store the char at EBX in AL
    mov ah, WHITE_ON_BLACK ; Store the attributes in AH

    cmp al, 0 ; if (al == 0), at end of string , so
    je print_string_pm_done ; jump to done

    mov [edx], ax   ; Store char and attributes at current
                    ; character cell.

    add ebx, 1 ; Increment EBX to the next char in string.
    add edx, 2 ; Move to next character cell in vid mem.
    jmp print_string_pm_loop ; loop around to print the next char.

print_string_pm_done:
;     cmp edx, INITIAL_VIDEO_MEMORY + (80 * 25 * 2)
;     jge print_string_pm_res
;     mov [VIDEO_MEMORY], edx
;     jmp print_string_pm_exit

; print_string_pm_res:
;     mov [VIDEO_MEMORY], dword INITIAL_VIDEO_MEMORY

; print_string_pm_exit:
    popa
    ret ; Return from the function

; VIDEO_MEMORY:
;     dd INITIAL_VIDEO_MEMORY
