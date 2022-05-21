#include <stdlib.h>
#include <string.h>

// include NESLIB header
#include "neslib.h"

const char PALETTE[32] = { 
  0x11,			// screen color

  0x11,0x30,0x27,0x00,	// background palette 0
  0x1C,0x20,0x2C,0x00,	// background palette 1
  0x00,0x10,0x20,0x00,	// background palette 2
  0x06,0x16,0x26,0x00,   // background palette 3

  0x16,0x35,0x24,0x00,	// sprite palette 0
  0x00,0x37,0x25,0x00,	// sprite palette 1
  0x2A,0x0D,0x01,0x00,	// sprite palette 2
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

// number of actors
#define NUM_ACTORS 8		// 64 sprites (maximum)

// actor x/y positions
byte actor_x[NUM_ACTORS];	// horizontal coordinates
byte actor_y[NUM_ACTORS];	// vertical coordinates

// actor x/y deltas per frame (signed)
sbyte actor_dx[NUM_ACTORS];	// horizontal velocity
sbyte actor_dy[NUM_ACTORS];	// vertical velocity

// main program
void main() {
  char i;	// actor index
  char oam_id;	// sprite ID
  const char *s = "FUERAJOH";
  
  // initialize actors with random values
  for (i=0; i<NUM_ACTORS; i++) {
    actor_x[i] = (i+1) *8;
    actor_y[i] = 20;
    actor_dy[i] = (rand() & 3);
  }
  // initialize PPU
  setup_graphics();
  
  // loop forever
  while (1) {
    // start with OAMid/sprite 0
    oam_id = 0;
    // draw and move all actors
    for (i=0; i<NUM_ACTORS; i++) {
      oam_id = oam_spr(actor_x[i], actor_y[i], s[i], 0, oam_id);
      //actor_y[i] += actor_dy[i];
    }
    // hide rest of sprites
    // if we haven't wrapped oam_id around to 0
    if (oam_id!=0) oam_hide_rest(oam_id);
    // wait for next frame
    ppu_wait_frame();
  }
}
