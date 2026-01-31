/* Linker script for the kernel */

ENTRY(_start)

SECTIONS
{
    /* Kernel starts at 1MB physical address */
    . = 1M;

    /* Multiboot header must come first */
    .multiboot ALIGN(4K) : {
        *(.multiboot)
    }

    /* Read-only code and data */
    .text ALIGN(4K) : {
        *(.text)
    }

    .rodata ALIGN(4K) : {
        *(.rodata)
    }

    /* Read-write data (initialized) */
    .data ALIGN(4K) : {
        *(.data)
    }

    /* Read-write data (uninitialized) and stack */
    .bss ALIGN(4K) : {
        *(COMMON)
        *(.bss)
    }

    /* C++ static constructors and destructors */
    .init_array ALIGN(4K) : {
        __init_array_start = .;
        *(.init_array)
        __init_array_end = .;
    }

    .fini_array ALIGN(4K) : {
        __fini_array_start = .;
        *(.fini_array)
        __fini_array_end = .;
    }
}
