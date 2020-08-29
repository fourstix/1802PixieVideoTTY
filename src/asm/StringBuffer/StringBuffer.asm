; *******************************************************************************************
; StringBuffer - Read characters from input and store in a buffer until a null is read, 
;		 then display the string on the video display.
;
; Copyright (c) 2020 by Gaston Williams
;
; *******************************************************************************************

UseGraphics		EQU "TRUE"
Resolution		EQU "64x32"			; "64x32" or "64x64"
BackBuffer		EQU "OFF"			; 'OFF', 'COPY' or 'SWAP'

UseText			EQU "TRUE"
UseTty			EQU "TRUE"

			INCLUDE "StdDefs.asm"
			INCLUDE "Initialize.asm"

; =========================================================================================
; Main
; =========================================================================================

Start:			CALL BeginTerminal

				
			CALL VideoOn		; turn video on		
			
MainLoop:		SEQ
			
  			CALL GetStringBuffer
			
			REQ 
			
			LOAD RF, StringBuffer	; Set up pointer to the String buffer
					
			CALL PutString		; Print it
					
			
			BR   MainLoop		; and start over
;----------------------------------------------------------------------------------------


; =========================================================================================
; StringBuffer - 31 characters plus null.  String is terminated with a null (0) character.
; =========================================================================================

StringBuffer  db 32 dup 00H
;----------------------------------------------------------------------------------------

; =========================================================================================
; GetStringBuffer - Read characters from input and store in a buffer until a null is read, 
;	      up to 31 characters.  String is terminated with a null (0) character.
;	
; Parameters:
;
; Note: Safe - This function checks the video status before returning
;
; Internal:
; RF 	- Pointer to StringBuffer
; RD    - Counter
; RC.0 	- Character value read from input
; =========================================================================================

GetStringBuffer:	LOAD RF, StringBuffer	; set up pointer to buffer
						
			LDI  00H		; set counter to zero
			PLO  RD
			PHI  RD
			
GSB_Read		GLO  RF			; push RF onto the stack
			STXD			
			GHI  RF
			STXD
			
			GLO  RD			; push RD onto the stack
			STXD
			GHI  RD
			STXD

			GLO RD			; show count on Hex display
			PLO RC
			
			CALL WriteHexOutput	
			
GSB_WaitInput:		BN4  GSB_WaitInput	; Wait for Input press
			
			INP  4			; Input stores byte in M(X)					
			PLO  RC			; Save byte for return
			CALL WriteHexOutput	; Show input on hex display
						
GSB_Release:		B4   GSB_Release	; Wait for Input release
			
			IRX			; restore RD from stack
			LDXA
			PHI  RD
			LDXA
			PLO  RD
						
			LDXA			; restore RF from stack
			PHI  RF
			LDX
			PLO  RF
			
			GLO RC					
			STR RF			; store a character
			BZ  GSB_Exit		; if null character, then exit
			
			INC RF			; increment pointer
			INC RD			; increment counter
			
			GLO RD			; check pointer to see if at end
			SMI 20H			; 32 characters max in the buffer				
			BL  GSB_Read		; if not at end yet, keep reading
			
			DEC RF			; back up RF to point to last character
			LDI 00H			; force last character to null
			STR RF
			
GSB_Exit:		RETURN
;------------------------------------------------------------------------------------------

