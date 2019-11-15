.MODEL small
.STACK 100h
.486


.data
buff db 126, 128 dup(?) ;   2 байта служебные
token db 40, 40 dup(?)
q_exit db 4, 'exit'
q_enter db 12, 'enter matrix'
q_draw db 11, 'draw matrix'
q_search_less db 11, 'search less'
q_search_nonzero db 14, 'search nonzero'
space_symb db ' '

.code
include io.asm
include string.asm

start:
    mov ax, @data
    mov ds, ax

    get_command:
        m_scan_s buff
        m_set_tokenizer buff, token, space_symb

        parse:
        call proc_next_token

        is_equal token, q_exit
        je endprg

        cmp cx, 0   ;   Последняя команда?
        jne parse

        call pnl
    jmp get_command
    
    endprg:
    call pnl
    mov ax, 4C00h
    int 21h
end start