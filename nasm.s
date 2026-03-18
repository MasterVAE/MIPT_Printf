section     .text

global _start

; =======================================================================
; MAIN OF PROGRAMM
; =======================================================================
_start:     
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
        cmp al, '$'               
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
            inc rcx

            push r9
            ret
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







section     .data


Symbol      db '0'
EndSymbol   db 0x0a


Argument    db "vovk%ba golovka$"