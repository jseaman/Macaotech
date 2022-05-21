#include <stdlib.h>
#include <string.h>

// include NESLIB header
#include "neslib.h"


/*{pal:"nes",layout:"nes"}*/
const char PALETTE[32] = { 
  0x11,			// screen color

  0x11,0x30,0x27,0x00,	// background palette 0
  0x1C,0x20,0x2C,0x00,	// background palette 1
  0x00,0x10,0x20,0x00,	// background palette 2
  0x06,0x16,0x26,0x00,   // background palette 3

  0x16,0x35,0x24,0x00,	// sprite palette 0
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
  
  // initialize PPU
  setup_graphics();

  oam_id = 0;
  oam_id = oam_spr(15 * 8 - 8, 15 *8 - 8, 0x80, 2, oam_id);
  oam_id = oam_spr(15 * 8 - 8, 15 * 8, 0x81, 2, oam_id); 

  oam_id = oam_spr(15 * 8, 15 *8 - 8, 0x80, 2 | 0x70, oam_id);
  oam_id = oam_spr(15 * 8, 15 * 8, 0x81, 2 | 0x70, oam_id);

  // loop forever
  while (1) ;
}
