funcFadeSprites:
    ldy SPRITE_COLOR_DELAY
    ldx SPRITE_COLORS_PTR
    iny
	cpy #$03
	bne !skip+
	ldy #$00
    inx
    cpx #$40
    bne !skip+
    ldx #$00 
!skip:
    sty SPRITE_COLOR_DELAY
    stx SPRITE_COLORS_PTR
	lda SPRITE_COLORS,x
	sta $d027
	sta $d028
	sta $d029
	sta $d02a
	sta $d02b
	sta $d02c
	sta $d02d
	sta $d02e
	rts

SPRITE_COLORS:
.byte $09, $08, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
.byte $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $08, $09, $00
.byte $05, $0c, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
.byte $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0c, $05, $00

SPRITE_COLORS_PTR:
.byte $00

SPRITE_COLOR_DELAY:
.byte $00
