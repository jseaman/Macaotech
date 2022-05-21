
/*
A simple "hello world" example.
Set the screen background color and palette colors.
Then write a message to the nametable.
Finally, turn on the PPU to display video.
*/

#include "neslib.h"

// link the pattern table into CHR ROM
//#link "chr_generic.s"

// main function, run after console reset
void main(void) {
  int x,y;

  // set palette colors
  pal_col(0,0x02);	// set screen to dark blue
  pal_col(1,0x14);	// fuchsia
  pal_col(2,0x20);	// grey
  pal_col(3,0x30);	// white

  // write text to name table
  //vram_adr(NTADR_A(2,2));		// set address
  //vram_write("HELLO, WORLD!", 13);	// write bytes to video RAM
  
  for (x=2;x<=29;x++)
  {
    vram_adr(NTADR_A(x,2));
    vram_put(2);
  }
  
  for (y=3; y<=25; y++)
  {
    vram_adr(NTADR_A(2,y));
    vram_put(2);
    
    vram_adr(NTADR_A(29,y));
    vram_put(2);
  }
  
  for (x=2;x<=29;x++)
  {
    vram_adr(NTADR_A(x,26));
    vram_put(2);
  }

  // enable PPU rendering (turn on screen)
  ppu_on_all();
  
  //scroll(60,0);
  ppu_wait_frame();
  
  asm("ldx $2005");
  asm("ldx #60");
  asm("stx $2005");
  asm("ldx #0");
  asm("stx $2005");
  asm("lda #$01");
  asm("sta $2000");
  

  // infinite loop
  while (1) ;
}
