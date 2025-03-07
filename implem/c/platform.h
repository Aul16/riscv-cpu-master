
#ifndef INCLUDE_PLATFORM_H
#define INCLUDE_PLATFORM_H

#define LOWRES

#ifdef LOWRES
/* 720p60 configuration
 * */

#define VRAM_WIDTH 1280
#define VRAM_HEIGHT 720
#define REFRESH_RATE 60

#else
/* 1080p30 configuration
 * */

#define VRAM_WIDTH 1920
#define VRAM_HEIGHT 1080
#define REFRESH_RATE 30

#endif

#define VRAM ((Color *)0x80000000)
#define INPUT ((volatile const int *)0x30000008)
#define TIMER_LO ((volatile const unsigned int *)0x0200BFF8)
#define TIMER_HI ((volatile const unsigned int *)0x0200BFFC)

#define SCREEN_WIDTH VRAM_WIDTH
#define SCREEN_HEIGHT VRAM_HEIGHT

#define IMASK_B1 0x00010000
#define IMASK_B2 0x00020000
#define IMASK_B3 0x00040000

// fourni par bootstrap.s
void WAIT();

#endif
