
#include "platform.h"
#include "util.h"

#ifndef INCLUDE_GRAPHICS_H
#define INCLUDE_GRAPHICS_H



typedef unsigned Color;

void clear_vram(Color color);
void draw_filled_rectangle(int x1, int y1, int x2, int y2, Color color);
void draw_ibuffer(int x, int y, int w, int h, const u8 *buf, const Color* palette);
void draw_ibuffer_scale(int x, int y, int w, int h, const u8 *buf, const Color* palette, int scale);


#define WHITE 0xFFFFFFFF
#define BLACK 0xFF000000
#define RED   0xFFFF0000
#define BLUE  0xFF0000FF
#define GREEN 0xFF00FF00
#define DARK_GREY 0xFF555555

extern const u8 HEX_TABLE[16][64];
extern const u8 SPACE[64];


static inline int alpha(Color c) {
    return (c >> 24) & 0xFF;
}

static inline void assert_gfx(int cnd, Color c) {
    if (!cnd) clear_vram(c);
}

#endif
