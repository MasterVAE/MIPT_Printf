DEFAULT REL

section     .text

global _start
global _my_printf

END_SYMBOL equ 0x00
PERSENT_SYMBOL equ '%'
REG_SIZE equ 8
MINUS_SYMBOL equ '-'
BUFFER_SIZE equ 64d

FIRST_LETTER equ 'a'
LAST_LETTER equ 'x'

; =======================================================================
; Обертка для принта
; =======================================================================
_my_printf:     
                mov [Return_adress], r13
                pop r13

                push r9
                push r8
                push rcx
                push rdx
                push rsi
                push rdi
                push rbx
                push r12
                push r13
                push r14
                push r15

                call _printf

                pop r15
                pop r14
                pop r13
                pop r12
                pop rbx


                push r13
                mov r13, [Return_adress]
                ret
; =======================================================================







; =======================================================================
; C-LIKE PRINTF FUNCTION
; Destroy :
; =======================================================================
_printf:
                mov r14, rsp
                add r14, 6 * REG_SIZE 

                mov rbx, [r14]
                add r14, 8

                xor rcx, rcx 

.cycle:
                mov al, [rbx + rcx]
                cmp al, END_SYMBOL        
                je .done

                cmp al, PERSENT_SYMBOL
                je .percent
            
                mov [Symbol], al
                call _print_symbol

                inc rcx
                jmp .cycle
.percent:

                call _parse_percent
                jmp .cycle


.done:
                call _print_buffer
                ret
; =======================================================================






            
; =======================================================================
; Proc to parse percentage agruments
; =======================================================================
_parse_percent:
                inc rcx

                mov al, [rbx + rcx]

                cmp al, '%'
                je .percent

                sub al, FIRST_LETTER 

                cmp al, LAST_LETTER - FIRST_LETTER
                ja .back

                movzx eax, al
                jmp [.jump_table + REG_SIZE * rax]

.percent:
                mov [Symbol], '%'
                call _print_symbol

.back:
                inc rcx

                ret



.char:
                mov rax, [r14]
                add r14, 8

                mov [Symbol], al
                call _print_symbol

                jmp .back

.hex:
                mov rax, [r14]
                add r14, 8


                                        ; проверка минуса
                mov r10, rax
                shr r10, 4 * REG_SIZE - 1
                cmp r10, 0
                je .hex_plus
                
                mov r10, rax
                xor rax, rax
                sub rax, r10
                mov [Symbol], MINUS_SYMBOL
                call _print_symbol

        .hex_plus:

                mov r10, 8
        .hex_clean_loop:                ; очистка буффера чисел
                mov r11, 64 + Num_buffer
                sub r11, r10
                mov byte [r11], 0                

                dec r10
                cmp r10, 0
                jne .hex_clean_loop


                mov r10, 0
        .hex_loop:                ; запись числа в буффер

                mov rsi, 0x0F
                and sil, al


                mov r11, 63 + Num_buffer
                sub r11, r10
                mov sil, byte [Numbers + rsi]       
                mov byte [r11], sil   

                shr rax, 4

                inc r10
                cmp r10, 8
                jne .hex_loop



                mov r10, 8
        .hex_zero_loop:                 ; выкидыш старших нулей
                mov r11, 64 + Num_buffer
                sub r11, r10

                mov dl, [r11]

                cmp dl, '0'
                jne .hex_print_loop

                dec r10
                cmp r10, 1
                jne .hex_zero_loop

        .hex_print_loop:                ; печать буффера
                mov r11, 64 + Num_buffer
                sub r11, r10

                mov dl, [r11]
                mov [Symbol], dl
                call _print_symbol

                dec r10
                cmp r10, 0
                jne .hex_print_loop

                jmp .back


.octo:
                mov rax, [r14]
                add r14, 8

                                        ; проверка минуса
                mov r10d, eax
                shr r10d, 31d
                cmp r10d, 0
                je .octo_plus
                
                mov r10d, eax
                xor eax, eax
                sub eax, r10d
                mov [Symbol], '-'
                call _print_symbol

        .octo_plus:

                mov r10, 11
        .octo_clean_loop:                ; очистка буффера чисел
                mov r11, 64 + Num_buffer
                sub r11, r10
                mov byte [r11], 0                

                dec r10
                cmp r10, 0
                jne .octo_clean_loop


                mov r10, 0
        .octo_loop:                ; запись числа в буффер

                mov rsi, 0x07
                and sil, al


                mov r11, 63 + Num_buffer
                sub r11, r10
                mov sil, byte [Numbers + rsi]       
                mov byte [r11], sil   

                shr eax, 3

                inc r10
                cmp r10, 11
                jne .octo_loop



                mov r10, 11
        .octo_zero_loop:                 ; выкидыш старших нулей
                mov r11, 64 + Num_buffer
                sub r11, r10

                mov dl, [r11]

                cmp dl, '0'
                jne .octo_print_loop

                dec r10
                cmp r10, 1
                jne .octo_zero_loop

        .octo_print_loop:                ; печать буффера
                mov r11, 64 + Num_buffer
                sub r11, r10

                mov dl, [r11]
                mov [Symbol], dl
                call _print_symbol

                dec r10
                cmp r10, 0
                jne .octo_print_loop

                jmp .back

.bin:
                mov rax, [r14]
                add r14, 8

                                        ; проверка минуса
                mov r10, rax
                shr r10, 31d
                cmp r10, 0
                je .bin_plus
                
                mov r10, rax
                xor rax, rax
                sub rax, r10
                mov [Symbol], '-'
                call _print_symbol

        .bin_plus:

                mov r10, 32
        .bin_clean_loop:                ; очистка буффера чисел
                mov r11, 64 + Num_buffer
                sub r11, r10
                mov byte [r11], 0                

                dec r10
                cmp r10, 0
                jne .bin_clean_loop


                mov r10, 0
        .bin_loop:                ; запись числа в буффер

                mov rsi, 0x01
                and sil, al


                mov r11, 63 + Num_buffer
                sub r11, r10
                mov sil, byte [Numbers + rsi]       
                mov byte [r11], sil   

                shr rax, 1

                inc r10
                cmp r10, 32
                jne .bin_loop



                mov r10, 32
        .bin_zero_loop:                 ; выкидыш старших нулей
                mov r11, 64 + Num_buffer
                sub r11, r10

                mov dl, [r11]

                cmp dl, '0'
                jne .bin_print_loop

                dec r10
                cmp r10, 1
                jne .bin_zero_loop


        .bin_print_loop:                ; печать буффера
                mov r11, 64 + Num_buffer
                sub r11, r10

                mov dl, [r11]
                mov [Symbol], dl
                call _print_symbol

                dec r10
                cmp r10, 0
                jne .bin_print_loop

                jmp .back

.decimal:
                mov rax, [r14]
                add r14, 8

                                        ; проверка минуса
                mov r10d, eax
                shr r10d, 31d
                cmp r10d, 0
                je .decimal_plus
                
                mov r10d, eax
                xor eax, eax
                sub eax, r10d
                mov [Symbol], '-'
                call _print_symbol

        .decimal_plus:

                mov r10, 8
        .dec_clean_loop:                ; очистка буффера чисел
                mov r11, 64 + Num_buffer
                sub r11, r10
                mov byte [r11], 0                

                dec r10
                cmp r10, 0
                jne .dec_clean_loop


                mov r10, 0
        .dec_loop:                ; запись числа в буффер

                mov esi, 10
                xor rdx, rdx
                div esi

                mov r11, 63 + Num_buffer
                sub r11, r10
                mov sil, byte [Numbers + rdx]       
                mov byte [r11], sil   

                inc r10
                cmp r10, 8
                jne .dec_loop



                mov r10, 8
        .dec_zero_loop:                 ; выкидыш старших нулей
                mov r11, 64 + Num_buffer
                sub r11, r10

                mov dl, [r11]

                cmp dl, '0'
                jne .dec_print_loop

                dec r10
                cmp r10, 1
                jne .dec_zero_loop

        .dec_print_loop:                ; печать буффера
                mov r11, 64 + Num_buffer
                sub r11, r10

                mov dl, [r11]
                mov [Symbol], dl
                call _print_symbol

                dec r10
                cmp r10, 0
                jne .dec_print_loop

                jmp .back



.string:
                mov rdx, [r14]
                add r14, 8

                push rcx
                push rax
                push rbx
                push rdi
                push rsi
                push rdx

                mov rbx, rdx
                call _strlen
                mov rcx, rax
                xor rdx, rdx
                mov rax, BUFFER_SIZE

                cmp rcx, rax
                jb .string_loop

                call _print_buffer

                mov rax, 0x01           ;syscall печати string
                mov rdi, 1
                mov rsi, rbx
                mov rdx, rcx
                syscall

                jmp .string_loop_done

.string_loop:
                cmp rdx, rcx
                je .string_loop_done

                mov al, byte [rbx + rdx]
                mov [Symbol], al
                call _print_symbol

                inc rdx
                jmp .string_loop
                
.string_loop_done:
                pop rdx
                pop rsi
                pop rdi
                pop rbx
                pop rax
                pop rcx

                jmp .back

.jump_table:
                dq .back
                dq .bin          
                dq .char         
                dq .decimal    
                dq 10 dup(.back)                                
                dq .octo         
                dq 3 dup(.back)       
                dq .string   
                dq 4 dup(.back)
                dq .hex
; =======================================================================





; =======================================================================
; PRINT SYMBOL FROM Symbol
; =======================================================================
_print_symbol:
                push rax     
                push rbx

                mov al, [Symbol]
                xor rbx, rbx
                mov bl, [Print_buffer_count]
                add rbx, Print_buffer

                mov [rbx], al

                mov bl, [Print_buffer_count]
                inc bl
                mov [Print_buffer_count], bl

                cmp bl, BUFFER_SIZE
                jne .done

                call _print_buffer

.done:
                pop rbx
                pop rax

                ret
; =======================================================================


; =======================================================================
; PRINT BUFFER IN ONE TIME
; =======================================================================
_print_buffer:
                push rax     
                push rdi
                push rsi
                push rdx
                push rcx

                mov rax, 0x01           ;syscall печати буффера
                mov rdi, 1
                mov rsi, Print_buffer
                xor rdx, rdx
                mov dl, [Print_buffer_count]
                syscall

                mov byte [Print_buffer_count], 0

                pop rcx
                pop rdx
                pop rsi
                pop rdi
                pop rax

                ret

; =======================================================================



; =======================================================================
; _strlen gives in RAX lenght of string in RBX till $
; =======================================================================
_strlen:
                push rcx

                xor rax, rax
.cycle:
                mov cl, [rbx + rax]
                cmp cl, END_SYMBOL
                je .done

                inc rax
                jmp .cycle

.done:
                pop rcx
                ret


; =======================================================================



section         .data

Symbol          db '0'
EndSymbol       db 0x0a
Numbers         db '0123456789ABCDEF'
Print_buffer_count  db 0
Return_adress   db 8 dup(0)

section         .bss

Num_buffer          resb 64
Print_buffer        resb BUFFER_SIZE


