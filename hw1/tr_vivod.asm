trans macro matrix
	local cycle, e_cycle, i_cycle, e_exit, i_exit, _out
	pusha
	
	mov al, matrix
	mov ah, matrix + 1
	mul ah
	mov bx, ax
	xor ax, ax
	cycle:
		dec bx
		mov al, matrix[bx + 2]
		push ax
		cmp bx, 0
		je _out
	jmp cycle
	_out:
	xor ax, ax
	xor dx, dx
	xor di, di
	mov di, word ptr matrix
	and di, 0FFh
	mov dl, matrix + 1
	mov cx, di
	xor si, si
	xor bx, bx
	;di -- ���-�� ����� � ��������
	;si -- ������ ������ � �����
	;������ si*di + bx
	;dx -- ���-�� �������� � ��������
	;bx -- ���-�� ������ ������ � �����
	e_cycle:
		i_cycle:
			mov ax, di
			push dx
			mul si
			pop dx
			mov si, ax
			pop ax
			mov matrix[bx+si+2], al
			mov ax, si
			push dx
			xor dx, dx
			div di
			pop dx
			mov si, ax
			inc si
			cmp si, dx
			je i_exit
			jmp i_cycle
		i_exit:
		xor si, si
		inc bx
		cmp bx, di
		je e_exit
		jmp e_cycle
	e_exit:
	mov al, matrix
	mov ah, matrix + 1
	mov matrix, ah
	mov matrix + 1, al
	
	popa
endm

print_matrix macro matrix
	local e_cycle, i_cycle, e_exit, i_exit
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	xor dx, dx
	xor di, di
	mov dl, matrix
	mov di, word ptr matrix + 1
	mov al, matrix + 1
	and di, 0FFh
	mul dl
	mov dx, ax
	mov cx, di
	xor si, si
	xor bx, bx
	mov ah, 0Eh
	e_cycle:
		i_cycle:
			;mov al, matrix[bx+si+2]
			;add al, 30h
			;int 10h
			;print_number matrix[bx+si+2]      ������ print_number ���� ������� ��� ������ �����
			mov al, ' '
			int 10h
			inc si
			cmp si, di
			je i_exit
			jmp i_cycle
		i_exit:
		xor si, si
		mov al, 0Ah
		int 10h
		mov al, 0Dh
		int 10h
		add bx, cx
		cmp bx, dx
		je e_exit
		jmp e_cycle
	e_exit:
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
endm