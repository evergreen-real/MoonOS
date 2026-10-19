; Multiboot header constants
MODULEALIGN equ  1 << 0
MEMINFO     equ  1 << 1
FLAGS       equ  MODULEALIGN | MEMINFO
MAGIC       equ  0x1BADB002        ; Magic number for GRUB
CHECKSUM    equ  -(MAGIC + FLAGS)

section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

section .bss
align 16
stack_bottom:
    resb 16384 ; Reserve 16 KB for the system stack
stack_top:

section .text
global _start
extern kernel_main

_start:
    mov esp, stack_top  ; Set up the stack pointer
    call kernel_main    ; Jump into your C kernel
    cli                 ; Clear interrupts if kernel returns
.hang:                  ; Infinite loop
    hlt
    jmp .hang
