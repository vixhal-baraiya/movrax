/* boot.asm - Multiboot header and entry point */

/* Multiboot header constants */
.set ALIGN,    1<<0                 /* align loaded modules on page boundaries */
.set MEMINFO,  1<<1                 /* provide memory map */
.set FLAGS,    ALIGN | MEMINFO      /* Multiboot 'flag' field */
.set MAGIC,    0x1BADB002            /* magic number for bootloader to find header */
.set CHECKSUM, -(MAGIC + FLAGS)     /* checksum to prove we are multiboot */

/* Multiboot header - must be in first 8KB of kernel file */
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/* Reserve stack space */
.section .bss
.align 16
stack_bottom:
.skip 16384  /* 16 KB stack */
stack_top:

/* Entry point */
.section .text
.global _start
.type _start, @function
_start:
    /* Set up stack pointer */
    mov $stack_top, %esp
    
    /* Reset EFLAGS */
    pushl $0
    popf
    
    /* Call kernel main function (C++) */
    call kernel_main
    
    /* If kernel_main returns, halt the CPU */
    cli
1:  hlt
    jmp 1b

/* Set size of _start symbol for debugging */
.size _start, . - _start