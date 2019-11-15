.model small
.stack 100h
.486

.data
enterNquote db 'Please, enter N: $'
enterCquote db 'Please, enter C: $'
enterDquote db 'Please, enter D: $'
enterArrayQuote db 'Please, enter N numbers: $'
resultQuote db 'The result is: $'

buffer db 20 dup(?),'$'
lineNumber db 0
currentNum dw 0

n dw 0
c dw 0
d dw 0
result db 0

include io.asm

.code
start:
    mov ax, @data
    mov ds, ax

    mCLS

    msetCursor 2, 20
    mprintStr enterNquote
    mscanW buffer, 20, n

    msetCursor 3, 20
    mprintStr enterCquote
    mscanW buffer, 20, c

    msetCursor 4, 20
    mprintStr enterDquote
    mscanW buffer, 20, d

    msetCursor 5, 20
    mprintStr enterArrayQuote

    mov cx, n                   ; Инициализируем счетчик
    mov dl, 0                   ; Счетчик элементов, c<=a[i]<=d
    mov [lineNumber], 4         ; Номер строки

    nextNumber:
        dec cx  ; Уменьшаем счетчик
        cmp cx, 0
        jge continue
            jmp stopInput
        continue:

        inc [lineNumber]
        msetCursor lineNumber, 45
        mscanW buffer, 20, currentNum

        mov ax, c
        mov bx, d

        cmp ax, [currentNum]
        jg skip                 ; Если c больше числа, пропускаем

        cmp bx, [currentNum]
        jl skip                 ; Если d больше числа, пропускаем

        inc dl

        skip:
        jmp nextNumber

    stopInput:

    msetCursor 16, 20
    mprintStr resultQuote
    mov [result], dl
    mprintInt buffer, 20, result
    

    mov ax, 4C00h
    int 21h
end start