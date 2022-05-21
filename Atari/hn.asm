    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    sei             ; Disable interrupts
    cld             ; Disable the BCD decimal math mode
    ldx #$FF        ; Loads the X register with #$FF
    txs             ; Transfer the X register to the (S)tack pointer

    

    lda #1
    sta CTRLPF

StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND 

    lda #0
    sta VSYNC 

    lda #$0E
    sta COLUBK
    lda #$AE
    sta COLUPF

    REPEAT 37
        sta WSYNC
    REPEND

    lda #0
	sta VBLANK	
    
    ;; Dibujar marco

    ldy #26

PlayFielfLoop:
    lda PFData0,y
    sta PF0
    lda PFData1,y
    sta PF1
    lda PFData2,y
    sta PF2

    REPEAT 7
        sta WSYNC
    REPEND

    dey
    bpl PlayFielfLoop

    lda #0
    sta PF0
    sta PF1
    sta PF2
    sta COLUBK

    REPEAT 3
        sta WSYNC
    REPEND

    lda #2
    sta VBLANK

    REPEAT 30
        sta WSYNC
    REPEND
    
    jmp StartFrame

PFData0
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
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
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000
    .byte #%11110000

PFData1
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%00000000
    .byte #%11000011
    .byte #%00111100
    .byte #%11011011
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%11000011
    .byte #%00111100
    .byte #%11011011
    .byte #%00000000
    .byte #%00000000
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111

PFData2
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00110000
    .byte #%11000000
    .byte #%10110000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
