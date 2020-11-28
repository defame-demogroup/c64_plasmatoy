

.import source "macros.asm"
.import source "Plasma.asm"
.import source "PlasmaSine.asm"
.import source "PlasmaCharset.asm"

/*
Parameters
*/
.var scrollYOffset = 8
.var scrollFgColor = $40
.var scrollBgColor = $80
/*
ZEROPAGE
*/
.var scrollTextPointer = $c0
.var scrollBytePointer = $c1

.var scrollFontLo = $c2
.var scrollFontHi = $c3

.pc =$0801 "Basic Upstart Program"
:BasicUpstart($2800)

//---------------------------------------------------------
.var bufA = $0400
.var mapA = %00011000


.var music = LoadSid("Run-Mild.sid")
.pc = $2800 "Main Program"
start:
			ldx #0
!loop:
			.for(var i=0; i<4; i++) {
				lda #$0b
				sta bufA+i*$100,x
				sta $d800+i*$100,x
			}
			inx
			bne !loop-

			lda #$00
			sta $d020
			
			//extended hires
			lda #$0f
			sta $d021
			lda #$0e
			sta $d022
			lda #$0d
			sta $d023
			lda #$0c
			sta $d024
			
			lda #$ff
			sta $d015
			sta $d001
			sta $d003
			sta $d005
			sta $d007
			sta $d009
			sta $d00b
			sta $d00d
			sta $d00f

			.for(var i=0;i<8;i++){
				lda # $30 + (i*8*3)
				sta $d000 + (i*2)
			}

			lda #$00
			sta $d010
			sta $d017
			sta $d01d
			
			lda #$ff
			sta $39ff

			.for(var i=0;i<8;i++){
				lda #($c4 + i)
				sta $0800-$08 + i
			}

			lda #$00
			sta $d01c

			lda #$01
			sta $d027
			sta $d028
			sta $d029
			sta $d02a
			sta $d02b
			sta $d02c
			sta $d02d
			sta $d02e			

			jsr funcDrawSettings

			lda #$00
			sta scrollBytePointer
			sta scrollTextPointer

			sei
			ldx #$00
			ldy #$00
			lda #$00
			jsr music.init	

			lda #<irq1
			sta $0314
			lda #>irq1
			sta $0315
			asl $d019
			lda #$7b
			sta $dc0d
			
			//bank selection
			lda $DD00
			and #%11111100
			ora #%00000011 
			sta $DD00
			
			jsr initPlasma
			
			lda #mapA
			sta $d018
					
			lda #$81
			sta $d01a
			lda #%01011011
			sta $d011
			lda #$08
			sta $d016
			lda #$f0
			sta $d012
			
			lda #%00110110	// Disable KERNAL and BASIC ROM and enable cass. motor
			sta $01
					
			cli
						
this:		
			jsr runPlasma 
			jmp this
//---------------------------------------------------------
irq1:  	
			asl $d019
			lda #%01011011
			sta $d011
!loop:
			lda $d012
			cmp #$fa
			bne !loop-
			lda #%01010011
			sta $d011

			jsr funcScrollSprite
			jsr music.play

			jsr funcKeys
			jsr funcDrawValues
			jsr funcFadeSprites
			jsr funcFadePlasmaColor
			pla
			tay
			pla
			tax
			pla
			rti

funcKeys:
	jsr ReadKeyboard
	bcs !NoValidInput+
	jmp !skip+
!NoValidInput:
	lda #$00
	sta LAST_EVENT
	sta LAST_EVENT + 1
	sta LAST_EVENT + 2
	rts
!skip:
	cpx LAST_EVENT
	bne !skip+
	cpy LAST_EVENT + 1
	bne !skip+
	cmp LAST_EVENT + 2
	bne !skip+
	rts
!skip:
	stx LAST_EVENT
	sty LAST_EVENT + 1
	sta LAST_EVENT + 2
	cmp #$ff
	beq NoNewAphanumericKey
	rts
NoNewAphanumericKey:
	cpx #$10
	beq !f1+
	cpx #$20
	beq !f3+
	cpx #$40
	beq !f5+
	cpx #$08
	beq !f7+
	rts
!f1:
	cpy #$10
	beq !f2+
	inc offset1
	lda offset1
	cmp #$0a
	bne !skip+
	lda #$09
	sta offset1
!skip:
	rts
!f2:
	dec offset1
	lda offset1
	cmp #$00
	bne !skip+
	lda #$01
	sta offset1
!skip:
	rts
!f3:
	cpy #$10
	beq !f4+
	inc offset2
	lda offset2
	cmp #$0a
	bne !skip+
	lda #$09
	sta offset2
!skip:
	rts
!f4:
	dec offset2
	lda offset2
	cmp #$00
	bne !skip+
	lda #$01
	sta offset2
!skip:
	rts
!f5:
	cpy #$10
	beq !f6+
	inc offset3
	lda offset3
	cmp #$0a
	bne !skip+
	lda #$09
	sta offset3
!skip:
	rts
!f6:
	dec offset3
	lda offset3
	cmp #$00
	bne !skip+
	lda #$01
	sta offset3
!skip:
	rts
!f7:
	cpy #$10
	beq !f8+
	inc PLASMA_SELECT_PTR
	lda PLASMA_SELECT_PTR
	cmp #$0a
	bne !skip+
	lda #$09
	sta PLASMA_SELECT_PTR
!skip:
	rts
!f8:
	dec PLASMA_SELECT_PTR
	lda PLASMA_SELECT_PTR
	cmp #$ff
	bne !skip+
	lda #$00
	sta PLASMA_SELECT_PTR
!skip:
	rts

LAST_EVENT:
.byte $00, $00, $00

funcFadeSprites:
	inc SPRITE_COLOR_DELAY
	lda SPRITE_COLOR_DELAY
	cmp #$02
	beq !skip+
	rts
!skip:
	lda #$00
	sta SPRITE_COLOR_DELAY
	ldx SPRITE_COLORS_PTR
	lda SPRITE_COLORS,x
	sta $d027
	sta $d028
	sta $d029
	sta $d02a
	sta $d02b
	sta $d02c
	sta $d02d
	sta $d02e
	inx
	cpx #$20
	bne !skip+
	ldx #$00
!skip:
	stx SPRITE_COLORS_PTR
	rts

SPRITE_COLORS:
.byte $09, $09, $08, $08, $07, $07, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $0d, $0d, $0c, $0c, $05, $05

SPRITE_COLORS_PTR:
.byte $00

SPRITE_COLOR_DELAY:
.byte $00

funcFadePlasmaColor:
	lda PLASMA_SELECT_PTR
	tax
	lda PLASMA_C1,x
	sta $d021
	lda PLASMA_C2,x
	sta $d022
	lda PLASMA_C3,x
	sta $d023
	lda PLASMA_C4,x
	sta $d024
	rts

PLASMA_SELECT_PTR:
.byte $00
PLASMA_C1:  //d021
.byte $04, $03, $02, $0c, $0c, $0f, $03, $04, $06, $0f
PLASMA_C2:  //d022
.byte $0f, $0e, $08, $0f, $0c, $0f, $01, $04, $0b, $0b
PLASMA_C3:  //d023
.byte $0c, $06, $0a, $0d, $0c, $0f, $0f, $04, $0b, $0f
PLASMA_C4:  //d024
.byte $0e, $04, $07, $05, $0c, $0f, $07, $04, $06, $0b

.import source "gui.input.keyboard_scan.asm"

.pc=* "DEBUG"
funcDrawValues:
	clc
	lda offset1
	adc #$30
	ldx #$05
	ldy #$01
	jsr funcDrawCharOnSprite
	clc
	lda offset2
	adc #$30
	ldx #$09
	ldy #$01
	jsr funcDrawCharOnSprite
	clc
	lda offset3
	adc #$30
	ldx #$0d
	ldy #$01
	jsr funcDrawCharOnSprite
	clc
	lda PLASMA_SELECT_PTR
	adc #$30
	ldx #$15
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

LABEL1:
	.text " defame plasmatoy v2.0  "
	.byte $00
LABEL3:
	.text "zoom=1 x=1 y=1 color=1  "
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

.align $100
.pc=* "SPRITE FONT DATA"
SPRFONT:
.import c64 "delta.prg"

.pc=$3100 "SPRITES"
SPR:
.fill $40 * 8, $00

CHRBUF:
.fill $08, $00

CHRCNT:
.byte $00

//Music	$1000-2000
//---------------------------------------------------------
.pc=music.location "Music"
.fill music.size, music.getData(i)
.var spriteyoff=12
.pc=$4000
funcScrollSprite:
	.for(var y=1;y<7;y++){
		asl CHRBUF + y
		.for(var i=7;i>=0;i--){
			.for(var x=2;x>=0;x--){
				rol $3100 + (i * $40) + ((y+spriteyoff) * 3) + x
			}
		}
	}
	ldx CHRCNT
	inx
	cpx #$08
	beq !newChar+
	stx CHRCNT
	rts
!newChar:
	lda #$00
	sta CHRCNT
	lda #$00
	sta ScrollOffsetHi
	lda scrollptr: SCROLLTEXT
	sta endprt
	cmp #$00 //end marker
	bne !skip+
	lda #$20 //space char
!skip:
	asl 
	rol ScrollOffsetHi
	asl
	rol ScrollOffsetHi
	asl
	rol ScrollOffsetHi
	sta scrollFontLo
	clc
	lda ScrollOffsetHi: #$00
	adc #>SPRFONT
	sta scrollFontHi
	ldy #$00
	ldx #$00
!loop:
	lda (scrollFontLo),y
	sta CHRBUF,x
	inx
	iny
	cpy #$07
	bne !loop-
	inc scrollptr
	bne !skip+
	inc scrollptr + 1
!skip:
	lda endprt: #$00
	cmp #$00
	bne !skip+
	lda #>SCROLLTEXT
	sta scrollptr + 1
	lda #<SCROLLTEXT
	sta scrollptr
!skip:
	rts

SCROLLTEXT:
.text "welcome back! after a couple of years its time for version 2 of the plasmatoy..."
.text " use f1 and f2 to change the zoom, use f3 and f4 to change x speed, use f5 and f6 to change y speed,"
.text " use f7 and f8 to change plasma colors.  this spicy version of plasmatoy has more colors with that smooth"
.text " plasma flavour. credits: code by zig and voltage of defame during syntax party. music is 'run mild' by coax of topaz beerline. "
.text " ...if you would like to get in touch, send an email to: joe at pixolut.com ... greets need to go out to: "
.text "chrome, "
.text "disaster area, "
.text "digital access, "
.text "cygnus oz, "
.text "duck and chicken, "
.text "ikon visual, "
.text "jimage, "
.text "the force, "
.text "desire, "
.text "0f.digital, "
.text "aday, "
.text "onslaught, "
.text " ...and the international greets..."
.text "abyss connection, "
.text "amnesty, "
.text "artstate, "
.text "arise, "
.text "arsenic, "
.text "atlantis, "
.text "artline designs, "
.text "bonzai, "
.text "booze, "
.text "camelot, "
.text "censor, "
.text "chorus, "
.text "cosine, "
.text "crest, "
.text "dekadence, "
.text "digital excess, "
.text "delysid, "
.text "elysium, "
.text "excess, "
.text "extend, "
.text "exon, "
.text "fairlight, "
.text "focus, "
.text "fossil, "
.text "genesis-project, "
.text "hitmen, "
.text "hack n' trade, "
.text "hoaxers, "
.text "hokuto force, "
.text "laxity, "
.text "lepsi developments, "
.text "level 64, "
.text "maniacs of noise, "
.text "multistyle labs, "
.text "mayday, "
.text "noice, "
.text "nah kolor, "
.text "nostalgia, "
.text "offence, "
.text "origo dreamline, "
.text "oxyron, "
.text "padua, "
.text "panda design, "
.text "pegboard nerds, "
.text "plush, "
.text "prosonix, "
.text "resource, "
.text "role, "
.text "samar, "
.text "shape, "
.text "success + trc, "
.text "svenonacid, "
.text "the dreams, "
.text "the solution, "
.text "triad, "
.text "trsi, "
.text "vibrants, "
.text "vision, "
.text "viruz, "
.text "wrath, "
.text "x-ample ...    "
.byte $00



