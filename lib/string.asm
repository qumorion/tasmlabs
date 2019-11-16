check_cx macro
cmp cx, 0
je stop_parse
endm


proc_next_token proc near
repe scasb ;skip spaces
dec di
inc cx
check_cx

    mov dx, di ; save start index 
    repne scasb ; find ending of the token
    
    cmp cx, 0   ; if was stopped by cx, we do not need to back by 1 index
    je copy
    dec di

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