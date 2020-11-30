.pc = * "SPRITE CHAR PLOTTER"
funcDrawValue:
	clc
    cmp #$0a //(alphabetic digit?)
    bcc !skip+ //  (no, skip next part)
    sec
    sbc #$09 //alpha
    jmp !doit+
!skip:
    adc #$30 //number
!doit:
	ldx #$02
	ldy #$01
	jsr funcDrawCharOnSprite
	rts

funcDrawSettings:
	ldx #< LABEL1
	ldy #> LABEL1
	lda #$00
	jsr funcDrawStringLine
	ldx #< LABEL3
	ldy #> LABEL3
	lda #$01
	jsr funcDrawStringLine
	rts

funcUpdateSettings:
	lda #$01
	jsr funcDrawStringLine
    lda #$ff
	rts

funcResetSettings:
	ldx #< LABEL3
	ldy #> LABEL3
	lda #$01
	jsr funcDrawStringLine
	rts

LABEL1:
	.text "plasmatoy v2.0  "
	.byte $00
LABEL3:
	.text "use keyboard to play... "
	.byte $00
LABEL4:
	.text "$0  : plasma zoom       "
	.byte $00
LABEL5:
	.text "$0  : plasma x speed    "
	.byte $00
LABEL6:
	.text "$0  : plasma y speed    "
	.byte $00
LABEL7:
	.text "$0  : plasma color 1    "
	.byte $00
LABEL8:
	.text "$0  : plasma color 2    "
	.byte $00
LABEL9:
	.text "$0  : plasma color 3    "
	.byte $00
LABELA:
	.text "$0  : plasma color 4    "
	.byte $00
LABELB:
	.text "$0  : plasma color 5    "
	.byte $00
LABELC:
	.text "$0  : plasma color 6    "
	.byte $00
LABELD:
	.text "$0  : plasma color 7    "
	.byte $00
LABELE:
	.text "$0  : plasma color 8    "
	.byte $00
LABELF:
	.text "$0  : plasma preset     "
	.byte $00


//x lo
//y hi
//a is row
funcDrawStringLine:
	sta desRow + 1
	stx srcString + 1
	sty srcString + 2
	ldx #$00
desRow:
	ldy #$00
srcString:
	lda $1000,x
	beq !end+
	jsr funcDrawCharOnSprite
	inx
	beq !end+
	jmp srcString
!end:
	rts


//a contains the letter
//x contains sprite char (x/8)
//y contains the pixel
funcDrawCharOnSprite:
	stx sSaveX
	sty sSaveY
	sta tmpChar
	lda #$00
	sta SpriteOffsetHi
	txa
	asl
	tax
	lda SPRFONTXOFFSETS,x
	sta spriteTop
	inx
	lda SPRFONTXOFFSETS,x
	sta spriteTop + 1
	lda tmpChar: #$00
	asl 
	rol SpriteOffsetHi
	asl
	rol SpriteOffsetHi
	asl
	rol SpriteOffsetHi
	sta scrollFontLo
	clc
	lda SpriteOffsetHi: #$00
	adc #>SPRFONT
	sta scrollFontHi
	ldy #$02
	lda sSaveY
	cmp #$01
	bne !skip+
	ldx #($03*$06)
	jmp !loop+
!skip:
	cmp #$02
	bne !skip+
	ldx #($03*$0c)
	jmp !loop+
!skip:
	ldx #$00
!loop:
	lda (scrollFontLo),y
	sta spriteTop: $3000,x
	inx
	inx
	inx
	iny
	cpy #$07
	bne !loop-
	ldx sSaveX: #$00
	ldy sSaveY: #$00
	rts

SPRFONTXOFFSETS:
	.for(var i=0;i<8;i++){
			.word $3100 + (i * $40)
			.word $3100 + (i * $40) + 1
			.word $3100 + (i * $40) + 2
	}


