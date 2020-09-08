; *****************************************************************************************
; Copyright (c) 2020 
; by Richard Dienstknecht
;
; Changes:
; Gaston Williams, July, 2020 - Moved Font definitions into separate file
; Gaston Williams, July, 2020 - Replaced Std Call and Std Return with Macros
; Gaston Williams  Aug,  2020 - Added Macro for loading Register
; *****************************************************************************************

		IF UseText == "TRUE"

; =========================================================================================
; Draws a zero terminated string at specified screen coordinates. 
;
; Parameters:
; RF		Pointer to the string
; RE.0		X coordinate
; RE.1		Y coordinate
; =========================================================================================

DrawString:		LDN  RF			; get character, exit if 0
			PLO  RC
			BZ   DS_Exit
			INC  RF
					
			GLO  RF			; push RF onto the stack
			STXD
			GHI  RF
			STXD
					
			GLO  RE			; push RE onto the stack
			STXD
			GHI  RE
			STXD
					
			CALL DrawCharacter	; draw the character
					
			IRX			; restore RE
			LDXA
			PHI  RE
			LDX
			PLO  RE
					
			GLO  RF			; advance the x coordinate by the
			STXD			; width of the character + 1
			IRX
			GLO  RE
			ADD
			ADI  01H
			PLO  RE
			
			IRX			; restore RF
			LDXA
			PHI  RF
			LDX
			PLO  RF
			BR   DrawString		; continue with the next character

DS_Exit:		RETURN

;------------------------------------------------------------------------------------------


; =========================================================================================
; Draws a character at specified screen coordinates 
;
; Parameters:
; RE.0		X coordinate of the character
; RE.1		Y coordinate of the character
; RC.0		ASCII code of the character (20 - 7F)
; 
; Internal:
; RF		Pointer to the unpacked character's pattern
; RD		Pointer to the font
; RC.1		Temporary values

; Returns:
; RF.0		Character width
; =========================================================================================

DrawCharacter:		LOAD RF, CharacterPattern	; RF points to the buffer for the character pattern
								
			LOAD RD, Font			; RD points to the font			
				
			GLO  RC				; calculate the offset in the font
			SMI  020H			; (( character code - 20) / 2) * 6
			ANI  0FEH
			PHI  RC
			SHL
			STXD
			IRX					
			GHI  RC
			ADD
			STXD
			IRX
			BNF  DC_SkipHighByte
			GHI  RD
			ADI	 01H
			PHI  RD
					
DC_SkipHighByte:	GLO  RD				; add to the address in RD
			ADD	
			PLO  RD
			BNF  DC_SkipHighByte2
			GHI  RD
			ADI  01H
			PHI  RD

DC_SkipHighByte2:	LDN  RD				; get the width of the first character pattern
			SHR
			SHR
			SHR
			SHR
			STXD
			IRX

			GLO  RC				; do we need the first or the second pattern?
			ANI  01H
			PHI  RC
			BNZ  DC_PrepareSecond
					
			LDX				; prepare the mask					
			PLO  RB	
			LDI  00H
			PHI  RB
DC_MaskLoop:		GHI  RB
			SHR
			ORI  80H
			PHI  RB
			DEC  RB
			GLO  RB
			BNZ  DC_MaskLoop

			LDX
			STXD				; keep the width of the first pattern on the stack
			BR   DC_CopyPattern

DC_PrepareSecond:	LDX				; use the width of the first pattern for shifting
			PHI  RB

			LDN  RD				; keep the width of the second character pattern on the stack
			ANI  07H
			STXD

DC_CopyPattern:		INC  RD
			LDI  05H			; prepare a loop over the five bytes of the pattern
			PLO  RC
					
DC_ByteLoop:		LDN  RD				; get a byte from the font
			STXD
			IRX
			INC  RD
					
			GHI  RC
			BNZ  DC_ByteShift

			GHI  RB				; mask out the first pattern
			AND
			STXD
			IRX
			BR   DC_ByteWrite

DC_ByteShift:		GHI  RB				; shift the second pattern
			PLO  RB
DC_ShiftLoop:		LDX
			SHL
			STXD
			IRX
			DEC  RB
			GLO  RB
			BNZ  DC_ShiftLoop

DC_ByteWrite:		LDX				; write the byte
			STR  RF
			INC  RF

			DEC  RC				; continue until all bytes of the pattern are done
			GLO  RC
			BNZ  DC_ByteLoop

			LDI  lo(CharacterPattern)	; restore RF to the beginning of the pattern
			PLO  RF
			LDI  05H			; set the length of the pattern
			PLO  RD
			CALL DrawSprite			; call sprite routine to draw  			

			IRX				; clean up and exit
			LDX
			PLO  RF
			RETURN

;------------------------------------------------------------------------------------------
		ENDIF