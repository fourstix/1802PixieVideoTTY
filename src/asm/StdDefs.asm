; *****************************************************************************************
; Copyright (c) 2020 
; by Richard Dienstknecht
;
; Changes:
; Gaston Williams, July, 2020   - Added Macros for Std Call and Std Return
; Gaston Williams  August, 2020 - Added Macro for loading Register
; *****************************************************************************************

; =========================================================================================
; Register definitions
; =========================================================================================

R0                                      EQU 00H
R1                                      EQU 01H
R2                                      EQU 02H
R3                                      EQU 03H
R4                                      EQU 04H
R5                                      EQU 05H
R6                                      EQU 06H
R7                                      EQU 07H
R8                                      EQU 08H
R9                                      EQU 09H
RA                                      EQU 0AH
RB                                      EQU 0BH
RC                                      EQU 0CH
RD                                      EQU 0DH
RE                                      EQU 0EH
RF                                      EQU 0FH

;------------------------------------------------------------------------------------------
; =========================================================================================
; Macro definitions for standard call and return
; See RCA CDP1802 User Manual, page 61 for more information
; =========================================================================================

CALL    MACRO   param1
        SEP R4
        dw  param1
        ENDM
        
RETURN  MACRO
        SEP R5
        ENDM
        
LOAD    MACRO   param1, param2
        LDI  lo(param2)
        PLO  param1
        LDI  hi(param2)
        PHI  param1     
        ENDM