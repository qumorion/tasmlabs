proc_find_less_num proc near    ;ПРИНИМАЕТ АДРЕС МАТРИЦЫ В bx, КОНТРОЛЬНОЕ ЗНАЧЕНИЕ В al, РЕЗУЛЬТАТ В EAX
enter 5, 0
local @@matrix:word:1, @@num:byte:1, @@counter:word:1
    mov @@matrix, bx
    mov @@num, al
    mov @@counter, 0

pusha
    xor si, si
    xor di, di
    xor dx, dx

    mov di, 0
    @@next_row:
    xor ax, ax
    mov al, [bx]
    cmp di, ax
    jae @@end_

        mov si, 0
        @@next_column:
        mov al, [bx][1]
        cmp si, ax
        jae @@end_column

        xor ax, ax
        call proc_get_by_index  ;   get element 
        inc si
        ; comparing element
        cmp al, @@num
        jge @@next_column
        inc @@counter
        jmp @@next_column

    @@end_column:
    inc di
    jmp @@next_row

@@end_:
popa
xor eax, eax
mov ax, @@counter
leave
ret
endp