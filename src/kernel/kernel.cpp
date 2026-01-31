#include "vga.h"

// Kernel entry point called from boot.asm
extern "C" void kernel_main() {
    // Initialize VGA terminal
    terminal.initialize();
    
    // Display welcome message
    terminal.set_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);
    terminal.write_string("========================================\n");
    terminal.write_string("  MOVRAX - Mini Persistent Memory OS - v0.1\n");
    terminal.write_string("========================================\n\n");
    
    terminal.set_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    terminal.write_string("Kernel loaded successfully!\n\n");
    
    // Explain the concept
    terminal.set_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
    terminal.write_string("Concept:\n");
    terminal.set_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    terminal.write_string("This OS uses a persistent memory model where\n");
    terminal.write_string("RAM and filesystem are unified. Files are just\n");
    terminal.write_string("memory-mapped regions - no explicit save/load!\n\n");
    
    // Show status
    terminal.set_color(VGA_COLOR_YELLOW, VGA_COLOR_BLACK);
    terminal.write_string("Phase 1: ");
    terminal.set_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    terminal.write_string("Bootable Kernel ");
    terminal.set_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
    terminal.write_string("[COMPLETE]\n");
    
    terminal.set_color(VGA_COLOR_YELLOW, VGA_COLOR_BLACK);
    terminal.write_string("Phase 2: ");
    terminal.set_color(VGA_COLOR_DARK_GREY, VGA_COLOR_BLACK);
    terminal.write_string("Memory Management [TODO]\n");
    
    terminal.set_color(VGA_COLOR_YELLOW, VGA_COLOR_BLACK);
    terminal.write_string("Phase 3: ");
    terminal.set_color(VGA_COLOR_DARK_GREY, VGA_COLOR_BLACK);
    terminal.write_string("Persistent Filesystem [TODO]\n");
    
    terminal.set_color(VGA_COLOR_YELLOW, VGA_COLOR_BLACK);
    terminal.write_string("Phase 4: ");
    terminal.set_color(VGA_COLOR_DARK_GREY, VGA_COLOR_BLACK);
    terminal.write_string("Text Editor [TODO]\n\n");
    
    terminal.set_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);
    terminal.write_string("System halted. Press Ctrl+C in QEMU to exit.\n");
    
    // Halt the CPU
    while(1) {
        asm volatile("hlt");
    }
}