.model tiny
.code
org 100h
begin:
	jmp short _start
	nop
_start:
	xor 	ax, ax
	xor 	bx, bx
	xor 	cx, cx
	xor		dx, dx
	xor 	sp, sp

	mov	ax, 3		
	int	10h

	cli
	mov 	ax, 1000h
	mov 	es, ax
	mov 	ds, ax
	mov 	ss, ax
	mov 	bx, 100h
	sti	
	mov 	ah, 2		
	mov 	al, 9		
	mov 	ch, 2		
	mov 	cl, 1		
	mov 	dh, 0		
	mov 	dl, 0		
	int 	13h		

	cli
	mov 	ax, 1000h
	mov 	es, ax
	mov 	ds, ax
	mov 	ss, ax
	mov 	bx, 1300h
	sti
	mov 	ah, 2
	mov 	al, 9
	mov 	ch, 3
	mov 	cl, 1
	mov 	dh, 0
	mov 	dl, 0
	int 	13h

	cli
	mov bx, 0fffeh
	mov sp, bx
	sti

	push 0
	mov		cx,	1000h
	push 	cx
	xor		cx, cx
	mov		cx, 100h
	push 	cx
	retf

	

org	766
dw	0aa55h
end begin