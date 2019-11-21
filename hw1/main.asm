LOCALS 
.MODEL small
.STACK 500
.486

.data
buff db 126, 126 dup(?) ;   2 байта служебные, первый - размер, второй - количество введенных пользователем
token db 40, 40 dup(0)
matrix dw 3,3,1,2,3,4,5,6,7,8,9, 91 dup(?)    ;   2 байта служебные, row + col
edited_string db 100, 100 dup(?), 'err$'

; ЗДЕСЬ НАХОДЯТСЯ СТРОКИ ДЛЯ ВЗАИМОДЕЙСТВИЯ С ПОЛЬЗОВАТЕЛЕМ, ВКЛЮЧАЯ КОМАНДЫ МЕНЮ
q_command db '> $'
q_exit db 4, 'exit'
q_result db 'result: $'
q_enter db 5, 'enter'
q_enter_sizes db 'Please, enter matrix sizes: $'
q_enter_matrix db 'Please, enter rows of matrix: $'
q_print db 5, 'print'
q_debug db 5, 'debug'
q_transpose db 9, 'transpose'
q_transpose_success db 'matrix was transposed!$'
q_labwork_8 db 8, 'labwork8'
q_help db 4, 'help'

q_manual_1 db 'enter - enter matrix from keyboard','$'
q_manual_2 db 'print - print matrix into console','$'
q_manual_3 db 'transpose -  transpose matrix','$'
q_manual_4 db 'search less - print a num of elements to be less than a entered value for every row of matrix','$'
q_manual_5 db 'search nzstrings - count a num of non-zero strings of matrix','$'
q_manual_6 db 'search sum - get sum of matrix elements under the main diagonal','$'
q_manual_7 db 'exit - shut down the program', '$'

q_search db 6, 'search'
q_less db 4, 'less'
q_nzstrings db 9, 'nzstrings'
q_sum db 3, 'sum'


space_symb db ' '
rows db 0
columns db 0
num dw 0

; ###########################################################################################################

.code
include io.asm          ; Содержит процедуры для ввода-вывода чисел, объединяет в себя scanner и printer
include string.asm      ; Предназначен для работы со строками, пока что содержит сравниватель и токенайзер
include xmatrix.asm     ; Для работы с матрицами
include task.asm        ; Задание варианта

start:
    mov ax, @data
    mov ds, ax
   ;call proc_cls
   ;m_set_cursor 1, 0

    get_string:

        call pnl
        m_print_s q_command
        m_scan_s buff                               ; read string from console
        m_set_tokenizer buff, token, space_symb     ; set up di, si and ds, es, also, delimeter

    parse:
        call proc_next_token                        ; get word from string
; ###########################################################################################################

        ; ЗДЕСЬ НАХОДИТСЯ ОСНОВНАЯ ЛОГИКА ИНТЕРФЕЙСА. 
        ; ТОКЕНАЙЗЕР РАЗБИРАЕТ СТРОКУ НА ОТДЕЛЬНЫЕ СЛОВА, ПОСЛЕ ЧЕГО 
        ; ЗДЕСЬ ПРОИСХОДИТ ИХ СРАВНЕНИЕ НА СОВПАДЕНИЕ С КОМАНДОЙ.

        ; ЗДЕСЬ МОЖНО ДОБАВЛЯТЬ ЛОГИКУ ИСПОЛНЯЕМЫХ КОМАНД.
        ; НУЖНО УКАЗАТЬ СЛЕДУЮЩУЮ ПО НОМЕРУ МЕТКУ, А В КОНЦЕ КЕЙСА МОЖНО ДОБАВИТЬ ПЕРЕХОД НА next_command.
        ; ЕСЛИ ВЫ РАБОТАЛИ С ВВОДОМ-ВЫВОДОМ, ТО ВМЕСТО next_command МОЖНО ДЕЛАТЬ ПЕРЕХОД НА get_string, - 
        ; - ЭТО ПРЕДОТВРАТИТ ВЫПОНЕНИЕ ДРУГИХ КОМАНД В СТРОКЕ

        ;ПРИМЕР:
        ; _x:                                   <= здесь номер вашего кейса
        ;       is_equal token, q_mycommand
        ;       jne _(x+1)                      <= в случае несовпадения, напишите переход на след. кейс
        ;       ... (code)
        ;       jmp next_command                <= в конце можно поставить "break"
        ;       ; Умножение матрицы             <= обязательно напишите, что делает ваш кейс
_1:
        is_equal token, q_exit
        jne _2                                    
                call pnl
                mov ax, 4C00h
                int 21h
        ; ВЫХОД ИЗ ПРОГРАММЫ
_2:
        is_equal token, q_enter
        jne _3
                call pnl
                m_print_s q_enter_sizes
                m_scan_s buff ; get string
                m_set_tokenizer buff, token, space_symb
                call proc_next_token ; get rows
                push si
                push ax
                lea si, token   
                call _convert_string_to_byte ; convert to number
                mov [rows], al
                pop ax
                pop si
                call proc_next_token ; get columns
                lea si, token   
                call _convert_string_to_byte ; convert to number
                mov [columns], al
                call pnl
                m_print_s q_enter_matrix
                call pnl
                m_enter_matrix matrix, rows, columns, buff, token
        jmp get_string ; skip cx checking
        ; ВВОД ПРОИЗВОЛЬНОЙ МАТРИЦЫ ЧЕРЕЗ КОНСОЛЬ

_3:
        is_equal token, q_print
        jne _4
                call pnl
                pusha
                lea si, [matrix]
                lea di, [buff]
                call proc_print_matrix
                popa
        ; ВЫВОД МАТРИЦЫ В КОНСОЛЬ

_4:
        is_equal token, q_debug
        jne _5
                    int 3
        ; ВЫЗОВ ОТЛАДЧИКА (ЕСЛИ ТОТ БЫЛ ЗАПУЩЕН)

_5:
        is_equal token, q_transpose
        jne _6
                    call pnl
                    push si
                    lea si, matrix
                    call proc_transpose_matrix
                    m_print_s q_transpose_success
                    call pnl
                    pop si
        ; ТРАНСПОНИРОВАНИЕ МАТРИЦЫ

_6:
        ; ОТДЕЛЬНАЯ ЛОГИКА ДЛЯ КОМПЛЕКСНОЙ КОМАНДЫ 'SEARCH'
        is_equal token, q_search
        jne _7
                call proc_next_token
                jmp _6_1

        _6_1:
                is_equal token, q_less
                jne _6_2
                        call pnl
                        call proc_next_token
                        push si
                        lea si, token
                        call _convert_string_to_byte
                        lea bx, [matrix]
                        lea dx, [buff]
                        call proc_find_less_num
                ; ПОИСК ЭЛЕМЕНТОВ В КАЖД. СТРОКЕ МАТРИЦЫ, МЕНЬШЕ ВВЕДЕННОГО ЗНАЧЕНИЯ

        _6_2:
                is_equal token, q_nzstrings
                jne _6_3  ; skip other parameters
                        call pnl
                        m_print_s q_result
                        lea bx, [matrix]
                        lea dx, [buff]
                        call proc_find_nonzero        
                ; ПОДСЧЕТ НЕНУЛЕВЫХ СТРОК МАТРИЦ

        _6_3:
                is_equal token, q_sum
                jne get_string ; skip other parameters
                        call pnl
                        m_print_s q_result
                        lea bx, [matrix]
                        lea dx, [buff]
                        call proc_find_sum
                ; СУММА ЭЛЕМЕНТОВ МАТРИЦЫ ПОД ГЛАВНОЙ ДИАГОНАЛЬЮ 

_7:
        is_equal token, q_labwork_8
        jne _8
                call pnl
                m_scan_s buff                              
                m_set_tokenizer buff, token, space_symb     ; set up di, si and ds, es, also, delimeter in al
                mov [num], 0
                mov [edited_string], 0
                mov [edited_string][1], '$'
                begin_split:
                        cmp cx, 0
                        je end_split

                        inc [num]

                        call proc_next_token

                        ; print
                        push bx 
                                xor bx, bx
                                mov bl, [token]
                                inc bx
                                mov [token][bx], '$'
                                call pnl
                                push ax  
                                push dx
                                mov  ah, 9
                                lea dx, [token]
                                inc dx
                                int  21h
                                pop  dx
                                pop  ax
                        pop bx

                        ;check for numbers
                        pusha
                                xor cx, cx
                                xor bx, bx
                                lea bx, [token]
                                mov cl, [token]

                                num_check:
                                cmp cx, 0
                                je end_num_ok

                                inc bx
                                dec cx
                                cmp [bx], byte ptr '0'
                                jb num_check
                                cmp [bx], byte ptr '9'
                                ja num_check
                                jmp end_dum_no

                                end_dum_no:
                                popa
                                jmp begin_split

                                end_num_ok:
                                popa
                        
                        ; copy
                        pusha
                                xor ax, ax
                                lea si, [token]
                                inc si ; skip size
                                lea di, [edited_string]
                                add di, 1
                                mov al, [edited_string]
                                add di, ax
                                mov al, [token]
                                xor cx, cx
                                mov cl, al
                                inc al ; space
                                add [edited_string], al
                                rep movsb
                                mov [di], byte ptr ' '
                                mov [di][1], byte ptr '$'
                        popa
                        jmp begin_split

                end_split:
                call pnl
                push ax               ; вывод отредактированной строки
                push dx
                mov  ah, 9
                mov  dx, offset [edited_string]
                inc dx
                int  21h
                pop  dx
                pop  ax
                call pnl
                m_print_s q_result
                m_print_w buff, num


_8:     is_equal token, q_help
        jne _9
        call pnl
        m_print_s q_manual_1
        call pnl
        m_print_s q_manual_2
        call pnl
        m_print_s q_manual_3
        call pnl
        m_print_s q_manual_4
        call pnl
        m_print_s q_manual_5
        call pnl
        m_print_s q_manual_6
        call pnl
        m_print_s q_manual_7
        call pnl
_9:
    
        

next_command:
cmp cx, 0                                   ; input done? take next string
jne parse
call pnl                                    ; print /n
jmp get_string
    

    
end start