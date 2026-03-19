section     .text

global _start

; =======================================================================
; MAIN OF PROGRAMM
; =======================================================================
_start:     

                push 13
                push 13
                push String1
                push 'a'
                push Argument

                call _printf

                jmp _end
; =======================================================================





; =======================================================================
; EXIT PROGRAMM
; =======================================================================
_end:
                mov rax, 0x01
                mov rdi, 1
                mov rsi, EndSymbol
                mov rdx, 1
                syscall


                mov rax, 0x3C
                xor rdi, rdi
                syscall
; =======================================================================







; =======================================================================
; C-LIKE PRINTF FUNCTION
; =======================================================================
_printf:
                pop r8                  ; извлекаем адрес возврата
                pop rbx

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
                push r8                 ; возвращаем адрес возврата
                ret
; =======================================================================






            
; =======================================================================
; Proc to parse percentage agruments
; =======================================================================
_parse_percent:
                pop r9

                inc rcx

                mov al, [rbx + rcx]

                cmp al, 'c'               
                je .char

                cmp al, 's'               
                je .string

                cmp al, 'h'               
                je .hex
                
                cmp al, 'b'               
                je .bin

                cmp al, 'd'               
                je .decimal
.back:
                inc rcx

                push r9
                ret




.char:
                pop rax

                mov [Symbol], al
                call _print_symbol

                jmp .back

.hex:
                pop rax


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
                pop rax


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
                jmp .back


.string:
                pop rdx

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

Argument        db "vovk%c golovka %s %h %b", 0x00
String1         db "Megaknight", 0x00
String2         db "Clash royal", 0x00