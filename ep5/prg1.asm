.MODEL small
.STACK 100h

.DATA
lastName db "Banny K.U.$" 
group db "ITD.B-31$"
faculty db "IU$"
exclamationMarks db "!!!!!$"
inputMessage1 db "Input A: $" 
inputMessage2 db "Input B: $"
resultMessage db "Result: $"
a dw 0
b dw 0
X dw 0
.CODE
start:
    mov ax, @data
    mov ds, ax
    
mCLS macro              ; Макрос очистки экрана и установки цветов фона и текста
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
endm

mGotoRowCol macro row, column   ; Макрос перехода на заданную строку и столбец
    push ax
    push bx
    push dx
    mov  dh, row
    mov  dl, column
    mov  bh, 0
    mov  ah, 2h
    int  10h
    pop  dx
    pop  bx
    pop  ax
endm
    
mDisplayStr macro string    ; Макрос вывода заданной строки string на экран
    push ax
    push dx
    mov  ah, 9
    mov  dx, offset string
    int  21h
    pop  dx
    pop  ax
endm

mDisplayRowCol macro row, column, string    ; Макрос вывода строки на экран на заданных координатах
    mGotoRowCol row, column 
    mDisplayStr string		
endm

mShowDecimalAX macro    ; Макрос вывода на экран содержания регистра ax в 10-ричной системе координат
local Convert, Show
    push ax
    push bx
    push cx
    push dx
    push di

    mov  cx, 10         ; cx - основание системы счисления
    xor  di, di         ; di - кол. цифр в числе
                        ; Eсли число в ax отрицательное, то:
                        ;   1) напечатать '-'
                        ;   2) сделать ax положительным
    or   ax, ax         ; Проверяем, равно ли число в ax нулю (и устанавливаем флаги)
    jns  Convert        ; Переход к конвертированию, если ax - без знака (если флаг SF = 0)
    push ax

    mov  dx, '-'
    mov  ah, 2h         
    int  21h            ; Вывод символа "-"

    pop  ax  
    neg  ax             ; Инвертируем отрицательное число
  
Convert:  
    xor  dx, dx  
    div  cx             ; dl = num mod 10
    add  dl, '0'        ; Перевод в символьный формат
    inc  di  
    push dx             ; Складываем в стэк
    or   ax, ax         ; Проверяем, равно ли число в ax нулю (и устанавливаем флаги)
    jnz  Convert        ; Переход к конвертированию, если ax не равно нулю (если флаг ZF = 0)
  
Show:                   ; Выводим значение из стэка на экран
    pop  dx             ; dl = очередной символ

    mov  ah, 2h   
    int  21h            ; Вывод очередного символа
    dec  di             ; Повторяем, пока di <> 0
    jnz  Show  
  
    pop  di
    pop  dx
    pop  cx
    pop  bx
    pop  ax
endm

    mCLS
    mDisplayRowCol 0, 0, lastName
    mDisplayRowCol 0, 74, exclamationMarks
    mDisplayRowCol 24, 0, faculty
    mDisplayRowCol 24, 71, group
    
    mDisplayRowCol 10, 35, inputMessage1
    mov ah, 01h           
    int 21h              ; Ввод первого числа
    sub al, 30h
    mov byte ptr a, al     

    mDisplayRowCol 11, 35, inputMessage2
    mov ah, 01h          
    int 21h              ; Ввод второго числа
    sub al, 30h
    mov byte ptr b, al       

    xor ax, ax
    xor bx, bx
    mov ax, a       
    mov bx, b 
    
    xor dx, dx

    cmp    ax, bx      
    ja     More  
    jl     Less  

    mov    ax, 25        ; Если равны
    jmp    Both      

   More:                 ; Если больше
    sub ax, bx
    idiv a
    add ax, 1

    jmp    Both     

   Less:                 ; Если меньше
    mov ax, 5
    idiv bx
    mov bx, a
    sub bx, ax
    mov ax, bx
    
    jmp    Both    

   Both:
    mov X, ax
    mDisplayRowCol 13, 35, resultMessage
    mShowDecimalAX

    mov ah,07h          
    int  21h          
    mov ax, 4c00h       ; Завершение программы
    int 21h
end start
