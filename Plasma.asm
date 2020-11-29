.pc= * "PLASMA CODE"
.var height = 25

.var bufferA = $0400

.var charHeight = 1
.var border = 0
.var width = 40

.var tpos1=$40
.var tpos2=$41
.var tpos3=$42
.var pos1=$43
.var pos2=$44
.var pos3=$45
.var tpos3v=$46
.var xReg=$47
.var yReg=$48
.var plasmaValues=$49
.var bufferPointer=$4a

.var tmpx = $4b

.var offset1 = $4c
.var offset2 = $4d
.var offset3 = $4e

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
}
//;--------------------------------------------------------------------------------------------------------------------------------			

.macro drawPlasmaLineA(line,width) {
	sty yReg
	.var screen = $0400 + [line * $28]
	.var cmem = $d800 + [line * $28]
	ldx tpos1 
	ldy tpos2
	.for (var i = 0 ; i < width; i++) {	
		clc 
		lda tpos3v 
		adc plasmaCos,x 
		adc plasmaCos,y
		iny 
		inx 
		stx tmpx
		sta screen + i
		tax
		lda plasmaColors,x
		sta cmem + i
		ldx tmpx
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
