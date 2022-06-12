
#include <string.h>
#include "GBADefs.h"
#include "mona.h"
#include "starry.h"
#include "macao.h"

void macao_intro()
{
    memcpy16_dma((unsigned short *)videoBuffer, (unsigned short *)macao, SCREEN_WIDTH*SCREEN_HEIGHT);
}

void paint_starry() {
    memcpy16_dma((unsigned short *)videoBuffer, (unsigned short *)starry, SCREEN_WIDTH*SCREEN_HEIGHT);
}

void paint_mona()
{
    memcpy16_dma((unsigned short *)videoBuffer, (unsigned short *)mona, SCREEN_WIDTH*SCREEN_HEIGHT);
}

/* the main function */
int main() {
    *display_control = MODE_3 | BG2_ENABLE;

    macao_intro();

    while (1)
    {
        wait_vblank();

        if (button_pressed(BUTTON_A))
            paint_mona();

        if (button_pressed(BUTTON_B))
            paint_starry();
    }
}

