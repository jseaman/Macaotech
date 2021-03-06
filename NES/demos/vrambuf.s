;
; File generated by cc65 v 2.18 - Git e091fc00
;
	.fopt		compiler,"cc65 v 2.18 - Git e091fc00"
	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.debuginfo	off
	.importzp	sp, sreg, regsave, regbank
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
	.macpack	longbranch
	.import		_ppu_wait_frame
	.export		_updptr
	.export		_vrambuf_end
	.export		_vrambuf_clear
	.export		_vrambuf_flush
	.export		_vrambuf_put
	.import		_memcpy

.segment	"DATA"

_updptr:
	.byte	$00

; ---------------------------------------------------------------
; void __near__ vrambuf_end (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_vrambuf_end: near

.segment	"CODE"

	ldx     #$01
	lda     #$00
	clc
	adc     _updptr
	bcc     L0007
	inx
L0007:	jsr     pushax
	ldx     #$00
	lda     #$FF
	ldy     #$00
	jsr     staspidx
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ vrambuf_clear (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_vrambuf_clear: near

.segment	"CODE"

	ldx     #$00
	lda     #$00
	sta     _updptr
	jsr     _vrambuf_end
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ vrambuf_flush (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_vrambuf_flush: near

.segment	"CODE"

	jsr     _vrambuf_end
	jsr     _ppu_wait_frame
	jsr     _vrambuf_clear
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ vrambuf_put (unsigned short, __near__ const unsigned char *, unsigned char)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_vrambuf_put: near

.segment	"CODE"

	jsr     pusha
	ldx     #$00
	lda     #$7C
	jsr     pushax
	ldy     #$02
	ldx     #$00
	lda     (sp),y
	jsr     tossubax
	jsr     pushax
	ldx     #$00
	lda     _updptr
	jsr     tosultax
	jeq     L0013
	jsr     _vrambuf_flush
L0013:	ldx     #$01
	lda     #$00
	clc
	adc     _updptr
	bcc     L0019
	inx
L0019:	jsr     pushax
	ldy     #$06
	jsr     ldaxysp
	txa
	ldx     #$00
	eor     #$40
	ldx     #$00
	ldy     #$00
	jsr     staspidx
	ldx     #$00
	inc     _updptr
	lda     _updptr
	ldx     #$01
	lda     #$00
	clc
	adc     _updptr
	bcc     L0021
	inx
L0021:	jsr     pushax
	ldy     #$05
	ldx     #$00
	lda     (sp),y
	ldy     #$00
	jsr     staspidx
	ldx     #$00
	inc     _updptr
	lda     _updptr
	ldx     #$01
	lda     #$00
	clc
	adc     _updptr
	bcc     L0028
	inx
L0028:	jsr     pushax
	ldy     #$02
	ldx     #$00
	lda     (sp),y
	ldy     #$00
	jsr     staspidx
	ldx     #$00
	inc     _updptr
	lda     _updptr
	ldx     #$00
	lda     _updptr
	jsr     pushax
	ldx     #$01
	lda     #$00
	jsr     tosaddax
	jsr     pushax
	ldy     #$04
	jsr     ldaxysp
	jsr     pushax
	ldy     #$04
	ldx     #$00
	lda     (sp),y
	ldx     #$00
	jsr     _memcpy
	ldy     #$00
	ldx     #$00
	lda     (sp),y
	ldx     #$00
	ldx     #$00
	clc
	adc     _updptr
	sta     _updptr
	jsr     _vrambuf_end
	jsr     incsp5
	rts

.endproc

