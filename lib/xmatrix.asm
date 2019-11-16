proc_enter_matrix proc near
local @@matrix:word:1, @@buff:word:1, @@token:word:1, @@delim:byte:1, @@ret_adr:word:1, @@max_row:word:1, @@max_column:word:1, @@row:word:1, @@column:word:1

    pop @@ret_adr
    pop @@matrix
    pop @@buff
    pop @@token
    pop @@max_row
    pop @@max_column
    mov @@delim, ' '
    mov @@row, 0
    mov @@column, 0


next_row:
    mov bx, @@row
    cmp bx, @@max_row
    jae end_enter
    call pnl

    push @@buff
    call proc_scan_s

    m_set_matrix_tokenizer @@buff, @@token, @@delim
    mov @@column, 0
next_column:
pusha
    mov di, @@column
    cmp di, @@max_column
    je end_row
popa

    call proc_next_token
    mov si, @@token

pusha
    call _convert_string_to_byte
    
    ; getting adress
    xor eax, eax
    mov ax, @@max_column
    mul @@row
    add ax, @@column
    add ax, @@matrix    ; full offset

    mov bx, ax
    pop edx             ; get result from _convert_string_to_byte
    mov [bx], dl        ; mov next number
popa

    inc @@column
jmp next_column

end_row:
    inc @@row
    jmp next_row

end_enter:
;popa ; last cycle must pop
    push @@ret_adr
    ret 
    endp



m_enter_matrix macro matrix, rows, columns, buff, token
pusha
    xor eax, eax
    mov al, columns
    push ax
    mov al, rows
    push ax
    push offset token
    push offset buff

    mov bx, offset matrix   ; skip sizes bytes
    mov al, rows
    mov [bx], al
    mov al, columns
    mov [bx]+1, al
    add bx, 2
    push bx

    call proc_enter_matrix
popa
endm


proc_get_by_index proc near ; index into di:si, matrix offset in bx
local @@_ret:word:1
pop @@_ret
push bx
    mov al, [bx]    ; num of rows
    add bx, 2
    mul di
    add ax, si
    add ax, bx

    mov bx, ax
    xor ax, ax
    mov al, [bx]  ;   result

pop bx
push @@_ret
ret
endp

proc_print_matrix proc near
local @@matrix:word:1, @@buff:word:1, @@ret_:word:1
    pop @@ret_
    pop @@buff
    pop @@matrix

    pusha
        mov bx, @@matrix
        mov di, 0
        mov si, 0

    @@next_row:
    call pnl
    xor ax, ax
    mov al, [bx]
    cmp di, ax
    jae @@end_print
    mov si, 0

        @@next_column:
        mov al, [bx][1]
        cmp si, ax
        jae @@end_column

        call proc_get_by_index  ;   get element

        ; PRINTING ELEMENT
        pusha
        mov si, @@buff
        cbw 
        cwde 
        call proc_print_int

        mov ah, 2
        mov dl, ' '
        int 21h
        popa

        inc si
        jmp @@next_column

    @@end_column:
    inc di
    jmp @@next_row

    popa

@@end_print:
push @@ret_
ret
endp
