.align $100
.pc=* "PLASMA_TABLES"
plasmaSine:
{
	.var amplitude = 24
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
	.var amplitude = 26
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

plasmaColors:
{
pc1a:
	.fill $20, $0e
pc2:
	.fill $20, $06
	.fill $20, $06
pc3:
	.fill $20, $0e
	.fill $20, $0e
pc4:
	.fill $20, $06
	.fill $20, $06
pc1b:
	.fill $20, $0e
}

