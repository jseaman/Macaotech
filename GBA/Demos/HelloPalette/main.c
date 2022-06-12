// include GBA Defined Registers and utils
#include "GBAdefs.h"

#define RGB(r,g,b) b << 10 | g << 5 | r

const unsigned short background_palette [] = { 0x7c1f, 0x5b0b, RGB(31,0,0), RGB(0,16,0), RGB(0,31,31) };

void setup_palette()
{
    int i;

    /* load the palette from the image into palette memory*/
    for (i = 0; i < sizeof(background_palette); i++) 
        bg_palette[i] = background_palette[i];
}

int main() {
    setup_palette();

    /* loop forever */
    while (1);
}

 
