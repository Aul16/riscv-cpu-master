
#include "util.h"

#define ENEMY_SPRITE_BW 11
#define ENEMY_SPRITE_BH 8
#define ENEMY_SPRITE_PAL_SIZE 2

#define X 1
#define A 2

const u8 ENEMY_SPRITE[] = {
    0, 0, X, 0, 0, 0, 0, 0, X, 0, 0,
    0, 0, 0, X, 0, 0, 0, X, 0, 0, 0,
    0, 0, X, X, X, X, X, X, X, 0, 0,
    0, X, X, A, X, X, X, A, X, X, 0,
    X, X, X, X, X, X, X, X, X, X, X,
    X, 0, X, X, X, X, X, X, X, 0, X,
    X, 0, X, 0, 0, 0, 0, 0, X, 0, X,
    0, 0, 0, X, X, 0, X, X, 0, 0, 0,
};

#define SHIP_SPRITE_BW 16
#define SHIP_SPRITE_BH 8
#define SHIP_SPRITE_PAL_SIZE 2

const u8 SHIP_SPRITE[] = {
    0, 0, 0, 0, 0, X, X, X, X, X, X, 0, 0, 0, 0, 0,
    0, 0, 0, X, X, X, X, X, X, X, X, X, X, 0, 0, 0,
    0, 0, X, X, X, X, X, X, X, X, X, X, X, X, 0, 0,
    0, X, X, A, X, X, A, X, X, A, X, X, A, X, X, 0,
    X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X,
    0, 0, X, X, X, 0, 0, X, X, 0, 0, X, X, X, 0, 0,
    0, 0, 0, X, 0, 0, 0, 0, 0, 0, 0, 0, X, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
};
