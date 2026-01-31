#include "vga.h"

VGATerminal terminal;

VGATerminal::VGATerminal() 
    : row(0), column(0), color(0), buffer(nullptr) {
}

void VGATerminal::initialize() {
    row = 0;
    column = 0;
    color = make_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    buffer = (uint16_t*)VGA_MEMORY;
    clear();
}

uint8_t VGATerminal::make_color(VGAColor fg, VGAColor bg) {
    return fg | bg << 4;
}

uint16_t VGATerminal::make_vga_entry(char c, uint8_t color) {
    return (uint16_t)c | (uint16_t)color << 8;
}

void VGATerminal::set_color(VGAColor fg, VGAColor bg) {
    color = make_color(fg, bg);
}

void VGATerminal::clear() {
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            buffer[index] = make_vga_entry(' ', color);
        }
    }
    row = 0;
    column = 0;
}

void VGATerminal::scroll() {
    // Move all rows up by one
    for (size_t y = 0; y < VGA_HEIGHT - 1; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            buffer[y * VGA_WIDTH + x] = buffer[(y + 1) * VGA_WIDTH + x];
        }
    }
    
    // Clear the last row
    for (size_t x = 0; x < VGA_WIDTH; x++) {
        buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = make_vga_entry(' ', color);
    }
    
    row = VGA_HEIGHT - 1;
}

void VGATerminal::putchar(char c) {
    if (c == '\n') {
        column = 0;
        if (++row == VGA_HEIGHT) {
            scroll();
        }
        return;
    }
    
    if (c == '\t') {
        column = (column + 4) & ~(4 - 1);
        if (column >= VGA_WIDTH) {
            column = 0;
            if (++row == VGA_HEIGHT) {
                scroll();
            }
        }
        return;
    }
    
    const size_t index = row * VGA_WIDTH + column;
    buffer[index] = make_vga_entry(c, color);
    
    if (++column == VGA_WIDTH) {
        column = 0;
        if (++row == VGA_HEIGHT) {
            scroll();
        }
    }
}

void VGATerminal::write(const char* data, size_t size) {
    for (size_t i = 0; i < size; i++) {
        putchar(data[i]);
    }
}

void VGATerminal::write_string(const char* data) {
    size_t len = 0;
    while (data[len]) len++;
    write(data, len);
}