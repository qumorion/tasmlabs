_convert_string_to_byte proc near
    @@getUserInput:
        ; startCheck   
        mov bx, si 
        mov cl, [bx]                      ; Инициализируем переменную счетчика
        xor eax, eax
        xor edx, edx
        inc bx
        inc si                              ; Введенная строка начинается со второго байта                                            

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
    pop dx
    push eax
    push dx
ret
endp


proc_enter_matrix proc near
local @@matrix:word:1, @@buff:word:1, @@token:word:1, @@delim:byte:1, @@ret_adr:word:1, @@max_row:word:1, @@max_column:word:1, @@row:word:1, @@column:word:1

    pop @@ret_adr
    pop @@matrix
    pop @@buff
    pop @@token
    pop @@max_row
    pop @@max_column
    mov @@delim, ' '


next_row:
    mov bx, @@row
    cmp bx, @@max_row
    jae end_enter
    call pnl

    push @@buff
    call proc_scan_s

    m_set_matrix_tokenizer @@buff, @@token, @@delim
    mov @@column, 0
next_column:
pusha
    mov di, @@column
    cmp di, @@max_column
    je end_row
popa

    call proc_next_token
    mov si, @@token

pusha
    call _convert_string_to_byte
    
    ; getting adress
    xor eax, eax
    mov ax, @@max_column
    mul @@row
    add ax, @@column
    add ax, @@matrix    ; full offset

    mov bx, ax
    pop edx             ; get result from _convert_string_to_byte
    mov [bx], dl        ; mov next number
popa

    inc @@column
jmp next_column

end_row:
    inc @@row
    jmp next_row

end_enter:
;popa ; last cycle must pop
    push @@ret_adr
    ret 
    endp



m_enter_matrix macro matrix, rows, columns, buff, token
pusha
    xor eax, eax
    mov al, columns
    push ax
    mov al, rows
    push ax
    push offset token
    push offset buff

    mov bx, offset matrix   ; skip sizes bytes
    mov [bx], rows
    mov [bx]+1, columns
    add bx, 2
    push bx

    call proc_enter_matrix
popa
endm

