
#include <string.h>
#include "GBADefs.h"
#include "mona.h"
#include "starry.h"
#include "macao.h"

#define LOWRES_WIDTH 160
#define LOWRES_HEIGHT 128

#define BACKBUFFER 0x10
unsigned short* FrontBuffer = (unsigned short*)0x6000000;
unsigned short* BackBuffer = (unsigned short*)0x600A000;


void paint_starry() {
    memcpy16_dma((unsigned short *)FrontBuffer, (unsigned short *)starry, LOWRES_WIDTH*LOWRES_HEIGHT);
}

void paint_mona()
{
    memcpy16_dma((unsigned short *)BackBuffer, (unsigned short *)mona, LOWRES_WIDTH*LOWRES_HEIGHT);
}

void flip()	
{
	if (*display_control & BACKBUFFER)
		*display_control &= ~BACKBUFFER;
    else
		*display_control |= BACKBUFFER;
}

/* the main function */
int main() {
    unsigned int i = 0;

    *display_control = MODE_5 | BG2_ENABLE;

    paint_starry();
    paint_mona();

    while (1)
    {
        wait_vblank();

        if (++i == 1000L)
        {
            if (button_pressed(BUTTON_A))
                flip();
                
            i = 0;
        }
    }
}

