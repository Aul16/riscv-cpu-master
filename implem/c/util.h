
#ifndef INCLUDE_UTIL_H
#define INCLUDE_UTIL_H

#include <stdint.h>
#include <stdbool.h>

#define false 0
#define true 1
#define NULL ((void*)0)

typedef uint32_t u32;
typedef int32_t i32;
typedef uint8_t u8;
typedef uint16_t u16;

#define IS_POW_2(x) (((x & (x-1)) == 0) && x > 0)

#endif
