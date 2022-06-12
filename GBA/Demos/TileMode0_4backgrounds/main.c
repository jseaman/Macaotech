/*
 * tiles.c
 * program which demonstraes tile mode 0
 */

#include <string.h>


/* include the image we are using */
#include "background.h"

/* include the tile map we are using */
#include "map.h"

#include "letters_tiles.h"
#include "letters_tile_map.h"

#include "rain_tiles.h"
#include "rain_tile_map.h"

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

void setup_palette( )
{
    int i;
    
    /* load the palette from the image into palette memory*/
    for (i=0;i<PALETTE_SIZE;i++)
        bg_palette[i] = background_palette[i];

    //memcpy(bg_palette, background_palette, PALETTE_SIZE * 2);
}

void setup_bg0()
{
    int x,y;
    int offset;

    BG_control crl_0;
    volatile unsigned short* dest;

    crl_0.priority = 3;
    crl_0.char_block = 0;
    crl_0.mosaic_flag = 0;
    crl_0.color_mode = 1;
    crl_0.screen_block = 13;
    crl_0.wrapping_flag = 1;
    crl_0.bg_size = 0;

    /* set all control the bits in this register */
    *bg0_control = get_bg_control(crl_0);

    /* load the tile map into screen block 16 */
    dest = screen_block(13);

    for (y=0;y<map_height;y++)
    {
        if ((y >=2 && y<=6) || (y>=15 && y<=17))
        {
            for (x=0;x<map_width;x++)
            {
                offset = y * map_width + x;
                dest[offset] = map[offset];
            }
        }
    }
}

void setup_bg1()
{
    int i;
    int x,y;
    int offset;

    BG_control crl_0;
    volatile unsigned short* dest;
    unsigned short* image = (unsigned short*) background_data;

    crl_0.priority = 2;
    crl_0.char_block = 0;
    crl_0.mosaic_flag = 0;
    crl_0.color_mode = 1;
    crl_0.screen_block = 15;
    crl_0.wrapping_flag = 1;
    crl_0.bg_size = 0;

    /* set all control the bits in this register */
    *bg1_control = get_bg_control(crl_0);

    /* load the tiles into char block 0 (16 bits at a time) */
    dest = char_block(0);

    for (i = 0; i < ((background_width * background_height) / 2); i++) {
        dest[i] = image[i];
    }
    
    /* load the tile map into screen block 16 */
    dest = screen_block(15);

    for (y=0;y<map_height;y++)
        for (x=0;x<map_width;x++)
        {
            offset = y * map_width + x;

            if ((y >=2 && y<=6) || (y>=15 && y<=17))
                dest[offset] = 65;
            else
                dest[offset] = map[offset];
        }
}

/* function to setup background 2 for this program */
void setup_bg2() {
    int i;
    BG_control ctrl_3;
    unsigned short* image = (unsigned short*) letters_tiles;
    volatile unsigned short* dest;

    ctrl_3.priority = 0;
    ctrl_3.char_block = 1;
    ctrl_3.mosaic_flag = 0;
    ctrl_3.color_mode = 1;
    ctrl_3.screen_block = 14;
    ctrl_3.wrapping_flag = 0;
    ctrl_3.bg_size = 0;

    *bg2_control = get_bg_control(ctrl_3);

    dest = char_block(1);

    for (i=0;i<sizeof(letters_tiles)/2;i++)
        dest[i] = image[i];
    

    /* load the tile data into screen block 14 */
    dest = screen_block(14);

    draw_text(dest,2,0,"NELSON: 10");
    draw_text(dest,17,0,"ANTONIO: 17");
}

/* function to setup background 2 for this program */
void setup_bg3() {
    int i;
    BG_control ctrl_3;
    unsigned short* image = (unsigned short*) rain_tiles;
    volatile unsigned short* dest;

    ctrl_3.priority = 1;
    ctrl_3.char_block = 2;
    ctrl_3.mosaic_flag = 0;
    ctrl_3.color_mode = 1;
    ctrl_3.screen_block = 25;
    ctrl_3.wrapping_flag = 1;
    ctrl_3.bg_size = 3;

    *bg3_control = get_bg_control(ctrl_3);

    dest = char_block(2);

    for (i=0;i<sizeof(rain_tiles)/2;i++)
        dest[i] = image[i];
    
    /* load the tile data into screen block 24 */
    dest = screen_block(25);

    for (i=0;i<sizeof(rain_tile_map);i++)
        dest[i] = rain_tile_map[i];
}

/* just kill time */
void delay(unsigned int amount) {
    int i;
    for (i = 0; i < amount * 10; i++);
}

// A * alpha + B * (1-alpha)
// enteros de 32 bits

// entero de 16 bytes

// 1 : 1/16
// 2 : 2/16
// 3 : 3/16
// 16 : 16/16
//AAAA CCCC

/* the main function */
int main() {
    /* set initial scroll to 0 */
    int xscroll = 0;
    short scroll_flag = 25;
    int paralax_scroll = 0;
    int rain_scroll_x = 0;
    int rain_scroll_y = 0;

    /* we set the mode to mode 0 with bg0 on */
    *display_control = MODE0 | BG0_ENABLE | BG1_ENABLE | BG2_ENABLE | BG3_ENABLE;

    setup_palette();

    /* setup the background 0 */
    setup_bg0();

    /* setup the background 1 */
    setup_bg1();

    /* setup the background 2 */
    setup_bg2();

    /* setup the background 2 */
    setup_bg3();

    // Set blending: BG2 and BG3
    
    REG_BLDMOD = BG3_A | BG1_B | BG0_B | NORMAL_TRANS; 
    REG_COLEV = WEIGHTOFA(8) | WEIGHTOFB(8);

    // 8/16 = 0.5

    /* loop forever */
    while (1) {
        /* scroll with the arrow keys */
        if (button_pressed(BUTTON_RIGHT)) {
            xscroll++;

            scroll_flag++;
            scroll_flag%=50;

            if (scroll_flag==0)
                paralax_scroll++;
        }
        if (button_pressed(BUTTON_LEFT)) {
            xscroll--;

            scroll_flag--;
            scroll_flag%=50;

            if (scroll_flag==0)
                paralax_scroll--;
        }

        /* wait for vblank before scrolling */
        wait_vblank();

        
        *bg0_x_scroll = paralax_scroll;
        *bg1_x_scroll = xscroll;

        rain_scroll_x++;
        rain_scroll_y--;

        *bg3_x_scroll = rain_scroll_x;
        *bg3_y_scroll = rain_scroll_y;

        /* delay some */
        delay(200);
    }
}

 
