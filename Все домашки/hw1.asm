.model tiny
.code
org 100h
begin:
	jmp short _start
	nop
operator	db 'MBR.180K'
; BPB
BytesPerSec	dw 200h
SectPerClust	db 1
RsvdSectors	dw 1
NumFATs		db 2
RootEntryCnt	dw 64		; 2 сектора на root dir
TotalSectors	dw 360	
MediaByte	db 0FCh		; 1 голова 9 секторов 40 цилиндров
FATsize		dw 2		; 2 сектора на каждый FAT
SecPerTrk	dw 9
NumHeads	dw 1
HidSec		dw 0, 0
TotSec32	dd 0
DrvNum		db 0
Reserved	db 0
Signatura	db ')'		; 29h
; 
Vol_ID		db 'XDRV'
DiskLabel	db 'TestMBRdisk'
FATtype		db 'FAT12   '
;
_start:
	cld
	mov	ax, 3		
	int	10h
	mov	ax, 0b800h
	mov	es, ax
	mov	di, 660
@@1:
	xor	ah,ah
	int	16h
	cmp	ah, 1
	jz	@@2
	cmp ah, 0Eh
	jz @@3
	mov	ah, 0fh
	stosw
	jmp	@@1
@@2:       				;exit
	db 0eah 
	dw 7c00h, 0
@@3:
	mov ah, 0fh
	mov al, 20h
	sub di, 2
	stosw
	sub di, 2
	jmp @@1
org	766
dw	0aa55h
end begin
