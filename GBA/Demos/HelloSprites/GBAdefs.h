/* the width and height of the screen */
#define SCREEN_WIDTH 240
#define SCREEN_HEIGHT 160

/* the three tile modes */
#define MODE_0 0x00
#define MODE_1 0x01
#define MODE_2 0x02

/* the three bitmap modes */
#define MODE_3 0x03
#define MODE_4 0x04
#define MODE_5 0x05

/* enable bits for the four tile layers */
#define BG0_ENABLE 0x100
#define BG1_ENABLE 0x200
#define BG2_ENABLE 0x400
#define BG3_ENABLE 0x800

#define SPRITE_MAP_2D 0x0
#define SPRITE_MAP_1D 0x40
#define SPRITE_ENABLE 0x1000

/* the control registers for the four tile layers */
volatile unsigned short* bg0_control = (volatile unsigned short*) 0x4000008;
volatile unsigned short* bg1_control = (volatile unsigned short*) 0x400000a;
volatile unsigned short* bg2_control = (volatile unsigned short*) 0x400000c;
volatile unsigned short* bg3_control = (volatile unsigned short*) 0x400000e;

/* palette is always 256 colors */
#define PALETTE_SIZE 256

//packs three values into a 15-bit color
#define RGB(r,g,b) ((r)+(g<<5)+(b<<10))

/* the display control pointer points to the gba graphics register */
volatile unsigned long* display_control = (volatile unsigned long*) 0x4000000;

/* the address of the color palettes */
volatile unsigned short* bg_palette = (volatile unsigned short*) 0x5000000;
volatile unsigned short* sprite_palette = (volatile unsigned short*) 0x5000200;

//create a pointer to the video buffer
unsigned short* videoBuffer = (unsigned short*)0x6000000;

/* the memory location which stores sprite image data */
volatile unsigned short* sprite_image_memory = (volatile unsigned short*) 0x6010000;

/* the button register holds the bits which indicate whether each button has
 * been pressed - this has got to be volatile as well
 */
volatile unsigned short* buttons = (volatile unsigned short*) 0x04000130;

/* scrolling registers for backgrounds */
volatile short* bg0_x_scroll = (unsigned short*) 0x4000010;
volatile short* bg0_y_scroll = (unsigned short*) 0x4000012;
volatile short* bg1_x_scroll = (unsigned short*) 0x4000014;
volatile short* bg1_y_scroll = (unsigned short*) 0x4000016;
volatile short* bg2_x_scroll = (unsigned short*) 0x4000018;
volatile short* bg2_y_scroll = (unsigned short*) 0x400001a;
volatile short* bg3_x_scroll = (unsigned short*) 0x400001c;
volatile short* bg3_y_scroll = (unsigned short*) 0x400001e;


/* the bit positions indicate each button - the first bit is for A, second for
 * B, and so on, each constant below can be ANDED into the register to get the
 * status of any one button */
#define BUTTON_A (1 << 0)
#define BUTTON_B (1 << 1)
#define BUTTON_SELECT (1 << 2)
#define BUTTON_START (1 << 3)
#define BUTTON_RIGHT (1 << 4)
#define BUTTON_LEFT (1 << 5)
#define BUTTON_UP (1 << 6)
#define BUTTON_DOWN (1 << 7)
#define BUTTON_R (1 << 8)
#define BUTTON_L (1 << 9)

typedef struct 
{
    unsigned char priority;  /* priority, 0 is highest, 3 is lowest */
    unsigned char char_block; /* the char block the image data is stored in */
    unsigned char mosaic_flag; /* the mosaic flag */
    unsigned char color_mode; /* color mode, 0 is 16 colors, 1 is 256 colors */
    unsigned char screen_block; /* the screen block the tile data is stored in */
    unsigned char wrapping_flag; /* wrapping flag */
    unsigned char bg_size; /* bg size, 0 is 256x256 */
} BG_control;

unsigned short get_bg_control(BG_control bg_ctrl)
{
    unsigned short ret_value =  
        bg_ctrl.priority |    
        (bg_ctrl.char_block << 2)  |       
        (bg_ctrl.mosaic_flag << 6)  |      
        (bg_ctrl.color_mode << 7)  |       
        (bg_ctrl.screen_block << 8) |      
        (bg_ctrl.wrapping_flag << 13) |    
        (bg_ctrl.bg_size << 14);        

    return ret_value;
}

/* the scanline counter is a memory cell which is updated to indicate how
 * much of the screen has been drawn */
volatile unsigned short* scanline_counter = (volatile unsigned short*) 0x4000006;

/* the memory location which controls sprite attributes */
volatile unsigned short* sprite_attribute_memory = (volatile unsigned short*) 0x7000000;

/* flag for turning on DMA */
#define DMA_ENABLE 0x80000000

/* flags for the sizes to transfer, 16 or 32 bits */
#define DMA_16 0x00000000
#define DMA_32 0x04000000

/* pointer to the DMA source location */
volatile unsigned int* dma_source = (volatile unsigned int*) 0x40000D4;

/* pointer to the DMA destination location */
volatile unsigned int* dma_destination = (volatile unsigned int*) 0x40000D8;

/* pointer to the DMA count/control */
volatile unsigned int* dma_count = (volatile unsigned int*) 0x40000DC;

/* copy data using DMA */
void memcpy16_dma(unsigned short* dest, unsigned short* source, int amount) {
    *dma_source = (unsigned int) source;
    *dma_destination = (unsigned int) dest;
    *dma_count = amount | DMA_16 | DMA_ENABLE;
}

void memcpy32_dma(unsigned short* dest, unsigned short* source, int amount) {
    *dma_source = (unsigned int) source;
    *dma_destination = (unsigned int) dest;
    *dma_count = amount | DMA_32 | DMA_ENABLE;
}

typedef struct {
    unsigned short attribute0;
    unsigned short attribute1;
    unsigned short attribute2;
    unsigned short attribute3;
} ARM_Sprite;

typedef struct {
    unsigned short shape;
    unsigned short color_mode;
    unsigned short mosaic;
    unsigned short effect;
    unsigned short affine;
    unsigned short y;
} HR_Attribute0;

typedef struct {
    unsigned short size;
    unsigned short vflip;
    unsigned short hflip;
    unsigned short x;
} HR_Attribute1;

typedef struct {
    unsigned short palette_bank;
    unsigned short priority;
    unsigned short tile_index;
} HR_Attribute2;

typedef struct {
    HR_Attribute0 attribute0;
    HR_Attribute1 attribute1;
    HR_Attribute2 attribute2;
} HR_Sprite;

ARM_Sprite Human_to_ARM(const HR_Sprite sprite)
{
    ARM_Sprite arm_sprite;

    arm_sprite.attribute0 =
        sprite.attribute0.shape << 14 |
        sprite.attribute0.color_mode << 13 |
        sprite.attribute0.mosaic << 12 |
        sprite.attribute0.effect << 10 |
        sprite.attribute0.affine << 8 |
        sprite.attribute0.y;

    arm_sprite.attribute1 = 
        sprite.attribute1.size << 14 |
        sprite.attribute1.vflip << 13 |
        sprite.attribute1.hflip << 12 |
        sprite.attribute1.x;

    arm_sprite.attribute2 = 
        sprite.attribute2.palette_bank << 12 |
        sprite.attribute2.priority << 10 |
        sprite.attribute2.tile_index;

    return arm_sprite;
}

/* wait for the screen to be fully drawn so we can do something during vblank */
void wait_vblank() {
    /* wait until all 160 lines have been updated */
    while (*scanline_counter < 160) { }
}


/* this function checks whether a particular button has been pressed */
unsigned char button_pressed(unsigned short button) {
    /* and the button register with the button constant we want */
    unsigned short pressed = *buttons & button;

    /* if this value is zero, then it's not pressed */
    if (pressed == 0) {
        return 1;
    } else {
        return 0;
    }
}


/* return a pointer to one of the 4 character blocks (0-3) */
volatile unsigned short* char_block(unsigned long block) {
    /* they are each 16K big */
    return (volatile unsigned short*) (0x6000000 + (block * 0x4000));
}

/* return a pointer to one of the 32 screen blocks (0-31) */
volatile unsigned short* screen_block(unsigned long block) {
    /* they are each 2K big */
    return (volatile unsigned short*) (0x6000000 + (block * 0x800));
}
