    processor 6502

    include "vcs.h"
    include "macro.h"
    
    seg.u Variables
    org $80
    
pigXpos .byte
pigYpos .byte
cowXpos .byte
cowYpos .byte
PFLine .byte
farmLine .byte
fenceLine .byte
temp .byte

 

PLAYFIELD_HEIGHT = 41
SPRITE_HEIGHT = 9

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    CLEAN_START
    
    
    lda #30
    sta pigXpos
    lda #20
    sta pigYpos
    
    lda #120
    sta cowXpos
    lda #50
    sta cowYpos

    lda #1
    sta CTRLPF   ; Playfield Reflection
    
    MAC DRAW_PIG
      sec ; carry flag
      sbc pigYpos ; A = A - yPos

      ;  if A < SPRITE_HEIGHT then jump DrawSprite
      cmp #SPRITE_HEIGHT 
      bcc .DrawPig
      ; else A == 0
      lda #0

.DrawPig:
      tax ; A = X
      lda PigFrame0,x  ; A = Sprite0[x]
      sta GRP0 ; GRPO = A
      lda PigColor,x ; A = ColorSprite0[x]
      sta COLUP0  
    ENDM
    
    MAC DRAW_COW
      sec ; carry flag
      sbc cowYpos ; A = A - yPos

      ;  if A < SPRITE_HEIGHT then jump DrawSprite
      cmp #SPRITE_HEIGHT 
      bcc .DrawCow
      ; else A == 0
      lda #0

.DrawCow:
      tax ; A = X
      lda CowFrame0,x  ; A = Sprite0[x]
      sta GRP1 ; GRPO = A
      lda CowColor,x ; A = ColorSprite0[x]
      sta COLUP1
   ENDM

StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND 

    lda #0
    sta VSYNC 

    sta HMCLR

    lda pigXpos
    ldx #0
    jsr SetHorizPos 
    
    lda cowXpos
    ldx #1
    jsr SetHorizPos 

    sta WSYNC
    sta HMOVE	; apply the previous fine position(s)

    REPEAT 34
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK	  

    ; ScoreSpace

    sta PF0
    sta PF1
    sta PF2
    sta COLUPF
    
    lda #$90
    sta COLUBK
    

    REPEAT 27
        sta WSYNC
    REPEND
    
    lda #$C4
    sta COLUBK
    
    lda #28
    sta farmLine
    
    lda #6
    sta fenceLine
        
    
    lda #0
    sta COLUPF
    
   
    ldy #82
    
    sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Playfield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayFieldLoop:
   
 
DrawFence:  
    tya
  
    cmp #6
    bcs DrawFarm
    
    dec fenceLine
    bmi DrawFarm
    
    ldx fenceLine
    
    lda FencePF1,x
    sta PF1
    
    lda FencePF2,x
    sta PF2
    
    lda FenceColor,x
    sta COLUPF
    
    
DrawFarm:
    tya ; A = Y
    DRAW_PIG
    sta WSYNC
    
    tya
    
    cmp #55
    bcs DrawCow
    
    
    
    dec farmLine
    bmi DrawCow        
  
    ldx farmLine
    lda Farm,x
    sta PF2
    
    lda FarmColor,x
    sta COLUPF
    
    
    
DrawCow    
    tya
    DRAW_COW
    sta WSYNC   
    
    dey
    bne PlayFieldLoop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    
    
    

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
    lda pigYpos
    cmp #75
    beq CheckP0Down
    inc pigYpos

CheckP0Down:
    lda #%00100000
    bit SWCHA
    bne CheckP0Left
    dec pigYpos

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    lda pigXpos
    cmp #25
    beq CheckP0Right
    dec pigXpos

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne NoInputP0
    lda pigXpos
    cmp #140
    beq NoInputP0
    inc pigXpos

NoInputP0:
    ; fallback when no input was performed

    sta WSYNC

CheckP1Up:
    lda #%00000001
    bit SWCHA
    bne CheckP1Down
    lda cowYpos
    cmp #75
    beq CheckP1Down
    inc cowYpos

CheckP1Down:
    lda #%00000010
    bit SWCHA
    bne CheckP1Left
    dec cowYpos

CheckP1Left:
    lda #%00000100
    bit SWCHA
    bne CheckP1Right
    lda cowXpos
    cmp #25
    beq CheckP1Right
    dec cowXpos

CheckP1Right:
    lda #%00001000
    bit SWCHA
    bne NoInputP1
    lda cowXpos
    cmp #140
    beq NoInputP1
    inc cowXpos

NoInputP1:
    ; fallback when no input was performed

    sta WSYNC
    
    jmp StartFrame

    
; SetHorizPos2 - Sets the horizontal position of an object.
; The X register contains the index of the desired object:
;  X=0: player 0
;  X=1: player 1
;  X=2: missile 0
;  X=3: missile 1
;  X=4: ball
; This routine does a WSYNC both before and after, followed by
; a HMOVE and HMCLR. So it takes two scanlines to complete.
SetHorizPos
        sta WSYNC	; start a new line
        sec		; set carry flag
DivideLoop
	sbc #15		; subtract 15
	bcs DivideLoop	; branch until negative
	eor #7		; calculate fine offset
    asl
    asl
    asl
    asl
    sta RESP0,x	; fix coarse position
    sta HMP0,x	; set fine offset
    rts		; return to caller 
    
    
Farm:
    .byte #%00000000
    .byte #%00000000
    .byte #%01110000
    .byte #%01110000
    .byte #%01110000
    .byte #%01110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%10110000
    .byte #%10110000
    .byte #%11110000
    .byte #%11110000
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
    .byte #%10000000
    .byte #%10000000
    
FarmColor:
    .byte #$F4
    .byte #$30
    .byte #$30
    .byte #$30
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    

FencePF1:
    .byte #%00100100
    .byte #%00100100
    .byte #%00100100
    .byte #%00100100
    .byte #%11111111
    .byte #%11111111

FencePF2:
    .byte #%01001001
    .byte #%01001001
    .byte #%01001001
    .byte #%01001001
    .byte #%11111111
    .byte #%11111111


FenceColor:
    .byte #$F2
    .byte #$F2
    .byte #$F2
    .byte #$F2
    .byte #$F4
    .byte #$F4
        
    
PFColBg
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #$C4
    .byte #10
    .byte #$9C
    .byte #$9A
    .byte #$98
    .byte #$96
    .byte #$94
    .byte #$92    
    .byte #$90
    
    
PFColFg
    .byte #$F2
    .byte #$F2
    .byte #$F4
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #$30
    .byte #$30
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #$F0
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #20
    .byte #$F2
    .byte #$DA
    .byte #$DA
    .byte #$DA
    .byte #$DA
    .byte #$DA
    .byte #$1E
    .byte #$1E


PFData0
    .byte #%10010000
    .byte #%10010000
    .byte #%11110000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000    
    .byte #%11110000
    .byte #%11110000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000

PFData1
    .byte #%00100100
    .byte #%00100100
    .byte #%11111111
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #0;#%11111111
    .byte #0;#%11111111
    .byte #0;#%00011111
    .byte #0;#%00001111
    .byte #0;#%00000111
    .byte #0;#%00000010
    .byte #%00000000
    .byte #%00000000

PFData2
    .byte #%01001001
    .byte #%01001001
    .byte #%11111111
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #0;#%01110000
    .byte #0;#%01110000
    .byte #0;#%11110000
    .byte #0;#%11110000
    .byte #0;#%11110000
    .byte #0;#%10110000
    .byte #0;#%11110000
    .byte #0;#%11111100
    .byte #0;#%11111000
    .byte #0;#%11110000
    .byte #0;#%11100000
    .byte #0;#%11000000
    .byte #0;#%10000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%11111111
    .byte #%11111111
    .byte #%00000011
    .byte #%00000001
    .byte #%00000000
    .byte #%00000000
    .byte #%10000000
    .byte #%10000000
    
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

;---Graphics Data from PlayerPal 2600---  VACA

CowFrame0
    .byte #%00000000;$54
    .byte #%10101010;$02
    .byte #%01000100;$0E
    .byte #%01111110;$0E
    .byte #%11111110;$0E
    .byte #%01010111;$0E
    .byte #%01111111;$0E
    .byte #%00001110;$0E
    .byte #%00001010;$F2
CowFrame1
	.byte #%00000000;$54
    .byte #%01000100;$02
    .byte #%01000100;$0E
    .byte #%01111110;$0E
    .byte #%11111110;$0E
    .byte #%01010111;$0E
    .byte #%01111111;$0E
    .byte #%00001110;$0E
    .byte #%00001010;$F2
;---End Graphics Data---


;---Color Data from PlayerPal 2600---

CowColor
    .byte #0
    .byte #$02;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$F2;
ColorFrame1
    .byte #$02;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$F2;
;---End Color Data---
     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
