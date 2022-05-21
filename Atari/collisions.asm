    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

;; Variables
xPos            .byte
yPos            .byte
houseLine       .byte

;; Constants
SPRITE_HEIGHT = 13

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    CLEAN_START  

    lda #$94
    sta COLUBK

    lda #$0E
    sta COLUP0

    lda #40
    sta xPos

    lda #40
    sta yPos
    
    lda #1
    sta CTRLPF   ; Playfield Reflection

StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND 

    lda #0
    sta VSYNC 

    lda xPos
    jsr SetObjectXPos 
    sta WSYNC
    sta HMOVE

    REPEAT 35
        sta WSYNC
    REPEND

    lda #0
	sta VBLANK	
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Visible lines
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #$0E
    sta COLUPF

    
    lda #18
    sta houseLine
    
    ldy #96 ; Y = 192 scanlines
    

VisibleLine:


DrawPlayfield:
    tya
    
    cmp #55
    bcs BeginDrawSprite
    
    dec houseLine
    bmi BeginDrawSprite
    
    ldx houseLine
    lda House,x
    sta PF2
    

BeginDrawSprite:
    sta WSYNC
    tya ; A = Y
    
    sec ; carry flag
    sbc yPos ; A = A - yPos

    ;  if A < SPRITE_HEIGHT then jump DrawSprite
    cmp #SPRITE_HEIGHT 
    bcc DrawSprite
    ; else A == 0
    lda #0

DrawSprite:
    tax ; A = X
    lda Sprite0,x  ; A = Sprite0[x]
    sta GRP0 ; GRPO = A
    lda ColorSprite0,x ; A = ColorSprite0[x]
    sta COLUP0

    sta WSYNC

    dey
    bne VisibleLine


    ;; End visible lines

    lda #2
    sta VBLANK

    REPEAT 28
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Joystick input test for P0 up/down/left/right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000
    bit SWCHA
    bne CheckP0Down
    lda yPos
    cmp #82
    beq CheckP0Down
    inc yPos

CheckP0Down:
    lda #%00100000
    bit SWCHA
    bne CheckP0Left
    lda yPos
    cmp #5
    beq CheckP0Left
    dec yPos

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    lda xPos
    cmp #8
    beq CheckP0Right
    lda #0
    sta REFP0
    dec xPos    

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne NoInput
    lda xPos
    cmp #148
    beq NoInput
    lda #8
    sta REFP0
    inc xPos

NoInput:
    ; fallback when no input was performed
    
TestCollision:
    lda #%10000000
    bit CXP0FB
    
    beq NoCollision
    lda #$30
    sta COLUBK
    jmp ClearCollisions
    
NoCollision:
    lda #$94
    sta COLUBK

ClearCollisions:
    sta CXCLR
    sta WSYNC

    sta WSYNC
    
    jmp StartFrame
     

SetObjectXPos subroutine
    sta WSYNC                ; start a fresh new scanline
    sec                      ; make sure carry-flag is set before subtracion
.Div15Loop
    sbc #15                  ; subtract 15 from accumulator
    bcs .Div15Loop           ; loop until carry-flag is clear
    eor #7                   ; handle offset range from -8 to 7
    asl
    asl
    asl
    asl                      ; four shift lefts to get only the top 4 bits
    sta HMP0                 ; store the fine offset to the correct HMxx
    sta RESP0                ; fix object position in 15-step increment
    rts

Sprite0:
    .byte #%00000000
    .byte #%11100111
    .byte #%01100011
    .byte #%00101011
    .byte #%00111111
    .byte #%10111111
    .byte #%11111111
    .byte #%00001111
    .byte #%00000111
    .byte #%11000011
    .byte #%11111111
    .byte #%10111111
    .byte #%11111110


ColorSprite0:
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    .byte #$C8
    
    
House:
    .byte #%00000000
    .byte #%00000000
    .byte #%11110000
    .byte #%11110000
    .byte #%10110000
    .byte #%10110000
    .byte #%11110000
    .byte #%11110000
    .byte #%10110000
    .byte #%10110000
    .byte #%11111100
    .byte #%11111100
    .byte #%11111000
    .byte #%11111000
    .byte #%11110000
    .byte #%11110000
    .byte #%11100000
    .byte #%11100000
    .byte #%11000000
    .byte #%11000000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
