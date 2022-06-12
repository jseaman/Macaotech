
#include <string.h>
#include "GBADefs.h"

/* function to setup background 0 for this program */
void setup_background() {
    int x,y;
    unsigned short color = 0;

    for (y=0;y<SCREEN_HEIGHT;y++)
    {
        //color = RGB((y*3)%32,(y*2)%32,(y*1)%32);

        for (x=0;x<SCREEN_WIDTH;x++)
        {
            color = RGB((y*3)%32,(y*2)%32,x);
            videoBuffer[y * SCREEN_WIDTH + x] = color;
        }
    }
}

/* the main function */
int main() {
    *display_control = MODE_3 | BG2_ENABLE;

    /* setup the background 3 */
    setup_background();

    wait_vblank();

    /* loop forever */
    while (1) ;
}

