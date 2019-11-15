.MODEL small
.STACK 100h
.486

.data
currentDigit db 0
inputString db 20 dup(?)
first dd 0
second dd 0

welcomeQuote db 'Please, enter integer number (< 4 billion)', 10, 13, '$'
.code
start:
    mov ax, @data
    mov ds, ax



mscanInt macro buffer, size, result         ; Макрос ввода целого числа на 28 бит
local getUserInput, startParser, endParser
    push ax
    push bx
    push dx
    push si

    getUserInput:
        mov [buffer], size                  ; Размер буфера c учетом двух служебных байтов
        sub [buffer], 2
        mov dx, offset [buffer]             ; Смещение для ввода
        mov ah, 0Ah                         ; Чтение строки из консоли
        int 21h

        mov ah, 02h                         ; Переносим каретку на новою строку
        mov dl, 0Dh
        int 21h
        mov ah, 02h
        mov dl, 0Ah
        int 21h

        ; startCheck    
        mov ah, 0h                       
        cmp ah, [buffer][1]                 ; Проверяем пустую строку
        jz getUserInput                     ; Если строка пустая - просим ввести снова

        mov cl, [buffer][1]                 ; Инициализируем переменную счетчика
        xor eax, eax
        xor edx, edx
        xor ebx, ebx
        mov bx, offset [buffer][2]          ; Введенная строка начинается со второго байта                                            

        cmp [buffer][2], 2Dh                ; Проверяем отрицательное ли число
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

    cmp [buffer][2], '-'                    ; Вновь проверяем на знак
    jne endParser   
    neg eax
    
    endParser:

    mov result, eax

    pop si
    pop dx
    pop bx
    pop ax

endm mscanInt
    

mPrintInt macro num, buf, size          ; Макрос вывода переменной на экран
local convert, print, endPrint

    push ax
    push bx
    push dx
    push si    
    
    mov bx, offset num                          
    add bx, size                        ; Пишем число задом наперед
    mov [bx], byte ptr '$'              ; Символ окончания строки
    sub bx, 2
    mov [bx], word ptr 0D0Ah
    dec bx
    mov eax, num                        ; Получаем число для вывода

    cmp eax, 80000000h                  ; Проверяем знак
    jb convert                         
    neg eax                             ; Приводим в прямой код
    jno convert                         ; Если приведение прошло успешно, 
                                        ; переходим конвертации
    mov bx, offset buf
    mov [bx], byte ptr 'O'
    mov [bx][1], byte ptr 'F'
    mov [bx][2], byte ptr ' '
    mov [bx][3], byte ptr 'E'
    mov [bx][4], byte ptr 'R'
    mov [bx][5], byte ptr 'R'
    mov [bx][6], byte ptr '$'
    jmp print
                             
    convert:
        mov esi, 10 
        xor dx, dx
        div esi                         ; Получаем остаток деления на 10

        ; Сохраняем символ
        add dx, '0'                     ; Переводим в ascii
        mov [bx], dl
        dec bx

        cmp eax, 00
        jne convert

    inc bx                              ; Последнее смещение в цикле было не нужно

    mov eax, num                        ; Проверяем знак
    or eax, eax
    jns print                           ; Добавляем минус, если число отрицательное
    dec bx
    mov [bx], byte ptr '-'

    print:
    mov  ah, 9
    mov  dx, bx
    int  21h                            ; Выводим строку на экран

    pop si
    pop dx
    pop bx
    pop ax

endm mPrintInt


    ;mov ax, 0007h                      ; Очищаем экран
    ;int 10h
    
    mscanInt inputString, 20, first
    mscanInt inputString, 20, second
    mov eax, [first]
    add eax, [second]
    mov [first], eax
    mPrintInt first, inputString, 20

    mov ax, 4C00h
    int 21h
end start
end