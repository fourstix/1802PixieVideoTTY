; *******************************************************************************************
; BasicTerminal - Basic Teletype Terminal demo that reads an ASCII charcter from input and 
;		  writes it to the display.
;
; Copyright (c) 2020 by Gaston Williams
;
; *******************************************************************************************

UseGraphics		EQU "TRUE"
Resolution		EQU "64x64"		; "64x32" or "64x64"
BackBuffer		EQU "OFF"		; 'OFF', 'COPY' or 'SWAP'

UseText			EQU "TRUE"
UseTty			EQU "TRUE"

			INCLUDE "StdDefs.asm"
			INCLUDE "Initialize.asm"


; =========================================================================================
; Main
; =========================================================================================

Start:			CALL BeginTerminal	; set up variables and clear video buffers			
				
			CALL VideoOn		; turn video on	
					
MainLoop:		SEQ			; turn on LED to signal input

			CALL GetChar		; get a character from input
			
			REQ 			; turn off LED to signal output					
			
			CALL PutChar		; put the character on the display				
  			
			BR   MainLoop		; do it over and over
;-------------------------------------------------------------------------------------------