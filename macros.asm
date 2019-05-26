.macro LoadMCSpritesFromPicture( filename, bgcolor, color0, color1, color2 ) {

    .var picture  = LoadPicture( filename, List().add(bgcolor, color0, color1, color2) )
    .var xsprites = floor( picture.width  / [ 3 * 8 ] )
    .var ysprites = floor( picture.height / 21 )

    .for (var ysprite = 0; ysprite < ysprites; ysprite++) {
        .for (var xsprite = 0; xsprite < xsprites; xsprite++) {
            .for (var i = 0; i < [3 * 21]; i++) {
                .byte picture.getMulticolorByte(
                    [[xsprite * 3]  + mod(i, 3)],
                    [[ysprite * 21] + floor(i / 3)]
                )
            }
            .byte 0
        }
    }
}

.macro LoadHiresCharsFromPicture(filename, numberOfChars , bgcolor, color0) {
	.var charsetPic = LoadPicture(filename, List().add(bgcolor, color0))
	.for ( var x = 0 ; x < numberOfChars ; x++) {
		.for( var y = 0; y < 8; y++) {
			.byte charsetPic.getSinglecolorByte(x,y)
		}
	}
}

.macro toBytes( items ) {
	.for (var i = 0 ; i < items.size() ; i++) {
		.byte items.get(i)
	}
}
