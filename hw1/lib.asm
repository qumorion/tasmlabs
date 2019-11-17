trans proc near
;in: si - адресс матрицы
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