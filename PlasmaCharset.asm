//Plasma ECI charset $2000
//---------------------------------------------------------
.pc = $2000
	.var charsetPic = LoadPicture("plasmacharset.gif", List().add($000000, $ffffff))
	.for(var j=0;j<$04;j++){
		.for ( var x = $3e ; x >= $20 ; x--) {
			.for( var y = 0; y < 8; y++) {
				.byte charsetPic.getSinglecolorByte(x,y)
			}
		}
		/*
		; .for( var y = 0; y < 8; y++) {
		; 	.byte $00
		; }	
		; .for( var y = 0; y < 8; y++) {
		; 	.byte $00
		; }	
		; .for( var y = 0; y < 8; y++) {
		; 	.byte $00
		; }	
		; .for( var y = 0; y < 8; y++) {
		; 	.byte $00
		; }
		*/	
		.for ( var x = $20 ; x < $3e ; x++) {
			.for( var y = 0; y < 8; y++) {
				.byte charsetPic.getSinglecolorByte(x,y)
			}
		}
	}

