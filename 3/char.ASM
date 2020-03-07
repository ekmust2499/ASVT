.model tiny
.code
org 100h
locals
_start:
	cld

	mov		ax, 	0b800h
	mov		es, 	ax      ;кладем в es B800
	xor 	di, 	di  	;кладем в di 0

_symbol:
	xor		ah, 	ah			
	int		16h				;в ah лежит скан код

	cmp 	di, 	4000	;25*160, проверяем количество строк, их 25 на экран влазит
	jl 	_print

_scroll:
	push 	ax
	xor 	ax,		ax
	mov		ax, 	0b800h
	mov		es, 	ax		;кладем в es:di B800:0 (куда)
	mov		ds, 	ax 		;кладем в ds:si B800:160 (откуда)

	xor		ax,		ax
	mov 	ax, 	160
	mov 	si,		ax
	xor 	di,		di

	mov 	cx, 	3840	;сколько раз будет исполняться перепеписывание байт
	rep 	movsb			;повторяем сохранение из строки в строку (2ую строку пишем на 1ую, 3ью на 2ую, и т.д., в последнюю строку пишем свой текст)

	pop ax

_print:
	mov 	bx, 	ax			
	mov		ah, 	0ah     ;цвет символа задаем
	stosw
	add 	di, 	2		;сместились на 2 байта(это пробел)

	mov 	cl, 	bl      ;ascii-код
	shr 	cl, 	4		;сдвигаем вправо на 4 бита
	add 	cl, 	30h		;прибавляем символ нуля, чтобы получить цифру
	cmp 	cl, 	3ah     ;если цифра получилась, то, переходим на метку 2 и печатаем, иначе
	jl 	_ascii1
	add 	cl, 	07h     ;прибавляем 7, чтобы получилась одна из букв ABCDEF и только тогда печатаем(это мы напечатали только 1 байт в 16сс)

_ascii1:
	mov 	al, 	cl    
	stosw

	mov 	cl, 	bl
	and 	cl, 	0fh    	;зануляем старшую часть байта al
	add 	cl, 	30h     ;снова переводим в 16сс
	cmp 	cl, 	3ah
	jl 	_ascii2
	add 	cl, 	07h

_ascii2:
	mov 	al, 	cl
	stosw              		;на этом моменте мы записали наш символ в 16 сс

	add 	di, 	2		;сместились на 2 байта (это пробел)

	mov 	cl, 	bh      
	shr 	cl, 	4
	add 	cl, 	30h
	cmp 	cl, 	3ah
	jl 	_scancode1
	add 	cl, 	07h

_scancode1:
	mov 	al, 	cl
	stosw

	mov 	cl, 	bh
	and 	cl, 	0fh
	add 	cl, 	30h
	cmp 	cl, 	3ah
	jl 	_scancode2
	add 	cl, 	07h

_scancode2:
	mov 	al, 	cl
	stosw	

	add		di, 	146		;мы заняли 7*2 = 14 байт и осуществляем перенос строки

	cmp 	bh, 	1		;сравниваем на escape
	jz 	_exit
	
	jmp _symbol

_exit:
	int		19h

end _start