
.MODEL small
.STACK 100h
.386
.DATA
a dd 876
b dd -356
.code
start:
    mov ax, @data
    mov ds, ax

    xor eax, eax
    mov eax, [b]
    imul eax         ;b ^ 2
    imul [a]        ; ab^2
    mov edx, 4
    imul edx         ; 4ab^2
    
    push eax

    mov eax, 2
    imul [b]        ;2b
    mov edx, 1
    add eax, edx      ;2b+1

    push eax
    mov eax, [a]
    mov edx, 4
    add eax, edx      ;a+4
    
    pop ebx
    xor edx, edx
    idiv ebx        ;(a+4)/(2b+1)

    mov edx, eax
    pop eax
    sub eax, edx      ;4ab^2 - (a+4)/(2b+1)


    mov ax, 4C00h
    int 21h
end start