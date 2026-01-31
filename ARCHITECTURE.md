# Architecture Documentation

## Overview

This document explains the technical architecture of Mini Persistent Memory OS and the design decisions behind it.

## Memory Model

### Traditional OS Model
```
┌─────────────┐     ┌─────────────┐
│     RAM     │     │    Disk     │
│  (Volatile) │     │(Persistent) │
├─────────────┤     ├─────────────┤
│   Buffers   │◄───►│    Files    │
│   Cache     │     │  Metadata   │
└─────────────┘     └─────────────┘
     ▲                    ▲
     └────────┬───────────┘
              │
         File I/O API
    (open/read/write/close)
```

### Our Persistent Memory Model
```
┌─────────────────────────────────┐
│      Unified Address Space      │
├─────────────────────────────────┤
│ 0x00000000 - 0x00100000: Kernel │
│ 0x00100000 - 0xC0000000: Free   │
│ 0xC0000000 - 0xC0100000: PersFS │◄── Memory-mapped
└─────────────────────────────────┘    to disk!
              ▲
              │ Direct memory access
         (no explicit I/O)
```

## Boot Process

### Stage 1: BIOS/UEFI
1. Power on
2. BIOS loads bootloader (GRUB) from disk
3. GRUB reads `grub.cfg`

### Stage 2: GRUB (Bootloader)
```
┌──────────────┐
│ GRUB         │
│ - Parse menu │
│ - Load kernel│
│ - Set up     │
│   Multiboot  │
└──────┬───────┘
       │
       ▼
```

### Stage 3: Multiboot Header
```asm
.set MAGIC, 0x1BADB002
.long MAGIC
.long FLAGS
.long CHECKSUM
```

GRUB searches first 8KB of kernel for this header. If found, it:
- Loads kernel to 1MB physical address
- Switches to 32-bit protected mode
- Passes control to `_start`

### Stage 4: Boot Assembly (boot.asm)
```asm
_start:
    mov $stack_top, %esp  # Set ESP to our stack
    call kernel_main      # Jump to C++
```

**Why we need assembly:**
- Stack pointer isn't initialized
- Can't call C++ without a valid stack
- Need to set up execution environment

### Stage 5: Kernel Main (kernel.cpp)
```cpp
extern "C" void kernel_main() {
    terminal.initialize();
    // ... rest of kernel ...
}
```

Now we're in C++!

## Memory Layout (Current)

```
Physical Memory:
┌─────────────────────┬──────────────┐
│  Address Range      │  Usage       │
├─────────────────────┼──────────────┤
│ 0x00000000-0x000400 │ IVT (unused) │
│ 0x00000400-0x000500 │ BDA (unused) │
│ 0x00007C00-0x00007E00│ Boot Sector  │
│ 0x00100000-0x????   │ Kernel       │
│ 0x000B8000-0x000C000│ VGA Text Mem │
└─────────────────────┴──────────────┘

Virtual Memory: (Phase 2)
┌─────────────────────┬──────────────┐
│  Address Range      │  Usage       │
├─────────────────────┼──────────────┤
│ 0x00000000-0x00100000│ Identity Map │
│ 0x00100000-0xC0000000│ User Space   │
│ 0xC0000000-0xC0100000│ Persistent FS│
│ 0xC0100000-0xFFFFFFFF│ Kernel Space │
└─────────────────────┴──────────────┘
```

## Compilation Process

### 1. Compile Assembly
```bash
i686-elf-as boot.asm -o boot.o
```
- Assembles x86 instructions
- Creates object file with symbols

### 2. Compile C++
```bash
i686-elf-g++ -ffreestanding -c kernel.cpp -o kernel.o
```
- `-ffreestanding`: No standard library
- `-fno-exceptions`: Disable C++ exceptions (needs runtime support)
- `-fno-rtti`: Disable runtime type info (needs runtime support)

### 3. Link
```bash
i686-elf-ld -T linker.ld -o kernel.bin boot.o kernel.o vga.o
```

Linker script (`linker.ld`) controls:
- Where sections go in memory
- Entry point (`_start`)
- Alignment (4KB for pages)

### 4. Create ISO
```bash
grub-mkrescue -o mini-os.iso isodir
```
- Packages kernel + GRUB into bootable CD image
- ISO can boot in QEMU or real hardware

## VGA Text Mode

### Memory Layout
```
Address: 0xB8000
┌────┬────┬────┬────┬─────┬─────┐
│ C0 │ A0 │ C1 │ A1 │ C2  │ A2  │ ...
└────┴────┴────┴────┴─────┴─────┘
  H    07   e    07    l     07
 Char Color Char Color Char Color

Color byte format:
┌────┬────┬────┬────┬────┬────┬────┬────┐
│ 7  │ 6  │ 5  │ 4  │ 3  │ 2  │ 1  │ 0  │
├────┴────┴────┴────┼────┴────┴────┴────┤
│   Background      │   Foreground      │
└───────────────────┴───────────────────┘
```

80 columns × 25 rows = 2000 characters = 4000 bytes

### Why 0xB8000?
Hardware convention. VGA card is mapped to this address in PC architecture.

## C++ in Kernel

### No Standard Library!
We can't use:
- `iostream` (needs OS)
- `new`/`delete` (no heap yet)
- `std::string` (needs heap)
- Exceptions (need unwinding support)

We CAN use:
- Classes and objects
- Templates
- Constructors/destructors (with care)
- Basic operators

### Static Objects
```cpp
VGATerminal terminal;  // Global object
```

Global constructors need special handling. Linker script provides:
```ld
.init_array : {
    __init_array_start = .;
    *(.init_array)
    __init_array_end = .;
}
```

We'd need to call these in `_start` (Phase 2).

## Design Decisions

### Why GRUB instead of custom bootloader?
- Bootloaders are complex (switch to protected mode, load from disk, etc.)
- GRUB is battle-tested and well-documented
- Focus on interesting parts (persistent memory), not boilerplate

### Why i686 (32-bit) instead of x86_64?
- Simpler page tables (2 levels vs 4)
- More tutorials/resources available
- Concept works the same in 64-bit

### Why C++ instead of C?
- Classes make code cleaner (VGATerminal is nicer than bunch of functions)
- Modern C++ features (RAII, templates) help in later phases
- Demonstrates C++ works in kernel context

### Why VGA text mode?
- Framebuffer is more complex
- Good enough for text editor
- Can add graphics later if desired

## Future Architecture (Phase 2-4)

### Phase 2: Memory Management
```cpp
class PageFrameAllocator {
    Bitmap free_frames;
    void* alloc_frame();
    void free_frame(void* frame);
};

class PageTable {
    uint32_t* directory;
    void map(void* virt, void* phys, uint32_t flags);
    void unmap(void* virt);
};
```

### Phase 3: Persistent Filesystem
```cpp
class PersistentFS {
    void* base_addr;  // 0xC0000000
    
    struct FileEntry {
        char name[32];
        uint32_t offset;
        uint32_t size;
    };
    
    FileEntry* find_file(const char* name);
    char* get_file_data(FileEntry* entry);
};
```

### Phase 4: Text Editor
```cpp
class TextEditor {
    char* buffer;  // Points into persistent memory!
    
    void insert(char c);
    void delete_char();
    void move_cursor(Direction d);
    // No save() - changes persist automatically!
};
```

## Security Considerations

**Current:** None - single user, no protection

**Future (if desired):**
- User/kernel mode separation (ring 3/ring 0)
- Page-level permissions (read/write/execute)
- Capability-based access to persistent regions

## Performance Considerations

**Current:** Not optimized - proof of concept

**Optimizations for future:**
- Lazy disk sync (dirty page tracking)
- Write coalescing (batch small writes)
- Copy-on-write for file versioning
- Compression for persistent region

## Testing Strategy

### Unit Tests
- Run kernel functions in userspace
- Mock VGA memory with regular array
- Test filesystem operations

### Integration Tests
- Boot in QEMU
- Automated testing with expect scripts
- Verify persistence across reboots

### Debugging
```bash
# Terminal 1
make debug

# Terminal 2
gdb kernel.bin
(gdb) target remote :1234
(gdb) break kernel_main
(gdb) continue
(gdb) layout asm
```

## Further Reading

- **Intel Manual Vol 3A**: Memory management
- **OSDev Wiki**: Comprehensive OS dev resource
- **GRUB Manual**: Multiboot specification
- **AMD64 Manual**: 64-bit architecture (future)

---

Questions? Open an issue on GitHub!