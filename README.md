# MOVRAX - Mini Persistent Memory OS

A minimalist operating system demonstrating a **persistent memory model** where RAM and filesystem are unified - no explicit save/load operations needed!

## 🎯 Concept

Traditional OSes treat memory (RAM) and storage (disk) as separate entities:
- You `open()` files, `read()` them into memory, modify, then `write()` back
- Clear separation between volatile and persistent storage

**This OS does it differently:**
- Files are memory-mapped regions
- Modifying "memory" directly modifies the "file"
- No save button - changes persist automatically
- Filesystem is just structured memory with metadata

## 🚀 Current Status: Phase 1 - Bootable Kernel

✅ **Completed:**
- Multiboot-compliant bootloader
- VGA text mode output with colors
- Basic kernel entry point
- Clean C++ architecture

🚧 **TODO:**
- Phase 2: Memory management (paging, persistent region)
- Phase 3: Simple filesystem (memory-backed)
- Phase 4: Text editor (direct memory editing)

## 📦 Prerequisites

### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install build-essential qemu-system-x86 grub-pc-bin xorriso mtools

# Install cross-compiler
sudo apt install gcc-multilib g++-multilib
# OR build i686-elf toolchain (see below)
```

### Building i686-elf Cross-Compiler (if needed):

```bash
# Download binutils and gcc
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

# Build binutils
cd /tmp
wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz
tar xf binutils-2.41.tar.xz
mkdir build-binutils && cd build-binutils
../binutils-2.41/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make -j$(nproc)
make install

# Build gcc
cd /tmp
wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
tar xf gcc-13.2.0.tar.xz
mkdir build-gcc && cd build-gcc
../gcc-13.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make -j$(nproc) all-gcc all-target-libgcc
make install-gcc install-target-libgcc
```

**Alternative:** If you can't build cross-compiler, modify Makefile to use system gcc:
```makefile
AS = as
CXX = g++
LD = ld
CXXFLAGS = -m32 -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -I$(INCLUDE_DIR)
```

## 🔨 Building

```bash
cd mini-os
make
```

This will:
1. Compile assembly bootloader
2. Compile C++ kernel code
3. Link into kernel binary
4. Create bootable ISO image

## ▶️ Running

```bash
make run
```

You should see:
```
========================================
  MOVRAX - Mini Persistent Memory OS - v0.1
========================================

Kernel loaded successfully!

Concept:
This OS uses a persistent memory model where
RAM and filesystem are unified. Files are just
memory-mapped regions - no explicit save/load!

Phase 1: Bootable Kernel [COMPLETE]
Phase 2: Memory Management [TODO]
Phase 3: Persistent Filesystem [TODO]
Phase 4: Text Editor [TODO]

System halted. Press Ctrl+C in QEMU to exit.
```

## 🐛 Debugging

```bash
# Terminal 1: Start QEMU with GDB server
make debug

# Terminal 2: Connect GDB
i686-elf-gdb kernel.bin
(gdb) target remote localhost:1234
(gdb) break kernel_main
(gdb) continue
```

## 📁 Project Structure

```
mini-os/
├── src/
│   ├── boot/
│   │   ├── boot.asm          # Multiboot entry, stack setup
│   │   └── grub.cfg          # GRUB menu configuration
│   ├── kernel/
│   │   ├── kernel.cpp        # Main kernel code
│   │   ├── vga.cpp           # VGA text mode driver
│   │   └── vga.h
│   └── include/
│       └── types.h           # Basic type definitions
├── linker.ld                 # Memory layout script
├── Makefile                  # Build system
└── README.md
```

## 🧠 Architecture Overview

```
Boot Process:
┌─────────────┐
│ GRUB        │
│ (Multiboot) │
└──────┬──────┘
       │
       v
┌─────────────┐
│ boot.asm    │ - Set up stack
│             │ - Call kernel_main
└──────┬──────┘
       │
       v
┌─────────────┐
│ kernel.cpp  │ - Initialize VGA
│             │ - Print messages
└─────────────┘
```

## 🎓 Learning Resources

- [OSDev Wiki](https://wiki.osdev.org/) - Comprehensive OS development guide
- [Writing a Simple Operating System from Scratch](https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf) - Excellent tutorial
- [Intel x86 Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) - Hardware reference

## 🤝 Contributing

This is a learning project! Feel free to:
- Open issues for questions
- Submit PRs for improvements
- Fork and experiment

## 📝 Next Steps

**For Phase 2 (Memory Management):**
1. Implement page frame allocator
2. Set up paging (identity map kernel)
3. Create persistent memory region
4. Add basic disk I/O (ATA PIO mode)

**Want to help?** Check the issues tab!

## 📄 License

MIT License - See LICENSE file

---

**Star ⭐ this repo if you find it interesting!**

Built with ❤️ as a demonstration of persistent memory concepts in OS design.