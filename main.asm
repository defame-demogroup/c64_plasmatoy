

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
			sta $d017
			lda #$ff
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

			jsr funcDrawSettings

			cli
						
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
	cpy #$00
	bne !modifier+
	cmp #$31
	beq !c1+
	cmp #$32
	beq !c2+
	cmp #$33
	beq !c3+
	cmp #$34
	beq !c4+
	cmp #$35
	beq !c5+
	cmp #$36
	beq !c6+
	cmp #$37
	beq !c7+
	cmp #$38
	beq !c8+
!modifier:
	cmp #$31
	beq !c1n+
	cmp #$32
	beq !c2n+
	cmp #$33
	beq !c3n+
	cmp #$34
	beq !c4n+
	cmp #$35
	beq !c5n+
	cmp #$36
	beq !c6n+
	cmp #$37
	beq !c7n+
	cmp #$38
	beq !c8n+
	rts
NoNewAphanumericKey:
	cpx #$10
	beq !f1+
	cpx #$20
	beq !f3+
	cpx #$40
	beq !f5+
	rts
!f1:jmp !f1+
!f3:jmp !f3+
!f5:jmp !f5+
!c1:jmp !c1+
!c2:jmp !c2+
!c3:jmp !c3+
!c4:jmp !c4+
!c5:jmp !c5+
!c6:jmp !c6+
!c7:jmp !c7+
!c8:jmp !c8+
!c1n:jmp !c1n+
!c2n:jmp !c2n+
!c3n:jmp !c3n+
!c4n:jmp !c4n+
!c5n:jmp !c5n+
!c6n:jmp !c6n+
!c7n:jmp !c7n+
!c8n:jmp !c8n+

!f1:
	cpy #$10
	beq !f2+
	inc D_ZOOM
	lda D_ZOOM
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_ZOOM
!skip:
	ldx #<LABEL4
	ldy #>LABEL4
	jsr funcUpdateSettings
	lda D_ZOOM
	jsr funcDrawValue
	dec display_timer
	rts
!f2:
	dec D_ZOOM
	lda D_ZOOM
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_ZOOM
!skip:
	ldx #<LABEL4
	ldy #>LABEL4
	jsr funcUpdateSettings
	lda D_ZOOM
	jsr funcDrawValue
	dec display_timer
	rts
!f3:
	cpy #$10
	beq !f4+
	inc D_X
	lda D_X
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_X
!skip:
	ldx #<LABEL5
	ldy #>LABEL5
	jsr funcUpdateSettings
	lda D_X
	jsr funcDrawValue
	dec display_timer
	rts
!f4:
	dec D_X
	lda D_X
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_X
!skip:
	ldx #<LABEL5
	ldy #>LABEL5
	jsr funcUpdateSettings
	lda D_X
	jsr funcDrawValue
	dec display_timer
	rts
!f5:
	cpy #$10
	beq !f6+
	inc D_Y
	lda D_Y
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_Y
!skip:
	ldx #<LABEL6
	ldy #>LABEL6
	jsr funcUpdateSettings
	lda D_Y
	jsr funcDrawValue
	dec display_timer
	rts
!f6:
	dec D_Y
	lda D_Y
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_Y
!skip:
	ldx #<LABEL6
	ldy #>LABEL6
	jsr funcUpdateSettings
	lda D_Y
	jsr funcDrawValue
	dec display_timer
	rts
!c1:
	inc D_COL1
	lda D_COL1
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_COL1
!skip:
	ldx #<LABEL7
	ldy #>LABEL7
	jsr funcUpdateSettings
	lda D_COL1
	jsr funcDrawValue
	dec display_timer
	rts
!c1n:
	dec D_COL1
	lda D_COL1
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_COL1
!skip:
	ldx #<LABEL7
	ldy #>LABEL7
	jsr funcUpdateSettings
	lda D_COL1
	jsr funcDrawValue
	dec display_timer
	rts
!c2:
	inc D_COL2
	lda D_COL2
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_COL2
!skip:
	ldx #<LABEL8
	ldy #>LABEL8
	jsr funcUpdateSettings
	lda D_COL2
	jsr funcDrawValue
	dec display_timer
	rts
!c2n:
	dec D_COL2
	lda D_COL2
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_COL2
!skip:
	ldx #<LABEL8
	ldy #>LABEL8
	jsr funcUpdateSettings
	lda D_COL2
	jsr funcDrawValue
	dec display_timer
	rts
!c3:
	inc D_COL3
	lda D_COL3
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_COL3
!skip:
	ldx #<LABEL9
	ldy #>LABEL9
	jsr funcUpdateSettings
	lda D_COL3
	jsr funcDrawValue
	dec display_timer
	rts
!c3n:
	dec D_COL3
	lda D_COL3
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_COL3
!skip:
	ldx #<LABEL9
	ldy #>LABEL9
	jsr funcUpdateSettings
	lda D_COL3
	jsr funcDrawValue
	dec display_timer
	rts
!c4:
	inc D_COL4
	lda D_COL4
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_COL4
!skip:
	ldx #<LABELA
	ldy #>LABELA
	jsr funcUpdateSettings
	lda D_COL4
	jsr funcDrawValue
	dec display_timer
	rts
!c4n:
	dec D_COL4
	lda D_COL4
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_COL4
!skip:
	ldx #<LABELA
	ldy #>LABELA
	jsr funcUpdateSettings
	lda D_COL4
	jsr funcDrawValue
	dec display_timer
	rts
!c5:
	inc D_COL5
	lda D_COL5
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_COL5
!skip:
	ldx #<LABELB
	ldy #>LABELB
	jsr funcUpdateSettings
	lda D_COL5
	jsr funcDrawValue
	dec display_timer
	rts
!c5n:
	dec D_COL5
	lda D_COL5
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_COL5
!skip:
	ldx #<LABELB
	ldy #>LABELB
	jsr funcUpdateSettings
	lda D_COL5
	jsr funcDrawValue
	dec display_timer
	rts
!c6:
	inc D_COL6
	lda D_COL6
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_COL6
!skip:
	ldx #<LABELC
	ldy #>LABELC
	jsr funcUpdateSettings
	lda D_COL6
	jsr funcDrawValue
	dec display_timer
	rts
!c6n:
	dec D_COL6
	lda D_COL6
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_COL6
!skip:
	ldx #<LABELC
	ldy #>LABELC
	jsr funcUpdateSettings
	lda D_COL6
	jsr funcDrawValue
	dec display_timer
	rts
!c7:
	inc D_COL7
	lda D_COL7
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_COL7
!skip:
	ldx #<LABELD
	ldy #>LABELD
	jsr funcUpdateSettings
	lda D_COL7
	jsr funcDrawValue
	dec display_timer
	rts
!c7n:
	dec D_COL7
	lda D_COL7
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_COL7
!skip:
	ldx #<LABELD
	ldy #>LABELD
	jsr funcUpdateSettings
	lda D_COL7
	jsr funcDrawValue
	dec display_timer
	rts
!c8:
	inc D_COL8
	lda D_COL8
	cmp #$10
	bne !skip+
	lda #$0f
	sta D_COL8
!skip:
	ldx #<LABELE
	ldy #>LABELE
	jsr funcUpdateSettings
	lda D_COL8
	jsr funcDrawValue
	dec display_timer
	rts
!c8n:
	dec D_COL8
	lda D_COL8
	cmp #$ff
	bne !skip+
	lda #$00
	sta D_COL8
!skip:
	ldx #<LABELE
	ldy #>LABELE
	jsr funcUpdateSettings
	lda D_COL8
	jsr funcDrawValue
	dec display_timer
	rts

LAST_EVENT:
.byte $00, $00, $00

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
