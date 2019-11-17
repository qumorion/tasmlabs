LOCALS 
.MODEL small
.STACK 500
.486

.data
buff db 126, 128 dup(?) ;   2 байта служебные, первый - размер, второй - количество введенных пользователем
token db 40, 40 dup(0)
matrix db 3,3,1,2,3,4,5,6,7,8,9, 89 dup(?)    ;   2 байта служебные, row + col

; ЗДЕСЬ НАХОДЯТСЯ СТРОКИ ДЛЯ ВЗАИМОДЕЙСТВИЯ С ПОЛЬЗОВАТЕЛЕМ, ВКЛЮЧАЯ КОМАНДЫ МЕНЮ
q_command db '> $'
q_exit db 4, 'exit'
q_enter db 5, 'enter'
q_enter_sizes db 'Please, enter matrix sizes: $'
q_enter_matrix db 'Please, enter rows of matrix: $'
q_print db 5, 'print'
q_debug db 5, 'debug'
q_transpose db 9, 'transpose'
q_transpose_success db 'matrix was transposed!$'

q_search db 6, 'search'
q_less db 4, 'less'
q_nzstrings db 9, 'nzstrings'
q_sum db 3, 'sum'


space_symb db ' '
rows db 0
columns db 0

; ###########################################################################################################

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
        is_equal token, q_print
        je handle_print
        is_equal token, q_debug
        je handle_debug
        is_equal token, q_transpose
        je handle_transpose

        ; ОТДЕЛЬНАЯ ЛОГИКА ДЛЯ ВЛОЖЕННОЙ КОМАНДЫ 'SEARCH'
        is_equal token, q_search
        jne end_search

        call proc_next_token
        is_equal token, q_less
        je handle_less
        is_equal token, q_nzstrings
        je handle_nzstrings
        is_equal token, q_sum
        je handle_sum

        end_search:
        jmp next_command



; ###########################################################################################################
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
            mov [rows], al
        popa
            call proc_next_token ; get columns
            lea si, token   
            call _convert_string_to_byte ; convert to number
            mov [columns], al

            call pnl
            m_print_s q_enter_matrix
            m_enter_matrix matrix, rows, columns, buff, token
            call pnl
            jmp get_string ; skip cx checking


    handle_print:
            call pnl
            pusha
            lea si, [matrix]
            lea di, [buff]
            call proc_print_matrix
            popa
    jmp next_command


    handle_debug:
    jmp next_command

    handle_transpose:
            call pnl
            push si
            mov si, offset matrix
            call proc_transpose_matrix
            m_print_s q_transpose_success
            call pnl
            pop si
    jmp next_command

    handle_less:
            call proc_next_token
            push si
            lea si, token
            call _convert_string_to_byte

            mov ax, si
    jmp next_command

    handle_nzstrings:
    jmp next_command

    handle_sum:
    jmp next_command



    next_command:
    cmp cx, 0                                   ; input done? take next string
    jne parse
    call pnl                                    ; print /n
    jmp get_string
    




    
end start