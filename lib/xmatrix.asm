;МОДУЛЬ ТРЕБУЕТ INCLUDE IO.ASM !!!



; ПРОЦЕДУРЫ ДЛЯ ЗАПИСИ/ЧТЕНИЯ ЭЛЕМЕНТА ИЗ МАТРИЦЫ.
; НОМЕР СТРОКИ И СТОЛБЦА ЗАНОСЯТСЯ В di:si, АДРЕС МАТРИЦЫ В bx, ЧИСЛО ЗАНОСИТСЯ В al
proc_get_by_index proc near ; index into di:si, matrix offset in bx, result in al
push bx
push dx
push di
push si
    xor ax, ax
    mov ax, word ptr [bx]    ; num of rows
    add bx, 4
    mov dx, 2
    mul dx
    mul di
    mov di, ax
    xor ax, ax
    mov ax, si
    mov dx, 2
    mul dx
    add ax, di
    
    add bx, ax
    xor ax, ax
    mov ax, word ptr [bx]  ;   result
pop si
pop di
pop dx
pop bx
ret
endp

proc_set_by_index proc near ; index into di:si, matrix offset in bx, result in al
push bx
push dx
push di
push si
    push ax
    xor ax, ax
    mov ax, word ptr [bx]    ; num of rows
    add bx, 4
    mov dx, 2
    mul dx
    mul di
    mov di, ax
    xor ax, ax
    mov ax, si
    mov dx, 2
    mul dx
    add ax, di
    
    add bx, ax
    pop ax
    mov [bx], ax  ;   result
pop si
pop di
pop dx
pop bx
ret
endp


; ############################################################################################################################


proc_print_matrix proc near     ;ПРИНИМАЕТ АДРЕС МАТРИЦЫ В si, АДРЕС БУФЕРА В di
enter 4, 0
local @@matrix:word:1, @@buff:word:1
    mov @@matrix, si
    mov @@buff, di

pusha
    mov bx, @@matrix
    mov di, 0
    @@next_row:
    call pnl
    xor ax, ax
    mov ax, [bx]
    cmp di, ax
    jae @@end_print
    mov si, 0

        @@next_column:
        mov ax, [bx][2]
        cmp si, ax
        jae @@end_column

        call proc_get_by_index  ;   get element 
        ; PRINTING ELEMENT
        pusha
        mov si, @@buff
        cwde 
        call proc_print_int
        
        mov ah, 2
        mov dl, 09h
        int 21h
        popa

        inc si
        jmp @@next_column

    @@end_column:
    inc di
    call pnl
    jmp @@next_row

@@end_print:
popa
leave
ret
endp


; ############################################################################################################################


proc_transpose_matrix proc near     
;in: bx - адресс матрицы, с размерами в первых друх словах: row, column
	push ax
	push bx
	push cx
	push dx
	push di
    
    xor di, di

    int 3
    @@next_row:
    cmp di, [bx]
    je @@end_

    mov si, 0
    add si, di

    @@next_column:
    cmp si, bx[2]
    je @@end_row
    cmp si, di
    je @@end_column

    call proc_get_by_index
    push ax
    xchg di, si
    call proc_get_by_index
    xchg di, si
    call proc_set_by_index
    xchg di, si
    pop ax
    call proc_set_by_index
    xchg di, si

    @@end_column:
    inc si
    jmp @@next_column

    @@end_row:
    inc di
    jmp @@next_row
    
	@@end_:
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
ret
endp


; ############################################################################################################################


proc_enter_matrix proc near ;   ВМЕСТО ПРОЦЕДУРЫ ИСПОЛЬЗУЙТЕ МАКРОС НИЖЕ
enter 15, 0                 ;   ЗДЕСЬ ПОЛУЧИЛОСЬ ДОВОЛЬНО МНОГО КОДА ИЗ-ЗА ТОГО, ЧТО 3 ПРОЦЕДУРЫ ИСПОЛЬЗУЮТ
pusha                       ;   ОДНИ И ТЕ ЖЕ РЕГИСТРЫ ПО-РАЗНОМУ. ПРИШЛОСЬ МНОГОЕ ПЕРЕСОХРАНЯТЬ.
local @@matrix:word:1, @@buff:word:1, @@token:word:1, @@delim:byte:1, @@max_row:word:1, @@max_column:word:1, @@_di:word:1, @@_si:word:1

    mov @@matrix, bx        
    mov @@buff, si         
    mov @@token, di       
    mov @@delim, ' '
    mov @@max_row, ax
    mov @@max_column, dx

    mov [bx], ax
    mov [bx][2], dx
    mov di, 0

    next_row:
        xor eax, eax
        cmp di, @@max_row
        jae end_enter

        push @@buff
        call proc_scan_s
        push di
        push si
        m_set_matrix_tokenizer @@buff, @@token, @@delim
        mov @@_di, di
        mov @@_si, si
        pop si
        pop di

        call pnl         
        mov si, 0
    next_column:
        cmp si, @@max_column
        je end_row

        push si
        push di
        mov si, @@_si
        mov di, @@_di
        call proc_next_token
        mov @@_di, di
        mov @@_si, si
        pop di
        pop si

        ; adding next number
        push eax
        push bx
        push si
            mov si, @@token
            mov bx, @@matrix
            call _convert_string_to_byte
        pop si
            call proc_set_by_index
        pop bx
        pop eax

        inc si
    jmp next_column

    end_row:
        inc di
        jmp next_row

    end_enter:
popa
leave
ret 
endp


m_enter_matrix macro matrix, rows, columns, buff, token
pusha
    lea bx, [matrix]
    lea si, [buff]
    lea di, [token]
    mov ax, rows
    mov dx, columns
    call proc_enter_matrix
popa
endm