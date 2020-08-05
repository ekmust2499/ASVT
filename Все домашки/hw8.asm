model tiny
.code
org 	100h
locals

_start:
	jmp 	begin

char 	db 	0
pos 	dw 	140
time  	db 9
color	db 	1bh
state 	db 	0
line 	equ 	8

int_08 	proc near
	push    bx
	push 	ax
	push 	dx
	push 	di
	push 	es
	push 	ds
	push 	cs
	pop 	ds
	inc 	byte ptr cs:state
	mov bl, time
	cmp 	byte ptr cs:state, bl
	jz 	@@1
	cmp 	byte ptr cs:state, 18
	jnz 	@@9
	mov 	byte ptr cs:state, 0
	mov 	dl, ' '
	jmp 	@@2
@@1:
	mov 	dl, char
@@2:
	mov 	ax, 0b800h
	mov 	es, ax
	mov 	di, pos
	add 	di, line * 160
	mov 	dh, color
	mov 	es:[di], dx
@@9:
	pop 	ds
	pop 	es
	pop 	di
	pop 	dx
	pop 	ax
	pop 	bx
	db 	0eah
old_08 	dw	0, 0
int_08 	endp

begin 	proc near
	cld
	mov 	ax, 3
	int 	10h

	push 0
	pop es
	mov bx, word ptr es:[34]

	cmp bx, 3000h
	jl _less
	jmp _pryg

_less:
	mov 	bx, 3000h
	jmp _prygpryg

_pryg:
	add bx, 100h

_prygpryg:	
	mov 	cx, 6	

big_loop:
	push 	cx
	mov 	ax, 0b800h
	mov 	es, ax
	xor 	di, di 
	push 	cs
	pop 	ds	
	
	cmp 	cx, 6
	je		_h
	cmp 	cx, 5
	je		_e
	cmp 	cx, 4
	je		_l1
	cmp 	cx, 3
	je		_l2
	cmp 	cx, 2
	je		_o
	cmp 	cx, 1
	je		_vz
_h:
	mov 	al, 48h
	dec 	time
	dec 	time
	dec 	time
	dec 	time
	jmp 	cont
_e:
	mov 	al, 65h
	inc 	time
	inc 	time
	add 	color, 33h
	jmp 	cont
_l1:
	mov 	al, 6Ch
	inc 	time
	inc 	time
	inc 	time
	inc 	time
	inc 	time
	sub 	color, 11h
	jmp 	cont
_l2:
	mov 	al, 6Ch
	dec 	time
	dec 	time
	add 	color, 24h
	jmp 	cont
_o:
	mov 	al, 6Fh
	inc 	time
	sub 	color, 35h
	jmp 	cont
_vz:
	mov 	al, 21h
	dec 	time
	dec 	time
	dec 	time
	add 	color, 33h
	
cont:
	mov 	byte ptr cs:char, al
	inc 	pos
	inc 	pos

	xor 	ax, ax
	mov 	ds, ax
	push 	cs
	pop 	es
	mov 	di, offset old_08
	mov 	si, 32
	movsw
	movsw

	mov 	ax, offset int_08
	cli
	mov 	ds:[32], ax
	mov 	ax, cs
	mov 	ds:[34], ax
	sti
my_end:
	mov 	cx, offset begin
	mov 	es, bx
	xor 	di, di
	push 	cs
	pop 	ds
	xor 	si, si
_loop:
	movsb
	loop 	_loop

	cli
	xor 	ax, ax
	mov 	ds, ax
	mov 	ds:[34], bx
	sti
	inc 	bh
	pop 	cx
	dec 	cx
	cmp 	cx, 0
	je 		_exit
	jmp 	big_loop
	
_exit:
	sub pos, 10
	inc time
	db 0eah 
	dw 7c00h, 0

print_str proc
	mov 	ah, 0eh
print_loop:
	lodsb
	cmp 	al, 0
	jz 	_coninue
	stosw
	jmp 	print_loop
_coninue:
	ret
print_str endp

begin	 endp
end _start 