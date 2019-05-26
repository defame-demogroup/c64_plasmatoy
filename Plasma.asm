.pc= $4100 "PLASMA CODE"
.var height = 25

.var bufferA = $0400
.var bufferB = $0800

.var charHeight = 1
.var border = 0
.var width = 40

.var tpos1=$2b
.var tpos2=$2c
.var tpos3=$2d
.var pos1=$2e
.var pos2=$2f
.var pos3=$30
.var tpos3v=$31
.var xReg=$32
.var yReg=$33
.var plasmaValues=$40
.var bufferPointer=$41

.var offset1 = $34
.var offset2 = $35
.var offset3 = $36

toggle: 
	.byte $00
ready: 
	.byte $00

initPlasma: {
	lda #$00
	sta tpos1
	sta tpos2
	sta tpos3
	sta pos1
	sta pos2
	sta pos3
	sta tpos3v

	lda #$01
	sta offset1
	sta offset2
	sta offset3
	
	ldx #width 
clrplasmavals:	
	sta plasmaValues,x
	dex
	bne clrplasmavals
	rts
}
	
//;--------------------------------------------------------------------------------------------------------------------------------			

runPlasma: {
	clc
	lda ready
	cmp #$02
	beq frameUpdated
	rts	
frameUpdated:	
	lda toggle
	bne goDrawA
	jmp goDrawB
	
goDrawA:
	clc
	:startPlasma()
	:endLineStep()
  //  lda pos3 sta tpos3
	.for (var line = 0 ; line < height ; line++) {
	    :startLineStep()
	    	:drawPlasmaLineA(line,width)
		:endLineStep()
	}
	:endPlasma()
	rts	

goDrawB:
	clc
	:startPlasma()
	:endLineStep()
	.for (var line = 0 ; line < height ; line++) {
	    :startLineStep()
	    	:drawPlasmaLineB(line,width)
		:endLineStep()
	}
	:endPlasma()
	rts	
}

//;--------------------------------------------------------------------------------------------------------------------------------			

.macro drawPlasmaLineA(line,width) {
	sty yReg
	.var screen = $0400 + [line * $28]
	ldx tpos1 
	ldy tpos2
	.for (var i = 0 ; i < width; i++) {	
		clc 
		lda tpos3v 
		adc plasmaCos,x 
		adc plasmaCos,y
		clc	
		iny 
		inx 
		sta screen + i
		iny
	 }
	stx tpos1 
	sty tpos2
	ldy yReg
}

.macro drawPlasmaLineB(line,width) {
	sty yReg
	.var screen = $0800 + [line * $28]
	ldx tpos1 
	ldy tpos2
	.for (var i = 0 ; i < width; i++) {	
		clc 
		lda tpos3v 
		adc plasmaCos,x 
		adc plasmaCos,y
		clc	
		iny 
		inx 
		sta screen + i
		iny
	 }
	stx tpos1 
	sty tpos2
	ldy yReg
}



.macro startLineStep() {
	lda pos1 
	sta tpos1 
	lda pos2 
	sta tpos2
}

.macro endLineStep() {
   	clc 
	lda tpos3 
	adc offset1
	sta tpos3
	tax
   	lda plasmaCos,x 
   	sta tpos3v	
}                    

.macro startPlasma() {
	lda #$00
	sta ready
    lda pos3 
    sta tpos3            
}
.macro endPlasma() {  
	clc 
	lda pos1
	adc offset2
	sta pos1

    clc 
	lda pos3
	adc offset3
	sta pos3

    inc ready
}

//;--------------------------------------------------------------------------------------------------------------------------------			
