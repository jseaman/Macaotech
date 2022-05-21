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


;; Constants
SPRITE_HEIGHT = 9
PF_TITLE = 7

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

    lda #40
    sta xPos0

    lda #40
    sta yPos0

    lda #100
    sta xPos1

    lda #40
    sta yPos1

StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND 

    lda #0
    sta VSYNC 

    lda xPos0
    ldx #0
    jsr SetObjectXPos 

    lda xPos1
    ldx #1
    jsr SetObjectXPos 

    sta WSYNC
    sta HMOVE
    
    REPEAT 34
        sta WSYNC
    REPEND

    lda #0
	sta VBLANK	
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Visible lines
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ;;;;;;;;;
    ;; Draw Title
    ;;;;;;;;;
    
    REPEAT 6
        sta WSYNC
    REPEND

    ldy #PF_TITLE
    dey

TitleLoop:    
    lda PFData2,y
    sta PF2
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC
    dey
    bpl TitleLoop

    ldy #79 ; Y = 79 scanlines

VisibleLine:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Draw Sprite 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    tya                     ; A = Y
    
    sec                     ; carry flag
    sbc yPos0               ; A = A - yPos0

    ;  if A < SPRITE_HEIGHT then jump DrawSprite0
    cmp #SPRITE_HEIGHT 
    bcc DrawSprite0
    ; else A == 0
    lda #0

DrawSprite0:
    tax                     ; A = X
    lda Sprite0,x           ; A = Sprite0[x]
    sta GRP0                ; GRPO = A
    lda ColorSprite0,x      ; A = ColorSprite0[x]
    sta COLUP0

    sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Draw Sprite 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    tya                     ; A = Y
    
    sec                     ; carry flag
    sbc yPos1               ; A = A - yPos1

    ;  if A < SPRITE_HEIGHT then jump DrawSprite1
    cmp #SPRITE_HEIGHT 
    bcc DrawSprite1
    ; else A == 0
    lda #0

DrawSprite1:
    tax                     ; A = X
    lda Sprite1,x           ; A = Sprite1[x]
    sta GRP1                ; GRPO = A
    lda ColorSprite1,x      ; A = ColorSprite0[x]
    sta COLUP1

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
    .byte #%00000000
    .byte #%10101010
    .byte #%01000100
    .byte #%01111100
    .byte #%11111110
    .byte #%01111111
    .byte #%00111110
    .byte #%00000100
    .byte #%00000000

ColorSprite0:
    .byte #0
    .byte #$54
    .byte #$5C
    .byte #$5C
    .byte #$5C
    .byte #$5C
    .byte #$5C
    .byte #$5A
    .byte #$5A

Sprite1:
    .byte #%00000000
    .byte #%11111111
    .byte #%11010101
    .byte #%11010101
    .byte #%11010001
    .byte #%11010101
    .byte #%11010101
    .byte #%10001111
    .byte #%11111111

ColorSprite1:
    .byte #0
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E

PFData2
    .byte #%00000000
    .byte #%00110000
    .byte #%00110000
    .byte #%11000000
    .byte #%11000000
    .byte #%10110000
    .byte #%10110000



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
