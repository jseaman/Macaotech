
#include <string.h>
#include "GBADefs.h"

#include "macao_pal.h"
#include "macao_bmp.h"

#include "mona_pal.h"
#include "mona_bmp.h"

#define BACKBUFFER 0x10
unsigned short* FrontBuffer = (unsigned short*)0x6000000;
unsigned short* BackBuffer = (unsigned short*)0x600A000;

void draw_macao()
{
    memcpy16_dma((unsigned short *)bg_palette, (unsigned short *) macao_palette, 256);
    memcpy16_dma((unsigned short *)FrontBuffer, (unsigned short *)macao_bmp, SCREEN_WIDTH*SCREEN_HEIGHT/2);
}

void draw_mona()
{
    memcpy16_dma((unsigned short *)BackBuffer, (unsigned short *)mona_bmp, SCREEN_WIDTH*SCREEN_HEIGHT/2);
}

void flip()	
{
	if(*display_control & BACKBUFFER)
	{
        memcpy16_dma((unsigned short *)bg_palette, (unsigned short *) macao_palette, 256);
		*display_control &= ~BACKBUFFER;
    }
    else
    {
        memcpy16_dma((unsigned short *)bg_palette, (unsigned short *) mona_palette, 256);
		*display_control |= BACKBUFFER;
	}
}

/* the main function */
int main() {
    unsigned int i;
    *display_control = MODE_4 | BG2_ENABLE;

    draw_macao();
    draw_mona();

    while (1)
    {
        for (i=1;i<1200;i++)
            wait_vblank();

        flip();
    }
}

