check_cx macro
cmp cx, 0
je stop_parse
endm


proc_next_token proc near
repe scasb ;skip spaces
dec di
check_cx

    mov dx, di ; save start index 
    repne scasb ; find ending of a token
    dec di

    pusha
        mov ax, di
        sub ax, dx ; size of token

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

    call proc_next_token
endm