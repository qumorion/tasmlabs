_convert_string_to_byte proc near
    getUserInput:
        ; startCheck   
        mov bx, si 
        mov cl, [bx][1]                 ; Инициализируем переменную счетчика
        xor eax, eax
        xor edx, edx
        xor ebx, ebx
        add bx, 2                         ; Введенная строка начинается со второго байта                                            

        cmp byte ptr [bx], 2Dh                ; Проверяем отрицательное ли число
        jne startParser                     ; Если отрицательное - нужно пропустить минус
        inc bx
        dec cl

    startParser:
        mov edx, 10                         ; Уножаем на 10 перед сложением с младшим разрядом
        mul edx
        cmp eax, 80000000h                  ; Если число оказалось слишком большим,
        jae getUserInput                    ; Просим ввести его снова
                                               

        mov dl, [bx]                        ; Получаем след символ
        sub dl, 30h                         ; Приводим к 16 системе счисления

        add eax, edx                        ; Прибавляем к конечному результату      
        cmp eax, 80000000h                  ; Если число оказалось слишком большим,
        jae getUserInput                    ; Просим ввести его снова

        inc bx                              ; Переходим к след. символу
        loop startParser

    mov bx, si
    cmp byte ptr [bx][2], '-'                    ; Вновь проверяем на знак
    jne endParser   
    neg eax
    endParser:
    push eax
ret
endp


proc_enter_matrix proc near
    

    take_row:
    call proc_next_token
    
    pusha
    _convert_string_to_byte
    popa
    pop eax ; get result
    mov [bx][bp][di], 1

ret
endp

m_enter_matrix macro matrix, rows, columns
pusha
    mov bp, rows
    mov di, columns
    mov bx, matrix
    call proc_enter_matrix                        ; get word from string
popa
endm