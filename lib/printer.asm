proc_cls proc near      ; Процедура очистки экрана и установки цветов фона и текста
    mov ah, 10h
    mov al, 3h
    int 10h             ; Включение режима видеоадаптора с 16-ю цветами

    mov ax, 0600h       ; ah = 06 - прокрутка вверх 
                        ; al = 00 - строки появляются снизу и заполняются нулями
    mov bh, 11110110b   ; 0001 - синий (фон), 1110 - желтый (текст)
    mov cx, 0000        ; ah = 00 - строка верхнуго левого угла
                        ; al = 00 - столбец верхнего левого угла
    mov dx, 184Fh       ; dh = 18h - строка нижнего правого угла
                        ; dl = 4Fh - столбец нижнего правого угла
    int 10h             ; Очистка экрана и установка цветов фона и текста 
ret
endp


proc_set_cursor proc near
push ax
push bx
mov  bh, 0
mov  ah, 2h
int  10h
pop bx
pop ax
ret
endp

m_set_cursor macro row, column   ; Макрос перехода на заданную строку и столбец
    push dx
    mov  dh, row
    mov  dl, column
    call proc_set_cursor
    pop dx
endm
    
m_print_s macro string    ; Макрос вывода заданной строки string на экран
    push ax
    push dx
    mov  ah, 9
    mov  dx, offset string
    int  21h
    pop  dx
    pop  ax
endm









proc_print_int proc near
    mov bx, si
    add bx, 14 ; размер максимального числа, пишем число задом наперед (с конца буфера) + служебные
    mov ecx, eax ; сохраняем число для проверок
    
    mov [bx], byte ptr '$'              ; Символ окончания строки
    sub bx, 2                           ; /n = 2 БАЙТА!!!!!
    mov [bx], word ptr 0D0Ah            ; /n
    dec bx

    cmp eax, 80000000h                  ; Проверяем знак
    jb convert                         
    neg eax                             ; Приводим в прямой код
    jno convert                         ; Если приведение прошло успешно, 
                                        ; переходим конвертации
    mov bx, si
    mov [bx], byte ptr 'O'
    mov [bx][1], byte ptr 'F'
    mov [bx][2], byte ptr ' '
    mov [bx][3], byte ptr 'E'
    mov [bx][4], byte ptr 'R'
    mov [bx][5], byte ptr 'R'
    mov [bx][6], byte ptr '$'
    jmp print
                             
    convert:
        xor edx, edx
        mov edi, 10 
        div edi                         ; Получаем остаток деления на 10

        ; Сохраняем символ
        add dx, '0'                     ; Переводим в ascii
        mov [bx], dl
        dec bx

        cmp eax, 00
        jne convert

    inc bx                              ; Последнее смещение в цикле было не нужно

    or ecx, ecx              ; Проверяем знак
    jns print                ; Добавляем минус, если число отрицательное
    dec bx
    mov [bx], byte ptr '-'

    print:
    mov  ah, 9
    mov  dx, bx
    int  21h                            ; Выводим строку на экран

ret
endp 

m_print_b macro buff, num
endm

m_print_w macro buff, num
endm

m_print_dw macro buff, num
mov si, offset buff
mov eax, num
call proc_print_int
endm

