; *****************************************************************************************
; Copyright (c) 2020 
; by Richard Dienstknecht
;
; Changes:
; Gaston Williams, July,   2020 - Rewrote Initialisation.asm file as Initialize.asm
; Gaston Williams, July,   2020 - Removed unused include files
; Gaston Williams, July,   2020 - Replaced Std Call and Return with Macros
; Gaston Williams  August, 2020 - Added IF blocks to change compile order
; Gaston Williams  August, 2020 - Included padding file
; Gaston Williams  August, 2020 - Added Macro for loading Register
; *****************************************************************************************
				INCLUDE "bitfuncs.inc"
				INCLUDE "buffers.asm"

; =========================================================================================
; Starting point of the program and initialisation of the CPU registers
;
; R0		Reserved as pointer to the DMA buffer
; R1		Reserved as interrupt vector
; R2		Main stack pointer
; R3		Main program counter
; R4		Program counter for standard call procedure
; R5		Program counter for standard return procedure
; R6		Reserved for temporary values from standard call/return procedures
; R7 - RF	Free to use in the program, not initialized
; =========================================================================================	
				CPU 1802
				ORG 0000H
		
Init:				LOAD R1, DisplayInt	; DMA Buffer pointer
				
				LOAD R2, StackTop	; Main Stack pointer
				
				LOAD R3, Start		; Main Program Counter
				
				LOAD R4, StdCall	; Standard CALL procedure
				
				LOAD R5, StdReturn	; Standard RETURN procedure
				
				SEP  R3			; Run Main program
;------------------------------------------------------------------------------------------


; =========================================================================================
; Standard Call Procedure
; as described in RCA CDP1802 User Manual, page 61 
; =========================================================================================
STC_Exit:			SEP  R3
StdCall:			SEX  R2
				GHI  R6
				STXD
				GLO  R6
				STXD
				GHI  R3
				PHI  R6
				GLO  R3
				PLO  R6
				LDA  R6
				PHI  R3
				LDA  R6
				PLO  R3
				BR   STC_Exit

;------------------------------------------------------------------------------------------


; =========================================================================================
; Standard Return Procedure
; as described in RCA CDP1802 User Manual, page 61 
; =========================================================================================
STR_Exit:			SEP  R3
StdReturn			GHI  R6
				PHI  R3
				GLO  R6
				PLO  R3
				SEX  R2
				INC  R2
				LDXA
				PLO  R6
				LDX
				PHI  R6
				BR   STR_Exit

;------------------------------------------------------------------------------------------


; =========================================================================================
; Simple delay loop
; 
; Parameters:
; RF.0				Delay time
; =========================================================================================
Delay:				NOP
				DEC  RF
				GLO  RF
				BNZ  Delay
				RETURN

;------------------------------------------------------------------------------------------


; =========================================================================================
; Includes - Change order of compiling to jump target not on same page errors
; =========================================================================================

				INCLUDE "Graphics1861.asm"
				
		IF Resolution == "64x64"				
			IF BackBuffer == "OFF"
				INCLUDE "Text1861.asm"							
				INCLUDE "Fonts.asm"
			ELSEIF
				INCLUDE "Fonts.asm"
				INCLUDE "Text1861.asm"				
			ENDIF				
				INCLUDE "Tty1861.asm"
		ENDIF
		
		IF Resolution == "64x32"				
			IF BackBuffer == "OFF"
				INCLUDE "Text1861.asm"							
				INCLUDE "Fonts.asm"
				INCLUDE "Tty1861.asm"
			ENDIF
			
			IF BackBuffer == "COPY"
				INCLUDE "Fonts.asm"
				INCLUDE "Text1861.asm"	
				INCLUDE "Tty1861.asm"
			ENDIF
			
			IF BackBuffer == "SWAP"			
				INCLUDE "Tty1861.asm"								
				INCLUDE "Text1861.asm"					
				INCLUDE "Fonts.asm"
			ENDIF				
				
		ENDIF
		
			; pad assembled code to end of page to avoid page boundary errors 	
				INCLUDE "Padding.asm"  
				


