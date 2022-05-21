#include "neslib.h"
#include <string.h>

const char PALETTE[20] = { 
  0x21,			// screen color

  0x14,0x20,0x30,0x00,	// background palette 0
  0x34,0x14,0x2a,0x00,	// background palette 1
  0x0f,0x30,0x37,0x00,	// background palette 2
  0x14,0x20,0x30,0x00,	// background palette 3 

  0x30,0x30,0x30     	// background sprite 0
};

const char ATTRIBUTE_TABLE1[0x40] = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 0-3
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, // rows 4-7
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 8-11
  0x00, 0x00, 0x00, 0x55, 0x00, 0x00, 0x00, 0x00, // rows 12-15
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 16-19
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 20-23
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 24-27
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // rows 28-29
};

const char ATTRIBUTE_TABLE2[0x40] = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 0-3
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, // rows 4-7
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 8-11
  0x00, 0x00, 0x00, 0xaa, 0x00, 0x00, 0x00, 0x00, // rows 12-15
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 16-19
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 20-23
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // rows 24-27
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // rows 28-29
};

// setup PPU and tables
void setup_graphics() {
  // clear sprites
  oam_clear();
  // set palette colors
  pal_all(PALETTE);

  vram_adr(NAMETABLE_A + 0x3c0);
  vram_write(ATTRIBUTE_TABLE1, sizeof(ATTRIBUTE_TABLE1));
  vram_adr(NAMETABLE_B + 0x3c0);
  vram_write(ATTRIBUTE_TABLE2, sizeof(ATTRIBUTE_TABLE2));
}

// function to write a string into the name table
//   adr = start address in name table
//   str = pointer to string
void put_str(unsigned int adr, const char *str) {
  vram_adr(adr);        // set PPU read/write address
  vram_write(str, strlen(str)); // write bytes to PPU
}

void scroll_demo()
{
  int dx = 1;
  int x = 0;
  
  int dy = 0;
  int y = 0;
  
  while(1)
  {
    scroll(x,y);
    x+=dx;
    y+=dy;
    ppu_wait_frame();
  }
}

void split_scroll_demo() {
  int x = 0;   
  int dx = 1;  
  
  while (1) {
    split(x, 0);
    
    x += dx;
    
    if (x >= 479) dx = -1;
    if (x == 0) dx = 1;
  }
}

void dibujar_nelson()
{
  put_str(NTADR_A(8,11), "Hola soy Nelson"); 
  
  vram_adr(NTADR_A(14,14));
  vram_put(0xd8);
  vram_adr(NTADR_A(15,14));
  vram_put(0xda);
  vram_adr(NTADR_A(14,15));
  vram_put(0xd9);
  vram_adr(NTADR_A(15,15));
  vram_put(0xdb);
}

void dibujar_antonio()
{
  put_str(NTADR_B(8,11), "Hola soy Antonio");

  vram_adr(NTADR_B(14,14));
  vram_put(0xf0);
  vram_adr(NTADR_B(15,14));
  vram_put(0xf2);
  vram_adr(NTADR_B(14,15));
  vram_put(0xf1);
  vram_adr(NTADR_B(15,15));
  vram_put(0xf3);
}

void dibujar_score()
{
  put_str(NTADR_A(2,2), "Nelson : 20");
  put_str(NTADR_A(17,2), "Antonio : 30");
  vram_adr(NTADR_A(0,4));
  vram_fill(0xa1,32);
  //vram_adr(NTADR_B(0,4));
  //vram_fill(0xa1,32);
}

void set_sprite_0 ()
{ 
  oam_clear();
  //oam_spr(0, 38, 0xa0, 0, 0);
  oam_spr(0, 38, 0x4, 0, 0);
}

// main function, run after console reset
void main(void) { 
  setup_graphics();
  
  dibujar_score();

  dibujar_nelson();
  dibujar_antonio();
  
  // enable PPU rendering (turn on screen)
  ppu_on_all();
  
  //scroll_demo();
  
  while(1) ;
}
