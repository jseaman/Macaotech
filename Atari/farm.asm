    processor 6502

    include "vcs.h"
    include "macro.h"

PLAYFIELD_HEIGHT = 41

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    CLEAN_START

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

    
    lda #$AE
    sta COLUPF

    REPEAT 37
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK	  

    ; ScoreSpace

    sta PF0
    sta PF1
    sta PF2
    
    lda #$90
    sta COLUBK
    
    ldy #PLAYFIELD_HEIGHT

    REPEAT 23
        sta WSYNC
    REPEND
    
    lda PFColBg,y
    sta COLUBK
    
    lda PFColFg,y
    sta COLUPF
    
    sta WSYNC

PlayFielfLoop:
    lda PFData0,y
    sta PF0
    lda PFData1,y
    sta PF1
    lda PFData2,y
    sta PF2
    
    REPEAT 3
        sta WSYNC
    REPEND
    
    tya
    tax
    dex
    
    bmi SkipColor
    lda PFColBg,x
    sta COLUBK
    
    lda PFColFg,x
    sta COLUPF
SkipColor:
    sta WSYNC

    dey
    bpl PlayFielfLoop
    

    lda #0
    sta PF0
    sta PF1
    sta PF2
    sta COLUBK

    lda #2
    sta VBLANK

    REPEAT 30
        sta WSYNC
    REPEND
    
    jmp StartFrame
    
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
    .byte #%11111111
    .byte #%11111111
    .byte #%00011111
    .byte #%00001111
    .byte #%00000111
    .byte #%00000010
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
    .byte #%01110000
    .byte #%01110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%10110000
    .byte #%11110000
    .byte #%11111100
    .byte #%11111000
    .byte #%11110000
    .byte #%11100000
    .byte #%11000000
    .byte #%10000000
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
    
 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
