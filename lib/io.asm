; ПРОЦЕДУРА ПЕРЕНОСИТ КАРЕТКУ НА НОВУЮ СТРОКУ.
; НЕ ПОРТИТ РЕГИСТРЫ.
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

; ВКЛЮЧАЕТ В СЕБЯ ПРИНТЕР И СКАНЕР ДЛЯ РАБОТЫ С ВЫВОДОМ-ВВОДОМ
include printer.asm
include scanner.asm
