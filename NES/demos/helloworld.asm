
	include "nesdefs.asm"

;;;;; ZERO-PAGE VARIABLES

	seg.u ZEROPAGE
	org $0
        
RLEPtr	word
Temp1	byte

	NES_HEADER 0,2,1,0 ; mapper 0, 2 PRGs, 1 CHR, horizontal

Start:
	NES_INIT		; set up stack pointer, turn off PPU
	jsr WaitSync
	jsr WaitSync		;wait for PPU warmup
	jsr ClearRAM		;clear CPU memory
	jsr ClearVRAM		;set PPU RAM
	jsr SetPalette		;set colors
	lda #0
	sta PPU_ADDR
	sta PPU_ADDR		;PPU addr = 0
	sta PPU_SCROLL
	sta PPU_SCROLL		;scroll = 0
	lda #$90
	sta PPU_CTRL		;enable NMI
	lda #$1e
	sta PPU_MASK		;enable rendering
.endless
	jmp .endless		;endless loop, NMI only

; fill video RAM
ClearVRAM: subroutine
	lda #$20
	sta PPU_ADDR
    lda #$00
	sta PPU_ADDR	; PPU addr = $2000
    tax				; X = 0 (inner loop)
	ldy #8			; Y = 8 (outer loop)
    lda #$2f		; A = value to write to VRAM
.loop:
	sta PPU_DATA
	inx
	bne .loop	; repeat 256 times
	dey
	bne .loop	; repeat 8 times
    rts

; set palette colors
SetPalette: subroutine
    ldy #$00
	lda #$3f
	sta PPU_ADDR
	sty PPU_ADDR
	ldx #32
.loop:
	lda Palette,y
	sta PPU_DATA
    iny
	dex
	bne .loop
    rts

; load RLE-compressed data to VRAM
WriteRLE: subroutine
	sta RLEPtr
    sty RLEPtr+1
.nextspan
    ldy #0
	lda (RLEPtr),y	; length
	beq .done
	tax		; X = length in bytes
	iny
	lda (RLEPtr),y	; lo byte
	pha
	iny
	lda (RLEPtr),y	; hi byte
	sta PPU_ADDR	; write hi byte
    pla
	sta PPU_ADDR	; write lo byte
    jsr RLEDoText
	tya
	sec		; + 1 (we didn't iny on last loop)
	adc RLEPtr	; add Y to RLEPtr
	sta RLEPtr
	bcc .nextspan	; no overflow
	inc RLEPtr+1
	bne .nextspan 	; branch almost always taken
.done
	rts

; translate ASCII to tiles and copy to VRAM
RLEDoText:
	iny
	lda (RLEPtr),y	; hi byte
	stx Temp1
	sec
	sbc #$20
	tax
	lda ASCII2Tile,x
	ldx Temp1
	sta PPU_DATA
	dex
	bne RLEDoText
	rts

ASCII2Tile:
	hex 2f242d2b 252d2d29 2d2d2d2d 2a27282d	; 20
	hex 00010203 04050607 08092600 00000000 ; 30
	hex 2f0a0b0c 0d0e0f10 11121314 15161718 ; 40
	hex 191a1b1c 1d1e1f20 2122232d 2d2d2d2c ; 50

;;;;; COMMON SUBROUTINES

	include "nesppu.asm"

;;;;; INTERRUPT HANDLERS

NMIHandler: subroutine
	lda #<HelloWorld
	ldy #>HelloWorld
	jsr WriteRLE		;write "hello world" message
	; restore PPU
	lda #0
	sta PPU_ADDR
	lda #0
	sta PPU_ADDR
	rti

;;;;; CONSTANT DATA

Palette:
	hex 1f		;background
	hex 0909191f	;bg0
	hex 0909191f	;bg1
	hex 0909191f	;bg2
	hex 0909191f	;bg3
	hex 14243400	;sp0
	hex 15253500	;sp1
	hex 16263600	;sp2
	hex 17273700	;sp3        

HelloWorld:
	byte 12
	word $2000 + (32*12) + 11
	byte "HELLO WORLD!"
        
	byte 32
	word $2041
	byte "ABCDEF0123456789"
	byte "$!:-.',#_       "

	byte 0

;;;;; CPU VECTORS

	NES_VECTORS

;;;;; TILE SETS

	org $10000
; OAM (sprite) pattern table
	REPEAT 256
	hex 00000000000000000000000000000000
    REPEND
; background (tile) pattern table
	REPEAT 5
;;{w:8,h:8,bpp:1,count:48,brev:1,np:2,pofs:8,remap:[0,1,2,4,5,6,7,8,9,10,11,12]};;
	hex 7e42424646467e007e42424646467e00
	hex 08080818181818000808081818181800
	hex 3e22023e30303e003e22023e30303e00
	hex 3c24041e06263e003c24041e06263e00
	hex 4444447e0c0c0c004444447e0c0c0c00
	hex 3c20203e06263e003c20203e06263e00
	hex 3e22203e26263e003e22203e26263e00
	hex 3e020206060606003e02020606060600
	hex 3c24247e46467e003c24247e46467e00
	hex 3e22223e060606003e22223e06060600
	hex 3c24247e626262003c24247e62626200
	hex 7c44447e62627e007c44447e62627e00
	hex 7e42406060627e007e42406060627e00
	hex 7e42426262627e007e42426262627e00
	hex 7c40407c60607c007c40407c60607c00
	hex 3c20203c303030003c20203c30303000
	hex 7e42406e62627e007e42406e62627e00
	hex 4242427e626262004242427e62626200
	hex 10101018181818001010101818181800
	hex 0404040606467e000404040606467e00
	hex 4444447e626262004444447e62626200
	hex 2020203030303e002020203030303e00
	hex fe9292d2d2d2d200fe9292d2d2d2d200
	hex 7e424262626262007e42426262626200
	hex 7e46464242427e007e46464242427e00
	hex 7e42427e606060007e42427e60606000
	hex 7e424242424e7e007e424242424e7e00
	hex 7c44447e626262007c44447e62626200
	hex 7e42407e06467e007e42407e06467e00
	hex 7e101018181818007e10101818181800
	hex 4242426262627e004242426262627e00
	hex 646464642c2c3c00646464642c2c3c00
	hex 4949494969697f004949494969697f00
	hex 4242423c626262004242423c62626200
	hex 4242427e181818004242427e18181800
	hex 7e42027e60627e007e42027e60427e00
	hex 10101818180018001010181818001800
	hex 187e407e067e1800187e407e067e1800
	hex 00180018180000000018001818000000
	hex 00003c3c0000000000003c3c00000000
	hex 00000018180000000000001818000000
	hex 18180810000000001818081000000000
	hex 00000018180810000000001818081000
	hex 7c7c7c7c7c7c7c007c7c7c7c7c7c7c00
	hex 0000000000007c000000000000007c00
	hex 00000000000000000000000000000000
	hex 00000000000000000000000000000000
	hex 00000000000000000000000000000000
;;
	REPEND

	REPEAT 15
	hex 00000000000000000000000000000000
	REPEND
	hex 00000000000000000000000000000000

