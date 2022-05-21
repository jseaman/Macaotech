    processor 6502

    include "vcs.h"

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    sei             ; Disable interrupts
    cld             ; Disable the BCD decimal math mode
    ldx #$FF        ; Loads the X register with #$FF
    txs             ; Transfer the X register to the (S)tack pointer

    lda #32
    sta COLUBK

    lda #50
    sta COLUPF
    
StartFrame:        
    ; Encender VBLANK y VSYNC strobing el valor 2
    lda #2
    sta VBLANK
    sta VSYNC

    ; Esperar 3 lineas

    sta WSYNC
    sta WSYNC
    sta WSYNC

    ; Apagar VSYNC strobing el valor 0

    lda #0
    sta VSYNC

    ; Esperar 37 lineas de Vertical Blank

    ldy #37
VerticalBlank:
    sta WSYNC
    dey 
    bne VerticalBlank

    ; Apagar VBLANK

    lda #0
    sta VBLANK

    ; Dibujar 192 lineas visibles

    ldy #6
DrawUpperBorder:
    lda #%11111111
    sta PF0
    sta PF1
    sta PF2
    sta WSYNC
    dey 
    bne DrawUpperBorder

    ldy #180
VisibleLines:
    lda #0
    sta PF0
    sta PF1
    sta PF2

    sta WSYNC
    dey 
    bne VisibleLines

    ldy #6
DrawLowerBorder:
    lda #%11111111
    sta PF0
    sta PF1
    sta PF2
    sta WSYNC
    dey 
    bne DrawLowerBorder

    ; Encender VBLANK

    lda #2
    sta VBLANK

    ; Esperar 30 lineas de Overscan   

    ldy #30
Overscan:
    sta WSYNC
    dey 
    bne Overscan

    ; Reinicio

    jmp StartFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)















