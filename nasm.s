section     .text

global _start
global _my_printf

; =======================================================================
; Обертка для принта
; =======================================================================
_my_printf:     
                mov r15, rsp

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


                mov rsp, r15
                ret
; =======================================================================







; =======================================================================
; C-LIKE PRINTF FUNCTION
; =======================================================================
_printf:
                mov r14, rsp
                add r14, 48

                mov rbx, [r14]
                add r14, 8

                xor rcx, rcx 

.cycle:
                mov al, [rbx + rcx]
                cmp al, 0x00               
                je .done

                cmp al, '%'
                je .percent
            
                mov [Symbol], al
                call _print_symbol

                inc rcx
                jmp .cycle
.percent:

                call _parse_percent
                jmp .cycle


.done:
                ret
; =======================================================================






            
; =======================================================================
; Proc to parse percentage agruments
; =======================================================================
_parse_percent:
                inc rcx

                mov al, [rbx + rcx]
                sub al, 'b'

                cmp al, 17
                ja .back

                movzx eax, al
                jmp [.jump_table + 8 * rax]
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


                mov r10, 16
        .hex_clean_loop:                ; очистка буффера чисел
                mov r11, 64 + Buffer
                sub r11, r10
                mov byte [r11], 0                

                dec r10
                cmp r10, 0
                jne .hex_clean_loop


                mov r10, 0
        .hex_loop:                ; запись числа в буффер

                mov rsi, 0x0F
                and sil, al


                mov r11, 63 + Buffer
                sub r11, r10
                mov sil, byte [Numbers + rsi]       
                mov byte [r11], sil   

                shr rax, 4

                inc r10
                cmp r10, 16
                jne .hex_loop



                mov r10, 16
        .hex_zero_loop:                 ; выкидыш старших нулей
                mov r11, 64 + Buffer
                sub r11, r10

                mov dl, [r11]

                cmp dl, '0'
                jne .hex_print_loop

                dec r10
                cmp r10, 1
                jne .hex_zero_loop

        .hex_print_loop:                ; печать буффера
                mov r11, 64 + Buffer
                sub r11, r10

                mov dl, [r11]
                mov [Symbol], dl
                call _print_symbol

                dec r10
                cmp r10, 0
                jne .hex_print_loop

                jmp .back

.bin:
                mov rax, [r14]
                add r14, 8


                mov r10, 64
        .bin_clean_loop:                ; очистка буффера чисел
                mov r11, 64 + Buffer
                sub r11, r10
                mov byte [r11], 0                

                dec r10
                cmp r10, 0
                jne .bin_clean_loop


                mov r10, 0
        .bin_loop:                ; запись числа в буффер

                mov rsi, 0x01
                and sil, al


                mov r11, 63 + Buffer
                sub r11, r10
                mov sil, byte [Numbers + rsi]       
                mov byte [r11], sil   

                shr rax, 1

                inc r10
                cmp r10, 64
                jne .bin_loop



                mov r10, 64
        .bin_zero_loop:                 ; выкидыш старших нулей
                mov r11, 64 + Buffer
                sub r11, r10

                mov dl, [r11]

                cmp dl, '0'
                jne .bin_print_loop

                dec r10
                cmp r10, 1
                jne .bin_zero_loop


        .bin_print_loop:                ; печать буффера
                mov r11, 64 + Buffer
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


                mov r10, 32
        .dec_clean_loop:                ; очистка буффера чисел
                mov r11, 64 + Buffer
                sub r11, r10
                mov byte [r11], 0                

                dec r10
                cmp r10, 0
                jne .dec_clean_loop


                mov r10, 0
        .dec_loop:                ; запись числа в буффер

                mov rsi, 10
                xor rdx, rdx
                div rsi

                mov r11, 63 + Buffer
                sub r11, r10
                mov sil, byte [Numbers + rdx]       
                mov byte [r11], sil   

                inc r10
                cmp r10, 32
                jne .dec_loop



                mov r10, 32
        .dec_zero_loop:                 ; выкидыш старших нулей
                mov r11, 64 + Buffer
                sub r11, r10

                mov dl, [r11]

                cmp dl, '0'
                jne .dec_print_loop

                dec r10
                cmp r10, 1
                jne .dec_zero_loop

        .dec_print_loop:                ; печать буффера
                mov r11, 64 + Buffer
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

                mov rax, 0x01           
                mov rdi, 1
                mov rsi, rdx
                mov rdx, rcx
                syscall

                pop rdx
                pop rsi
                pop rdi
                pop rbx
                pop rax
                pop rcx

                jmp .back

.jump_table:
                dq .bin          
                dq .char         
                dq .decimal      
                dq .back         
                dq .back         
                dq .back         
                dq .hex          
                dq .back         
                dq .back         
                dq .back         
                dq .back         
                dq .back         
                dq .back         
                dq .back         
                dq .back         
                dq .back         
                dq .back         
                dq .string   
; =======================================================================





; =======================================================================
; PRINT SYMBOL FROM Symbol
; =======================================================================
_print_symbol:
                push rax     
                push rdi
                push rsi
                push rdx
                push rcx

                mov rax, 0x01           ;syscall печати символа
                mov rdi, 1
                mov rsi, Symbol
                mov rdx, 1
                syscall


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
                cmp cl, 0x00
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
Buffer          resb 64

Argument        db "bebra", 0x00
String1         db "Megaknight", 0x00
String2         db "Clash royal", 0x00

