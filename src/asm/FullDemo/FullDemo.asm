; *****************************************************************************************
; Copyright (c) 2020 by Richard Dienstknecht
; Changes:
; Gaston Williams, July, 2020 - Modified file to use Initialize.asm and tty1861.asm
; *****************************************************************************************

UseGraphics			EQU "TRUE"
Resolution			EQU "64x64"			; "64x32" or "64x64"
BackBuffer			EQU "OFF"			; 'OFF', 'COPY' or 'SWAP'

UseText				EQU "TRUE"
UseTty				EQU "TRUE"

				INCLUDE "StdDefs.asm"
				INCLUDE "Initialize.asm"

; =========================================================================================
; Main
; =========================================================================================

Start:				CALL BeginTerminal	; set up video buffers and variables
				
			IF BackBuffer <> "OFF"
				CALL CopyBackBuffer	; clear back buffers				
			ENDIF
											
MainLoop:			CALL Text
				CALL BigSprites
				
				BR   MainLoop
;------------------------------------------------------------------------------------------


; =========================================================================================
; Let's show off the 96 character font: 
; =========================================================================================

Text:				CALL ClearScreen

				LOAD RF, FontTitle
				CALL PutString

				LOAD RF, Font1
				CALL PutString

				LOAD RF, Font2
				CALL PutString

				LOAD RF, Font3
				CALL PutString
				
				LOAD RF, Font4
				CALL PutString

				LOAD RF, Font5
				CALL PutString

				LOAD RF, Font6
				CALL PutString				
			
				LOAD RF, PressI
				CALL PutString
				
			IF BackBuffer <> "OFF"
				CALL CopyBackBuffer 	; update swap or copy buffer
			ENDIF				
						
				CALL VideoOn		; show text
				CALL WaitForInput
				
				CALL VideoOff		; hide text while drawing graphics
				RETURN
;------------------------------------------------------------------------------------------


; =========================================================================================
; Let's draw some big sprites
; =========================================================================================

BigSprites:			CALL ClearScreen

				LDI  0008H		; The Klingon ship is actually made
				PLO  RE			; up of four sprites drawn next to
				LDI  0007H		; each other.
				PHI  RE
				
				LOAD RF, Klingon_0
				
				LDI  000FH
				PLO  RD
				CALL DrawSprite

				LDI  0010H
				PLO  RE
				LDI  0000H
				PHI  RE
				
				LOAD RF, Klingon_1
			
				LDI  000EH
				PLO  RD
				CALL DrawSprite

				LDI  0018H
				PLO  RE
				LDI  0003H
				PHI  RE
				
				LOAD RF, Klingon_2
				
				LDI  000BH
				PLO  RD
				CALL DrawSprite

				LDI  0020H
				PLO  RE
				LDI  000CH
				PHI  RE
				
				LOAD RF, Klingon_3
				
				LDI  000AH
				PLO  RD
				CALL DrawSprite

				LDI  0020H		; same with the Romulans
				PLO  RE
				LDI  0020H
				PHI  RE
				
				LOAD RF, Romulan_0
				
				LDI  000BH
				PLO  RD
				CALL DrawSprite

				LDI  0028H
				PLO  RE
				LDI  0025H
				PHI  RE
				
				LOAD RF, Romulan_1
				
				LDI  0008H
				PLO  RD
				CALL DrawSprite

				LDI  0030H
				PLO  RE
				LDI  0026H
				PHI  RE
				
				LOAD RF, Romulan_2
				
				LDI  0006H
				PLO  RD
				CALL DrawSprite

				LDI  0038H
				PLO  RE
				LDI  0020H
				PHI  RE
				
				LOAD RF, Romulan_3
				
				LDI  0008H
				PLO  RD
				CALL DrawSprite

				LOAD RF, SpriteTitle
				
				LDI  0DH
				PLO  RE
				LDI  32H
				PHI  RE
				
				CALL DrawString

				LOAD RF, PressI
				
				LDI  08H
				PLO  RE
				LDI  38H
				PHI  RE
				
				CALL DrawString
				
			IF BackBuffer <> "OFF"
				CALL CopyBackBuffer 	; update swap or copy buffer
			ENDIF
				CALL VideoOn		; show graphics
				CALL WaitForInput
				
				CALL VideoOff		; hide graphics while drawing text
				RETURN
;------------------------------------------------------------------------------------------


; =========================================================================================
; Graphics
; =========================================================================================

Klingon_0	db 0001H, 0003H, 0007H, 000FH, 000FH, 001FH, 0038H, 0070H	; offset 7
		db 00E0H, 00C0H, 00C0H, 00C0H, 0060H, 0060H, 0020H

Klingon_1	db 0006H, 0006H, 000FH, 007FH, 007FH, 007FH, 001FH, 00DFH	; offset 0
		db 00D9H, 00C9H, 00E6H, 00F0H, 00FFH, 001FH

Klingon_2	db 00E0H, 00E0H, 00E0H, 0080H, 00B8H, 00BCH, 003EH, 007FH	; offset 3
		db 00FFH, 00FFH, 0081H

Klingon_3	db 0080H, 00C0H, 00E0H, 0070H, 0030H, 0030H, 0030H, 0030H	; offset 12
		db 0060H, 0040H

;------------------------------------------------------------------------------------------

Romulan_0	db 0060H, 00F0H, 00F0H, 00F0H, 0060H, 0070H, 0038H, 001CH	; offset 0
		db 000FH, 0007H, 0003H

Romulan_1	db 0006H, 000FH, 007FH, 00FFH, 00FFH, 00F9H, 0039H, 000FH	; offset 5

Romulan_2	db 0001H, 00E3H, 00FFH, 00FEH, 00FCH, 00C0H			; offset 6

Romulan_3	db 0060H, 00F0H, 00F0H, 00F0H, 0060H, 00E0H, 00C0H, 0080H	; offset 0

;------------------------------------------------------------------------------------------

; =========================================================================================
; Strings
; =========================================================================================

FontTitle:			db  "\t96 char. font\n\n\0"	
Font1:				db  " !\"#$%&'()*+,-.\\\0"
Font2:				db  "0123456789:;<=>?\0"
Font3:				db  "@ABCDEFGHIJKLMN\0"
Font4:				db  "OPQRSTUVWXYZ[/]\0"
Font5:				db  "^_`abcdefghijklmn\0"
Font6:				db  "opqrstuvwxyz{|}~\n\n\t\0"

SpriteTitle:			db "Big Sprites!\0"

PressI				db "(Press Input)\0"

;------------------------------------------------------------------------------------------