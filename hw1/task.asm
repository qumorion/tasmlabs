proc_find_less_num proc near    ;ПРИНИМАЕТ АДРЕС МАТРИЦЫ В bx, КОНТРОЛЬНОЕ ЗНАЧЕНИЕ В ax, БУФЕР ДЛЯ ВЫВОДА В dx
enter 10, 0                     
local @@matrix:word:1, @@control_num:word:1, @@counter:word:1, @@buff:word:1, @@row:word:1
    mov @@matrix, bx
    mov @@control_num, ax
    mov @@counter, 0
    mov @@buff, dx

pusha
    xor si, si
    xor di, di
    xor dx, dx

    mov di, 0
    @@next_row:
    xor ax, ax
    mov ax, [bx]
    cmp di, ax
    jae @@end_

        mov si, 0
        @@next_column:
        mov ax, [bx][2]
        cmp si, ax
        jae @@end_row

        xor ax, ax
        call proc_get_by_index  ;   get element 
        inc si
        ; comparing element
        cmp ax, @@control_num
        jge @@next_column
        inc @@counter
        jmp @@next_column

    @@end_row:
    mov @@row, di
    m_print_w @@buff, @@row
    mov ah, 02h
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    m_print_w @@buff, @@counter
    call pnl
    inc di
    mov @@counter, 0
    jmp @@next_row

@@end_:
popa
xor eax, eax
mov ax, @@counter
leave
ret
endp



proc_find_nonzero proc near    ;ПРИНИМАЕТ АДРЕС МАТРИЦЫ В bx, БУФЕР ДЛЯ ВЫВОДА В dx
enter 7, 0                    
local @@matrix:word:1, @@nonzero:byte:1, @@counter:word:1, @@buff:word:1
    mov @@matrix, bx
    mov @@nonzero, 0
    mov @@counter, 0
    mov @@buff, dx

pusha
    xor si, si
    xor di, di
    xor dx, dx

    mov di, 0
    @@next_row:
    xor ax, ax
    mov ax, [bx]
    cmp di, ax
    jae @@end_

        mov si, 0
        @@next_column:
        mov ax, [bx][2]
        cmp si, ax
        jae @@end_row

        xor ax, ax
        call proc_get_by_index  ;   get element 
        inc si
        ; comparing element
        cmp ax, 0
        je @@next_column
        inc @@nonzero
        jmp @@end_row

    @@end_row:
    inc di
    cmp @@nonzero, 0
    je @@next_row
    inc @@counter
    mov @@nonzero, 0
    jmp @@next_row

@@end_:
m_print_w @@buff, @@counter
call pnl
popa
xor eax, eax
mov ax, @@counter
leave
ret
endp


proc_find_sum proc near    ;ПРИНИМАЕТ АДРЕС МАТРИЦЫ В bx, БУФЕР ДЛЯ ВЫВОДА В dx
enter 8, 0                    
local @@matrix:word:1, @@buff:word:1, @@sum:dword:1
    mov @@matrix, bx
    mov @@buff, dx
    mov @@sum, 0
int 3
pusha
    xor si, si
    xor di, di
    xor dx, dx

    mov di, 0
    @@next_row:
    xor ax, ax
    mov ax, [bx]
    cmp di, ax
    jae @@end_

        mov si, 0
        @@next_column:
        mov ax, [bx][2]
        cmp si, ax
        jae @@end_row
        cmp si, di
        ja @@end_row

        xor eax, eax
        call proc_get_by_index  ;   get element 
        inc si
        ; comparing element
        cwde
        add @@sum, eax
        jmp @@next_column

    @@end_row:
    inc di
    jmp @@next_row

@@end_:
m_print_dw @@buff, @@sum
call pnl
popa
leave
ret
endp