#include "graphics.h"

#include "gfx_data.c"

void clear_vram(Color col) {

  for (int i = 0; i < VRAM_WIDTH * VRAM_HEIGHT; i++) {
    VRAM[i] = col;
  }
}

void draw_filled_rectangle(int x1, int y1, int x2, int y2, Color col) {
  int t;
  if (x1 > x2) {
    t = x1;
    x1 = x2;
    x2 = t;
  }
  if (y1 > y2) {
    t = y1;
    y1 = y2;
    y2 = t;
  }

  Color *ptr = VRAM + VRAM_WIDTH * y1 + x1;
  for (int y = y1; y < y2; y++, ptr += VRAM_WIDTH + (x1 - x2))
    for (int x = x1; x < x2; x++, ptr += 1) {
      ptr[0] = col;
    }
}

void draw_ibuffer(int x, int y, int w, int h, const u8 *buf, const Color *pal) {
  Color *ptr = VRAM + VRAM_WIDTH * y + x;
  for (int y = 0; y < h; y++, ptr += VRAM_WIDTH - w)
    for (int x = 0; x < w; x++, ptr += 1, buf += 1) {
      if (buf[0] > 0) {
        ptr[0] = pal[buf[0] - 1];
      }
    }
}
unsigned int __mulsi3(unsigned int a, unsigned int b) {
  unsigned int r = 0;

  while (a) {
    if (a & 1)
      r += b;
    a >>= 1;
    b <<= 1;
  }
  return r;
}

void draw_ibuffer_scale(int x, int y, int w, int h, const u8 *buf,
                        const Color *pal, int scale) {
  Color *ptr = VRAM + VRAM_WIDTH * y + x;
  Color *lstart = ptr;

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {

      if (buf[0] > 0) {
        for (int sx = 0; sx < scale; sx++, ptr += 1) {
          for (int sy = 0; sy < scale; sy++) {
            ptr[sy * VRAM_WIDTH] = pal[buf[0] - 1];
          }
        }

      } else {
        ptr += scale;
      }

      buf += 1;
    }

    lstart += VRAM_WIDTH * scale;
    ptr = lstart;
  }
}
