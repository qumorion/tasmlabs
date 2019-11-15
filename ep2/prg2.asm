.MODEL small
STACK 100h

.DATA
array dw 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
fio db 'Banniy Kirill Yurevich', '$'
birthYear dw 07D0h
constant dw 1302
softName db 'Kirushenka'
char_1 db ' ', 15, '$'
DOB dd 13022000                 ;‭ C6B330‬

.CODE
start:
    mov ax, @data
    mov ds, ax
    
    mov ax, [array]+1*2
    mov bx, [array]+3*2
    mov cx, [array]
    mov dx, [array]+2*2
    mov si, [array]+2*2
    mov di, [array]
    mov bp, [array]
    mov sp, [array]
    
    lea ax, [fio]
    lea ax, [fio]+8-1
    lea ax, [fio]+15-1
    mov al, [fio]+11-1

    mov ds:0516h, 07D0h         ; помещаем по адресу 1302 (дата рожд.) 
                                ; 2000 год в 16 системе счисления
    mov cx, [constant]
    
    mov ah, 09h
    mov dx, offset softName 
    int 21h

    mov ax, 4c00h
    int 21h
end start