
#include "graphics.h"
#include "platform.h"
#include "util.h"

#include "gameover.c"
#include "sprites.c"

#define FRAME_TIME 0x400000
#define BG_COLOR BLACK
#define SIDE_COLOR DARK_GREY

#define GAMEOVER_SCALE 16
#define GAMEOVER_LEFT ((SCREEN_WIDTH - GAMEOVER_SCALE * GAMEOVER_TEXT_BW) / 2)

#define FINAL_SCORE_SCALE 8
#define FINAL_SCORE_LEFT ((SCREEN_WIDTH - FINAL_SCORE_SCALE * 8 * 8) / 2)

#define ENEMY_COUNT 10
#define SPAWN_FREQ 16
#define EN_WIDTH 1024
#define EN_LEFT ((SCREEN_WIDTH - EN_WIDTH) / 2)
#define DIFFICULTY_BASE 8
#define DIFFICULTY_SCALE 16

#define PLAYER_SCALE 4
#define PLAYER_W (PLAYER_SCALE * SHIP_SPRITE_BW)
#define PLAYER_H (PLAYER_SCALE * SHIP_SPRITE_BH)
#define PLAYER_Y (SCREEN_HEIGHT - PLAYER_H)
#define PLAYER_INIT_X (SCREEN_WIDTH / 2 - PLAYER_W / 2)
#define PLAYER_PAL {WHITE, BLUE}
#define PLAYER_SPEED 30

#define BULLET_H 50
#define BULLET_W 8
#define BULLET_INIT_Y (SCREEN_HEIGHT - BULLET_H - PLAYER_H)
#define BULLET_INIT_X (SCREEN_WIDTH / 2 - BULLET_W / 2)
#define BULLET_SPEED 40

#define ENEMY_SPRITE_S 6
#define ENEMY_W (ENEMY_SPRITE_BW * ENEMY_SPRITE_S)
#define ENEMY_H (ENEMY_SPRITE_BH * ENEMY_SPRITE_S)
#define ENEMY_SPRITE_PAL {GREEN, RED}

_Static_assert(EN_WIDTH <= SCREEN_WIDTH,
               "EN_WIDTH doit etre plus petit que SCREEN_WIDTH");
_Static_assert(IS_POW_2(EN_WIDTH), "EN_WIDTH doit etre une puissance de 2");
_Static_assert(IS_POW_2(DIFFICULTY_SCALE),
               "DIFFICULTY_SCALE doit etre une puissance de 2");

/* ----------------------------------------------------------------- */
/*      UTILITY FUNCTIONS */
/* ----------------------------------------------------------------- */

void wait_clock(unsigned start, unsigned clks) {
  if (start == 0)
    start = *TIMER_LO;
  while (true) {
    unsigned cur = *TIMER_LO;
    if (cur - start >= clks)
      return;
  }
}

void print_hex32(int x, int y, int v, Color bg, Color fg, int scale) {
  draw_filled_rectangle(x, y - 2, x + 64 * scale, y + 10 * scale, bg);
  x += 64 * scale;
  for (int i = 0; i < 8; i++) {
    x -= scale * 8;
    draw_ibuffer_scale(x, y, 8, 8, HEX_TABLE[v & 0xF], &fg, scale);
    v >>= 4;
  }
}

u16 lfsr = 0xACE1u;
static inline void lfsr_step() {
  u16 bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1u;
  lfsr = (lfsr >> 1) | (bit << 15);
}
int random() {
  int out = 0;
  lfsr_step();
  lfsr_step();
  out |= lfsr;
  lfsr_step();
  out |= ((int)lfsr) << 16;
  return out;
}

/* ----------------------------------------------------------------- */
/*      Sprites et fonctions liées */
/* ----------------------------------------------------------------- */

typedef struct {
  int bh, bw, scale;
  const Color *pal;
  const u8 *data;
} SpriteBuf;

typedef struct {
  int x, y;
  int ox, oy;
  int w, h;
  SpriteBuf *spritebuf;
  Color col;
} Sprite;

void Sprite_draw_nohide(Sprite *sp) {
  if (sp->spritebuf) {
    draw_ibuffer_scale(sp->x, sp->y, sp->spritebuf->bw, sp->spritebuf->bh,
                       sp->spritebuf->data, sp->spritebuf->pal,
                       sp->spritebuf->scale);

  } else {
    draw_filled_rectangle(sp->x, sp->y, sp->x + sp->w, sp->y + sp->h, sp->col);
  }

  sp->ox = sp->x;
  sp->oy = sp->y;
}

void Sprite_draw(Sprite *sp, Color bg) {
  if (sp->x != sp->ox || sp->y != sp->oy || sp->ox == -1) {
    draw_filled_rectangle(sp->ox, sp->oy, sp->ox + sp->w, sp->oy + sp->h, bg);

    Sprite_draw_nohide(sp);
  }
}

void Sprite_hide(Sprite *sp, Color bg) {
  draw_filled_rectangle(sp->ox, sp->oy, sp->ox + sp->w, sp->oy + sp->h, bg);
  sp->ox = -1;
}

bool Sprite_hit(Sprite sp1, Sprite sp2) {
  return sp1.x + sp1.w >= sp2.x && sp1.x <= sp2.x + sp2.w &&
         sp1.y + sp1.h >= sp2.y && sp1.y <= sp2.y + sp2.h;
}

/* ----------------------------------------------------------------- */
/*      DATA                                                         */
/* ----------------------------------------------------------------- */

Color en_pal[2] = ENEMY_SPRITE_PAL;
SpriteBuf en_spbuf = (SpriteBuf){
    .bh = ENEMY_SPRITE_BH,
    .bw = ENEMY_SPRITE_BW,
    .scale = ENEMY_SPRITE_S,
    .pal = en_pal,
    .data = ENEMY_SPRITE,
};

Color pl_pal[2] = PLAYER_PAL;
SpriteBuf pl_spbuf = (SpriteBuf){
    .bh = SHIP_SPRITE_BH,
    .bw = SHIP_SPRITE_BW,
    .scale = PLAYER_SCALE,
    .pal = pl_pal,
    .data = SHIP_SPRITE,
};

int difficulty;

void Enemy_spawn(Sprite *en, int *speed) {
  int rnd = random() & (EN_WIDTH - 1);
  en->x = EN_LEFT + rnd;
  if (en->x < EN_LEFT)
    en->x = EN_LEFT;
  if (en->x > EN_WIDTH + EN_LEFT - en->w)
    en->x = EN_WIDTH + EN_LEFT - en->w;
  en->y = 0;
  en->ox = en->x + 1;
  en->oy = en->y;

  *speed = difficulty + (random() & 31);
}

/* ----------------------------------------------------------------- */
/*      Programme */
/* ----------------------------------------------------------------- */

int main() {

  clear_vram(BLACK);

  const Color pal[1] = {WHITE};

  Sprite player = (Sprite){
      .x = PLAYER_INIT_X,
      .y = PLAYER_Y,
      .w = PLAYER_W,
      .h = PLAYER_H,
      .spritebuf = &pl_spbuf,
      .col = WHITE,
  };

  Sprite bullet = (Sprite){
      .x = BULLET_INIT_X,
      .y = BULLET_INIT_Y,
      .w = BULLET_W,
      .h = BULLET_H,
      .spritebuf = 0,
      .col = BLUE,
  };
  bool bullet_enable = false;
  difficulty = DIFFICULTY_BASE;
  lfsr = *TIMER_LO ^ *TIMER_HI;

  Sprite enemies[ENEMY_COUNT];
  bool enemy_enable[ENEMY_COUNT];
  int enemy_speed[ENEMY_COUNT];
  for (int i = 0; i < ENEMY_COUNT; i++) {
    enemy_enable[i] = false;
    enemies[i] = (Sprite){
        .ox = -1,
        .w = ENEMY_W,
        .h = ENEMY_H,
        .spritebuf = &en_spbuf,
        .col = GREEN,
    };
  }

  Sprite_draw(&player, BG_COLOR);

  draw_filled_rectangle(0, 0, EN_LEFT, SCREEN_HEIGHT, DARK_GREY);
  draw_filled_rectangle(SCREEN_WIDTH - EN_LEFT, 0, SCREEN_WIDTH, SCREEN_HEIGHT,
                        DARK_GREY);

  int fc = 0;
  while (true) {
    u32 tstart = *TIMER_LO;
    int in = *INPUT;

    int y = *TIMER_LO;
    print_hex32(0, 0, difficulty - DIFFICULTY_BASE, SIDE_COLOR, WHITE, 2);

    if (in & IMASK_B1) {
      lfsr_step();
      player.x += PLAYER_SPEED;
      if (player.x > SCREEN_WIDTH - EN_LEFT - player.w)
        player.x = SCREEN_WIDTH - EN_LEFT - player.w;
    }
    if (in & IMASK_B2) {
      lfsr_step();
      player.x -= PLAYER_SPEED;
      if (player.x < EN_LEFT) {
        player.x = EN_LEFT;
      }
    }

    // handle bullet
    if (in & IMASK_B3 && !bullet_enable) {
      lfsr_step();
      bullet.x = player.x + player.w / 2 - bullet.w / 2;
      bullet.y = BULLET_INIT_Y;
      bullet_enable = true;
      Sprite_draw_nohide(&bullet);
    }

    if (bullet_enable) {
      bullet.y -= BULLET_SPEED;
      if (bullet.y < 0) {
        bullet_enable = false;
        Sprite_hide(&bullet, BLACK);
      } else {
        Sprite_draw(&bullet, BLACK);
      }
    }

    // spawn enemy

    bool do_spawn = fc % SPAWN_FREQ == 0;

    // handle enemies
    for (int i = 0; i < ENEMY_COUNT; i++) {
      if (do_spawn & !enemy_enable[i]) {
        enemy_enable[i] = true;
        Enemy_spawn(&enemies[i], &enemy_speed[i]);
        do_spawn = false;
      }
      if (enemy_enable[i]) {
        if (enemies[i].y >= SCREEN_HEIGHT) {

          enemy_enable[i] = false;
          Sprite_hide(&enemies[i], BLACK);

          goto GAMEOVER;

        } else if (Sprite_hit(bullet, enemies[i]) && bullet_enable) {
          bullet_enable = false;
          Sprite_hide(&bullet, BLACK);

          difficulty += 1;

          enemy_enable[i] = false;
          Sprite_hide(&enemies[i], BLACK);
        } else {
          enemies[i].y += 1 + enemy_speed[i] / DIFFICULTY_SCALE;
          Sprite_draw(&enemies[i], BLACK);
        }
      };
    }

    Sprite_draw(&player, BLACK);

    wait_clock(tstart, FRAME_TIME);
    fc += 1;
  }

GAMEOVER:
  clear_vram(RED);
  const Color goc = BLACK;
  draw_ibuffer_scale(GAMEOVER_LEFT, 100, sizeof(GAMEOVER_DATA) / 8, 8,
                     GAMEOVER_DATA, &goc, GAMEOVER_SCALE);
  print_hex32(FINAL_SCORE_LEFT, 600, difficulty - 8, RED, BLACK,
              FINAL_SCORE_SCALE);

  WAIT();
}
