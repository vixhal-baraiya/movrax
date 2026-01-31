#ifndef VGA_H
#define VGA_H

#include "types.h"

// VGA text mode colors
enum VGAColor {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
};

// VGA terminal interface
class VGATerminal {
private:
    static const size_t VGA_WIDTH = 80;
    static const size_t VGA_HEIGHT = 25;
    static const uint32_t VGA_MEMORY = 0xB8000;
    
    size_t row;
    size_t column;
    uint8_t color;
    uint16_t* buffer;
    
    uint8_t make_color(VGAColor fg, VGAColor bg);
    uint16_t make_vga_entry(char c, uint8_t color);
    void scroll();

public:
    VGATerminal();
    void initialize();
    void set_color(VGAColor fg, VGAColor bg);
    void clear();
    void putchar(char c);
    void write(const char* data, size_t size);
    void write_string(const char* data);
};

// Global terminal instance
extern VGATerminal terminal;

#endif // VGA_H