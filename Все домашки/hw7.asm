.model tiny
.code
org 100h
indent 		equ 44
next_string equ 86
space		equ 20h ; пробел
vert 		equ 0b3h ; вертикальная одинарная 
d_vert 		equ 0bah ; вертикальная двойная
horiz		equ 0c4h ; горизонтальная одинарная 
d_horiz		equ 0cdh ; горизонтальная двойная 
lu_corn		equ 0c9h ; левый верхний двойной угол
ru_corn		equ 0bbh ; правый верхний двойной угол
ld_corn		equ 0c8h ; левый нижний двойной угол
rd_corn		equ 0bch ; правый нижний двойной угол
duu_corn	equ 0d1h ; буква Т с двойной шляпой 
dud_corn	equ 0cfh ; перевёрнутая Т с двойной шляпой
cross		equ 0c5h ; плюс
dul_corn	equ 0c7h ; двойные вертикальные линии с выступом справа
dur_corn	equ 0b6h ; двойные вертикальные линии с выступом слева

table_width	equ 37 ; ширина таблицы

locals @@
_start:
jmp 	_begin

print_symbol proc near
	and 	bl, 0fh
	add 	bl, 30h 
	cmp 	bl, 3ah 
	jl 	@@1
	add 	bl, 07h
@@1:
	mov 	al, bl 
	stosw
	ret
print_symbol endp

_begin: 
	mov 	ax, 3 
	int 	10h
	xor 	dh, dh
	jmp _screen
_mode1:
	mov ax, 1
	int 10h
	xor dh, dh
	mov dh, 1
_screen:
	mov 	ax, 0b800h 
	mov 	es, ax
	cmp dh, 1
	je _indent_mode1
	jmp _indent_mode3

_indent_mode1:
   mov di, indent - 42
   jmp _left_corner

_indent_mode3:	
	mov 	di, indent 

_left_corner:
	mov 	ah, 3fh 
	mov 	al, lu_corn 
	stosw
	mov 	al, d_horiz
	stosw
	mov 	al, duu_corn
	stosw
	mov 	cx, table_width - 4
	mov 	al, d_horiz 
_top_frame:
	stosw
	loop 	_top_frame
	mov 	al, ru_corn
	stosw
	cmp dh, 1
	je _next1_mode1
	jmp _next1_mode3
_next1_mode1:
    add di, next_string - 80
    jmp _empty_cell
_next1_mode3:    
	add 	di, next_string ; 37*2 = 74 байта мы записали, 160 - (74+48) = 38- это осталось от первой строки => + 48 = 86 - след строка

_empty_cell:
	mov 	al, d_vert
	stosw
	mov 	al, space 
	stosw
	mov 	al, vert
	stosw
	mov 	al, space 
	stosw
	mov 	cx, 16 
_column_numbering:
	mov 	bx, 16
	sub 	bx, cx
	call 	print_symbol
	mov 	al, space 
	stosw
	loop 	_column_numbering

	mov 	al, d_vert 
	stosw
	cmp dh, 1
	je _next2_mode1
	jmp _next2_mode3
_next2_mode1:
    add di, next_string - 80
    jmp _third
_next2_mode3:    	
	add 	di, next_string ; 3 строка

_third:
	mov 	al, dul_corn ; 3 строка
	stosw
	mov 	al, horiz
	stosw
	mov 	al, cross
	stosw
	mov 	cx, table_width - 4
	mov 	al, horiz
_sep:
	stosw
	loop _sep 

	mov 	al, dur_corn 
	stosw
    cmp dh, 1
    je _next3_mode1
    jmp _next3_mode3
_next3_mode1:
    add di, next_string - 80
    jmp _table
_next3_mode3:    
	add 	di, next_string 

_table:  
	xor 	dl, dl
	mov 	cx, 16 
_table_outer_loop:
	mov 	al, d_vert ; нумеруем строки
	stosw
	mov 	bx, 16
	sub 	bx, cx
	call 	print_symbol
	mov 	al, vert
	stosw
	mov 	al, space
	stosw
	push 	cx 
	mov 	cx, 16 

_tabel_inner_loop:
	mov 	al, dl ; dl от 0 до 255 - как раз ascii табл
	stosw
	mov 	al, space
	stosw
	inc 	dl 
	loop 	_tabel_inner_loop
	pop 	cx
	mov 	al, d_vert
	stosw
	cmp dh, 1
    je _next4_mode1
    jmp _next4_mode3
_next4_mode1:
    add di, next_string - 80
    jmp _next
_next4_mode3:
	add 	di, next_string 

_next:	
	loop 	_table_outer_loop 

_last_string:
	mov 	al, ld_corn ; последняя строка таблицы с уголками
	stosw
	mov 	al, d_horiz 
	stosw
	mov 	al, dud_corn
	stosw
	mov 	cx, table_width - 4
	mov 	al, d_horiz

_down_frame:
	stosw
	loop 	_down_frame
	mov 	al, rd_corn
	stosw

_cycle:
	xor 	ax, ax
	int 	16h
	cmp ah, 1 ; escape - выход
	je _exit
	cmp dh, 0
	jne _mode3
	jmp _mode1
_mode3:
	jmp _begin
_exit:
	db 0eah 
	dw 7c00h, 0


end _start
