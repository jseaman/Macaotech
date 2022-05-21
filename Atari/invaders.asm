    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

;; Variables
xPos0                   .byte
xPos1                   .byte
yPos0                   .byte
yPos1                   .byte
temp                    .byte
yPosOffset              .byte
invaderSpritePtr        .word
invaderSpriteOffset     .byte
invaderStep             .byte
frameCount              .byte


;; Constants
SPRITE_HEIGHT = 10
PF_TITLE = 7
ANIMATION_WAIT = 10

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    CLEAN_START  

    lda #$94
    sta COLUBK

    lda #$0E
    sta COLUPF

    lda #1
    sta CTRLPF
    
    lda #35
    sta xPos0
    
    lda #83
    sta xPos1

    lda #120
    sta yPos0
    
    lda #100
    sta yPos1
    
    lda #$FA
    sta COLUP0
    sta COLUP1
    
    lda #3
    sta NUSIZ0
    sta NUSIZ1
    
    lda #0
    sta yPosOffset
    
    ; Initialize invader pointer
    lda #<Sprite0
    sta invaderSpritePtr
    lda #>Sprite0
    sta invaderSpritePtr+1
    
    lda #0
    sta invaderSpriteOffset
    
    lda #1
    sta invaderStep
    
    lda #ANIMATION_WAIT
    sta frameCount

StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND 

    lda #0
    sta VSYNC 
    
    REPEAT 37
        sta WSYNC
    REPEND

    lda #0
	sta VBLANK	
        
    lda #0
    sta invaderSpriteOffset
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Visible lines
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ldy #192 ; Y = 192 scanlines

VisibleLine:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Draw Sprite 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda yPosOffset
    tax
    
    tya ; A = Y
    
    
    sec ; carry flag
    sbc yPos0,x ; A = A - yPos0

    ;  if A < SPRITE_HEIGHT then jump DrawSprite
    cmp #SPRITE_HEIGHT 
    beq SetInvader0Pos
    bcc DrawInvader0
    bmi ChangeInvader
    jmp ContinueInvading
    ; else A == 0
    
ChangeInvader:
    lda #SPRITE_HEIGHT 
    sta invaderSpriteOffset
    
    lda yPosOffset
    eor #1
    sta yPosOffset
    

ContinueInvading:
    lda #0
    jmp DrawInvader0
    
SetInvader0Pos:
   sta temp
   
   lda xPos0
   ldx #0
   jsr SetObjectXPos
   sta WSYNC
   
   lda xPos1
   ldx #1
   jsr SetObjectXPos
   sta WSYNC
   
   sta HMOVE
   
   lda temp
   
DrawInvader0:
    clc
    adc invaderSpriteOffset
    
    sty temp
    
    tay ; A = X
    lda (invaderSpritePtr),Y  ; A = Sprite0[x]
    sta GRP0 ; GRPO = A
    sta GRP1
    
    ldy temp

    sta WSYNC

    dey
    bne VisibleLine


    ;; End visible lines

    lda #2
    sta VBLANK
    
    dec frameCount
    beq MoveInvaders
    jmp ContinueNextFrame
    
MoveInvaders:
    lda #ANIMATION_WAIT
    sta frameCount

    lda xPos1
    clc
    adc invaderStep
    sta xPos1
    
    lda xPos0
    clc
    adc invaderStep
    sta xPos0
    
    
    cmp #65
    beq ChangeToLeft
    
    cmp #25
    beq ChangeToRight
    
    jmp ContinueNextFrame
    
ChangeToLeft:
   lda #-1
   sta invaderStep
   jmp ContinueNextFrame
   
ChangeToRight:
   lda #1
   sta invaderStep
   jmp ContinueNextFrame

ContinueNextFrame:
    
    
    sta WSYNC

    REPEAT 29
        sta WSYNC
    REPEND
    
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
    sta WSYNC	; start a new line
    sec		; set carry flag
.DivideLoop
	sbc #15		; subtract 15
	bcs .DivideLoop	; branch until negative

	eor #7		; calculate fine offset
    asl
    asl
    asl
    asl
    sta RESP0,x	; fix coarse position
    sta HMP0,x	; set fine offset
    rts		; return to caller 

Sprite0:
    .byte #0
    .byte #%01100110
    .byte #%00100010
    .byte #%00100010
    .byte #%00100010
    .byte #%11111010
    .byte #%11001111
    .byte #%11001111
    .byte #%01111110
    .byte #%00111100


Sprite1:
    .byte #0
    .byte #%11000110
    .byte #%01000010
    .byte #%01111110
    .byte #%01010110
    .byte #%01111100
    .byte #%00011001
    .byte #%00100101
    .byte #%01000010
    .byte #%10000000

    ;; OFF BY ONE, JODER!!
    .byte #0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
