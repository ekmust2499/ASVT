.model tiny
.code
org 100h
begin:
	jmp short _start
	nop
operator	db 'MBR.180K'
; BPB
empty 		db '---', 0	; 7c44h
_start:
	mov	ax, 3		; очистка экрана
	int	10h
	cli
	mov 	ax, 2000h
	mov 	ss, ax
	xor 	sp, sp
	sti
	push 	sp
	mov 	ax, 2000h
	mov 	ch, 1		; номер цилиндра
	xor 	bx, bx
	call 	load_from_mem
	mov 	ax, 0b800h
	mov 	es, ax
	mov 	ax, 2000h
	mov 	ds, ax
	xor 	si, si
	mov 	di, 166
	mov 	ah, 0fh
	mov 	cx, 19
	mov 	al, 41h
_loop:
	add 	di, 160
	push 	di
	push 	cx
	stosw
	inc 	al
	push 	ax
	mov 	al, 29h
	stosw
	mov 	al, 20h
	stosw
	add 	si, 26
	push 	si
	sub 	si, 26
	lodsb 
	cmp 	al, 01h
	je 	_read_file_info
	push 	si
	push 	ds
	xor 	dx, dx
	mov 	ds, dx
	mov 	si, offset empty + 7b00h
	call 	print_str
	pop 	ds
	pop 	si
	jmp 	_new_iter
_read_file_info:
	lodsb
	xor 	cx, cx
	mov 	cl, 24
_read_file_info_loop:
	lodsb
	stosw
	loop 	_read_file_info_loop
_new_iter:
	pop 	si
	pop		ax
	pop 	cx
	pop 	di
	loop 	_loop
	mov		ax, 2000h
	mov		ds, ax
	xor		si, si
	mov 	cx, 160
	xor 	ax, ax
	mov		bx, 2
_loopi:
	lodsb
	cmp		al, 01h
	jz		_lin
	inc		bx
	add		si, 25
	loop	_loopi
_fir_lin:
	mov		di, 320
	mov		si, 320
	mov 	ch, 2
	jmp _li_next
_lin:
	xor 	ax, ax
	mov 	ax,	160
	mul 	bx
	mov 	si, ax
	mov 	di, si
	dec 	bx
	shl		bx, 1
	mov 	ch, bl
_li_next:	
	mov 	ax, 0b800h
	mov 	ds, ax
	mov 	ah, 0f0h
	call 	c_light_str
navigation:
	xor 	ah, ah
	int 	16h
	cmp 	ah, 50h ; Down
	jz 	down
	cmp 	ah, 48h ; Up
	jz 	up
	cmp 	ah, 1ch
	jz 	_enter_jmp
	cmp 	ah, 1
	jz 	_exit_next
	cmp 	al, 41h
	jl		navigation
	cmp 	al, 53h
	jg		navigation
	jmp 	_enter
_enter_jmp:
	jmp 	_enter_next
up:
	dec 	si
	dec 	di
	dec 	si
	dec 	di
	std
	mov 	ah, 0fh
	call 	c_light_str
	cmp 	di, 320
	mov 	ah, 0f0h
	jg 	light_str_up
	mov 	di, 3358
	mov 	si, 3358
	mov 	ch, 40
light_str_up:
	call 	c_light_str
	add 	di, 162
	add 	si, 162
	cld
	sub 	ch, 2
	push 	cx
	push 	ax
	push 	si
	push 	di
	push	ds
	call	sravn
	lodsb 
	cmp 	al, 01h
	jz 	_ent1
	pop 	ds
	pop 	di
	pop 	si
	pop 	ax
	pop 	cx
	jmp 	up
_ent1:
	pop 	ds
	pop 	di
	pop 	si
	pop		ax
	pop 	cx
_jmp_nav:
	jmp 	navigation
_enter_next:
	jmp 	_enter_contin
_exit_next:
	jmp 	exit
down:
	sub 	di, 160
	sub 	si, 160
	mov 	ah, 0fh
	call 	c_light_str
	cmp 	di, 3360
	mov 	ah, 0f0h
	jl 	light_str_down
	mov 	di, 320
	mov 	si, 320
	xor 	ch, ch
light_str_down:
	call 	c_light_str
	add 	ch, 2
	push 	cx
	push 	ax
	push 	si
	push 	di
	push	ds
	call	sravn
	lodsb
	cmp 	al, 01h
	jz 	_ent1
	pop 	ds
	pop 	di
	pop 	si
	pop 	ax
	pop 	cx
	jmp 	down
exit:
	int 	19h
_enter:
	mov		ch, al
	sub 	ch, 40h
	sal 	ch, 1
	push 	cx
	call 	sravn
	lodsb
	pop 	cx
	cmp 	al, 01h
	jnz 	_jmp_nav
_enter_contin:

	mov 	ax, 2000h
	mov 	bx, 100h	; смещение оперативной памяти, куда копируем программу
	call 	load_from_mem
	inc 	ch
	mov 	ax, 2000h
	mov 	bx, 1300h
	call 	load_from_mem

	push 	ss
	pop 	ds
	xor 	ax, ax
	xor 	bx, bx
	mov 	cx, 0ffh
	mov 	dx, 18dbh
	mov 	si, 100h
	mov 	di, 0fffeh
	mov 	bp, 91ch
db	9ah, 0, 1, 0, 20h
	xor 	ax, ax
	mov 	ds, ax
	jmp 	_start
print_str proc
	mov 	ah, 0fh
print_loop:
	lodsb
	cmp 	al, 0
	jz 	_coninue
	stosw
	jmp 	print_loop
_coninue:
	ret
print_str endp
sravn proc
	mov 	ax, 2000h
	mov 	ds, ax
	xor 	ax, ax
	sar 	ch, 1
	dec 	ch
	mov 	al, 26
	mul 	ch
	xor 	si, si
	mov 	si, ax
	xor 	ax, ax
	mov 	al, ch
	ret
sravn endp
c_light_str proc
	push 	cx
	mov 	bh, ah
	mov 	cx, 80
c_light_str_loop:
	lodsw
	mov 	ah, bh
	stosw
	loop 	c_light_str_loop
	pop 	cx
	ret
c_light_str endp
load_from_mem proc
	mov 	es, ax		; сегмент оперативной памяти, куда копируем программу
	mov 	ah, 2		; номер прерывания (чтение секторов из памяти)
	mov 	al, 9		; количество сегментов
	mov 	cl, 1		; номер сегмента дорожки, с которого начинаем копировать
	mov 	dh, 0		; номер головки
	mov 	dl, 0		; номер диска 
	int 	13h		; вызов прерывания
	ret
load_from_mem endp
org	766
dw	0aa55h
end begin