.MODEL small
.STACK 100h
.DATA
message1    db 'My Name is Kirill, My Family name is Sipuhov. ', '$'
message2    db 'My group IDT.B-31', '$'
Pa      	db	73H
Pb	        dw	0AE21H
Pc      	dd	38EC76A4H
Mas	        db	10 dup(1),2,3
Pole	    db	5 dup(?)
Adr	        dw	Pc
Adr_full	dd	Pc
fin         db 'Ending the segment of data $'
.CODE
start:
    mov ax, @data
    mov ds, ax
    mov ah, 09h
    mov dx, offset message1
    int 21h
    mov ah, 09h
    mov dx, offset message2
    int 21h
    mov ah, 07h
    int 21h
    mov ax, 04c00h
    int 21h
end start
