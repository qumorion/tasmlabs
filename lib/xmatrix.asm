_convert_string_to_byte proc near
    @@getUserInput:
        ; startCheck   
        mov bx, si 
        mov cl, [bx][1]                 ; Инициализируем переменную счетчика
        xor eax, eax
        xor edx, edx
        xor ebx, ebx
        add bx, 2                         ; Введенная строка начинается со второго байта                                            

        cmp byte ptr [bx], 2Dh                ; Проверяем отрицательное ли число
        jne @@startParser                     ; Если отрицательное - нужно пропустить минус
        inc bx
        dec cl

    @@startParser:
        mov edx, 10                         ; Уножаем на 10 перед сложением с младшим разрядом
        mul edx
        cmp eax, 80000000h                  ; Если число оказалось слишком большим,
        jae @@getUserInput                    ; Просим ввести его снова
                                               

        mov dl, [bx]                        ; Получаем след символ
        sub dl, 30h                         ; Приводим к 16 системе счисления

        add eax, edx                        ; Прибавляем к конечному результату      
        cmp eax, 80000000h                  ; Если число оказалось слишком большим,
        jae @@GetUserInput                    ; Просим ввести его снова

        inc bx                              ; Переходим к след. символу
        loop @@startParser

    mov bx, si
    cmp byte ptr [bx][2], '-'                    ; Вновь проверяем на знак
    jne @@endParser   
    neg eax
    @@endParser:
    mov edx, eax
ret
endp


proc_enter_matrix proc near
local @@matrix:word:?, @@buff:word:?, @@token:word:?, @@delim:byte:' ', @@ret_adr:word:?
local @@max_row:word:?, @@max_column:word:?, @@row:word:0, @@column:word:0

    pop @@ret_adr
    pop @@matrix
    pop @@buff
    pop @@token
    pop @@max_row
    pop @@max_column
    m_set_matrix_tokenizer @@buff, @@token, @@delim
    pusha

take_row:
    mov di, @@column
    cmp di, @@max_column
    je end_enter

    popa
    call proc_next_token
    pusha
    mov si, @@token
    call _convert_string_to_byte
    
    ; getting adress
    xor eax, eax
    mov ax, @@max_column
    mul @@row
    add ax, @@column
    add ax, @@matrix    ; full offset

    mov bx, ax
    mov [bx], dl

    inc @@column
jmp take_row

mov bp, @@row
cmp bp, @@max_row
je end_enter
inc @@row
jmp take_row

end_enter:
popa ; last cycle must pop
push @@ret_adr
ret 
endp

m_enter_matrix macro matrix, rows, columns, buff, token
pusha
    int 3
    xor eax, eax
    mov al, columns
    push ax
    mov al, rows
    push ax
    push offset token
    push offset buff
    push offset matrix
    call proc_enter_matrix
popa
endm