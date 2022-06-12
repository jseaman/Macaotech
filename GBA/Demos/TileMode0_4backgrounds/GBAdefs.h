/* the width and height of the screen */
#define WIDTH 240
#define HEIGHT 160

/* the three tile modes */
#define MODE0 0x00
#define MODE1 0x01
#define MODE2 0x02

/* enable bits for the four tile layers */
#define BG0_ENABLE 0x100
#define BG1_ENABLE 0x200
#define BG2_ENABLE 0x400
#define BG3_ENABLE 0x800

/* the control registers for the four tile layers */
volatile unsigned short* bg0_control = (volatile unsigned short*) 0x4000008;
volatile unsigned short* bg1_control = (volatile unsigned short*) 0x400000a;
volatile unsigned short* bg2_control = (volatile unsigned short*) 0x400000c;
volatile unsigned short* bg3_control = (volatile unsigned short*) 0x400000e;

/* palette is always 256 colors */
#define PALETTE_SIZE 256

/* the display control pointer points to the gba graphics register */
volatile unsigned long* display_control = (volatile unsigned long*) 0x4000000;

/* the address of the color palette */
volatile unsigned short* bg_palette = (volatile unsigned short*) 0x5000000;

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

// Blending
#define REG_BLDMOD *(unsigned short*)0x4000050 //blend modes
#define REG_COLEV *(unsigned short*)0x4000052 //weights

//weights for each object
#define WEIGHTOFA(weight) (weight)
#define WEIGHTOFB(weight) ((weight) << 8)

//object a
#define BG0_A (1 << 0)
#define BG1_A (1 << 1)
#define BG2_A (1 << 2)
#define BG3_A (1 << 3)
#define OBJ_A (1 << 4)
#define BACKDROP_A (1 << 5)

//turn on bg blending
#define NORMAL_TRANS (1 << 6)

//object b
#define BG0_B (1 << 8)
#define BG1_B (1 << 9)
#define BG2_B (1 << 10)
#define BG3_B (1 << 11)
#define OBJ_B (1 << 12)
#define BACKDROP_B (1 << 13)

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





