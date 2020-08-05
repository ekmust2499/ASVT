; перехватываем обработку нажатия клавиш
.model tiny
.code
org 	100h
locals @@

start:
	
old_di  dw      0
        mov     ax, 3           
        int     10h
        mov     si,     4*vector
        mov     di,     offset old_int
        xor     ax,     ax
        mov     ds,     ax
        movsw ; ds:si -> es:di
        movsw

        push    ds
        pop     es
        push    cs
        pop     ds
        mov     ax,     offset my_int
        mov     di,     4*vector
        cli
        stosw
        mov     ax,     cs
        stosw
        sti
        push    cs
        pop     es
@@2:
        xor     ax,     ax
        int     16h
        cmp     ah,     1
        jnz     @@2
        
        mov     di,     4*vector
        mov     si,     offset old_int
        xor     ax,     ax
        mov     es,     ax
        cli
        movsw
        movsw
        sti
 _exit:
        db 0eah 
        dw 7c00h, 0       

my_int  proc
        push    ax
        push    di
        push    es

        in      al,     60h
        test    al,     80h
        jnz     @@1
        
        mov     ax,     0b800h
        mov     es,     ax
        mov     di,     cs:old_di
        mov     al,     20h
        inc     di
        stosb
        mov     cs:old_di,      di
@@1:
        pop     es
        pop     di
        pop     ax

        db      0eah
old_int dw      0, 0
my_int  endp
vector = 8

end     start