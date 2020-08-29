; *****************************************************************************************
; Padding - Code with 64x64 resolution and the Swap and Copy BackBuffer options assembles  
;	    to near the end of a page boundary.  This file contains padding definitions to 
;           prevent errors in user code caused by branches straddling a page boundary.  
;	    This can cause 'jump target not on same page' errors when assembling user code.
;
; Copyright (c) 2020 by Gaston Williams
; *****************************************************************************************

; =========================================================================================
; Padding for more than 16 bytes is commented out.
; =========================================================================================
		
		IF Resolution == "64x64"
			IF BackBuffer == "COPY"
				db 7 dup 00H
			ENDIF	
			
			IF BackBuffer == "SWAP"
				db 13 dup 00H
			ENDIF				
			
			; Uncomment the lines below if there's a boundary issue with 64x64
			; resolution user code when assembled with the BackBuffer option "OFF"
	
			;IF BackBuffer == "OFF"
			;	db 41 dup 00H
			;ENDIF
			
		ENDIF
		
		IF Resolution == "64x32"
			; Uncomment the lines below if there's a boundary issue with 64x32
			; resolution user code when assembled with the BackBuffer option "COPY"
			
			;IF BackBuffer == "COPY"
			;	db 24 dup 00H
			;ENDIF

			; Uncomment the lines below if there's a boundary issue with 64x32
			; resolution user code when assembled with the BackBuffer option "SWAP"
			
			;IF BackBuffer == "SWAP"
			;	db 32 dup 00H
			;ENDIF
			
			; Uncomment the lines below if there's a boundary issue with 64x32
			; resolution user code when assembled with the BackBuffer option "OFF"
	
			;IF BackBuffer == "OFF"
			;	db 56 dup 00H
			;ENDIF			
		
		ENDIF
;------------------------------------------------------------------------------------------