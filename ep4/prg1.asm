.MODEL small
.STACK 100h
.386
.data
input db 10010110b
maskForResult db 10000000b
result db 0
.code
start:
    mov ax, @data
    mov ds, ax
    mov ax, word ptr [input]
    ; Умножаем число на 16
    mov bx, 16
    mul bx

    ; Установка счетчика и индекса
    mov cx, 8
    mov bx, 0
    fori:
        bt ax, bx               ; Смотрим на бит в ax по индексу bx
        jae endifzero           ; Если бит - ноль, делаем переход
        ; Складываем маску с результатом
            mov dl, [result]    
            or dl, [[maskForResult]]
            mov [result], dl
        endifzero:
        shr [maskForResult], 1             ; Сдвигаем маску вправо
        inc bx                  ; Увеличиваем указатель текущего бита
    loop fori    
    
    mov ax, 4C00h
    int 21h
end start