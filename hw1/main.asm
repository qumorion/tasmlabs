LOCALS 
.MODEL small
.STACK 100h
.486

.data
buff db 126, 128 dup(?) ;   2 байта служебные
token db 40, 40 dup(?)
matrix db 102 dup(?)    ;   2 байта служебные
q_command db '> $'
q_exit db 4, 'exit'
q_enter db 5, 'enter'
q_enter_row db 'Enter'
q_enter_please db 'Please, enter matrix sizes: $'
q_draw db 4, 'draw'
q_search db 6, 'search'
q_less db 4, 'less'
q_nonzero db 7, 'nonzero'
space_symb db ' '
rows db 0
columns db 0

.code
include io.asm
include string.asm
include xmatrix.asm

start:
    mov ax, @data
    mov ds, ax

    get_string:
        m_print_s q_command
        m_scan_s buff                               ; read string from console
        m_set_tokenizer buff, token, space_symb     ; set up di, si and ds, es, also, delimeter

    parse:
        call proc_next_token                        ; get word from string

        ; Comparing with menu commands
        is_equal token, q_exit ; == exit?  
        je handle_exit
        is_equal token, q_enter
        je handle_enter
        is_equal token, q_draw
        je handle_draw
        jmp next_command

        handle_exit:    ; shut down program                                       
            call pnl
            mov ax, 4C00h
            int 21h
  

        handle_enter:   ; ENTER MATRIX
            call pnl
            m_print_s q_enter_please
            m_scan_s buff ; get string
            m_set_tokenizer buff, token, space_symb

            int 3
            call proc_next_token ; get rows
        pusha
            lea si, token   
            call _convert_string_to_byte ; convert to number
            pop eax
            mov [rows], al
        popa
            call proc_next_token ; get columns
            lea si, token   
            call _convert_string_to_byte ; convert to number
            pop eax
            mov [columns], al
        
            m_enter_matrix matrix, rows, columns, buff, token
            call pnl
            jmp get_string ; skip cx checking


        handle_draw:

            jmp next_command

    next_command:
    int 3
    cmp cx, 0                                   ; input done? take next string
    jne parse
    call pnl                                    ; print /n
    jmp get_string
    
    
end start