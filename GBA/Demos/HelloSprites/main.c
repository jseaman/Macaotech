/*
 * tiles.c
 * program which demonstraes tile mode 0
 */
#include <string.h>
/* include the image we are using */

#include "GBAdefs.h"
#include "cachureco_pal.h"
#include "cachureco_tiles.h"

#include "nacional_pal.h"
#include "nacional_tiles.h"
#include "nacional_tile_map.h"

void load_background_pal()
{
    int i;

    for (i=0;i<PALETTE_SIZE;i++)
        bg_palette[i] = nacional_pal[i];
}

void load_background_tiles()
{
    int i;
    unsigned short* image = (unsigned short*) nacional_tiles;  
    unsigned short *back = (unsigned short *)char_block(0);

    for (i=0;i<sizeof(nacional_tiles)/2;i++)
        back[i] = image[i];    
}

void load_background_map()
{
    int i;
    unsigned short *map = (unsigned short *)screen_block(4);

    for (i=0;i<sizeof(nacional_tile_map);i++)
        map[i] = nacional_tile_map[i];
}

void load_sprite_pal()
{
    int i;

    for (i = 0; i < PALETTE_SIZE; i++) {
        sprite_palette[i] = cachureco_pal[i];
    }
}

void load_sprite_tiles() {
    int i;
    unsigned short* image = (unsigned short*) cachureco_tiles;  

    for (i=0;i<sizeof(cachureco_tiles)/2;i++)
        sprite_image_memory[i] = image[i];    
}


/* just kill time */
void delay(unsigned int amount) {
    int i;
    for (i = 0; i < amount * 10; i++);
}

HR_Sprite config_sprite()
{
    HR_Sprite sprite;

    memset(&sprite,0,sizeof(HR_Sprite));

    sprite.attribute0.color_mode = 1;
    sprite.attribute0.shape = 2;
    sprite.attribute0.y = 70;

    sprite.attribute1.size = 2;
    sprite.attribute1.x = 60;

    sprite.attribute2.tile_index = 0;

    return sprite;
}

void setup_background()
{
    BG_control bg0_cfg;

    bg0_cfg.bg_size = 0;
    bg0_cfg.char_block = 0;
    bg0_cfg.screen_block = 4;
    bg0_cfg.color_mode = 1;

    *bg0_control = get_bg_control(bg0_cfg);

    load_background_pal();
    load_background_tiles();
    load_background_map();
}

void setup_sprites()
{
    load_sprite_pal();
    load_sprite_tiles();
}

/* the main function */
int main() {
    int wait = 40;
    HR_Sprite cerdo_sprite;
    ARM_Sprite cerdo_bin;
    
    setup_background();
    setup_sprites();

    cerdo_sprite = config_sprite();

    *display_control = MODE_0 | BG0_ENABLE | SPRITE_ENABLE | SPRITE_MAP_1D;

    *bg0_y_scroll = -200;

    /* loop forever */
    while (1) {
        wait_vblank();

        cerdo_bin = Human_to_ARM(cerdo_sprite);
        memcpy16_dma((unsigned short *) sprite_attribute_memory, (unsigned short *) &cerdo_bin, 4);

        /* delay some */
        delay(50);

        if (--wait == 0)
        {
            cerdo_sprite.attribute1.x++;
            cerdo_sprite.attribute1.x%=SCREEN_WIDTH;
            cerdo_sprite.attribute2.tile_index = cerdo_sprite.attribute2.tile_index == 0 ? 16 : 0;
            wait = 40;
        }
    }
}

