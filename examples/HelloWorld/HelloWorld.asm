; *******************************************************************************************
; HelloWorld - Write a message to the display using PutChar function
;
; Copyright (c) 2020 by Gaston Williams
;
; *******************************************************************************************
UseGraphics                     EQU "TRUE"
Resolution                      EQU "64x32"            ; "64x32", "64x64" or "64x128"
BackBuffer                      EQU "OFF"               ; 'OFF', 'COPY' or 'SWAP'

UseText                         EQU "TRUE"
UseTty                          EQU "TRUE"

                        INCLUDE "StdDefs.asm"
                        INCLUDE "Initialize.asm"


; =========================================================================================
; Main
; =========================================================================================

Start:                  CALL BeginTerminal


                        CALL VideoOn            ; turn video on

MainLoop:               CALL HelloWorld


                        CALL WaitForInput       ; wait for input from the hex keyboard

                        BR   MainLoop           ; say Hello! again
;----------------------------------------------------------------------------------------


; =========================================================================================
; HelloWorld - write a Hello, World! message to the screen using PutChar
;
; Internals:
; RC.0 - Character to write to screen
; =========================================================================================

HelloWorld:             LDI  "H"
                        PLO  RC

                        CALL PutChar

                        LDI  "e"
                        PLO  RC

                        CALL PutChar

                        LDI  "l"
                        PLO  RC

                        CALL PutChar

                        LDI  "l"
                        PLO  RC

                        CALL PutChar

                        LDI  "o"
                        PLO  RC

                        CALL PutChar

                        LDI  ","
                        PLO  RC

                        CALL PutChar

                        LDI  " "
                        PLO  RC

                        CALL PutChar

                        LDI  "W"
                        PLO  RC

                        CALL PutChar

                        LDI  "o"
                        PLO  RC

                        CALL PutChar

                        LDI  "r"
                        PLO  RC

                        CALL PutChar

                        LDI  "l"
                        PLO  RC

                        CALL PutChar

                        LDI  "d"
                        PLO  RC

                        CALL PutChar

                        LDI  "!"
                        PLO  RC

                        CALL PutChar

                        LDI  " "
                        PLO  RC

                        CALL PutChar

                        RETURN;
;-----------------------------------------------------------------------
