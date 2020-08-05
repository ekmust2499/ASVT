model tiny
.code
org 100h
locals @@

line macro
	add di, (2000h - 2)
	stosw
	sub di, (2000h - 78)
	stosw
endm

_start:
	mov ax, 4 			;переводим подсистему в графический режим
	int 10h
						;320 пикселей 2хбитного цвета (ширина) - 80 байт. В середине 5 строки пишем слово (439-440 байты). 
	mov ax, 0b800h
	mov es, ax
	mov ax, 0ffffh 		;8 пикселей (по 4 пикселя же на один байт) цветная полоска
	mov di, 439
	stosw
	line
	line
	line
	line  				;нарисовали 9 строк по 8 пикселей

	mov ax, 1
	int 33h				;курсор добавили

	xor ax, ax
	int 16h
	cmp ah,	1		;сравниваем на escape
	jz 	_exit
	mov ax, 3 			;переводим в текстовый режим (по умолчанию он)
	int 10h

_exit:
	db 0eah 
	dw 7c00h, 0

end _start