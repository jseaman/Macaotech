
#include "neslib.h"
#include <string.h>


void put_str(unsigned int adr, const char *str) {
  vram_adr(adr);        // set PPU read/write address
  vram_write(str, strlen(str)); // write bytes to PPU
}


void scroll_demo() {
  int x = 0;   // x scroll position
  int y = 0;   // y scroll position
  int dy = 1;  // y scroll direction
  // infinite loop
  while (1) {
    // wait for next frame
    ppu_wait_frame();
    // update y variable
    y += dy;
    // change direction when hitting either edge of scroll area
    if (y >= 479) dy = 0;
    if (y == 0) dy = 1;
    // set scroll register
    scroll(x, y);
  }
}

// main function, run after console reset
void main(void) {
  // set palette colors
  pal_col(0,0x02);	// set screen to dark blue
  pal_col(1,0x14);	// pink
  pal_col(2,0x20);	// grey
  pal_col(3,0x30);	// white

  // write text to name table
  put_str(NTADR_A(2,15), "Gracias por su Atencion");
  put_str(NTADR_A(2,29),"Los esperamos a la proxima");
  
  put_str(NTADR_C(2,15), "Atentamente:");
  put_str(NTADR_C(2,18), "Julio Seaman");
  put_str(NTADR_C(2,22), "Macaotech:");
  put_str(NTADR_C(2,26), "Nelson Milla");
  put_str(NTADR_C(2,28), "Antonio Cardenas");

  // enable PPU rendering (turn on screen)
  ppu_on_all();

  // scroll window back and forth
  scroll_demo();
}
