.model tiny
.code
org 100h
locals @@
vector equ 9
_start:
	jmp begin
	
d_vert 	equ 0bah ; вертикальная двойная
d_horiz	equ 0cdh ; гориз двойная
ld_corn	equ 0c8h ; нижний левый дв угол
rd_corn	equ 0bch ; нижний правый дв угол

fig_1 db 0, 1, 0, 0, 0, 0, 0, 0, 0
		 
fig_2 db 0, 1, 1, 0, 0, 0, 0, 0, 0
		 
fig_3 db 1, 1, 1, 0, 0, 0, 0, 0, 0
		 
fig_4 db 1, 1, 0, 1, 0, 0, 0, 0, 0
		 
fig_5 db 0, 1, 1, 0, 1, 1, 0, 0, 0
		 
fig_6 db 1, 1, 0, 1, 0, 0, 1, 0, 0
		 
fig_7 db 0, 1, 1, 0, 0, 1, 0, 0, 1

fig_8 db 0, 0, 1, 0, 1, 1, 0, 0, 1

fig_9 db 0, 1, 1, 1, 1, 0, 0, 0, 0

fig_10 db 1, 1, 0, 0, 1, 1, 0, 0, 0

fig_11 db 0, 1, 0, 1, 1, 1, 0, 1, 0

gameovert db 'T H E  E N D !!!'

scores db '���: '
score: dw 0
speedline db '᪮����: '
maxscore: dw 0

nextline db '᫥����� 䨣��:'
maxline db '���ᨬ���� ���:'
cur_color db 00h
next_color db 00h

cur_fig db 9 dup(0)
next_fig db 9 dup(0)

speed: db 18 ; 5-я скорость
counter: db 0

ispause: db 0

isstop: db 0
quad: db 0
quadnext:db 0

gameover_check dw 0

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
	cmp byte ptr cs:ispause, 1 ; если пауза или стоп мы не пишем в буффер по таймеру
	je @@9
	cmp byte ptr cs:isstop, 1
	je @@9
	mov bl, 10h
	call write
@@9:
	ret
checkrot endp

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
	cmp al, 1
	je callw
	cmp al, 02h
	je callw
	cmp al, 03h
	je callw
	cmp al, 04h
	je callw
	cmp al, 05h
	je callw
	cmp al, 06h
	je callw
	cmp al, 07h
	je callw
	cmp al, 08h
	je callw
	cmp al, 09h
	je callw
	cmp al, 0ah
	je callw
	cmp al, 0dh ;+
	je callw
	cmp al, 0ch ;-
	je callw
	cmp al, 1fh ; stop
	je callw
	cmp al, 31h ; n
	je callw
	cmp al, 13h ;r
	je callw
	cmp al, 19h
	je callw; pause
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

int08: ;обработчик 8-го инта, по таймеру кладем в буффер 10h
	push bx
	push ax
	call checkrot
	pop ax
	pop bx
	db 	0eah
old08 	dw	0, 0	

read proc near ; читаем из буффера
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

write proc near ;пишем в буффер
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
	ret
write endp

printfig proc near ; рисуем фигуру
	push 0b800h
	pop es
	
	mov bp, sp
	mov di, [bp+2]
	push cs
	pop ds
	mov si, offset cur_fig
	mov cx, 9
	xor dx, dx
	
floop1:
	lodsb
	inc dx
	
	cmp dx, 4
	jne floop1c
	add di, 148
	mov dx, 1
	

floop1c:
	cmp al, 1
	je floop1p
	add di, 4
	jmp floop11
	
floop1p:
	inc bh
	mov al, 0dbh
	mov ah, cur_color
	stosw
	stosw
	
floop11:
	loop floop1
	ret
printfig endp

startprintfig proc near ; рисуем фигуру
	push 0b800h
	pop es
	
	mov bp, sp
	mov di, [bp+2]
	push cs
	pop ds
	mov si, offset cur_fig
	mov cx, 9
	xor dx, dx
	xor bx, bx
	
floop13:
	lodsb
	inc dx
	
	cmp dx, 4
	jne floop1c3
	cmp bx, 00h
	je _suda
	add di, 148
	mov dx, 1
	inc bl
	jmp floop1c3
_suda:
	sub di, 12
	mov dx, 1
	inc bl

floop1c3:
	cmp al, 1
	je floop1p3
	add di, 4
	jmp floop113
	
floop1p3:
	inc bh
	mov al, 0dbh
	mov ah, cur_color
	stosw
	stosw
	
floop113:
	loop floop13
	ret
startprintfig endp

	
clearfig proc near ;очищаем след от фигуры, когда она движется
	push 0b800h
	pop es
	
	mov bp, sp
	mov di, [bp+2]
	push cs
	pop ds
	mov si, offset cur_fig
	
	mov cx, 9
	xor dx, dx
l1:
	lodsb
	inc dx
	
	cmp dx, 4
	jne l2
	add di, 148
	mov dx, 1
l2:
	cmp al, 1
	je l3
	add di, 4
	jmp l4
l3:
	mov ax, 0000h
	stosw
	stosw
l4:
	loop l1
	
	ret
clearfig endp

printnextfig proc near ; рисуем следующую фигуру
	push 0b800h
	pop es
	
	mov di, 656
	push cs
	pop ds
	mov si, offset next_fig
	mov cx, 9
	xor dx, dx
	xor bx, bx
floop12:
	lodsb
	inc dx
	
	cmp dx, 4
	jne floop1c2
	add di, 148
	mov dx, 1

floop1c2:
	cmp al, 1
	je floop1p2
	add di, 4
	jmp floop112
	
floop1p2:
	mov al, 0dbh
	mov ah, next_color
	stosw
	stosw
	
floop112:
	loop floop12
	ret
printnextfig endp

	
clearnextfig proc near
	push 0b800h
	pop es
	
	mov di, 656
	push cs
	pop ds
	mov si, offset next_fig
	
	mov cx, 9
	xor dx, dx
l12:
	lodsb
	inc dx
	
	cmp dx, 4
	jne l22
	add di, 148
	mov dx, 1
l22:
	cmp al, 1
	je l32
	add di, 4
	jmp l42
l32:
	mov ax, 0000h
	stosw
	stosw
l42:
	loop l12
	
	ret
clearnextfig endp

getrandom proc near ; рандомное число по таймеру
	xor ax, ax
	int 1ah
	mov al, dl
	div bl

	ret
getrandom endp

draw_field proc near ;начальное поле рисуем, заполняем его внутренность 0000h, высота - 24 строки, ширина - 28 (или 14), цвет белый
	pole:
	mov 	ax, 0b800h
	mov 	es, ax
	mov di, 50
	mov cx, 24
lp1:
	mov al, 0dbh
	mov ah, 07h
	stosw
	stosw
	push cx
	mov cx, 28
lp2:
	mov ax, 0000h
	stosw
	loop lp2
	
	pop cx
	mov al, 0dbh
	mov ah, 07h
	stosw
	stosw
	add di, 96
	loop lp1
	
	mov al, 0dbh
	stosw
	
	mov cx,30
	mov al, 0dbh
loop2:
	stosw
	loop loop2
	
	mov al, 0dbh
	stosw

    ret
draw_field endp

checktouchright proc near ;чекаем правую границу 
	push 0b800h
	pop es
	
	mov bp, sp
	mov di, [bp+2]
	push cs
	pop ds
	mov si, offset cur_fig
	mov cx, 9
	xor dx, dx
g1:
	lodsb
	inc dx
	
	cmp dx, 4
	jne g2
	add di, 148
	mov dx, 1
g2:
	cmp al, 1
	je g3
	jmp g4
g3:
	cmp dx, 3
	je g5
	lodsb
	dec si
	cmp al, 1
	je g4
g5:
	push si
	push ds
	push 0b800h 
	pop ds
	mov si, di
	add si, 4
	lodsw
	pop ds
	pop si
	cmp ax, 0000h
	jne g6
g4:
	add di, 4
	loop g1
	xor ax, ax
	ret
g6:
	mov ax, 1
	ret
checktouchright endp

checktouchleft proc near ;чекаем левую границу
	push 0b800h
	pop es
	
	mov bp, sp
	mov di, [bp+2]
	push cs
	pop ds
	mov si, offset cur_fig
	mov cx, 9
	xor dx, dx
h1:
	lodsb
	inc dx
	
	cmp dx, 4
	jne h2
	add di, 148
	mov dx, 1
h2:
	cmp al, 1
	je h3
	jmp h4
h3:
	cmp dx, 1
	je h5
	sub si, 2
	lodsb
	inc si
	cmp al, 1
	je h4
h5:
	push si
	push ds
	push 0b800h 
	pop ds
	mov si, di
	sub si, 4
	lodsw
	pop ds
	pop si
	cmp ax, 0000h
	jne h6
h4:
	add di, 4
	loop h1
	xor ax, ax
	ret
h6:
	mov ax, 1
	ret
checktouchleft endp

checktouchup proc near ;чтобы вверх не уйти, за крышку
	push 0b800h
	pop es
	
	mov bp, sp
	mov di, [bp+2]
	push cs
	pop ds
	mov si, offset cur_fig
	mov cx, 9
	xor dx, dx
q1:
	lodsb
	inc dx
	
	cmp dx, 4
	jne q2
	add di, 148
	mov dx, 1
q2:
	cmp al, 1
	je q3
	jmp q4
q3:
	cmp cx, 7
	jge q5
	sub si, 2
	lodsb
	inc si
	cmp al, 1
	je q4
q5:
	push si
	push ds
	push 0b800h 
	pop ds
	mov si, di
	sub si, 160
	mov ax, si
	pop ds
	pop si
	cmp ax, 0
	jle q6
q4:
	add di, 4
	loop q1
	xor ax, ax
	ret
q6:
	mov ax, 1
	ret
checktouchup endp

checktouchdown proc near ; проверяем, не достигнули ли мы снизу дна или другой фигуры - надо тогда остановиться
	push 0b800h
	pop es
	
	mov bp, sp
	mov di, [bp+2]
	push cs
	pop ds
	mov si, offset cur_fig
	mov cx, 9
	xor dx, dx
ch1:
	lodsb
	inc dx
	
	cmp dx, 4
	jne ch2
	add di, 148
	mov dx, 1
ch2:
	cmp al, 1
	je ch3
	jmp ch4
ch3:
	cmp cx, 3
	jle ch5
	add si, 2
	lodsb
	sub si, 3
	cmp al, 1
	je ch4
ch5:
	push si
	push ds
	push 0b800h 
	pop ds
	mov si, di
	add si, 160
	lodsw
	pop ds
	pop si
	cmp ax, 0000h
	jne ch6
ch4:
	add di, 4
	loop ch1
	xor ax, ax
	ret
ch6:
	mov ax, 1
	ret
checktouchdown endp

checkrotate proc near ; проверяем что можем повернуть
	push 0b800h
	pop es
	
	mov bp, sp
	mov di, [bp+2]
	push cs
	pop ds
	mov si, offset cur_fig
	mov cx, 9
	xor dx, dx
w1:
	lodsb
	inc dx
	
	cmp dx, 4
	jne w2
	add di, 148
	mov dx, 1
w2:
	cmp al, 0
	je w3
	jmp w4
w3:
	cmp cx, 3
	jle w5
	add si, 2
	lodsb
	sub si, 3
	cmp al, 1
	je w4
w5:
	push si
	push ds
	push 0b800h 
	pop ds
	mov si, di
	lodsw
	pop ds
	pop si
	cmp ax, 0000h
	jne w6
w4:
	add di, 4
	loop w1
	xor ax, ax
	ret
w6:
	mov ax, 1
	ret
checkrotate endp

addscores proc near
    push ax ;Сохраняем в стек значения нужных регистров
    push cx
    push dx
	push bx
	push es
	push di
	push ds
	xor bx, bx
	xor dx, dx
	xor ax, ax
	xor di, di
	push 0b800h
	pop es
	mov di, 3386
 
    mov bx, 10
    mov cx, 0
    mov ax, word ptr cs:score
    @@DivLoop:
        mov     dx,     0
        inc     cx
        div     bx
        push    dx
        cmp     ax,     0
    jnz @@DivLoop

    @@ToStrLoop:
        pop     ax
        add     al,     '0'
		mov ah, 0fh
		stosw
    loop @@ToStrLoop
 
	pop ds
	pop di
	pop es
	pop bx
	pop dx
    pop cx
    pop ax
	ret
addscores endp

draw_score proc near
	push di
	push cx
	push bx
	push ax
	push dx
	push es
	push si
	push 0b800h
	pop es
	mov di, 3374
	mov cx, 6
go11:
	mov si, offset scores
	mov bx, 6
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 0fh
	stosw
	loop go11
	
	mov cx, 10
	;mov di, 3390
go12:
	mov ax, 0000h
	stosw
	loop go12
	
	pop si
	pop es
	pop dx
	pop ax
	pop bx
	pop cx
	pop di
	ret
draw_score endp

get_speed proc near
    push ax ;Сохраняем в стек значения нужных регистров
    push cx
    push dx
	push bx
	push es
	push di
	push ds
	push dx
	xor bx, bx
	xor dx, dx
	xor ax, ax
	xor di, di
	xor dx, dx
	push 0b800h
	pop es
	
	mov cx, 8
	mov di, 3226
go22:
	mov ax, 0000h
	stosw
	loop go22
	
	mov di, 3226
	xor bx, bx
	xor ax, ax
	mov ax, word ptr cs:speed
	and ah, 00000000b
	sub ax, 2
	mov bx, 4
	div bx
	xor bx, bx
	mov bx, 9
	sub bx, ax
	mov ax, bx
	xor bx, bx
    mov bx, 10
    mov cx, 0
    @@DivLoop:
        mov     dx,     0
        inc     cx
        div     bx
        push    dx
        cmp     ax,     0
    jnz @@DivLoop

    @@ToStrLoop:
        pop     ax
        add     al,     '0'
		mov ah, 0fh
		stosw
    loop @@ToStrLoop
	pop dx
	pop ds
	pop di
	pop es
	pop bx
	pop dx
    pop cx
    pop ax
	ret
get_speed endp

draw_linespeed proc near
	push di
	push cx
	push bx
	push ax
	push dx
	push es
	push si
	push 0b800h
	pop es
	mov di, 3206
	mov cx, 10
go21:
	mov si, offset speedline
	mov bx, 10
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 0fh
	stosw
	loop go21
	
	pop si
	pop es
	pop dx
	pop ax
	pop bx
	pop cx
	pop di
	ret
draw_linespeed endp

checkfillline proc near
	push ds
	push es
	push 0b800h
	push 0b800h
	pop ds
	pop es
	mov si, 54
	mov cx, 24
lineloop1:
	cmp cx, 0
	jne _vpered
	jmp exex
_vpered:
	push cx
	mov cx, 28
lineloop2:
	lodsw
	cmp ax, 0000h
	je lineloop1c
	loop lineloop2
	
movelinesdown:
	std
	pop ax
	push ax
	mov cx, 24
	sub cx, ax
	push cx
	sub si, 2
	mov di, si
	sub si, 160
movelineloop:
	push cx
	mov cx, 28
	rep movsw
	add si, 56
	add di, 56
	sub si, 160
	sub di, 160
	pop cx
	loop movelineloop
	cld
	pop cx
	inc cx
	add word ptr cs:score, 10
	call addscores
	push ax
	mov ax, word ptr cs:score
	cmp ax, word ptr cs:maxscore
	jle _ff
	mov ax, word ptr cs:score
	mov word ptr cs:maxscore, ax
	call write_from_mem
	call load_from_mem
_ff:
	pop ax
@@1:
	add si, 160
	loop @@1
	add si, 4
	mov di, 54
	mov cx, 28
	mov ax, 0000h
	rep stosw
	
lineloop1c:
	mov ax, 28
	sub ax, cx
	mov bh, 2
	mul bh
	sub si, ax
	sub si, 2
	add si, 160
	pop cx
	inc bx	
	dec cx
	jmp lineloop1
exex:	
	pop es
	pop ds
	ret
checkfillline endp

setcolandfigcur proc near ; установить рандомный цвет и рандомную фигуру
	push ax
	push bx
	xor bx, bx
	mov bl, 7
	call getrandom
getcolor:
	cmp ah, 1
	je c1
	cmp ah, 2
	je c2
	cmp ah, 3
	je c3
	cmp ah, 4
	je c4
	cmp ah, 5
	je c5
	cmp ah, 6
	je c6
	cmp ah, 0
	je c7
	jmp stop
c1:
	mov cur_color, 04h
    jmp stop
c2:
	mov cur_color, 05h
    jmp stop
c3:
	mov cur_color, 07h
    jmp stop
c4:
	mov cur_color, 02h
    jmp stop
c5:
	mov cur_color, 01h
    jmp stop
c6:
	mov cur_color, 03h
    jmp stop
c7:
	mov cur_color, 06h
    jmp stop
stop:
	xor bx, bx
	mov bl, 12
	call getrandom
getfig:
	cmp ah, 1
	je f1
	cmp ah, 2
	je f2
	cmp ah, 3
	je f3
	cmp ah, 4
	jne _s2
	jmp f4
_s2:	
	cmp ah, 5
	jne _s1
	jmp f5
_s1:
	cmp ah, 6
	jne lol5
	jmp f6
lol5:
	cmp ah, 7
	jne lol1
	jmp f7
lol1:
	cmp ah, 8
	jne lol2
	jmp f8
lol2:
	cmp ah, 9
	jne lol3
	jmp f9
lol3:
	cmp ah, 10
	jne lol4
	jmp f10
lol4:
	cmp ah, 11
	jne lol15
	jmp f11
lol15:
	jmp stop2
f1:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_6
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
f2:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_9
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
f3:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_2
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
f4:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_1
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 1
	jmp stop2
f5:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_10
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
f6:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_3
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
f7:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_7
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
f8:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_11
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
f9:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_5
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 1
	jmp stop2
f10:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_9
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
f11:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_4
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quad, 0
	jmp stop2
stop2:
	pop bx
	pop ax
	ret
setcolandfigcur endp

setcolandfignext proc near ; СѓСЃС‚Р°РЅРѕРІРёС‚СЊ СЂР°РЅРґРѕРјРЅС‹Р№ С†РІРµС‚ Рё СЂР°РЅРґРѕРјРЅСѓСЋ С„РёРіСѓСЂСѓ
	push ax
	push bx
	xor bx, bx
	mov bl, 7
	call getrandom
getcolor2:
	cmp ah, 1
	je c12
	cmp ah, 2
	je c22
	cmp ah, 3
	je c32
	cmp ah, 4
	je c42
	cmp ah, 5
	je c52
	cmp ah, 6
	je c62
	cmp ah, 0
	je c72
	jmp stop1
c12:
	mov next_color, 01h
    jmp stop1
c22:
	mov next_color, 02h
    jmp stop1
c32:
	mov next_color, 03h
    jmp stop1
c42:
	mov next_color, 04h
    jmp stop1
c52:
	mov next_color, 05h
    jmp stop1
c62:
	mov next_color, 06h
    jmp stop1
c72:
	mov next_color, 07h
    jmp stop1
stop1:
	xor bx, bx
	mov bl, 12
	call getrandom
getfig2:
	cmp ah, 1
	je f12
	cmp ah, 2
	je f22
	cmp ah, 3
	je f32
	cmp ah, 4
	jne _s3
	jmp f42
_s3:
	cmp ah, 5
	jne _s4
	jmp f52
_s4:
	cmp ah, 6
	jne lol52
	jmp f62
lol52:
	cmp ah, 7
	jne lol12
	jmp f72
lol12:
	cmp ah, 8
	jne lol22
	jmp f82
lol22:
	cmp ah, 9
	jne lol32
	jmp f92
lol32:
	cmp ah, 10
	jne lol42
	jmp f102
lol42:
	cmp ah, 11
	jne lol152
	jmp f112
lol152:
	jmp stop22
f12:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_1
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 1
	jmp stop22
f22:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_2
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
f32:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_3
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
f42:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_4
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
f52:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_5
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 1
	jmp stop22
f62:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_6
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
f72:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_7
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
f82:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_8
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
f92:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_9
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
f102:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_10
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
f112:
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset fig_11
	mov di, offset next_fig
	mov cx, 9
	rep movsb
	mov byte ptr cs:quadnext, 0
	jmp stop22
stop22:
	pop bx
	pop ax
	ret
setcolandfignext endp

nextlines proc near
	push es
	push ax 
	push di
	push cx
	push bx
	mov 	ax, 0b800h ; адрес первой стреки
	mov 	es, ax
	mov di, 326
	mov cx, 17
gogo:
	mov si, offset nextline
	mov bx, 17
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 0fh
	stosw
	loop gogo
	pop bx
	pop cx
	pop di
	pop ax
	pop es
	ret
nextlines endp

maxlines proc near
	push es
	push ax 
	push di
	push cx
	push bx
	mov 	ax, 0b800h ; адрес первой стреки
	mov 	es, ax
	mov di, 440
	mov cx, 18
gogo2:
	mov si, offset maxline
	mov bx, 18
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 0fh
	stosw
	loop gogo2
	pop bx
	pop cx
	pop di
	pop ax
	pop es
	ret
maxlines endp

load_from_mem proc
	push bx
	push es
	push ax
	push cx
	push dx
	push si
	push ds
	mov 	bx, 0
	mov 	ax, 3000h
	mov 	es, ax		; сегмент оперативной памяти, куда копируем программу
	mov 	ah, 2		; номер прерывания (чтение секторов из памяти)
	mov 	al, 1		; количество сегментов
	mov 	ch, 1
	mov 	cl, 2		; номер сегмента дорожки, с которого начинаем копировать
	mov 	dh, 0		; номер головки
	mov 	dl, 0		; номер диска 
	int 	13h		; вызов прерывания
	mov 	ax, 3000h
	mov 	ds, ax
	xor 	si, si
	lodsw
	mov word ptr cs:maxscore, ax
	push 0b800h
	pop es
	mov di, 614
	mov bx, 10
    mov cx, 0
    @@DivLoop:
        mov     dx,     0
        inc     cx
        div     bx
        push    dx
        cmp     ax,     0
    jnz @@DivLoop

    @@ToStrLoop:
        pop     ax
        add     al,     '0'
		mov ah, 0fh
		stosw
    loop @@ToStrLoop
	pop ds
	pop si
	pop dx
	pop cx
	pop ax
	pop es
	pop bx
	ret
load_from_mem endp

write_from_mem proc
	push bx
	push es
	push ax
	push cx
	push dx
	push si
	push ds
	mov 	di, 0
	mov 	bx, 3000h
	mov 	es, bx		; сегмент оперативной памяти, куда копируем программу
	mov 	ax, word ptr cs:maxscore
	stosw
	xor 	bx, bx
	mov 	ah, 3		; номер прерывания (чтение секторов из памяти)
	mov 	al, 1		; количество сегментов
	mov 	ch, 1
	mov 	cl, 2		; номер сегмента дорожки, с которого начинаем копировать
	mov 	dh, 0		; номер головки
	mov 	dl, 0		; номер диска 
	int 	13h		; вызов прерывания

	pop ds
	pop si
	pop dx
	pop cx
	pop ax
	pop es
	pop bx
	ret
write_from_mem endp

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

newgame:	;новая игра
	
	mov ax, word ptr cs:score
	cmp ax, word ptr cs:maxscore
	jle _dalee
	mov ax, word ptr cs:score
	mov word ptr cs:maxscore, ax
	call write_from_mem
_dalee:
	call maxlines
	call load_from_mem
	call draw_score
	call draw_field
	mov word ptr cs:score, 0
	call addscores
	call nextlines
	call clearnextfig
	call setcolandfigcur
	call setcolandfignext
	call printnextfig
	

	mov byte ptr cs:speed, 18
	mov byte ptr cs:counter, 0
	mov byte ptr cs:ispause, 0
	
	call draw_linespeed
	call get_speed
	
	mov di, 74 ;середина стакана
	push di
	call printfig
	pop di
	
_loop:
	
	hlt
	mov ax, tail
	mov bx, head
	cmp ax, bx
	je _loop
	call read
	cmp bl, 1
	jne kek1
	jmp exit
kek1:
	cmp bl, 02h
	jne kek2
	jmp lev1
kek2:
	cmp bl, 03h
	jne kek3
	jmp lev2
kek3:
	cmp bl, 04h
	jne kek4
	jmp lev3
kek4:
	cmp bl, 05h
	jne kek5
	jmp lev4
kek5:
	cmp bl, 06h
	jne kek6
	jmp lev5
kek6:
	cmp bl, 07h
	jne kek7
	jmp lev6
kek7:
	cmp bl, 08h
	jne kek8
	jmp lev7
kek8:
	cmp bl, 09h
	jne kek9
	jmp lev8
kek9:
	cmp bl, 0ah
	jne kek10
	jmp lev9
kek10:
	cmp bl, 48h
	jne kek11
	jmp up
kek11:
	cmp bl, 39h
	jne kek12
	jmp drop	
kek12:
	cmp bl, 4dh
	jne kek13
	jmp right
kek13:
	cmp bl, 4bh
	jne kek14
	jmp left
kek14:
	cmp bl, 50h
	jne kek15
	jmp down
kek15:
	cmp bl, 10h
	jne kek16
	jmp move
kek16:
	cmp bl, 0dh
	jne kek17
	jmp decspeed
kek17:
	cmp bl, 0ch
	jne kek18
	jmp incspeed
kek18:
	cmp bl, 19h
	jne kek19
	jmp setpause
kek19:
	cmp bl, 1fh
	jne kek20
	jmp setstop
kek20:
	cmp bl, 31h
	jne kek21
	jmp newgame
kek21:
	cmp bl, 13h
	jne kek22
	jmp rotate
kek22:
	jmp _loop
	
rotate: ;поворачиваем
	cmp byte ptr cs:quad, 1
	jne _dalee1
	jmp _loop
_dalee1:
	push di
	call checkrotate
	pop di
	
	cmp ax, 1
	jne rotatec
	jmp _loop

rotatec: 
	push di
	call clearfig
	pop di
	
	push di
	push cs
	pop ds
	mov si, offset cur_fig
	mov cx, 9
rloop:
	lodsb
	push ax
	loop rloop
	
	push cs
	pop es
	mov dx, 6
	mov cx, 3
rloop1:
	pop ax
	mov di, offset cur_fig
	add di, dx
	stosb
	sub dx, 3
	loop rloop1
	
	mov dx, 7
	mov cx, 3
rloop2:
	pop ax
	mov di, offset cur_fig
	add di, dx
	stosb
	sub dx, 3
	loop rloop2
	
	mov dx, 8
	mov cx, 3
	
rloop3:
	pop ax
	mov di, offset cur_fig
	add di, dx
	stosb
	sub dx, 3
	loop rloop3
	
	pop di
	push di
	call printfig
	pop di	
	jmp _loop
	

	
setstop: ;стопаемся
	cmp byte ptr cs:isstop, 0
	je sets1
sets0:
	dec byte ptr cs:isstop
	jmp _loop
sets1:
	inc byte ptr cs:isstop
	jmp _loop
	
setpause: ;делаем паузу
	inc byte ptr cs:ispause

	push 0
    pop es
    mov ax, old09
    mov bx, old09+2
    cli
    mov word ptr es:[36], ax
    mov word ptr es:[38], bx
    sti
	
	xor ax, ax
	int 16h
	
	cmp ah, 1
	jne other
	jmp exit
	
other:	
	dec byte ptr cs:ispause
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
	
	jmp _loop
	
incspeed: ;увеличить скорость по плюсику
	cmp byte ptr cs:speed, 34
	je ex
check:
	inc byte ptr cs:speed
	inc byte ptr cs:speed
	inc byte ptr cs:speed
	inc byte ptr cs:speed
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl ex
	mov byte ptr cs:counter, 0
ex:
	call get_speed
	jmp _loop
	
decspeed: ;уменьшить скорость по минусу
	cmp byte ptr cs:speed, 2
	je ex2
check2:
	dec byte ptr cs:speed
	dec byte ptr cs:speed
	dec byte ptr cs:speed
	dec byte ptr cs:speed
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl ex2
	mov byte ptr cs:counter, 0
ex2:
	call get_speed
	jmp _loop
	
lev1: ;меняем скорость по клавише
	mov byte ptr cs:speed, 34
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep1
	mov byte ptr cs:counter, 0
rep1:
	call get_speed
	jmp _loop
	
lev2:
	mov byte ptr cs:speed, 30
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep2
	mov byte ptr cs:counter, 0
rep2:
	call get_speed
	jmp _loop
	
lev3:
	mov byte ptr cs:speed, 26
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep3
	mov byte ptr cs:counter, 0
rep3:
	call get_speed
	jmp _loop
	
lev4:
	mov byte ptr cs:speed, 22
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep4
	mov byte ptr cs:counter, 0
rep4:
	call get_speed
	jmp _loop
	
lev5:
	mov byte ptr cs:speed, 18
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep5
	mov byte ptr cs:counter, 0
rep5:
	call get_speed
	jmp _loop
	
lev6:
	mov byte ptr cs:speed, 14
    mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep6
	mov byte ptr cs:counter, 0
rep6:
	call get_speed
	jmp _loop
	
lev7:
	mov byte ptr cs:speed, 10
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep7
	mov byte ptr cs:counter, 0
rep7:
	call get_speed
	jmp _loop
	
lev8:
	mov byte ptr cs:speed, 6
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep8
	mov byte ptr cs:counter, 0
rep8:
	call get_speed
	jmp _loop
	
lev9:
	mov byte ptr cs:speed, 2
	mov al, byte ptr cs:counter
	cmp al, byte ptr cs:speed
	jl rep9
	mov byte ptr cs:counter, 0
rep9:
	call get_speed
	jmp _loop
	
move:
	push di
	call checktouchdown ;проверяем не опустились ли мы до дна
	pop di
	
	cmp ax, 1 ; тут единица, если внизу дно какое-то или фигура
	jne next
	cmp word ptr cs:gameover_check, 0
	je gameover
	jmp newfigure
next:
	inc word ptr cs:gameover_check
	push di
	call clearfig ; очищаем прежнее положение фигуры
	pop di
	
	add di, 160
	
	push di
	call printfig ;рисуем новое положение фигуры
	pop di
	
    jmp _loop
	

newfigure: ;нужна новая фигура с новым цветом
	call checkfillline
	push di
	push si
	xor cx, cx
xchange:
	push cs
	push cs
	pop es
	pop ds
	mov si, offset next_fig
	mov di, offset cur_fig
	mov cx, 9
	rep movsb
	
	mov si, offset next_color
	mov di, offset cur_color
	mov cx, 1
	rep movsb
	
	mov si, offset quadnext
	mov di, offset quad
	mov cx, 1
	rep movsb
	call clearnextfig
	call setcolandfignext
	
	call printnextfig
	pop si
	pop di
	mov di, 74
	push di
	mov byte ptr cs:counter, 0
	call printfig
	pop di
	mov word ptr cs:gameover_check, 0
	jmp _loop
	
gameover:
	push di
	inc byte ptr cs:ispause

	push 0
    pop es
    mov ax, old09
    mov bx, old09+2
    cli
    mov word ptr es:[36], ax
    mov word ptr es:[38], bx
    sti
	
	mov 	ax, 0b800h ; адрес первой стреки
	mov 	es, ax
	mov di, 1826
	mov cx, 16
go:
	mov si, offset gameovert
	mov bx, 16
	sub bx, cx
	add si, bx
	lodsb
	mov ah, 8fh
	stosw
	loop go

key:	
	xor ax, ax
	int 16h
	
	cmp ah, 1
	jne key2
	jmp exit
key2:
	cmp ah, 31h
	jne key
	
	dec byte ptr cs:ispause
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
	
	pop di
	
	jmp newgame
	
left:
	push di
	call checktouchleft ;проверяем не опустились ли мы до дна
	pop di
	
	cmp ax, 1
	jne left_next
	jmp _loop
left_next:
	push di
	call clearfig ; очищаем прежнее положение фигуры
	pop di
	
	sub di, 4
	
	push di
	call printfig ;рисуем новое положение фигуры
	pop di
	
    jmp _loop

right:
	push di
	call checktouchright ;проверяем не опустились ли мы до дна
	pop di
	
	cmp ax, 1
	jne right_next
	jmp _loop
right_next:
	push di
	call clearfig ; очищаем прежнее положение фигуры
	pop di
	
	add di, 4
	
	push di
	call printfig ;рисуем новое положение фигуры
	pop di
	
    jmp _loop
jmp_gameover:
	jmp gameover
drop:
	push di
	call checktouchdown ;проверяем не опустились ли мы до дна
	pop di
	
	cmp ax, 1 ; тут единица, если внизу дно какое-то или фигура
	jne drop_next
	cmp word ptr cs:gameover_check, 0
	je jmp_gameover
	jmp newfigure
drop_next:
	push di
	call clearfig ; очищаем прежнее положение фигуры
	pop di
	
	add di, 160
	inc word ptr cs:gameover_check
	push di
	call printfig ;рисуем новое положение фигуры
	pop di

    jmp drop
	
down:
	push di
	call checktouchdown ;проверяем не опустились ли мы до дна
	pop di
	
	cmp ax, 1 ; тут единица, если внизу дно какое-то или фигура
	jne down_next
	cmp word ptr cs:gameover_check, 0
	je jmp_gameover
	jmp newfigure
down_next:
	push di
	call clearfig ; очищаем прежнее положение фигуры
	pop di
	
	add di, 160 
	inc word ptr cs:gameover_check
	push di
	call printfig ;рисуем новое положение фигуры
	pop di
	
    jmp _loop
	
up:
	push di
	call checktouchup ;проверяем не опустились ли мы до дна
	pop di
	
	cmp ax, 1
	jne up_next
	jmp _loop
up_next:
	push di
	call clearfig ; очищаем прежнее положение фигуры
	pop di
	
	sub di, 160 
	
	push di
	call printfig ;рисуем новое положение фигуры
	pop di
	
    jmp _loop
	
exit:
	mov ax, word ptr cs:score
	cmp ax, word ptr cs:maxscore
	jle _dalee2
	mov ax, word ptr cs:score
	mov word ptr cs:maxscore, ax
	call write_from_mem
_dalee2:
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
	