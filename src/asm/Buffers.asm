; *****************************************************************************************
; Copyright (c) 2020 
; by Richard Dienstknecht
;
; Changes:
; Gaston Williams, July, 2020 - Removed 64x128 Resolution logic
; Gaston Williams, July, 2020 - Put Buffer definitions into a separate file
; Gaston Williams, Aug,  2020 - Added Cursor and Video flag definitions
; Gaston Williams, Sept, 2020 - Restored 64x128 Resolution logic
; *****************************************************************************************

; =========================================================================================
; Define Video Buffers and Main Stack
; =========================================================================================
                                        CPU 1802
                                        
; =========================================================================================
; Display buffers
; =========================================================================================
                IF BackBuffer == "OFF"                  ; OFF uses only one video buffer
                        IF Resolution == "64x32"
                                ORG 7E00H       
DisplayBuffer:                  db 256 dup (?)
                        ENDIF

                        IF Resolution == "64x64"
                                ORG 7D00H
DisplayBuffer:                  db 512 dup (?)
                        ENDIF

                        IF Resolution == "64x128"
                                ORG 7B00H
DisplayBuffer:                  db 1024 dup (?)
                        ENDIF
                        
                
                ENDIF
                
                IF BackBuffer <> "OFF"                  ; COPY and SWAP use two video buffers
                        IF Resolution == "64x32"
                                ORG 7D00H       
DisplayBuffer:                  db 256 dup (?)
DoubleBuffer:                   db 256 dup (?)
                        ENDIF

                        IF Resolution == "64x64"
                                ORG 7B00H
DisplayBuffer:                  db 512 dup (?)
DoubleBuffer:                   db 512 dup (?)
                        ENDIF
                        
                        IF Resolution == "64x128"
                                ORG 7700H
DisplayBuffer:                  db 1024 dup (?)
DoubleBuffer:                   db 1024 dup (?)
                        ENDIF                                   
                ENDIF

                                ORG 7F00H
                                
; =========================================================================================
; Buffer for unpacked characters
; =========================================================================================

CharacterPattern:       db 5 dup ?

; =========================================================================================
; Cursor location for video console
; =========================================================================================

CursorX                 db ?

CursorY                 db ?
;------------------------------------------------------------------------------------------

; =========================================================================================
; Flag to indicate if 1861 Video is currently on or off
; =========================================================================================

VideoFlag               db ?
;------------------------------------------------------------------------------------------

; 
;Buffers and variables end at 7F08, leaving 120 bytes available for program stack


; =========================================================================================
; Space for the main stack
; =========================================================================================

                                        
                        ORG 7F7FH
StackTop:
;------------------------------------------------------------------------------------------     

; =========================================================================================
; Reserve 7F80H to 7FFFH for Super Monitor program
; =========================================================================================