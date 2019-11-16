; СРАВНИВАЕТ ДВЕ СТРОКИ, ОСТАНАВЛИВАЕТСЯ, КОГДА НАШЛОСЬ РАЗЛИЧИЕ.
; ПОДНИМАЕТ ФЛАГИ, АНАЛОГИЧНО КОМАНДЕ CMP
; ДЛЯ УДОБСТВА РЕКОМЕНДУЕТСЯ ИСПОЛЬЗОВАТЬ МАКРОС, 
; КОТОРЫЙ САМ УКЛАДЫВАЕТ ПАРАМЕТРЫ В РЕГИСТРЫ.

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


is_equal macro first, second ; < ================= РЕКОМЕНДУЕТСЯ ДЛЯ СРАВНЕНИЯ
pusha
    mov ax, seg first
    mov ds, ax
    mov ax, seg second
    mov es, ax

    lea si, first
    lea di, second

    call _cmp_s_proc
popa
endm


;===============================================================================================================
;                                           ТОКЕНАЙЗЕР

; КОД НИЖЕ ДОВОЛЬНО ЗАПУТАН, ЕСЛИ ЧТО-ТО В НЕМ КАЖЕТСЯ БЕССМЫСЛЕННЫМ, 
; ТО СТОИТ ДЕРЖАТЬ СЕБЯ В РУКАХ, И ВСЕ-ТАКИ НИЧЕГО НЕ ТРОГАТЬ.
; АВТОР ПОТРАТИЛ НА НЕГО ОКОЛО 15 ЧАСОВ, И ОЧЕНЬ РАД, ЧТО ВСЕ КОНЧИЛОСЬ.

; КАК РАБОТАЕТ ТОКЕНАЙЗЕР?
; ВНУТРИ ОН ИСПОЛЬЗУЕТ КОМАНДЫ SCASB И MOVSB, КОТОРЫЕ ТРЕБУЮТ ПРАВИЛЬНОЙ 
; ПЕРЕДАЧИ АРГУМЕНТОВ ЧЕРЕЗ РЕГИСТРЫ. ПО ЭТОЙ ПРИЧИНЕ БЫЛ СОЗДАН МАКРОС
; m_set_matrix_tokenizer, КОТОРОМУ НУЖНО ПЕРЕДАТЬ САМУ СТРОКУ ДЛЯ РАЗБОРА (string),
; ПОТОМ МЕСТО ДЛЯ ХРАНЕНИЯ ПОЛУЧЕННОГО ТОКЕНА (token) И РАЗДЕЛИТЕЛЬ, КОТОРЫМ
; НУЖНО РАЗБИВАТЬ СТРОКУ (delimiter). 
; 
; 
; ВНИЗУ ЕСТЬ АНАЛОГ МАКРОСА m_set_matrix_tokenizer    -    m_set_matrix_tokenizer.
; ЕДИНСТВЕННОЕ ОТЛИЧИЕ - ВТОРОЙ МАКРОС ПРИНИМАЕТ АДРЕСА СТРОКИ И ТОКЕНА, А НЕ ПЕРЕМЕННЫЕ.
; 
;
; 
; КАК ПОЛЬЗОВАТЬСЯ:
; 
; 1 - ВЫЗОВИТЕ ОДИН ИЗ МАКРОСОВ, ЧТОБЫ ОН ПРАВИЛЬНО ЗАПОЛНИЛ РЕГИСТРЫ.
; МАКРОС ПРИНИМАЕТ СТРОКУ С РАЗМЕРОМ В ПЕРВОМ БАЙТЕ, И ВОЗВРАЩАЕТ АНАЛОГИЧНЫЙ ТОКЕН.
; 
; 2 - НАЧИНАЙТЕ ВЫЗЫВАТЬ proc_next_token, ЧТОБЫ ПОЛУЧИТЬ СЛЕДУЮЩИЙ ТОКЕН.
; БУДЬТЕ ОСТОРОЖНЫ, ЕСЛИ ОДИН ИЗ НАСТРОЕННЫХ МАКРОСОВ РЕГИСТРОВ СОБЬЕТСЯ,
; ТО ДАЛЬНЕЙШЕЕ ПОВЕДЕНИЕ БУДЕТ НЕОПРЕДЕЛЕННЫМ.
; 
; 3 - ЕСЛИ ПРОЦЕДУРА ДОШЛА ДО КОНЦА СТРОКИ, ТО ОНА НЕ БУДЕТ МЕНЯТЬ ПОСЛЕДНИЙ 
; ПОЛУЧЕННЫЙ ТОКЕН.
; 

; ПЕРЕД ИСПОЛЬЗОВАНИЕМ ВЫЗОВИТЕ ОДИН ИЗ МАКРОСОВ НИЖЕ!!!
proc_next_token proc near
repe scasb ;skip spaces
dec di
inc cx
cmp cx, 0
je stop_parse

    mov dx, di ; save start index 
    repne scasb ; find ending of the token
    
    cmp cx, 0   ; if was stopped by cx, we do not need to back by 1 index
    je copy
    dec di
    inc cx

    copy:
    pusha
        mov ax, di
        sub ax, dx ; size of the token

        mov cx, ax      ; counter
        mov [bx], ax    ; size in the token size byte

        mov si, dx      ; swap dist and source for copying
        mov di, bx
        inc di          ; skip size byte

        rep movsb       ; COPYING
    popa

stop_parse:
ret
endp

m_set_tokenizer macro string, token, delimiter ; адрес строки должен быть в di
    mov ax, seg string
    mov ds, ax
    mov es, ax

    xor cx, cx
    mov cl, string[1]  ; mov size of string

    lea bx, token   ; save start
    xor eax, eax
    mov al, delimiter
    lea di, string
    add di, 2          ; skip system bytes of buffer

endm

m_set_matrix_tokenizer macro string_off, token_off, delimiter ; адрес строки должен быть в di
    mov ax, @data
    mov ds, ax
    mov es, ax

    mov di, string_off
    xor cx, cx
    mov cl, [di][1]  ; mov size of string

    xor bx, bx
    mov bx, token_off   ; save start
    xor eax, eax
    mov al, delimiter
    mov di, string_off
    add di, 2          ; skip system bytes of buffer

endm