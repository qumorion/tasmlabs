LOCALS 
.MODEL small
.STACK 100h
.486

.data
buff db 126, 128 dup(?) ;   2 байта служебные, первый - размер, второй - количество введенных пользователем
token db 40, 40 dup(?)
matrix db 102 dup(?)    ;   2 байта служебные, row + col

; ЗДЕСЬ НАХОДЯТСЯ СТРОКИ ДЛЯ ВЗАИМОДЕЙСТВИЯ С ПОЛЬЗОВАТЕЛЕМ, ВКЛЮЧАЯ КОМАНДЫ МЕНЮ
q_command db '> $'
q_exit db 4, 'exit'
q_enter db 5, 'enter'
q_enter_sizes db 'Please, enter matrix sizes: $'
q_enter_matrix db 'Please, enter rows of matrix: $'
q_draw db 4, 'draw'
q_search db 6, 'search'
q_less db 4, 'less'
q_nonzero db 7, 'nonzero'
q_debug db 5, 'debug'

space_symb db ' '
rows db 0
columns db 0





.code
include io.asm          ; Содержит процедуры для ввода-вывода чисел, объединяет в себя scanner и printer
include string.asm      ; Предназначен для работы со строками, пока что содержит сравниватель и токенайзер
include xmatrix.asm     ; Для работы с матрицами

start:
    mov ax, @data
    mov ds, ax

    get_string:
        m_print_s q_command
        m_scan_s buff                               ; read string from console
        m_set_tokenizer buff, token, space_symb     ; set up di, si and ds, es, also, delimeter

    parse:
        call proc_next_token                        ; get word from string


        ; ЗДЕСЬ НАХОДИТСЯ ОСНОВНАЯ ЛОГИКА ИНТЕРФЕЙСА. 
        ; ТОКЕНАЙЗЕР РАЗБИРАЕТ СТРОКУ НА ОТДЕЛЬНЫЕ СЛОВА, ПОСЛЕ ЧЕГО 
        ; ЗДЕСЬ ПРОИСХОДИТ ИХ СРАВНЕНИЕ НА СОВПАДЕНИЕ С КОМАНДОЙ.
        is_equal token, q_exit ; В ЭТУ СЕКЦИЮ МОЖНО ДОБАВЛЯТЬ ПРОВЕРКУ НА КОМАНДУ. СРАВНЕНИЕ УЖЕ НАСТРОЕНО.
        je handle_exit         ; ЗДЕСЬ НУЖНО УКАЗАТЬ МЕТКУ, ВЫБРАННУЮ ДЛЯ ИСПОЛНЕНИЯ КОМАНДЫ.
                               ; САМО ИСПОЛНЕНИЕ ОПИСЫВАЕТСЯ НИЖЕ
        ; ПРИМЕР:
        ; is_equal token, my_command
        ; je handle_my_command
        is_equal token, q_enter
        je handle_enter
        is_equal token, q_draw
        je handle_draw
        is_equal token, q_debug
        je handle_debug
        jmp next_command


; ==========================================================================================================
        ; ЗДЕСЬ МОЖНО ДОБАВЛЯТЬ ЛОГИКУ ИСПОЛНЯЕМЫХ КОМАНД.
        ; НУЖНО УКАЗАТЬ ВЫБРАННУЮ МЕТКУ, А В КОНЦЕ ДОБАВИТЬ ПЕРЕХОД НА next_command

        ; ЕСЛИ ВЫ РАБОТАЛИ С ВВОДОМ-ВЫВОДОМ, ТО В КОНЦЕ МОЖНО ДЕЛАТЬ ПЕРЕХОД НА get_string, НО ЕСЛИ
        ; В СТРОКЕ С КОМАНДАМИ БЫЛИ И ДРУГИЕ КОМАНДЫ, ТО ОНИ НЕ БУДУТ ВЫПОЛНЕНЫ

        ;ПРИМЕР:
        ;       handle_my_command:
        ;       ... (code)
        ;       jmp next_command

    handle_exit:    ; shut down program                                       
            call pnl
            mov ax, 4C00h
            int 21h


    handle_enter:   ; ENTER MATRIX
            call pnl
            m_print_s q_enter_sizes
            m_scan_s buff ; get string
            m_set_tokenizer buff, token, space_symb

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

            call pnl
            m_print_s q_enter_matrix
            m_enter_matrix matrix, rows, columns, buff, token
            call pnl
            jmp get_string ; skip cx checking


    handle_draw:
            call pnl
            push offset matrix
            push offset buff
            call proc_print_matrix
    jmp next_command


    handle_debug:
            int 3
    jmp next_command


    next_command:
    cmp cx, 0                                   ; input done? take next string
    jne parse
    call pnl                                    ; print /n
    jmp get_string
    




    
end start