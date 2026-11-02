bits 16
org 0x7c00

start:
	cli
	jmp 0x0000:boot_start

boot_start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00
	mov [boot_drive], dl
	sti

	mov si, disk_packet
	mov dl, [boot_drive]
	mov ah, 0x42
	int 0x13
	jc disk_error

	mov si, kernel_packet
	mov dl, [boot_drive]
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

	xor ax, ax
	mov ds, ax
	cli
	lgdt [gdt_descriptor]
	mov eax, cr0
	or al, 1
	mov cr0, eax
	jmp 0x08:protected_mode

disk_error:
	cli
	hlt
	jmp disk_error

align 4
disk_packet:
	db 0x10, 0
	dw 125
	dw 0, 0x1000
	dq 1

kernel_packet:
	db 0x10, 0
	dw 32
	dw 0, 0x2000
	dq 126

boot_drive:
	db 0

align 8
gdt:
	dq 0
	dq 0x00cf9a000000ffff
	dq 0x00cf92000000ffff
gdt_end:

gdt_descriptor:
	dw gdt_end - gdt - 1
	dd gdt

bits 32
protected_mode:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esp, 0x90000
	mov eax, 0x20000
	call eax

kernel_returned:
	cli
.halt:
	hlt
	jmp .halt

bits 16
times 510-($-$$) db 0
dw 0xaa55
incbin "MoonOS.raw"
incbin "kernel.bin"
