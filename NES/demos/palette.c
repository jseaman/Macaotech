/*
Setting the attribute table, which controls palette selection
for the nametable. We copy it from an array in ROM to video RAM.
*/
#include "neslib.h"
#include <string.h>
#include <stdlib.h>


/*{pal:"nes",layout:"nes"}*/
const char PALETTE[16] = { 
  0x02,			// screen color

  0x14,0x20,0x30,0x0,	// background palette 0
  0x1c,0x20,0x2c,0x0,	// background palette 1
  0x1A,0x21,0x20,0x0,	// background palette 2
  0x06,0x16,0x26        // background palette 3
};

// main function, run after console reset
void main(void) {
  // set background palette colors
  pal_bg(PALETTE);

  vram_adr(NTADR_A(0,1));
  vram_put('1');

  vram_adr(NTADR_A(0,2));
  vram_put('2');

  vram_adr(NTADR_A(1,1));
  vram_put('3');

  vram_adr(NTADR_A(1,2));
  vram_put('4');
  
  // enable PPU rendering (turn on screen)
  ppu_on_all();

  // infinite loop
  while (1) { 
      ppu_wait_nmi();
  }
}
