CC ?= gcc
LD ?= ld
OBJCOPY ?= objcopy
NASM ?= nasm

KERNEL_LOAD_ADDRESS := 0x20000
KERNEL_SECTORS := 32
SECTOR_SIZE := 512

.PHONY: all
all: boot.bin

kernel.o: kernel.c Makefile
	$(CC) -m32 -ffreestanding -fno-pic -fno-pie -fno-stack-protector \
		-fno-asynchronous-unwind-tables -fno-unwind-tables -O0 -c $< -o $@

kernel.elf: kernel.o Makefile
	$(LD) -m elf_i386 -Ttext $(KERNEL_LOAD_ADDRESS) -e kernel_main -o $@ $<

kernel.bin: kernel.elf Makefile
	$(OBJCOPY) -O binary $< $@
	test "$$(wc -c < $@)" -le $$(( $(KERNEL_SECTORS) * $(SECTOR_SIZE) ))
	truncate -s $$(( $(KERNEL_SECTORS) * $(SECTOR_SIZE) )) $@

boot.bin: boot.asm MoonOS.raw kernel.bin
	$(NASM) -f bin $< -o $@
