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

    lda #$94
    sta COLUBK

    lda #$0E
    sta COLUPF

    lda #1
    sta CTRLPF   ; CTRLPF = 1

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
    
    ;; Dibujar marco

    REPEAT 6
        lda #%11111111
        sta PF0
        sta PF1
        sta PF2
        sta WSYNC
    REPEND

    REPEAT 180
        ; 7 6 5 4 3 2 1 0
        ; 0 0 0 1 0 0 0 0


        lda #%00010000
        sta PF0

        lda #0
        sta PF1
        sta PF2
        sta WSYNC
    REPEND

    REPEAT 6
        lda #%11111111
        sta PF0
        sta PF1
        sta PF2
        sta WSYNC
    REPEND

    lda #2
    sta VBLANK

    REPEAT 30
        sta WSYNC
    REPEND
    
    jmp StartFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
