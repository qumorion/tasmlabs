_cmp_s_proc proc near
    ; ds:si - первая строка
    ; es:di - вторая строка   
    xor cx, cx
    mov cl, [si] 
    comp_char:
        cmpsb       ; Сравниваем символы строк
        jne return
    loop comp_char
    return:
ret ; команда возврата берет адрес из стека
endp _cmp_s_proc


is_equal macro buff, second 
pusha
mov ax, seg buff
mov ds, ax
mov ax, seg second
mov es, ax

lea si, buff
inc si              ; Пропускаем служебный байт буфера
lea di, second

call _cmp_s_proc
popa
endm





pnl proc near
push ax
push dx
mov ah, 02h ; Переносим каретку на новою строку
mov dl, 0Dh
int 21h
mov ah, 02h
mov dl, 0Ah
int 21h
pop dx
pop ax
ret
endp pnl

include printer.asm
include scanner.asm
