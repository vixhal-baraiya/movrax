# Quick Start Guide - Phase 1

## What You Just Got

A minimal bootable OS kernel that:
- Boots using GRUB (Grand Unified Bootloader)
- Displays colored text via VGA text mode
- Written in clean C++ (not C!)
- ~300 lines of actual code

## Understanding the Code

### 1. Boot Flow (boot.asm)

```asm
_start:
    mov $stack_top, %esp    # Set up stack
    call kernel_main        # Jump to C++
```

**Why assembly?** The CPU starts in real mode (16-bit). GRUB gets us to protected mode (32-bit), but we still need assembly to:
- Set up the stack pointer
- Call our C++ function

### 2. Multiboot Header

```asm
.set MAGIC, 0x1BADB002
```

This magic number tells GRUB "hey, I'm a bootable kernel!" Without it, GRUB won't load us.

### 3. VGA Text Mode (vga.cpp)

```cpp
buffer = (uint16_t*)0xB8000;  // VGA memory address
```

**Memory-mapped I/O:** Writing to `0xB8000` directly controls the screen. Each character is 2 bytes:
- Byte 0: ASCII character
- Byte 1: Color (4 bits foreground, 4 bits background)

### 4. Main Kernel (kernel.cpp)

```cpp
extern "C" void kernel_main() {
    terminal.initialize();
    terminal.write_string("Hello!");
    while(1) { asm volatile("hlt"); }
}
```

**extern "C":** Tells C++ not to mangle the function name (C++ adds type info to names). Assembly expects `kernel_main`, not `_Z11kernel_mainv`.

**hlt instruction:** Halts CPU until next interrupt. Saves power vs. infinite empty loop.

## Testing Your Setup

### Step 1: Check if you have the tools

```bash
# Check for cross-compiler
i686-elf-gcc --version

# If not found, you need to install it (see README)
# OR modify Makefile to use system gcc with -m32 flag
```

### Step 2: Build

```bash
cd mini-os
make
```

**Expected output:**
```
i686-elf-as src/boot/boot.asm -o build/boot.o
i686-elf-g++ -ffreestanding -O2 ... -c src/kernel/vga.cpp -o build/vga.o
i686-elf-g++ -ffreestanding -O2 ... -c src/kernel/kernel.cpp -o build/kernel.o
i686-elf-ld -T linker.ld -nostdlib -o kernel.bin build/boot.o build/vga.o build/kernel.o -lgcc
grub-mkrescue -o mini-os.iso isodir
```

### Step 3: Run

```bash
make run
```

QEMU window should pop up with your OS!

## Common Issues

### "i686-elf-gcc: command not found"

**Solution 1:** Install cross-compiler (see README)

**Solution 2:** Use system gcc with `-m32`:

Edit Makefile:
```makefile
AS = as
CXX = g++
LD = ld
CXXFLAGS = -m32 -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -I$(INCLUDE_DIR)
LDFLAGS = -m elf_i386 -T linker.ld -nostdlib -lgcc
```

Then install 32-bit libs:
```bash
sudo apt install gcc-multilib g++-multilib
```

### "grub-mkrescue: command not found"

```bash
sudo apt install grub-pc-bin xorriso
```

### QEMU hangs at "Booting from CD-ROM"

This is actually correct! Press Ctrl+C to exit.

If you see a GRUB menu but it doesn't boot:
- Check that `grub.cfg` is correct
- Verify kernel.bin is in `isodir/boot/`

### Triple fault / reboot loop

Your kernel crashed. Common causes:
- Stack overflow (increase stack size in boot.asm)
- Null pointer dereference
- Unaligned memory access

Use `make debug` and GDB to investigate.

## Modifying the Code

### Change the welcome message

Edit `src/kernel/kernel.cpp`:
```cpp
terminal.write_string("Your custom message here!\n");
```

Then rebuild:
```bash
make clean
make run
```

### Add more colors

Edit `src/kernel/kernel.cpp`:
```cpp
terminal.set_color(VGA_COLOR_LIGHT_MAGENTA, VGA_COLOR_BLUE);
terminal.write_string("Pretty colors!\n");
```

### Make it scroll

The VGA terminal already handles scrolling! Try:
```cpp
for (int i = 0; i < 30; i++) {
    terminal.write_string("Line ");
    // TODO: Print number (need to implement itoa)
    terminal.write_string("\n");
}
```

## Next: Phase 2 Preview

In Phase 2, we'll add:
- **Physical memory manager:** Allocate/free 4KB pages
- **Virtual memory:** Page tables, mapping
- **Persistent region:** Map a disk file to memory address

The persistent region will look like:
```cpp
void* persistent_mem = (void*)0xC0000000;  // 3GB mark
// Writing to this address writes to disk!
char* file_data = (char*)persistent_mem;
file_data[0] = 'H';  // Persists across reboot!
```

## Questions?

Open an issue on GitHub or check OSDev Wiki for deeper explanations!

---

**You've completed Phase 1! 🎉**

Next step: Implement page frame allocator (Phase 2, Week 1).