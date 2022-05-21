#include <string.h>
#include "neslib.h"

void print (unsigned char x, unsigned char y, const char *s)
{
  vram_adr(NTADR_A(x,y));		// set address
  vram_write(s, strlen(s));	// write bytes to video RAM
}

void set_palette()
{
  // set palette colors
  pal_col(0,0x02);	// set screen to dark blue
  pal_col(1,0x14);	// fuchsia
  pal_col(2,0x20);	// grey
  pal_col(3,0x30);	// white
}

// main function, run after console reset
void main(void) {
  set_palette();

  print(1,2,"HOLA MUNDO!");

  // enable PPU rendering (turn on screen)
  ppu_on_all();

  // infinite loop
  while (1) ;
}
