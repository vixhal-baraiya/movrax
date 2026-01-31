# Makefile for Mini Persistent Memory OS

# Compiler and tools
AS = i686-elf-as
CXX = i686-elf-g++
LD = i686-elf-ld

# Directories
SRC_DIR = src
BUILD_DIR = build
BOOT_DIR = $(SRC_DIR)/boot
KERNEL_DIR = $(SRC_DIR)/kernel
INCLUDE_DIR = $(SRC_DIR)/include

# Flags
CXXFLAGS = -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -I$(INCLUDE_DIR)
LDFLAGS = -T linker.ld -nostdlib -lgcc

# Source files
ASM_SRC = $(BOOT_DIR)/boot.asm
CPP_SRC = $(wildcard $(KERNEL_DIR)/*.cpp)

# Object files
ASM_OBJ = $(BUILD_DIR)/boot.o
CPP_OBJ = $(patsubst $(KERNEL_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(CPP_SRC))
OBJ = $(ASM_OBJ) $(CPP_OBJ)

# Output
KERNEL_BIN = kernel.bin
ISO_FILE = mini-os.iso

# Default target
all: $(ISO_FILE)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Assemble boot code
$(BUILD_DIR)/boot.o: $(ASM_SRC) | $(BUILD_DIR)
	$(AS) $< -o $@

# Compile C++ files
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Link kernel
$(KERNEL_BIN): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $(OBJ)

# Create bootable ISO
$(ISO_FILE): $(KERNEL_BIN)
	mkdir -p isodir/boot/grub
	cp $(KERNEL_BIN) isodir/boot/
	cp $(BOOT_DIR)/grub.cfg isodir/boot/grub/
	grub-mkrescue -o $(ISO_FILE) isodir

# Run in QEMU
run: $(ISO_FILE)
	qemu-system-i386 -cdrom $(ISO_FILE)

# Run in QEMU with debugging enabled
debug: $(ISO_FILE)
	qemu-system-i386 -cdrom $(ISO_FILE) -s -S

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) isodir $(KERNEL_BIN) $(ISO_FILE)

.PHONY: all run debug clean