/*
 * tiles.c
 * program which demonstraes tile mode 0
 */

#include <string.h>
#include <stdlib.h>

/* include the image we are using */
#include "background.h"

/* include the tile map we are using */
#include "map.h"

// Inlcude Letters
#include "letters_tiles.h"
#include "letters_tile_map.h"

// include GBA Defined Registers and utils
#include "GBAdefs.h"


void draw_text(volatile unsigned short *vram, unsigned char x, unsigned char y, const char *text)
{
    int i;
    int offset;
    short c = 0;

    for (i=0;i<strlen(text);i++)
    {
        offset = y * 32 + x;
        
        if (text[i] >= 'A' && text[i] <= 'Z')
            c = text[i] - 'A' + 1;
        else if (text[i] >= '0' && text[i] <= '9')
            c = text[i]- '0' + 27;
        else if (text[i] == ':')
            c = 43;
        else
            c = 0;

        vram[offset + i] = c;
    }
}

void setup_palette()
{
    int i;

    /* load the palette from the image into palette memory*/
    for (i = 0; i < PALETTE_SIZE; i++) {
        bg_palette[i] = background_palette[i];
    }
}

void setup_bg0()
{
    int i;
    BG_control ctrl_0;
    volatile unsigned short* dest;
    unsigned short* image = (unsigned short*) background_data;

    ctrl_0.priority = 1;
    ctrl_0.char_block = 0;
    ctrl_0.mosaic_flag = 0;
    ctrl_0.color_mode = 1;
    ctrl_0.screen_block = 15;
    ctrl_0.wrapping_flag = 1;
    ctrl_0.bg_size = 0;

    /* set all control the bits in this register */
    *bg0_control = get_bg_control(ctrl_0);

    /* load the tiles into char block 0 (16 bits at a time) */
    dest = char_block(0);
    
    memcpy((unsigned short *)dest,(unsigned short *)image,background_width * background_height * sizeof(unsigned short));
    /*for (i = 0; i < ((background_width * background_height) / 2); i++) {
        dest[i] = image[i];
    }*/

    /* load the tile map into screen block 16 */
    dest = screen_block(15);
    
    for (i = 0; i < (map_width * map_height); i++) {
        dest[i] = map[i];
    }
}

/* function to setup background 0 for this program */
void setup_bg1() {
    int i;
    BG_control ctrl_1;
    unsigned short* image = (unsigned short*) letters_tiles;
    volatile unsigned short* dest;

    ctrl_1.priority = 0;
    ctrl_1.char_block = 1;
    ctrl_1.mosaic_flag = 0;
    ctrl_1.color_mode = 1;
    ctrl_1.screen_block = 14;
    ctrl_1.wrapping_flag = 0;
    ctrl_1.bg_size = 0;

    *bg1_control = get_bg_control(ctrl_1);

    dest = char_block(1);

    for (i=0;i<sizeof(letters_tiles)/2;i++)
        dest[i] = image[i];
    

    /* load the tile data into screen block 14 */
    dest = screen_block(14);

    draw_text(dest,2,0,"NELSON: 10");
    draw_text(dest,17,0,"ANTONIO: 17");
}


/* just kill time */
void delay(unsigned int amount) {
    int i;
    for (i = 0; i < amount * 10; i++);
}

/* the main function */
int main() {
    /* set initial scroll to 0 */
    int xscroll = 0;
    int yscroll = 0;

    /* we set the mode to mode 0 with bg0 on */
    *display_control = MODE0 | BG0_ENABLE | BG1_ENABLE;

    setup_palette();

    /* setup the background 0 */
    setup_bg0();

    /* setup the background 1 */
    setup_bg1();

    /* loop forever */
    while (1) {
        /* scroll with the arrow keys */
        if (button_pressed(BUTTON_DOWN)) {
            yscroll++;
        }
        if (button_pressed(BUTTON_UP)) {
            yscroll--;

        }
        if (button_pressed(BUTTON_RIGHT)) {
            xscroll++;
        }
        if (button_pressed(BUTTON_LEFT)) {
            xscroll--;
        }

        /* wait for vblank before scrolling */
        wait_vblank();
        *bg0_x_scroll = xscroll;
        *bg0_y_scroll = yscroll;

        /* delay some */
        delay(200);
    }
}

 
