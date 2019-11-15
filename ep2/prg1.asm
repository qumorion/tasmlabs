.MODEL small    
.STACK 100h

.DATA
A db ?
B db ?
C db ?
D db ?

.code
start:
mov ax, @data
mov ds, ax

mov A, 3
mov B, 9
mov C, 2Eh
mov D, 0AAh

mov al, A
mov ah, B
xchg al, ah
mov bx, 3E10h
mov cx, bx
push bx
push cx
push ax
lea si, C
mov ax, si
lea di, D
mov bx, di
pop ax
pop cx
pop bx
mov bx, ax
mov A, al
mov B, ah
mov C, 0

mov ax, 4C00h
int 21h
end start
end