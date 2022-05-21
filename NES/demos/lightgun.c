#include <stdlib.h>
#include <string.h>

// include NESLIB header
#include "neslib.h"

// Goomba Metasprite

#define TILE 0x80
#define ATTR 2

// define a 2x2 metasprite
const unsigned char meta_sprite[]={
        0,      0,      TILE+0,   ATTR, 
        0,      8,      TILE+1,   ATTR, 
        8,      0,      TILE+0,   ATTR | 0x70, 
        8,      8,      TILE+1,   ATTR | 0x70, 
        128};

const unsigned char target_sprite[]={
        0,      0,      0x8f,   0, 
        0,      8,      0x8f,   0, 
        8,      0,      0x8f,   0, 
        8,      8,      0x8f,   0, 
        128};

/*{pal:"nes",layout:"nes"}*/
const char PALETTE[32] = { 
  0x11,			// screen color

  0x11,0x30,0x27,0x00,	// background palette 0
  0x1C,0x20,0x2C,0x00,	// background palette 1
  0x00,0x10,0x20,0x00,	// background palette 2
  0x06,0x16,0x26,0x00,   // background palette 3

  0x16,0x30,0x24,0x00,	// sprite palette 0
  0x00,0x37,0x25,0x00,	// sprite palette 1
  0x0F,0x36,0x17,0x00,	// sprite palette 2
  0x0D,0x27,0x2A	// sprite palette 3
};

// setup PPU and tables
void setup_graphics() {
  // clear sprites
  oam_clear();
  // set palette colors
  pal_all(PALETTE);
  // turn on PPU
  ppu_on_all();
}


// main program
void main() {
  char oam_id;	// sprite ID
  unsigned char x=120,y=105;
  unsigned char pad;

  const unsigned char *sprite;
  unsigned char bg_color = 0x11;
  
  // initialize PPU
  setup_graphics();

  // loop forever
  while (1) 
  {
    pad = pad_poll(0);

    if (pad & PAD_A)
    {
        sprite = target_sprite;
        bg_color = 0xf;
    }
    else 
    {
        sprite = meta_sprite;
        bg_color = 0x11;
    }

    vram_adr(0x3f00);
    vram_put(bg_color);

    oam_id = 0;
    oam_id = oam_meta_spr(x++, y++, oam_id, sprite); 
    ppu_wait_frame();
  }
}
