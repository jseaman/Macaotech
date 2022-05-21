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
    sta COLUP0

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
    
    REPEAT 80
        sta WSYNC
    REPEND

    ;; Dibujar player 0
    lda #$FF                ; a = 0xff
    sta GRP0                ; GRP0 = a
    sta RESP0               ; trigger resp0
    sta WSYNC               ; wait scanline
    ;;

    lda #0                  ; a = 0
    sta GRP0                ; GRP0 = a

    REPEAT 111
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
