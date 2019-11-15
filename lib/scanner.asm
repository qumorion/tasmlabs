; ЧТЕНИЕ СТРОКИ ИЗ КОНСОЛИ
proc_scan_s proc near
pop ax
pop dx
push ax ; возвращаем адрес ret на стек
mov ah, 0Ah
int 21h
ret
endp

m_scan_s macro buff
    push offset buff
    call proc_scan_s
endm
   


; ПРОЦЕДУРА ЧТЕНИЯ ЧИСЛА ИЗ КОНСОЛИ
proc_scan_int proc near
    pop di ; SI, DI СТИРАЮТСЯ, SI ИСПОЛЬЗУЕТСЯ ДЛЯ ХРАНЕНИЯ АДРЕСА БУФЕРА
    pop si
    push di
    
    push ax
    push bx
    push cx
    push dx

    getUserInput:
        push si         ; смещение для буфера сканера строки
        call proc_scan_s
        call pnl

        ; startCheck   
        mov bx, si 
        mov ah, 0h                       
        cmp ah, byte ptr [bx][1]                 ; Проверяем пустую строку
        jz getUserInput                     ; Если строка пустая - просим ввести снова

        mov cl, [bx][1]                 ; Инициализируем переменную счетчика
        xor eax, eax
        xor edx, edx
        xor ebx, ebx
        add bx, 2                         ; Введенная строка начинается со второго байта                                            

        cmp byte ptr [bx], 2Dh                ; Проверяем отрицательное ли число
        jne startParser                     ; Если отрицательное - нужно пропустить минус
        inc bx
        dec cl

    startParser:
        mov edx, 10                         ; Уножаем на 10 перед сложением с младшим разрядом
        mul edx
        cmp eax, 80000000h                  ; Если число оказалось слишком большим,
        jae getUserInput                    ; Просим ввести его снова
                                               

        mov dl, [bx]                        ; Получаем след символ
        sub dl, 30h                         ; Приводим к 16 системе счисления

        add eax, edx                        ; Прибавляем к конечному результату      
        cmp eax, 80000000h                  ; Если число оказалось слишком большим,
        jae getUserInput                    ; Просим ввести его снова

        inc bx                              ; Переходим к след. символу
        loop startParser

    mov bx, si
    cmp byte ptr [bx][2], '-'                    ; Вновь проверяем на знак
    jne endParser   
    neg eax
    endParser:
    mov esi,eax
    pop dx
    pop cx
    pop bx
    pop ax

ret
endp

m_scan_b macro buffer, result
pusha
push offset buffer
call proc_scan_int ; ОТВЕТ БЫЛ В АИКС
push ax
mov ax, si
mov result, al
pop ax
popa
endm

m_scan_w macro buffer, result
pusha
push offset buffer
call proc_scan_int
mov  result, si
popa
endm

m_scan_dw macro buffer, result
pusha
push offset buffer
call proc_scan_int
mov result, esi
popa
endm






