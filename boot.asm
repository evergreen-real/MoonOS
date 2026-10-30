bits 16
org 0x7c00

start:
	cli
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00
	sti

	mov si, disk_packet
	mov ah, 0x42
	int 0x13
	jc disk_error

	mov ax, 0x0013
	int 0x10

	mov dx, 0x03c8
	mov al, 14
	out dx, al
	inc dx
	mov al, 63
	out dx, al
	mov al, 57
	out dx, al
	mov al, 32
	out dx, al

	mov ax, 0x1000
	mov ds, ax
	xor si, si
	mov ax, 0xa000
	mov es, ax
	xor di, di
	mov cx, 32000
	cld
	rep movsw

hang:
	jmp hang

disk_error:
	cli
	hlt
	jmp disk_error

disk_packet:
	db 0x10, 0
	dw 125
	dw 0, 0x1000
	dq 1

times 510-($-$$) db 0
dw 0xaa55
incbin "MoonOS.raw"
