; *******************************************************************************************
; PutString - Write strings to the display using the PutString function
;
; Copyright (c) 2020 by Gaston Williams
;
; *******************************************************************************************

UseGraphics		EQU "TRUE"
Resolution		EQU "64x64"			; "64x32" or "64x64"
BackBuffer		EQU "OFF"			; 'OFF', 'COPY' or 'SWAP'

UseText			EQU "TRUE"
UseTty			EQU "TRUE"

			INCLUDE "StdDefs.asm"
			INCLUDE "Initialize.asm"

; =========================================================================================
; Strings
; =========================================================================================

Alphabet:		db "abcdefghijklmnopqrstuvwxyz\0"
Capitals:		db " ABCDEFGHIJKLMNOPQRSTUVWXYZ\0"
Numbers:		db "\n0123456789\0"

; =========================================================================================
; Main
; =========================================================================================

Start:			CALL BeginTerminal

				
			CALL VideoOn		; turn video on					
			
MainLoop:  		CALL Lowercase
			
			CALL WaitForInput      	; wait for input from the hex keyboard	
			
			CALL Uppercase
			
			CALL WaitForInput      	; wait for input from the hex keyboard	
			
			CALL Numerals
			
			CALL WaitForInput      	; wait for input from the hex keyboard	
			
			CALL ClearScreen
			
			BR   MainLoop		; and start over
;----------------------------------------------------------------------------------------


; =========================================================================================
; Lowercase - write the small alphabet letters to the screen
;
; Internals:
; RF - Pointer to String
; =========================================================================================

Lowercase:		LOAD RF, Alphabet			
			CALL PutString

			RETURN
;------------------------------------------------------------------------------------------			

; =========================================================================================
; Uppercase - write the Capital Alphabet letters to the screen
;
; Internals:
; RF - Pointer to String
; =========================================================================================

Uppercase:		LOAD RF, Capitals
			CALL PutString

			RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; Numerals - write the numbers 0 through 9 to the screen
;
; Internals:
; RF - Pointer to String
; =========================================================================================

Numerals:		LOAD RF, Numbers			
			CALL PutString

			RETURN
;-----------------------------------------------------------------------					


