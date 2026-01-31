#!/bin/bash
# Setup script for Mini Persistent Memory OS

echo "========================================="
echo "MOVRAX - Setup Script"
echo "========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${YELLOW}Warning: This script is designed for Linux. You may need to adapt for your OS.${NC}"
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Checking dependencies..."
echo ""

# Check for QEMU
echo -n "Checking for QEMU... "
if command_exists qemu-system-i386; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    echo "  Install with: sudo apt install qemu-system-x86"
    MISSING_DEPS=1
fi

# Check for GRUB tools
echo -n "Checking for grub-mkrescue... "
if command_exists grub-mkrescue; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    echo "  Install with: sudo apt install grub-pc-bin xorriso"
    MISSING_DEPS=1
fi

# Check for xorriso
echo -n "Checking for xorriso... "
if command_exists xorriso; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    echo "  Install with: sudo apt install xorriso"
    MISSING_DEPS=1
fi

# Check for cross-compiler
echo -n "Checking for i686-elf-gcc... "
if command_exists i686-elf-gcc; then
    echo -e "${GREEN}✓ Found${NC}"
    CROSS_COMPILER=1
else
    echo -e "${YELLOW}✗ Not found${NC}"
    echo "  You can either:"
    echo "  1. Build cross-compiler (see README)"
    echo "  2. Use system gcc with -m32 flag"
fi

# Check for system gcc if cross-compiler not found
if [ -z "$CROSS_COMPILER" ]; then
    echo -n "Checking for system gcc... "
    if command_exists gcc; then
        echo -e "${GREEN}✓ Found${NC}"
        echo -n "Checking for 32-bit support... "
        if dpkg -l | grep -q gcc-multilib; then
            echo -e "${GREEN}✓ Found${NC}"
            echo ""
            echo -e "${YELLOW}Would you like to configure Makefile for system gcc? (y/n)${NC}"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                cp Makefile Makefile.backup
                sed -i 's/i686-elf-as/as/g' Makefile
                sed -i 's/i686-elf-g++/g++/g' Makefile
                sed -i 's/i686-elf-ld/ld/g' Makefile
                sed -i 's/CXXFLAGS = -ffreestanding/CXXFLAGS = -m32 -ffreestanding/g' Makefile
                sed -i 's/LDFLAGS = -T linker.ld/LDFLAGS = -m elf_i386 -T linker.ld/g' Makefile
                echo -e "${GREEN}✓ Makefile configured for system gcc${NC}"
                echo "  (Backup saved as Makefile.backup)"
            fi
        else
            echo -e "${RED}✗ Not found${NC}"
            echo "  Install with: sudo apt install gcc-multilib g++-multilib"
            MISSING_DEPS=1
        fi
    else
        echo -e "${RED}✗ Not found${NC}"
        echo "  Install with: sudo apt install build-essential"
        MISSING_DEPS=1
    fi
fi

echo ""
echo "========================================="
if [ -z "$MISSING_DEPS" ]; then
    echo -e "${GREEN}All dependencies satisfied!${NC}"
    echo ""
    echo "Try building the OS:"
    echo "  make"
    echo ""
    echo "Then run it:"
    echo "  make run"
else
    echo -e "${RED}Some dependencies are missing.${NC}"
    echo ""
    echo "On Ubuntu/Debian, install everything with:"
    echo "  sudo apt update"
    echo "  sudo apt install build-essential qemu-system-x86 grub-pc-bin xorriso gcc-multilib g++-multilib"
fi
echo "========================================="