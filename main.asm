

.import source "macros.asm"

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
:BasicUpstart(start)

//---------------------------------------------------------
.var bufA = $0400
.var mapA = %00011000


.var music = LoadSid("Run-Mild.sid")

.pc = $4000 "Main Program"
start:
			.for(var i=0;i<8;i++){
				lda #($c4 + i)
				sta $0800-$08 + i
			}	
			lda #$ff
			sta $d015
			lda #$01
			sta $d001
			sta $d003
			sta $d005
			sta $d007
			sta $d009
			sta $d00b
			sta $d00d
			sta $d00f
			lda #$00
			sta $d020
			sta $d021
			sta $d017
			sta $d01c
			lda #$ff
			sta $d01d
			lda #$ff
			sta $39ff
			lda #$01
			sta $d027
			sta $d028
			sta $d029
			sta $d02a
			sta $d02b
			sta $d02c
			sta $d02d
			sta $d02e			
			lda $dd00
			and #%11111100
			ora #%00000011 
			sta $dd00			
			lda #mapA
			sta $d018
			lda #$08
			sta $d016

			sei
			lda #%00110110	// Disable KERNAL and BASIC ROM and enable cass. motor
			sta $01
			jsr initPlasma
			ldx #$00
			ldy #$00
			lda #$00
			jsr music.init	
			//bank selection
			lda #$f0
			sta $d012
			lda #$81
			sta $d01a
			lda #%01011011
			sta $d011
			lda #<irq1
			sta $0314
			lda #>irq1
			sta $0315
			asl $d019
			lda #$7b
			sta $dc0d
			cli
			jsr funcDrawSettings
this:		
			jsr runPlasma 
			jmp this
//---------------------------------------------------------
.import source "spritescroller.asm"
.import source "Plasma.asm"
.import source "PlasmaSine.asm"
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

			lda #$ff
			sta $d015

			lda #$00
			sta $d01d
			.for(var i=0;i<8;i++){
				lda #$30 + (i*8*3)
				sta $d000 + (i*2)
			}
			lda #%00000000
			sta $d010
			jsr funcScrollSprite
			lda #$ff
			sta $d01d
			.for(var i=0;i<8;i++){
				lda #$10 + (i*16*3)
				sta $d000 + (i*2)
			}
			lda #%11100000
			sta $d010
			lda #$05
			sta $d027
			sta $d028
			sta $d029
			sta $d02a
			sta $d02b
			sta $d02c
			sta $d02d
			sta $d02e
			jsr music.play
			jsr funcScrollSpriteNewChar
			lda #$00
			sta $d015
			jsr funcKeys
			jsr funcFadeSprites
			jsr funcSetPlasmaColor
			jsr funcUpdateSpriteChars
			lda #$00
			sta $d017
			pla
			tay
			pla
			tax
			pla
			rti

.import source "keyboard_handler.asm"
.import source "spritefade.asm"


funcSetPlasmaColor:
	lda D_COL1
	sta $d021
	lda D_COL2
	sta $d022
	lda D_COL3
	sta $d023
	lda D_COL4
	sta $d024
	lda D_COL5
	.for(var i=0;i<$20;i++){
		sta plasmaColors.pc1a + i
		sta plasmaColors.pc1b + i
	}
	lda D_COL6
	.for(var i=0;i<$40;i++){
		sta plasmaColors.pc2 + i
	}
	lda D_COL7
	.for(var i=0;i<$40;i++){
		sta plasmaColors.pc3 + i
	}
	lda D_COL7
	.for(var i=0;i<$40;i++){
		sta plasmaColors.pc4 + i
	}
	lda D_ZOOM
	sta offset1
	lda D_X
	sta offset2
	lda D_Y
	sta offset3	
	rts

funcUpdateSpriteChars:
	lda display_timer
	beq !skip+
	dec display_timer
	bne !skip+
	jsr funcResetSettings
!skip:
	rts

display_timer:
.byte $00

.pc=* "DATA PAYLOAD"
D_ZOOM:	.byte $01
D_X:	.byte $01
D_Y:	.byte $01
D_COL1:	.byte $08
D_COL2:	.byte $09
D_COL3:	.byte $0a
D_COL4:	.byte $0b
D_COL5:	.byte $0c
D_COL6:	.byte $0d
D_COL7:	.byte $0e
D_COL8:	.byte $0f
D_PRESET: .byte $00

.import source "gui.input.keyboard_scan.asm"
.import source "spritechars.asm" 


//Music	$1000-2000
//---------------------------------------------------------
.pc=music.location "Music"
.fill music.size, music.getData(i)

.pc = $2000 "PLASMA CHARSET"
.import source "PlasmaCharset.asm"

.pc=$3100 "SPRITES"
SPR:
.fill $40 * 8, $00

.align $100
.pc=* "SPRITE FONT DATA"
SPRFONT:
.import c64 "delta.prg"
