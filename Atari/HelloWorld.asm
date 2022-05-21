    processor 6502

    seg code
    org $F000       ; Define the code origin at $F000

    
Start:
    sei             ; Disable interrupts
    cld             ; Disable the BCD decimal math mode
    ldx #$FF        ; Loads the X register with #$FF
    txs             ; Transfer the X register to the (S)tack pointer

    ldx #127        ; x = 127
    lda #0          ; a = 0


    ; while (x!=0) // OFF BY ONE

Loop:
    sta $80,x       ; RAM[x] = 0
    dex             ; x--
    bpl Loop        ; Branch if Plus; x >= 0

    ; 6 * 9 = 6 * (2^3 + 1) = 
    ; 6 * 2 * 2 * 2 + 6

    lda #6
    asl             ; a << 1
    asl             ; a << 1
    asl             ; a << 1

    adc #6

    
    jmp Start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
