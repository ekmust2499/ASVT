.model tiny
.code
org 100h
locals @@
vector = 9
_start:
	jmp 	begin
bufferlen equ 10
buffer 	db bufferlen dup (0)
head 	dw offset buffer
tail 	dw offset buffer


int_09h proc near
	push	ax
	push	di
	push	es
	in	al, 60h    ;скан. код клавиши из РА
					
	mov 	bl, al
	call 	write  ;запись в буфер

	pop	es
	pop	di
	in	al, 61h    ;ввод порта РВ
	mov	ah, al
	or 	al, 80h    ;установить бит "подтверждения ввода"
	out	61h, al
	nop
	nop
	nop
	xchg	ah, al ;вывести старое значение РВ
	out	61h, al
	mov	al, 20h    ;послать сигнал EOI
	out	20h, al    ;контроллеру прерываний
	pop	ax
	iret
old_int 	dw 	0, 0
int_09h endp

read proc near
	push 	ds
	push 	si
	push 	ax
	push 	cs
	pop 	ds
	mov 	si, head
	cli
	lodsb
	sti
	mov 	bl, al 								
	inc 	head
	cmp 	head, offset buffer + bufferlen
	jnz 	_ret_read
	mov 	head, offset buffer
_ret_read:
	pop 	ax
	pop 	si
	pop 	ds
	ret
read endp

write proc near
	push 	es
	push 	di
	push 	cx
	push 	ax
	mov 	cx, tail
	push 	cs
	pop 	es
	mov 	di, tail
	mov 	al, bl
	cli
	stosb
	sti
											
	inc 	tail
	cmp 	tail, offset buffer + bufferlen
	jnz 	_ret_write
	mov 	tail, offset buffer 			;переход на начало буфера
_ret_write:
	pop 	ax
	pop 	cx
	pop 	di
	pop 	es
	ret
write endp

print proc near
	push 	ax
	push 	es
	push 	ds
	push 	di
	mov 	ax, 0b800h
	mov 	es, ax
	mov 	ds, ax
	mov 	di, cx

	cmp 	di, 3840
	jle 	_scancode
_scroll:
	mov 	si, 800			;6ую строку на 1ую, 7ую на 2ую и т.д. (ds:si -> es:di)
	xor 	di, di
	mov 	cx, 3200
	rep movsb

	mov 	cx, 800			;очистили последние 5 строк
	push 	di
	mov	ax, 0020h
	rep stosw
	pop 	di

_scancode:
	mov 	ah, 0fh
	push 	cx
	mov 	cl, bl
	sar 	cl, 4
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_scancode1
	add 	cl, 07h
_scancode1:
	mov 	al, cl
	stosw

	mov 	cl, bl
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_scancode2
	add 	cl, 07h
_scancode2:
	mov 	al, cl
	stosw

	pop 	cx
	mov 	cx, di
	add 	cx, 156
	pop 	di
	pop 	ds
	pop 	es
	pop 	ax
	ret
print endp


begin proc near
	mov 	si, 4*vector
	mov 	di, offset old_int
	push 	ds
	xor 	ax, ax
	mov 	ds, ax
	movsw 
	movsw
	push 	ds
	push 	es
	pop 	ds
	pop 	es
	mov 	di, 4*vector
	mov 	ax, offset int_09h
	cli
	stosw
	mov 	ax, cs
	stosw
	sti

	mov 	ax, 3
	int 	10h

	mov 	cx, 0
_cycle:
	mov 	ax, head
	mov 	bx, tail
	cmp 	ax, bx
	jnz _obr
	hlt
	jmp _cycle
_obr:
	call 	read
	call 	print
	cmp 	bl, 1
	jz 	_end
	cmp 	bl, 0b9h
	jz 	_separate
	jmp 	_cycle

_separate:
	push 	ax
	push 	es
	push 	di

	mov 	ax, 0b800h
	mov 	es, ax
	mov 	di, cx
	mov 	ax, 0f2Dh		
	mov 	cx, 5
_separate_loop:
	stosw
	loop 	_separate_loop
	add 	di, 150
	mov 	cx, di

	pop 	di
	pop 	es
	pop 	ax
	jmp 	_cycle

_end:
	push 	0
	pop 	es
	mov 	di, 4*vector
	push 	cs
	pop 	ds
	mov 	si, offset old_int
	cli
	movsw
	movsw
	sti
	pop 	es
_exit:
	db 0eah 
	dw 7c00h, 0
begin endp
end _start