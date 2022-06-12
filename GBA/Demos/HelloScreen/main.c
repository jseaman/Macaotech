// include GBA Defined Registers and utils
#include "GBAdefs.h"

#define RGB(r,g,b) b << 10 | g << 5 | r

const unsigned short background_palette [] = { RGB(0,0,0), RGB(0,10,20), RGB(31,31,31), RGB(29,8,6) };

const unsigned char tile [] = 
{
    1, 1, 2, 2, 2, 2, 3, 3,
    1, 1, 2, 2, 2, 2, 3, 3,
    1, 1, 2, 2, 2, 2, 3, 3,
    1, 1, 2, 2, 2, 2, 3, 3,
    1, 1, 2, 2, 2, 2, 3, 3,
    1, 1, 2, 2, 2, 2, 3, 3,
    1, 1, 2, 2, 2, 2, 3, 3,
    1, 1, 2, 2, 2, 2, 3, 3
};

void setup_palette()
{
    int i;

    /* load the palette from the image into palette memory*/
    for (i = 0; i < sizeof(background_palette); i++) 
        bg_palette[i] = background_palette[i];
}

void load_tiles()
{
    int i;
    unsigned short *tilePtr = (unsigned short *) tile;
    unsigned short *tileMem = (unsigned short *)char_block(0);

    for (i=0;i<32;i++)
        tileMem[i] = 0;

    for (i=0;i<sizeof(tile)/2;i++)
        tileMem[i+32] = tilePtr[i];
}

void load_map()
{
    unsigned short *tileMap = (unsigned short *)screen_block(2);

    tileMap[0] = 1;
}

int main() {
    setup_palette();
    load_tiles();
    load_map();

    BG_control bg0_cfg;

    bg0_cfg.bg_size = 0;
    bg0_cfg.wrapping_flag = 0;
    bg0_cfg.screen_block = 2;
    bg0_cfg.color_mode = 1;
    bg0_cfg.mosaic_flag = 0;
    bg0_cfg.char_block = 0;
    bg0_cfg.priority = 0;

    *bg0_control = get_bg_control(bg0_cfg);

    *display_control = MODE0 | BG0_ENABLE;

    /* loop forever */
    while (1);
}

 







































/*
for (i=0;i<32;i++)
        tileMem[i] = 0;

    for (i=0;i<sizeof(tile)/2;i++)
        tileMem[i+32] = tilePtr[i];

*/
