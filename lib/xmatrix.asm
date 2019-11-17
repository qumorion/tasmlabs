;МОДУЛЬ ТРЕБУЕТ INCLUDE IO.ASM !!!



; ПРОЦЕДУРЫ ДЛЯ ЗАПИСИ/ЧТЕНИЯ ЭЛЕМЕНТА ИЗ МАТРИЦЫ.
; НОМЕР СТРОКИ И СТОЛБЦА ЗАНОСЯТСЯ В di:si, АДРЕС МАТРИЦЫ В bx, ЧИСЛО ЗАНОСИТСЯ В al
proc_get_by_index proc near ; index into di:si, matrix offset in bx, result in al
push bx
push dx
    xor ax, ax
    mov al, [bx]    ; num of rows
    add bx, 2
    mul di
    add ax, si
    add ax, bx

    mov bx, ax
    xor ax, ax
    mov al, [bx]  ;   result
pop dx
pop bx
ret
endp

proc_set_by_index proc near ; index into di:si, matrix offset in bx, num in al
push bx
push dx
push ax
    xor ax, ax
    mov al, [bx]    ; num of rows
    add bx, 2
    mul di
    add ax, si
    add ax, bx

    mov bx, ax
pop ax
    mov [bx], al  ;   result
pop dx
pop bx
ret
endp


; ############################################################################################################################


proc_print_matrix proc near     ;ПРИНИМАЕТ АДРЕС МАТРИЦЫ В si, АДРЕС БУФЕРА В di
enter 4, 0
local @@matrix:word:1, @@buff:word:1
    mov @@matrix, si
    mov @@buff, di

pusha
    mov bx, @@matrix
    mov di, 0
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

@@end_print:
popa
leave
ret
endp


; ############################################################################################################################


proc_transpose_matrix proc near     ;(c) maxim
;in: si - адресс матрицы, с размерами в первых друх байтах: row, column
;out: ____
	local @@temp:word:1
	push ax
	push bx
	push cx
	push dx
	push di
	
	mov bx, si
	
	mov al, [bx]
	mov ah, [bx+1]
	mul ah
	mov si, ax
	xor ax, ax
	@@cycle:
		dec si
		mov al, [bx + si + 2]
		push ax
		cmp si, 0
		je @@_out
	jmp @@cycle
	@@_out:
	xor ax, ax
	xor dx, dx
	xor di, di
	mov di, word ptr [bx]
	and di, 0FFh
	mov dl, [bx + 1]
	mov @@temp, di
	mov cx, di
	add di, bx
	;di -- кол-во строк в исходном
	;si -- индекс строки в проге
	;индекс si*di + bx
	;dx -- кол-во столбцов в исходном
	;bx -- кол-во индекс строки в проге
	@@e_cycle:
		xor si, si
		@@i_cycle:
			mov ax, cx
			push dx
			mul si
			pop dx
			mov si, ax
			pop ax
			mov [bx+si+2], al
			mov ax, si
			push dx
			xor dx, dx
			div cx
			pop dx
			mov si, ax
			inc si
			cmp si, dx
			je @@i_exit
			jmp @@i_cycle
		@@i_exit:
		inc bx
		cmp bx, di
		je @@e_exit
		jmp @@e_cycle
	@@e_exit:
	sub bx, @@temp
	mov al, [bx]
	mov ah, [bx + 1]
	mov [bx], ah
	mov [bx + 1], al
	
	
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
ret
endp


; ############################################################################################################################


proc_enter_matrix proc near ;   ВМЕСТО ПРОЦЕДУРЫ ИСПОЛЬЗУЙТЕ МАКРОС НИЖЕ
enter 15, 0                 ;   ЗДЕСЬ ПОЛУЧИЛОСЬ ДОВОЛЬНО МНОГО КОДА ИЗ-ЗА ТОГО, ЧТО 3 ПРОЦЕДУРЫ ИСПОЛЬЗУЮТ
pusha                       ;   ОДНИ И ТЕ ЖЕ РЕГИСТРЫ ПО-РАЗНОМУ. ПРИШЛОСЬ МНОГОЕ ПЕРЕСОХРАНЯТЬ.
local @@matrix:word:1, @@buff:word:1, @@token:word:1, @@delim:byte:1, @@max_row:word:1, @@max_column:word:1, @@_di:word:1, @@_si:word:1

    mov @@matrix, bx        
    mov @@buff, si         
    mov @@token, di       
    mov @@delim, ' '
    xor dx, dx
    mov dl, ah
    mov @@max_row, dx
    mov dl, al
    mov @@max_column, dx

    mov [bx], ah
    mov [bx][1], al
    mov di, 0

    next_row:
        xor eax, eax
        cmp di, @@max_row
        jae end_enter

        push @@buff
        call proc_scan_s
        push di
        push si
        m_set_matrix_tokenizer @@buff, @@token, @@delim
        mov @@_di, di
        mov @@_si, si
        pop si
        pop di

        call pnl         
        mov si, 0
    next_column:
        cmp si, @@max_column
        je end_row

        push si
        push di
        mov si, @@_si
        mov di, @@_di
        call proc_next_token
        mov @@_di, di
        mov @@_si, si
        pop di
        pop si

        ; adding next number
        push eax
        push bx
        push si
            mov si, @@token
            mov bx, @@matrix
            call _convert_string_to_byte
        pop si
            call proc_set_by_index
        pop bx
        pop eax

        inc si
    jmp next_column

    end_row:
        inc di
        jmp next_row

    end_enter:
popa
leave
ret 
endp


m_enter_matrix macro matrix, rows, columns, buff, token
pusha
    lea bx, [matrix]
    lea si, [buff]
    lea di, [token]
    mov ah, rows
    mov al, columns
    call proc_enter_matrix
popa
endm