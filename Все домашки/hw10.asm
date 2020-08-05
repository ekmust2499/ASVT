.model tiny
.code
org 100h
locals @@
vector equ 9
_start:
	jmp begin

h1 db 'Справка:'
h2 db 'z - увеличить скорость вращения'
h3 db 'x - уменьшить скорость вращения'
h4 db 'c - увеличить скорость перемещения'
h5 db 'v - уменьшить скорость перемещения'
h6 db 'b - изменить направление вращения'
h7 db 'стрелкa - перемещение в соответствующую сторону'
h8 db 'пробел - остановить движение, вращение на месте'
h9 db 'ESC - завершение работы'
h10 db 'F11 - вызов справки'
h11 db 'F2 - закрытие справки'
;shift+f4
;right shift - lang
vent db '\', '|', '/', '-'
pos dw 0
side db 0

speed: db 4
counter: db 0
movecounter: db 0
movespeed: db 2

ishelp db 0

up db 0
down db 0
left db 0
right db 0

ismove: db 0

head 	dw offset buffer
tail 	dw offset buffer
bufflen = 6
buffer 	db 6 dup (0)

checkrot proc near
	inc 	byte ptr cs:counter
	mov ah, byte ptr cs:speed
	cmp byte ptr cs:counter, ah
	jne @@9
	mov byte ptr cs:counter, 0
	mov bl, 10h
	call write
@@9:
	ret
checkrot endp

checkmoverot proc near
	inc 	byte ptr cs:movecounter
	mov ah, byte ptr cs:movespeed
	cmp byte ptr cs:movecounter, ah
	jne @@8
	mov byte ptr cs:movecounter, 0
	cmp byte ptr ismove, 0
	je @@8
	mov bl, 11h
	call write
@@8:
	ret
checkmoverot endp

int08:
	push bx
	push ax
	call checkrot
	call checkmoverot
	pop ax
	pop bx
	db 	0eah
old08 	dw	0, 0

int09 proc near
	push ax
	push di
	push es
	push bx
	in	al, 60h

	cmp al, 48h
	je callw
	cmp al, 50h
	je callw
	cmp al, 4bh
	je callw
	cmp al, 4dh
	je callw
	cmp al, 39h
	je callw
	cmp al, 2ch ;z
	je callw
	cmp al, 2dh ;x
	je callw
	cmp al, 2eh ;c
	je callw
	cmp al, 2fh ;v
	je callw
	cmp al, 57h ;f11
	je callw
	cmp al, 30h ;b
	je callw
	cmp al, 1 ;т√їюф
	je callw
	jmp skipw
callw:
	mov bl, al
	call write
skipw:
	in	al, 61h
	mov	ah, al
	or 	al, 80h
	out	61h, al
	nop
	nop
	nop
	xchg	ah, al
	out	61h, al
	mov	al, 20h
	out	20h, al
	pop bx
	pop es
	pop di
	pop	ax
	iret
old09 dw 0, 0
int09 endp

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
	cmp 	head, offset buffer + bufflen
	jnz 	@@1
	mov 	head, offset buffer 
@@1:
	pop 	ax
	pop 	si
	pop 	ds
	ret
read endp

write proc near
	cmp ishelp, 0
	jne block
writer:
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
	cmp 	tail, offset buffer + bufflen
	jnz 	@@1
	mov 	tail, offset buffer 
@@1:
	xor 	ax, ax
	xor 	bx, bx
	mov 	ax, cs:tail
	mov 	bx, cs:head
	cmp 	ax, bx
	jnz 	@@2
	mov 	tail, cx 
@@2:
	pop 	ax
	pop 	cx
	pop 	di
	pop 	es
block:
	ret
write endp

begin:
	mov 	ax, 3
	int 	10h

writenewint08:
	push 0
	pop es
	mov ax, word ptr es:[32]
	mov bx, word ptr es:[34]
	mov old08, ax
	mov old08+2, bx
	mov ax, offset int08
	mov bx, cs
	cli
	mov es:[32], ax
	mov es:[34], bx
	sti

	mov ax, word ptr es:[36]
	mov bx, word ptr es:[38]
	mov old09, ax
	mov old09+2, bx
	mov ax, offset int09
	mov bx, cs
	cli
	mov es:[36], ax
	mov es:[38], bx
	sti

	mov 	di, 2000
	push di

_loop:
	hlt
	mov ax, tail
	mov bx, head
	cmp ax, bx
	je _loop
	call read
	cmp bl, 1
	jne m1
	jmp exit
m1:
	cmp bl, 2ch
	jne m2
	jmp incrot
m2:
	cmp bl, 2dh
	jne m3
	jmp decrot
m3:
	cmp bl, 2eh
	jne m4
	jmp incmove
m4:
	cmp bl, 2fh
	jne m5
	jmp decmove
m5:
	cmp bl, 48h
	jne m6
	jmp upspin
m6:
	cmp bl, 4dh
	jne m7
	jmp rightspin
m7:
	cmp bl, 4bh
	jne m8
	jmp leftspin
m8:
	cmp bl, 50h
	jne m9
	jmp downspin
m9:
	cmp bl, 39h
	jne m10
	jmp stopmove
m10:
	cmp bl, 11h
	jne m11
	jmp movespin
m11:
	cmp bl, 57h
	jne m12
	jmp helpopen
m12:
	cmp bl, 30h 
	jne m13
	jmp sidee
m13:
	cmp bl, 10h
	jne _loop
	jmp spin
;	
sidee:
	cmp side, 2
	je move0
	cmp side, 0
	je move2
	jmp _loop
move0:
	mov side, 0
	jmp _loop
move2:
	mov side, 2
	jmp _loop
;

helpopen:
	mov ishelp, 1

	push 0
    pop es
    mov ax, old09
    mov bx, old09+2
    cli
    mov word ptr es:[36], ax
    mov word ptr es:[38], bx
    sti

    push 0b800h
    pop es
    mov di, 0
    mov cx, 24*160
    mov al, 0DBh
    mov ah, 77h ;Їюэ
    rep stosw

    push cs
    pop ds
    mov di, 220 
    mov cx, 8
help1:
	mov si, offset h1
	mov bx, 8
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help1

	mov di, 350
	mov cx, 31
help2:
    mov si, offset h2
	mov bx, 31
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help2
    
    mov di, 510
    mov cx, 31
help3:
    mov si, offset h3
	mov bx, 31
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help3    

	mov di, 670
	mov cx, 34
help4:
    mov si, offset h4
	mov bx, 34
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help4

	mov di, 830
	mov cx, 34
help5:
    mov si, offset h5
	mov bx, 34
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help5

    mov di, 990
    mov cx, 33
help6:
    mov si, offset h6
	mov bx, 33
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help6

	mov di, 1150
	mov cx, 47
help7:
    mov si, offset h7
	mov bx, 47
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help7

	mov di, 1310
	mov cx, 47
help8:
    mov si, offset h8
	mov bx, 47
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help8

	mov di, 1470
	mov cx, 23
help9:
    mov si, offset h9
	mov bx, 23
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help9
	
	mov di, 1630
	mov cx, 19
help10:
    mov si, offset h10
	mov bx, 19
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help10
	
	mov di, 1790
	mov cx, 21
help11:
    mov si, offset h11
	mov bx, 21
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 70h
	stosw
	loop help11

helploop:
	xor ax, ax
	int 16h

	cmp ah, 3ch ; f2
	jne helploop

    mov ishelp, 0
    push 0
    pop es
    mov ax, word ptr es:[36]
	mov bx, word ptr es:[38]
	mov old09, ax
	mov old09+2, bx
	mov ax, offset int09
	mov bx, cs
	cli
	mov es:[36], ax
	mov es:[38], bx
	sti
	mov ax, 3
	int 10h
	jmp _loop

;
incrot:
	cmp byte ptr cs:speed, 2
	je back
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl incrott
	mov byte ptr cs:counter, 0
incrott:
	dec byte ptr cs:counter
	dec byte ptr cs:speed
	jmp back
decrot:
	cmp byte ptr cs:speed, 32
	je back
	inc byte ptr cs:speed
	je back
incmove:
	cmp byte ptr cs:movespeed, 2
	je back
	mov al, byte ptr cs:movecounter
	cmp al, byte ptr cs:movespeed
	jl incmovee
	mov byte ptr cs:movecounter, 0
incmovee:
	dec byte ptr cs:movecounter
	dec byte ptr cs:movespeed
	jmp back
decmove:
	cmp byte ptr cs:movespeed, 32
	je back
	inc byte ptr cs:movespeed
	je back
back:
	jmp _loop
;
stopmove:
	mov up, 0
	mov down, 0
	mov left, 0
	mov right, 0
	mov byte ptr cs:ismove, 0
	jmp _loop
;
upspin:
	mov up, 1
	mov down, 0
	mov left, 0
	mov right, 0
	mov byte ptr cs:ismove, 1
	jmp _loop
;
rightspin:
	mov up, 0
	mov down, 0
	mov left, 0
	mov right, 1
	mov byte ptr cs:ismove, 1
	jmp _loop
;
leftspin:
	mov up, 0
	mov down, 0
	mov left, 1
	mov right, 0
	mov byte ptr cs:ismove, 1
	jmp _loop
;
downspin:
	mov up, 0
	mov down, 1
	mov left, 0
	mov right, 0
	mov byte ptr cs:ismove, 1
	jmp _loop
;
movespin:
    mov bx, 0b800h
    mov es, bx
    pop di

    mov al, 20h
    mov ah, 0h
    stosw
    sub di, 2

@@u:
	cmp up, 0
	je @@d
	sub di, 160
	cmp di, 0
	jnl @@ub
	add di, 160*25
@@ub:
	jmp @@end
@@d:
	cmp down, 0
	je @@r
	add di, 160
	cmp di, 4000
	jl @@dc
	add di, -160*25
@@dc:
	jmp @@end
@@r:
	cmp right, 0
	je @@l
	add di, 2
	mov ax, di
	mov bx, 160
	xor dx, dx
	div bx
	cmp dx, 0
	jne @@rc
	sub di, 160
@@rc:
	jmp @@end
@@l:
	cmp left, 0
	je @@end
	sub di, 2
	mov ax, di
	add ax, 2
	mov bx, 160
	xor dx, dx
	div bx
	cmp dx, 0
	jne @@end
	add di, 160
@@end:
	push di
	push cs
	pop ds
	mov si, offset vent
	add si, pos
	lodsb
	mov ah, 0fh ; color
	stosw
	jmp _loop

;
spin:
    push 0b800h
	pop es
	pop di
	
	push cs
	pop ds
	mov si, offset vent
	add si, pos
	lodsb
	mov ah, 0fh ; color
	
	xor dx, dx
	mov dl, side
	add pos, dx
	dec pos
	cmp side, 0
	je posr
	cmp pos, 4
	jl cont
	mov pos, 0
	jmp cont
posr:
	cmp pos, -1
	jg cont
	mov pos, 3
cont:
	stosw
	sub di, 2
	push di
	jmp _loop
;

exit:
    push 0
    pop es
    mov ax, old08
    mov bx, old08+2
    cli
    mov word ptr es:[32], ax
    mov word ptr es:[34], bx
    sti

    push 0
    pop es
    mov ax, old09
    mov bx, old09+2
    cli
    mov word ptr es:[36], ax
    mov word ptr es:[38], bx
    sti

    ;int 20h

    db 0eah
    dw 7c00h, 0
dw 0aa55h
end _start