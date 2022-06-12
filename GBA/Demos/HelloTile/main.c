// include GBA Defined Registers and utils
#include "GBAdefs.h"

#define RGB(r,g,b) b << 10 | g << 5 | r

const unsigned short background_palette [] = { 0x7c1f, RGB(0,10,20), RGB(31,31,31), RGB(29,8,6) };

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

    for (i=0;i<sizeof(tile)/2;i++)
        tileMem[i] = tilePtr[i];
}

int main() {
    setup_palette();
    load_tiles();

    /* loop forever */
    while (1);
}

 
