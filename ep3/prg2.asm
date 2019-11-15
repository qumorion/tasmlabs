.MODEL small
.STACK 100h

.code
start:
    mov ax, @data
    mov ds, ax

    mov ax, 2
    mov bx, 34
    imul bx          ; 2 * 34
    sub ax, 3           ; (2 * 34) - 3

    push ax         ; Первое слагаемое
    
    mov ax, 152
    xor dx, dx
    mov bx, 3
    idiv bx             ; 152 / 3
    add ax, 2        ; (152 / 3 + 2)

    pop bx
    xchg ax, bx
    sub ax, bx           ; (2 * 34 - 3) - (152 / 3 +2)

    push ax              ; Сохраняем числитель

    mov ax, 6 
    mov bx, 2  
    sub ax, bx
    mov bx, 5
    imul bx
    add ax, 8                 ; 8 + 5(6 - 2)

    pop bx
    xchg ax, bx
    div bx                  ; (2 * 34 - 3) - (152 / 3 +2)  /  8 + 5(6 - 2)

    mov ax, 4C00h
    int 21h
end start
