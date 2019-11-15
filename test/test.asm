.MODEL SMALL
.STACK 100H
.386

.DATA
str1 db 'Hello my dear friend!$'
word1 dw 0AAh
word2 dw 0BBh

.CODE
START:
mov ax, @data
mov ds, ax

mov eax, 0FFFFFFFFh
or eax, eax

mov ax, 4c00h
int 21h


END START