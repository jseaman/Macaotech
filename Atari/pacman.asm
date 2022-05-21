    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

;; Variables
xPos0    .byte
yPos0    .byte
xPos1    .byte
yPos1    .byte

xGhostPos0 .byte
xGhostPos1 .byte
xGhostPos2 .byte
xGhostPos3 .byte

yGhostPos0 .byte
yGhostPos1 .byte
yGhostPos2 .byte
yGhostPos3 .byte

ghostOffset .byte


;; Constants
SPRITE_HEIGHT = 9

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    CLEAN_START  

    lda #$94
    sta COLUBK

    lda #$0E
    sta COLUPF

    lda #$1E
    sta COLUP0

    lda #$40
    sta COLUP1

    lda #40
    sta xPos0

    lda #40
    sta yPos0

    lda #40
    sta yGhostPos0
    sta yGhostPos1
    sta yGhostPos2
    sta yGhostPos3

    lda #70
    sta xGhostPos0
    lda #90
    sta xGhostPos1
    lda #110
    sta xGhostPos2
    lda #130
    sta xGhostPos3

    lda #0
    sta ghostOffset


StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND 

    lda #0
    sta VSYNC 

    ldx ghostOffset             ; x = ghostOffset
    lda xGhostPos0,x            ; a = xGhostPost0[x]
    sta xPos1                   ; xPos1 = a
    lda yGhostPos0,x            ; a = yGhostPost0[x]
    sta yPos1                   ; yPos = a
    lda GhostColor,x            ; a = GhostColor[x]
    sta COLUP1                  ; COLUP1 = a
    inx                         ; x++ // x = x+1
    txa                         ; a = x
    and #%00000011              ; a = a & 3 // 00000011  // 0 <= a <= 3
    sta ghostOffset             ; ghostOffset = a
    
    sta WSYNC
    
    lda xPos0
    ldx #0
    jsr SetObjectXPos 

    lda xPos1
    ldx #1
    jsr SetObjectXPos 

    sta WSYNC
    sta HMOVE
    
    REPEAT 33
        sta WSYNC
    REPEND

    lda #0
	sta VBLANK	
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Visible lines
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ldy #96 ; Y = 96 scanlines

VisibleLine:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Draw Sprite 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    tya ; A = Y
    
    sec ; carry flag
    sbc yPos0 ; A = A - yPos0

    ;  if A < SPRITE_HEIGHT then jump DrawSprite
    cmp #SPRITE_HEIGHT 
    bcc DrawSprite0
    ; else A == 0
    lda #0

DrawSprite0:
    tax ; A = X
    lda Sprite0,x  ; A = Sprite0[x]
    sta GRP0 ; GRPO = A

    sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Draw Sprite 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    tya ; A = Y
    
    sec ; carry flag
    sbc yPos1 ; A = A - yPos1

    ;  if A < SPRITE_HEIGHT then jump DrawSprite
    cmp #SPRITE_HEIGHT 
    bcc DrawSprite1
    ; else A == 0
    lda #0

DrawSprite1:
    tax ; A = X
    lda Sprite1,x  ; A = Sprite1[x]
    sta GRP1 ; GRPO = A

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
    .byte #%00000000
    .byte #%00111000
    .byte #%01111100
    .byte #%11111110
    .byte #%11110000
    .byte #%11111110
    .byte #%11111100
    .byte #%01101100
    .byte #%00111000

Sprite1:
    .byte #%00000000
    .byte #%01010101
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11011101
    .byte #%10011001
    .byte #%01111110
    .byte #%00111100

GhostColor:
    .byte #$40
    .byte #$5C
    .byte #$3E
    .byte #$AC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
