/*
Setting the attribute table, which controls palette selection
for the nametable. We copy it from an array in ROM to video RAM.
*/
#include "neslib.h"
#include <string.h>
#include <stdlib.h>

// link the pattern table into CHR ROM
//#link "chr_generic.s"

// attribute table in PRG ROM
const char ATTRIBUTE_TABLE[0x40] = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 0-3
  0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, // rows 4-7
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, // rows 8-11
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, // rows 12-15
  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // rows 16-19
  0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, // rows 20-23
  0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, // rows 24-27
  0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  // rows 28-29
};

/*{pal:"nes",layout:"nes"}*/
const char PALETTE[16] = { 
  0x02,			// screen color

  0x14,0x20,0x30,0x0,	// background palette 0
  0x1c,0x20,0x2c,0x0,	// background palette 1
  0x1A,0x21,0x3B,0x0,	// background palette 2
  0x06,0x16,0x26        // background palette 3
};

// main function, run after console reset
void main(void) {
  const char a = 0;
  const char b = 1;
  const char c = 2;
  const char d = 3;

  char attr = d << 6 | c << 4 | b << 2 | a;

  // set background palette colors
  pal_bg(PALETTE);
  
  vram_adr(NTADR_A(0,0));
  vram_write("aabb",4);

  vram_adr(NTADR_A(0,1));
  vram_write("aabb",4);

  vram_adr(NTADR_A(0,2));
  vram_write("ccdd",4);

  vram_adr(NTADR_A(0,3));
  vram_write("ccdd",4);
  
  vram_adr(NAMETABLE_A + 0x3c0);
  vram_put(attr);
  
  ppu_on_all();

  // infinite loop
  while (1) ;
}
