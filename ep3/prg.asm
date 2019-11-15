.MODEL small
.STACK 100h

.data
x db 1d
y db 1101b
sumResult db 0
subResult db 0
mulResult dw 1
modResult db ?
quotient db ?

.CODE
start:
    mov ax, @data
    mov ds, ax
    
    ; Сложение
    mov ah, [x]
    add ah, [y]
    mov [sumResult], ah

    ; Вычитание X и Y
    mov ah, [y]
    sub ah, [x]
    mov [subResult], ah

    ; Вычитание X и -Y
    neg [y]
    mov al, [x]
    sub ah, [y]

    ; Умножение с учетом знака
    xor ax, ax
    mov al, [x]
    imul [y]
    mov [mulResult], ax

    ; Умножение без учёта знака
    xor ax, ax
    mov al, [x]
    mul [y]

    ; Деление
    neg [y] 
    xor ax, ax
    mov al, [y]
    div [x]
    mov [quotient], al
    mov [modResult], ah

    mov dx, ax
    xor ax, dx

    mov ax, 4C00h
    int 21h
end start
end