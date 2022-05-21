    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

;; Variables
xPos    .byte
yPos    .byte

;; Constants
SPRITE_HEIGHT = 9

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

    lda #10
    sta yPos

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

    ldy #96 ; Y = 192 scanlines

VisibleLine:
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
    lda PigFrame0,x  ; A = Sprite0[x]
    sta GRP0 ; GRPO = A
    lda PigColor,x ; A = ColorSprite0[x]
    sta COLUP0

    sta WSYNC
    sta WSYNC
    
    dey
    bne VisibleLine


    ;; End visible lines

    lda #2
    sta VBLANK

    REPEAT 29
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Joystick input test for P0 up/down/left/right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000
    bit SWCHA
    bne CheckP0Down
    inc yPos

CheckP0Down:
    lda #%00100000
    bit SWCHA
    bne CheckP0Left
    dec yPos

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    dec xPos

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne NoInput
    inc xPos

NoInput:
    ; fallback when no input was performed

    sta WSYNC
    
    jmp StartFrame

SetObjectXPos subroutine
    and #127
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

;---Graphics Data from PlayerPal 2600--- XERDO

PigFrame0
	.byte #%00000000;$54
    .byte #%10101010;$54
    .byte #%01000100;$5C
    .byte #%01111100;$5C
    .byte #%11111110;$5C
    .byte #%01111111;$5C
    .byte #%00111110;$5C
    .byte #%00000100;$5A
    .byte #%00000000;$5A
PigFrame1
	.byte #%00000000;$54
    .byte #%01000100;$54
    .byte #%01000100;$5C
    .byte #%01111100;$5C
    .byte #%11111110;$5C
    .byte #%01111111;$5C
    .byte #%00111110;$5C
    .byte #%00000100;$5A
    .byte #%00000000;$5A
;---End Graphics Data---


;---Color Data from PlayerPal 2600--- 

PigColor
	.byte #$54;
    .byte #$54;
    .byte #$5C;
    .byte #$5C;
    .byte #$5C;
    .byte #$5C;
    .byte #$5C;
    .byte #$5A;
    .byte #$5A;
;---End Color Data---

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
