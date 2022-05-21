    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

;; Variables
xPos    .byte
yPos    .byte

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

    lda #14
    sta xPos

    lda #80
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

    ldy #192 ; Y = 192 scanlines

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
    tax ; X = A
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

    REPEAT 30
        sta WSYNC
    REPEND
    
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
