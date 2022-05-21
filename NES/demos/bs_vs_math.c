#include <stdlib.h>
#include <string.h>

// include NESLIB header
#include "neslib.h"

#include "bcd.h"

// include CC65 NES Header (PPU)
#include <nes.h>

///// METASPRITES

const unsigned char bs_Right1[] =
{
  0 , 0 , 0xe0,  0,
  0 , 8 , 0xe1,  0,
  8 , 0 , 0xe2,  0,
  8 , 8 , 0xe3,  0,
  128
};

const unsigned char bs_Right2[] =
{
  0 , 0 , 0xdc,  0,
  0 , 8 , 0xdd,  0,
  8 , 0 , 0xde,  0,
  8 , 8 , 0xdf,  0,
  128
};

const unsigned char bs_Left1[] =
{
  0 , 0 , 0xde,  0 | 0x70,
  0 , 8 , 0xdf,  0 | 0x70, 
  8 , 0 , 0xdc,  0 | 0x70,
  8 , 8 , 0xdd,  0 | 0x70,
  128
};

const unsigned char bs_Left2[] =
{
  0 , 0 , 0xe2,  0 | 0x70,
  0 , 8 , 0xe3,  0 | 0x70,
  8 , 0 , 0xe0,  0 | 0x70,
  8 , 8 , 0xe1,  0 | 0x70,
  128
};


const unsigned char * const bs_SeqRight[2] = 
{
  bs_Right1,bs_Right2
};

const unsigned char * const bs_SeqLeft[2] = 
{
  bs_Left1,bs_Left2
};

#define MAX_NUMBERS 5
#define MAX_MISSILES 3

typedef struct 
{
  short xpos, ypos;
  unsigned char speed;
  char visible;
  unsigned char value;
} t_sprite;

t_sprite enemy_numbers[MAX_NUMBERS];
t_sprite missiles[MAX_MISSILES];

/*{pal:"nes",layout:"nes"}*/
const char PALETTE[32] = { 
  0x0f,			// screen color

  0x11,0x30,0x27,0x00,	// background palette 0
  0x1C,0x20,0x0a,0x00,	// background palette 1
  0x00,0x10,0x20,0x00,	// background palette 2
  0x06,0x16,0x26,0x00,	// background palette 3

  0x11,0x30,0x27,0x00,	// sprite palette 0
  0x00,0x37,0x2a,0x00,	// sprite palette 1
  0x0D,0x2D,0x3A,0x00,	// sprite palette 2
  0x0D,0x27,0x2A	      // sprite palette 3
};

const char ATTRIBUTE_TABLE1[0x40] = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 0-3
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 4-7
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 8-11
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 12-15
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 16-19
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 20-23
  0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, // rows 24-27
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // rows 28-29
};

// Global Variables

char oam_id;	// sprite ID
char pad;	// controller flags
unsigned char bs_xpos = 12 * 8;
unsigned char bs_ypos = 24 * 8;
char bs_xdiff = 0;
char bs_ydiff = 0;
char moving = false;
char seq = 0;
const char *anim_frame;
char frame_counter = 1;
short i,j;
char missile_cooldown = 0;
char collision = false;
word score = 0;
unsigned char number_color = 0x2a;
char color_frame_counter = 5;

// setup PPU and tables
void setup_graphics() {
  // clear sprites
  oam_hide_rest(0);
  // set palette colors
  pal_all(PALETTE);

  vram_adr(NAMETABLE_A + 0x3c0);
  vram_write(ATTRIBUTE_TABLE1, sizeof(ATTRIBUTE_TABLE1));

  anim_frame = bs_SeqRight[0];

  // turn on PPU
  ppu_on_all();
}

void reset_number(t_sprite *number)
{
  number->xpos = 8 + ((short)rand())%240;
  number->ypos = 20;
  number->value = '1' + ((short)rand())%9;
  number->speed = 1 + ((short)rand())%4;
}

void setup_numbers()
{
  short i;

  for (i=0;i<MAX_NUMBERS;i++)
  {
    reset_number(&enemy_numbers[i]);
    enemy_numbers[i].value = '1' + i;
    enemy_numbers[i].visible = i < 4;
  }
}

void setup_missiles()
{
  short i;

  for (i=0;i<MAX_MISSILES;i++)
  {
    missiles[i].xpos = missiles[i].ypos = 0;
    missiles[i].value = 0xb7;
    missiles[i].visible = false;
    missiles[i].speed = 2;
  }
}

char in_rect(short x, short y, short x0, short y0, byte w, byte h) {
  return x-x0 < w && y-y0 < h;
}

void draw_bcd_word(byte col, byte row, word bcd) {
  char buff[4] = {'0','0','0','0'};

  buff[3] = '0' + (bcd & 0xf);
  bcd>>=4;
  buff[2] = '0' + (bcd & 0xf);
  bcd>>=4;
  buff[1] = '0' + (bcd & 0xf);
  bcd>>=4;
  buff[0] = '0' + (bcd & 0xf);

  vram_adr(NTADR_A(col, row));
  vram_write(buff, 4);
  vram_adr(0);
}

void print_score(byte row, byte col, int score)
{
  char score_buff[8];
  itoa(score, score_buff, 10);
  vram_adr(NTADR_A(col, row));
  vram_write(score_buff, strlen(score_buff));
  vram_adr(0);
  scroll(0,0);
}

void move_bs()
{
  if (pad & PAD_LEFT && bs_xpos > 8)
    {
      bs_xdiff = -1;
      moving = true;
      anim_frame = bs_SeqLeft[seq];
      
    } else if (pad & PAD_RIGHT && bs_xpos < 232)
    {
      bs_xdiff = 1;
      moving = true;
      anim_frame = bs_SeqRight[seq];

    } else 
      bs_xdiff = 0;
    
    if (++frame_counter == 5)
    {
      if (moving)
        seq = (seq + 1) % 2;
      
      frame_counter = 0;
    }

    bs_xpos+=bs_xdiff;
    bs_ypos+=bs_ydiff;

    oam_id = oam_meta_spr(bs_xpos, bs_ypos, oam_id, anim_frame);   
}

void check_missile_fired()
{
  if (missile_cooldown > 0)
    missile_cooldown--;

  if (pad & PAD_A && !missile_cooldown)
    for (i=0;i<MAX_MISSILES;i++)
      if (!missiles[i].visible)
      {
        missiles[i].xpos = bs_xpos;
        missiles[i].ypos = bs_ypos;
        missiles[i].visible = true;
        missile_cooldown = 6;
        break;
      }
}

void draw_missiles()
{
  for (i=0; i<MAX_MISSILES; i++)
    {
      if (missiles[i].visible)
      {
        if (missiles[i].ypos < 0)
        { 
          missiles[i].visible = false;
          continue;
        }

        oam_id = oam_spr(missiles[i].xpos, missiles[i].ypos, missiles[i].value, 0, oam_id);
        missiles[i].ypos -= missiles[i].speed;
      }
    }
}

void check_collisions()
{
  for (i=0;i<MAX_MISSILES;i++)
    if (missiles[i].visible)
      for (j=0;j<MAX_NUMBERS;j++)
        if (enemy_numbers[j].visible)
        {
          if (in_rect(missiles[i].xpos, missiles[i].ypos, enemy_numbers[j].xpos-8, enemy_numbers[j].ypos, 16, 16))
          {
            missiles[i].visible = false;
            score = bcd_add(score, enemy_numbers[j].value - '0');
            reset_number(&enemy_numbers[j]);
            collision = true;
            break;
          }
        }
}

void check_if_numbers_landed()
{
  for (i=0;i<MAX_NUMBERS;i++)
      if (enemy_numbers[i].visible)
      {
        oam_id = oam_spr(enemy_numbers[i].xpos, enemy_numbers[i].ypos, enemy_numbers[i].value, 1, oam_id);
        enemy_numbers[i].ypos += enemy_numbers[i].speed;

        if (enemy_numbers[i].ypos >= 208)
          reset_number(&enemy_numbers[i]);
      }
}

void draw_floor()
{
  vram_adr(NTADR_A(0,26));
  vram_fill(3,32);
}

void shine_numbers()
{
  if (--color_frame_counter == 0)
  {
    number_color^=0x10;
    vram_adr(0x3f00 + 23);
    vram_put(number_color);
    color_frame_counter = 5;
  }
}

void main() {
  draw_floor();
  
  setup_numbers();
  setup_missiles();

  setup_graphics();

  
  
  // loop forever
  while (1) {
    oam_id = 0;
    shine_numbers();
    draw_bcd_word(2, 2, score);
    moving = false;
    
    pad = pad_poll(0);
    
    move_bs();
    
    check_missile_fired();
    draw_missiles();

    check_collisions();

    check_if_numbers_landed();

    oam_hide_rest(oam_id);
    
    // wait for next frame*/
    ppu_wait_frame();
  }
}
