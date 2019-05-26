.pc=* "PLASMA_TABLES"
plasmaSine:
{
	.var amplitude = 50
	.var frequency = 128
	table:
	.for (var j=0; j<256;j++) { 	
		.if (round(amplitude+amplitude * sin(toRadians( 360/frequency * j))) > 255) {
			.byte 255
		} else {
			.byte amplitude+amplitude * sin(toRadians( 360/frequency * j))		
		}	
	}
}  

plasmaCos:
{
	.var amplitude = 50
	.var frequency = 128
	table:
	.for (var j=0; j<256;j++) { 	
		.if (round(amplitude+amplitude * cos(toRadians( 360/frequency * j))) > 255) {
			.byte 255
		} else {
			.byte amplitude+amplitude * cos(toRadians( 360/frequency * j))
		}	
	}
}
