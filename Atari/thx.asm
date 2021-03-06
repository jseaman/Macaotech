
	processor 6502
        include "vcs.h"
        include "macro.h"
        include "xmacro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Now that we know how to draw extra-wide sprites, we can
; apply this technique to another type of object: text.
;
; We can draw scoreboards and other kinds of text using the
; playfield registers. However, these are pretty blocky, and
; limited to 40 pixels in width. But we can draw lines of text
; that are 48 pixels width by five pixels high using the
; sprite retriggering trick.
;
; Instead of fetching our bitmap data from ROM, we build a 
; bitmap in RAM using lookup tables. Building the bitmap array
; efficiently is a challenge, because we've got to look up 60
; bytes in memory and combine those into 30 bytes. If we did
; this without regard to performance, it might consume a few
; thousand CPU cycles, which would require 30 or 40 scanlines
; just to set up the sprite.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        seg.u Variables
	org $80

Temp		.byte
WriteOfs	.byte ; offset into dest. array FontBuf	
LoopCount	.byte ; counts scanline when drawing
StrPtr		.word ; pointer to text string
StrLen		.byte ; counts chars when building string
TempSP		.byte ; temp. storage for stack pointer

FontBuf	; 30 bytes for text bitmap
	REPEAT 30
        .byte
        REPEND

LoChar		equ #41	; lowest character value
HiChar		equ #90 ; highest character value

THREE_COPIES    equ %011 ; for NUSIZ registers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	seg Code
        org $f000

Start
	CLEAN_START

NextFrame
	VERTICAL_SYNC

	TIMER_SETUP 37
        lda #$18
        sta COLUP0
        lda #$28
        sta COLUP1
        lda #THREE_COPIES
        sta NUSIZ0
        sta NUSIZ1
        sta WSYNC
        SLEEP 20
        sta RESP0
        sta RESP1
        lda #$10
        sta HMP1
        sta WSYNC
        sta HMOVE
        sta HMCLR
        lda #1
        sta VDELP0
        sta VDELP1
        TIMER_WAIT

	TIMER_SETUP 192

	lda #<String0
        sta StrPtr
        lda #>String0
        sta StrPtr+1
        jsr BuildText	; build the 48x5 bitmap
        jsr DrawText	; draw the bitmap

	lda #<String1
        sta StrPtr
        lda #>String1
        sta StrPtr+1
        jsr BuildText	; build the 48x5 bitmap
        jsr DrawText	; draw the bitmap

        TIMER_WAIT

	TIMER_SETUP 29
        TIMER_WAIT
        jmp NextFrame

; Create the 48x5 bitmap of a line of text, using
; 12 characters pointed to by StrPtr.
; The bitmap is stored in a 30-byte array starting at FontBuf.
BuildText subroutine
        lda #$80
        sta COLUBK
; First, save the original stack pointer.
	tsx
        stx TempSP
; Initialize WriteOfs (dest offset)
; and StrLen (source offset)
	lda #FontBuf+4	; +4 because PHA goes in decreasing order
        sta WriteOfs	; offset into dest. array FontBuf
	ldy #0
        sty StrLen	; start at first character
.CharLoop
; Get next pair of characters.
; Get first character
        lda (StrPtr),y	; load next character
        sec
        sbc #LoChar	; subtract 32 (1st char is Space)
	sta Temp
        asl
        asl
        adc Temp	; multiply by 5
        tax		; first character offset -> X
; Get second character
        iny
        lda (StrPtr),y	; load next character
        sec
        sbc #LoChar	; subtract 32 (1st char is Space)
	sta Temp
        asl
        asl
        adc Temp	; multiply by 5
        iny
        sty StrLen	; StrLen += 2
        tay		; second character offset -> Y
; Setup stack pointer so that successive PHA copy bytes
; to decreasing addresses, starting at WriteOfs.
        txa
	ldx WriteOfs
        txs
        tax
; Write the character to FontBuf, copying all 5 bytes.
; Because we are using PHA, we have essentially three
; registers to work with.
	lda FontTableLo+4,y
        ora FontTableHi+4,x
        pha
	lda FontTableLo+3,y
        ora FontTableHi+3,x
        pha
	lda FontTableLo+2,y
        ora FontTableHi+2,x
        pha
	lda FontTableLo+1,y
        ora FontTableHi+1,x
        pha
	lda FontTableLo+0,y
        ora FontTableHi+0,x
        pha
; Go to next WriteOfs (skip 5 bytess)
        lda WriteOfs
        clc
        adc #5
        sta WriteOfs
.NoIncOfs
; Repeat until we run out of characters.
	ldy StrLen
        cpy #12
        bne .CharLoop
; Restore stack pointer.
        ldx TempSP
        txs
	rts

; Display the resulting 48x5 bitmap from FontBuf
DrawText subroutine
	sta WSYNC
	SLEEP 40	; start near end of scanline
        lda #4
        sta LoopCount
BigLoop
	ldy LoopCount	; counts backwards
        lda FontBuf+0,y	; load B0 (1st sprite byte)
        sta GRP0	; B0 -> [GRP0]
        lda FontBuf+5,y	; load B1 -> A
        sta GRP1	; B1 -> [GRP1], B0 -> GRP0
        sta WSYNC	; sync to next scanline
        lda FontBuf+10,y	; load B2 -> A
        sta GRP0	; B2 -> [GRP0], B1 -> GRP1
        lda FontBuf+25,y	; load B5 -> A
        sta Temp	; B5 -> temp
        ldx FontBuf+20,y	; load B4 -> X
        lda FontBuf+15,y	; load B3 -> A
        ldy Temp	; load B5 -> Y
        sta GRP1	; B3 -> [GRP1]; B2 -> GRP0
        stx GRP0	; B4 -> [GRP0]; B3 -> GRP1
        sty GRP1	; B5 -> [GRP1]; B4 -> GRP0
        sta GRP0	; ?? -> [GRP0]; B5 -> GRP1
        dec LoopCount	; go to next line
	bpl BigLoop	; repeat until < 0
        
        lda #0		; clear the sprite registers
        sta GRP0
        sta GRP1
        sta GRP0
        sta GRP1
        rts

; Unpacked font tables. Each character consists of 5 nibbles
; packed into 5 bytes. There's a table with the bitmap data in
; the low nibble, and one with the bitmap data in the high nibble.
        align $100 ; make sure data doesn't cross page boundary
FontTableLo
	hex 0402020204050205000002070200000402000000070000000004000000000404
        hex 0201010605050503020202060207040201060601020106010107050506010604
        hex 0707050704030404020107070507050706010705070400040000040200020001
        hex 0204020107000700000402010204020002010703040705020505070502060506
        hex 0506030404040306050505060704070407040407040703050704030505070505
        hex 0702020207020501010105050605050704040404050507070505070707050205
        hex 0505020404060506030705050205060705060601020403020202020703050505
        hex 0502020505050507070505050502050502020205050704020107000000000000
        align $100 ; make sure data doesn't cross page boundary
FontTableHi
	hex 4020202040502050000020702000004020000000700000000040000000004040
        hex 2010106050505030202020602070402010606010201060101070505060106040
        hex 7070507040304040201070705070507060107050704000400000402000200010
        hex 2040201070007000004020102040200020107030407050205050705020605060
        hex 5060304040403060505050607040704070404070407030507040305050705050
        hex 7020202070205010101050506050507040404040505070705050707070502050
        hex 5050204040605060307050502050607050606010204030202020207030505050
        hex 5020205050505070705050505020505020202050507040201070000000000000

String0	dc "MUCHAS[[[[[["
String1 dc "GRACIAS[[[[["

; Epilogue
	org $fffc
        .word Start
        .word Start
