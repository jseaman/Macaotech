#include <stdlib.h>
#include <string.h>

// include NESLIB header
#include "neslib.h"

// include CC65 NES Header (PPU)
#include <nes.h>

///// METASPRITES

const unsigned char link_Right1[] =
{
  0 , 0 , 0xdc,  0,
  0 , 8 , 0xdd,  0,
  8 , 0 , 0xde,  0,
  8 , 8 , 0xdf,  0,
  128
};

const unsigned char link_Right2[] =
{
  0 , 0 , 0xe0,  0,
  0 , 8 , 0xe1,  0,
  8 , 0 , 0xe2,  0,
  8 , 8 , 0xe3,  0,
  128
};

const unsigned char link_Left1[] =
{
  0 , 0 , 0xde,  0 | 0x70,
  0 , 8 , 0xdf,  0 | 0x70, 
  8 , 0 , 0xdc,  0 | 0x70,
  8 , 8 , 0xdd,  0 | 0x70,
  128
};

const unsigned char link_Left2[] =
{
  0 , 0 , 0xe2,  0 | 0x70,
  0 , 8 , 0xe3,  0 | 0x70,
  8 , 0 , 0xe0,  0 | 0x70,
  8 , 8 , 0xe1,  0 | 0x70,
  128
};

const unsigned char link_Up1[] =
{
  0 , 0 , 0xe4,  0,
  0 , 8 , 0xe5,  0,
  8 , 0 , 0xe6,  0,
  8 , 8 , 0xe7,  0,
  128
};

const unsigned char link_Up2[] =
{
  0 , 0 , 0xe4,  0,
  0 , 8 , 0xe7,  0 | 0x70,
  8 , 0 , 0xe6,  0,
  8 , 8 , 0xe5,  0 | 0x70,
  128
};

const unsigned char link_Down1[] =
{
  0 , 0 , 0xe8,  0,
  0 , 8 , 0xe9,  0,
  8 , 0 , 0xea,  0,
  8 , 8 , 0xeb,  0,
  128
};

const unsigned char link_Down2[] =
{
  0 , 0 , 0xe8,  0,
  0 , 8 , 0xec,  0,
  8 , 0 , 0xea,  0,
  8 , 8 , 0xed,  0,
  128
};

const unsigned char * const link_SeqRight[2] = 
{
  link_Right1,link_Right2
};

const unsigned char * const link_SeqLeft[2] = 
{
  link_Left1,link_Left2
};

const unsigned char * const link_SeqUp[2] = 
{
  link_Up1,link_Up2
};

const unsigned char * const link_SeqDown[2] = 
{
  link_Down1,link_Down2
};


/*{pal:"nes",layout:"nes"}*/
const char PALETTE[32] = { 
  0x0,			// screen color

  0x11,0x30,0x27,0x00,	// background palette 0
  0x1C,0x20,0x2C,0x00,	// background palette 1
  0x00,0x10,0x20,0x00,	// background palette 2
  0x06,0x16,0x26,0x00,	// background palette 3

  0x29,0x27,0x17,0x00,	// sprite palette 0
  0x00,0x37,0x25,0x00,	// sprite palette 1
  0x0D,0x2D,0x3A,0x00,	// sprite palette 2
  0x0D,0x27,0x2A	// sprite palette 3
};

// setup PPU and tables
void setup_graphics() {
  // clear sprites
  oam_hide_rest(0);
  // set palette colors
  pal_all(PALETTE);
  // turn on PPU
  ppu_on_all();
}


void main() {
  char oam_id;	// sprite ID
  char pad;	// controller flags
  unsigned char link_xpos = 14 * 8;
  unsigned char link_ypos = 14 * 8;
  char link_xdiff = 0;
  char link_ydiff = 0;
  char moving_hor = false;
  char moving_ver = false;
  char hor_seq = 0;
  char ver_seq = 0;
  const char *anim_frame = link_SeqRight[0];
  char frame_counter = 1;
  
  
  setup_graphics();
  
  // loop forever
  while (1) {
    moving_hor = moving_ver = false;
    
    pad = pad_poll(0);
    
    if (pad & PAD_LEFT)
    {
      link_xdiff = -1;
      moving_hor = true;
      anim_frame = link_SeqLeft[hor_seq];
      
    } else if (pad & PAD_RIGHT)
    {
      link_xdiff = 1;
      moving_hor = true;
      anim_frame = link_SeqRight[hor_seq];

    } else 
      link_xdiff = 0;
    
    if (pad & PAD_UP)
    {
      link_ydiff = -1;
      moving_ver = true;
      
      if (!moving_hor)
        anim_frame = link_SeqUp[ver_seq];
    }
    else if (pad & PAD_DOWN)
    {
      link_ydiff = 1;
      moving_ver = true;
      
      if (!moving_hor)
        anim_frame = link_SeqDown[ver_seq];
    }
    else
      link_ydiff = 0;
    
    if (++frame_counter == 5)
    {
      if (moving_hor)
        hor_seq = (hor_seq + 1) % 2;
      else if (moving_ver)
        ver_seq = (ver_seq + 1) % 2;
      
      frame_counter = 0;
    }
    
    
    link_xpos+=link_xdiff;
    link_ypos+=link_ydiff;
    
    oam_id = 0;
    oam_id = oam_meta_spr(link_xpos, link_ypos, oam_id, anim_frame);   
    
    // wait for next frame*/
    ppu_wait_frame();
  }
}
