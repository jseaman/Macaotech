    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

;; Variables
p0_xPos    .byte
p0_yPos    .byte
p1_xPos    .byte
p1_yPos    .byte
missile_fired   .byte
missile_xPos	.byte
missile_yPos    .byte
p1_yStep        .byte

;; Constants
SPRITE_HEIGHT = 17

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    CLEAN_START  

    lda #$0E
    sta COLUP0

    lda #40
    sta p0_xPos

    lda #40
    sta p0_yPos

    lda #140
    sta p1_xPos

    lda #40
    sta p1_yPos

    lda #$C8
    sta COLUP1
    
    lda #0
    sta COLUBK
        
    
    lda #0
    sta missile_xPos
    sta missile_yPos
    sta missile_fired
    
    lda #1
    sta p1_yStep

StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND 

    lda #0
    sta VSYNC

    lda WSYNC 

    lda p0_xPos
    ldx #0
    jsr SetObjectXPos 
    sta WSYNC

    lda p1_xPos
    ldx #1
    jsr SetObjectXPos 
    sta WSYNC
    
    lda missile_xPos
    ldx #2
    jsr SetObjectXPos 
    sta WSYNC

    sta HMOVE
    
    

    REPEAT 30
        sta WSYNC
    REPEND
       

    lda #0
	sta VBLANK	
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Visible lines
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldy #96 ; Y = 96 scanlines

VisibleLine:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw Player 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    tya ; A = Y
    
    sec ; carry flag
    sbc p0_yPos ; A = A - p0_yPos

    ;  if A < SPRITE_HEIGHT then jump DrawSprite
    cmp #SPRITE_HEIGHT 
    bcc DrawSprite0
    ; else A == 0
    lda #0

DrawSprite0:
    tax ; A = X
    lda Sprite0,x  ; A = Sprite0[x]
    sta GRP0 ; GRPO = A
    lda ColorSprite0,x ; A = ColorSprite0[x]
    sta COLUP0

    sta WSYNC
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw Missile 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    lda #0
    
    ldx missile_fired
    cpx #1
    bne SkipMissile
    
    cpy missile_yPos
    bne SkipMissile
DrawMissile:
    lda #%00000010
SkipMissile:
    sta ENAM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw Player 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    tya ; A = Y
    
    sec ; carry flag
    sbc p1_yPos ; A = A - p0_yPos

    ;  if A < SPRITE_HEIGHT then jump DrawSprite
    cmp #SPRITE_HEIGHT 
    bcc DrawSprite1
    ; else A == 0
    lda #0

DrawSprite1:
    tax ; A = X
    lda Sprite1,x  ; A = Sprite0[x]
    sta GRP1 ; GRPO = A
    
    sta WSYNC

    dey
    bne VisibleLine


    ;; End visible lines

    lda #2
    sta VBLANK

    REPEAT 25
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Joystick input test for P0 up/down/left/right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000
    bit SWCHA
    bne CheckP0Down
    inc p0_yPos

CheckP0Down:
    lda #%00100000
    bit SWCHA
    bne CheckP0Left
    dec p0_yPos

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    dec p0_xPos

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne NoInput
    inc p0_xPos

NoInput:
    ; fallback when no input was performed

    sta WSYNC
    
CheckButtonPressed:
    lda #%10000000           ; if button is pressed
    bit INPT4
    bne EndButtonCheck
    
ButtonPressed:
    lda p0_xPos
    clc 
    adc #5
    sta missile_xPos
    
    lda p0_yPos
    clc
    adc #8
    sta missile_yPos
    
    ldx #1
    stx missile_fired
    
EndButtonCheck:
    sta WSYNC
    

MoveMissile:
    ldx missile_xPos
    inx
    
    cpx #150
    beq DeactivateMissile
    
    stx missile_xPos
    
    jmp EndMissileMove
    
DeactivateMissile:
    ldx #0
    stx missile_fired
    
EndMissileMove:

    sta WSYNC
    
TestMissileCollision:
    ldx #$4

    lda #%10000000
    bit CXM0P
    beq EndMissileTest
    
    ldx #$30
         
EndMissileTest:
    stx COLUBK
    
    sta CXCLR

    sta WSYNC
    
MoveET:
    lda p1_yPos
    beq GoUp
    
    cmp #78
    beq GoDown
    
    jmp ApplyETMovement
    
    
GoDown:
    lda #-1
    sta p1_yStep
    jmp ApplyETMovement

GoUp:
    lda #1
    sta p1_yStep
    jmp ApplyETMovement

ApplyETMovement:
    lda p1_yPos
    clc
    adc p1_yStep
    sta p1_yPos
    sta WSYNC
    
    jmp StartFrame

; SetHorizPos - Sets the horizontal position of an object.
; The X register contains the index of the desired object:
;  X=0: player 0
;  X=1: player 1
;  X=2: missile 0
;  X=3: missile 1
;  X=4: ball
; This routine does a WSYNC both before and after, followed by
; a HMOVE and HMCLR. So it takes two scanlines to complete.
SetObjectXPos subroutine
    sta WSYNC	            ; start a new line
    sec		                ; set carry flag
.DivideLoop
	sbc #15		            ; subtract 15
	bcs .DivideLoop	        ; branch until negative

	eor #7		            ; calculate fine offset
    asl
    asl
    asl
    asl
    sta RESP0,x	            ; fix coarse position
    sta HMP0,x	            ; set fine offset
    rts		                ; return to caller 

Sprite0:
    .byte #0
    .byte #%11001100
    .byte #%01001000
    .byte #%01001000
    .byte #%01111000
    .byte #%00110000
    .byte #%00110000
    .byte #%10110100
    .byte #%10110100
    .byte #%01111000
    .byte #%00110000
    .byte #%00110000
    .byte #%00100000
    .byte #%00110000
    .byte #%01111000
    .byte #%00110000
    .byte #%00110000


ColorSprite0:
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$02
    .byte #$02
    .byte #$02
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$3E
    .byte #$3E
    .byte #$3E
    .byte #$F2
    .byte #$F2
    .byte #$F2

Sprite1:
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
