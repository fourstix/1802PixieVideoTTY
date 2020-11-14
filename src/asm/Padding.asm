; *****************************************************************************************
; Padding - Code with 64x64 or 64x128 resolution and the Swap or Copy BackBuffer option
;           assembles to near the end of a page boundary.  This file contains padding
;           definitions to prevent errors in user code caused by branches straddling a page
;           boundary.  This can cause 'jump target not on same page' errors when assembling
;           user code.  Padding values greater than 32 bytes are commented out.
;
; Copyright (c) 2020 by Gaston Williams
;
; Changes:
; Sept, 2020 - Added padding definitions for 64x128 resolution
; *****************************************************************************************

; =========================================================================================
; Padding definitions for more than 16 bytes are commented out.
; =========================================================================================

                IF Resolution == "64x128"
                        ; 64x128 resolution user code when assembled with the BackBuffer option "COPY"
                        ; ends exactly on a page boundary so no padding is needed
                        ;IF BackBuffer == "COPY"
                        ;        db 0 dup 00H
                        ;ENDIF

                        IF BackBuffer == "SWAP"
                                db 6 dup 00H
                        ENDIF

                        ; Uncomment the lines below if there's a boundary issue with 64x128
                        ; resolution user code when assembled with the BackBuffer option "OFF"

                        ;IF BackBuffer == "OFF"
                        ;       db 22H dup 00H
                        ;ENDIF

                ENDIF

                IF Resolution == "64x64"
                        IF BackBuffer == "COPY"
                                db 2 dup 00H
                        ENDIF

                        IF BackBuffer == "SWAP"
                                db 8 dup 00H
                        ENDIF

                        ; Uncomment the lines below if there's a boundary issue with 64x64
                        ; resolution user code when assembled with the BackBuffer option "OFF"

                        ;IF BackBuffer == "OFF"
                        ;       db 24H dup 00H
                        ;ENDIF

                ENDIF

                IF Resolution == "64x32"
                        IF BackBuffer == "COPY"
                               db 13H dup 00H
                        ENDIF

                        IF BackBuffer == "SWAP"
                               db 1BH dup 00H
                        ENDIF

                        ; Uncomment the lines below if there's a boundary issue with 64x32
                        ; resolution user code when assembled with the BackBuffer option "OFF"

                        ;IF BackBuffer == "OFF"
                        ;       db 33H dup 00H
                        ;ENDIF

                ENDIF
;------------------------------------------------------------------------------------------
