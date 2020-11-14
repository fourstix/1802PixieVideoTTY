; *******************************************************************************************
; Tty1861 - Teletype Terminal functions
; Copyright (c) 2020 by Gaston Williams
;
; These functions implement basic terminal functions in 64x64 bit graphics.

; Notes: 
;       1. Functions named with "Get" or "Put" are safe functions that check before updating
;       and those named with "Read" or "Write" may not be safe, and the caller is responsible
;       for checking to see if it's safe before calling them update the video data.
;
;       2. BeginTerminal should be called before any video, and the VideoOn and VideoOff 
;       functions should be used to turn the 1861 on and off.
;
;       3. The WaitForSafeUpdate function can be used to check for the end of Video DMA 
;       when it is safe to update video data.
;
; Changes:
; Gaston Williams, Sept, 2020 - Added 64 x 128 Resolution logic
; Gaston Williams, Nov,  2020 - Added support for EOT to clear screen
; *******************************************************************************************

                        IF UseTty == "TRUE"
                                
; =========================================================================================
; Initialize system variables for TTY Terminal
;
; Note: *** MANDATORY *** This function must be called before any other Terminal functions
;
; Internal:
; RF.0          Value to set Video Flag false
; =========================================================================================

BeginTerminal:          SEX  R2                 ; make sure X points to stack pointer
                        
                        LDI  00H                ; set the video flag to false
                        PLO  RF                                         
                        CALL SetVideoFlag
                                                
                        CALL ClearScreen        ; set cursor to home
                        
                IF BackBuffer <> "OFF"
                        CALL CopyBackBuffer     ; clear second video buffer
                ENDIF

                                                        
                        RETURN                  
;------------------------------------------------------------------------------------------

; =========================================================================================
; VideoOn - Turn pixie video on and set the flag
;
; Note: *** MANDATORY *** This function must be used to turn the video on
;
; Internal:
; RF.0          Value to set Video Flag true
; =========================================================================================

VideoOn:                INP 1                   ; turn 1861 video on
                                                
                        LDI  00FFH              ; set video flag to true (-1)
                        PLO  RF
                        CALL SetVideoFlag       
                
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; VideoOff - Turn pixie video off and clear the flag
;
; Note: *** MANDATORY *** This function must be used to turn the video off
;
; Internal:
; RD            Pointer to video flag
; =========================================================================================

VideoOff:               OUT 1                   ; turn 1861 video off

                        DEC  R2                 ; The output instruction increments stack
                                                ; pointer, so back up the stack pointer to
                                                ; point to its previous location.
                                                
                        LDI  00H                ; set the video flag to false
                        PLO  RF                                         
                        CALL SetVideoFlag
                
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; WaitForSafeUpdate -
;               Check the 1861 video status and wait for DMA to complete before returning.
;               When this function returns it is safe to make updates to the video.
;               There will be time for about 8000 instruction cycles (at 2MHz) before the
;               next DMA to occur.  All Get/Put video functions call this function before
;               making any changes.  This logic is based on code found in Tom Pittman's, 
;               Short Course In Programming, Chapter 7, Interrupts and DMA.
;               
;               Before DMA begins, EF1 is asserted for 28 instruction cycles, and before
;               DMA ends EF1 is asserted for only 12 instruction cycles.  This code counts
;               cycles while EF1 is asserted to determine when DMA has ended.
;
; Note: *REQUIRED* to guarantee safety before accessing video data. 
;               Must call this function before calling any UNSAFE function.
;
; Internal:
; RD            Pointer to video flag
; =========================================================================================

WaitForSafeUpdate:      LOAD RD, VideoFlag      ; set pointer to video flag                                             
                        LDN  RD                 ; check video flag so we don't wait forever
                        BZ   WFSU_Exit          ; for an EF1 signal that never occurs.
                                                ; Any updates are fine when video is off
                        

WFSU_Check_DMA:         B1   WFSU_Check_DMA     ; wait for first EF1 siginal
                
WFSU_Sync:              LDI  14H                ; 20 instruction cycles

WFSU_New_EF1:           BN1  WFSU_New_EF1       ; wait for next EF1 signal to start count

WFSU_Count:             SMI  02                 ; count down by 2 and keep counting for 12
                        B1   WFSU_Count         ; (DMA end) or 28 (DMA begin) instructions
                        
                        SHL                     ; check sign bit to see if negative (20-28)
                        BDF  WFSU_Sync          ; at DMA begin. DF = 1, means DMA begin
                                                ; and we must wait for the DMA end

WFSU_Exit:              RETURN                  ; return now that DMA has ended
;------------------------------------------------------------------------------------------                     

; =========================================================================================
; Create a pointer into a Video buffer at the location specified by Y location
;
; Note: *Internal* - Used to manipulator pointer into video buffer
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
; Internal:
; R7.0          Swap Pointer for video buffers
;
; Return:
; RF            Pointer to video buffer with Y Offset
; =========================================================================================

VideoOffsetY:           IF BackBuffer == "OFF"
                                LDI  hi(DisplayBuffer)  ; prepare the pointer to the video buffer
                                PHI  RF
                        ENDIF

                        IF BackBuffer == "COPY"
                                LDI  hi(DoubleBuffer)   ; prepare the pointer to the back buffer
                                PHI  RF
                        ENDIF

                        IF BackBuffer == "SWAP"
                                GLO  R7                 ; prepare pointer to the current back buffer
                                PHI  RF
                        ENDIF                                   
                        
                                GHI  RE                 ; get the y position into video buffer                          
                                
                        IF Resolution == "64x32"
                                ANI  1FH                ; between 0 - 31
                        ENDIF
                                                                
                        IF Resolution == "64x64"
                                ANI  3FH                ; or 0 - 63
                        ENDIF
                        
                        IF Resolution == "64x128"
                                ANI  7FH                ; or 0 - 127
                        ENDIF
                                SHL                     ; Convert Y value to position offset = (y * 8)
                                SHL                     ; check high bit of 64x128 count in df

                        IF Resolution == "64x128"
                                PLO  RF                 ; save RF low byte
                                BNF  VY_SkipHighInc     ; check high order bit of 64x128 count
                                GHI  RF                 ; get RF high byte
                                ADI  02H                ; df represents two's bit after shifting
                                PHI  RF                 ; update RF high byte
VY_SkipHighInc:                 GLO  RF                 ; restore RF low byte and continue shifting

                        ENDIF                           
                                SHL
                                PLO  RF
                                BNF  VY_SkipLowInc
                                GHI  RF
                                ADI  01H
                                PHI  RF

VY_SkipLowInc:                  RETURN
;------------------------------------------------------------------------------------------


; =========================================================================================
; Add the X byte offset to a pointer into a Video buffer
;
; Note: *Internal* - Used to manipulator pointer into video buffer
;
; Parameters:
; RF            Pointer to video buffer with Y Offset
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
; Return:
; RF            Pointer to video buffer at X,Y byte Offset
; RC.1          X Offset byte value
; RC.0          X Offset bit value
; =========================================================================================

VideoOffsetX:           GLO  RE         ; get the x bit position 
                        ANI  07H        ; mask off all but lowest 3 bits
                        PLO  RC         ; save bit value in RC.0
                                
                        GLO  RE         ; get the x byte position into video buffer
                        ANI  3FH        ; value 0 - 63
                        SHR             ; Convert x value to position offset = (x / 8)
                        SHR                     
                        SHR
                        PHI  RC         ; save byte value in RC.1
                                                

                        STXD            ; byte position offset in M(X)
                        IRX
                                
                        GLO  RF         ; advance the pointer coordinate by byte offset                         
                        ADD             ; add the offset to pointer                                     
                        PLO  RF         ; save lower byte
                        
                        GHI  RF         ; update high byte if needed                    
                        ADCI 00H        ; Add carry into high byte and save
                        PHI  RF
                                
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; SetVideoFlag - Set the video flag to false or true
;
; Note: *Internal* - Use VideoOn and VideOff to set or clear the video flag
;
; Parameters:
; RF.0          Value for flag, zero for false, non-zero for true
; Internal:
; RD            Pointer to video flag
; =========================================================================================
SetVideoFlag:           LOAD RD, VideoFlag      ; set pointer to video flag                                                     
                        GLO  RF                 ; get the value for the flag
                        STR  RD                 ; store the flag
                        
                        RETURN
;------------------------------------------------------------------------------------------                     

; =========================================================================================
; Clear a line of text on the video console (6 rows of pixels at 8 bytes per row) along
; with the 2 rows of the next row of text.
;
; Note: *** UNSAFE *** This function does not check before accessing video data.
;               Must call WaitForSafeUpdate function before calling this function.
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
; Internal:
; RF            Pointer to video buffer
; RD            Counter
; R7.0          Swap Pointer for video buffers
; =========================================================================================

BlankLine:              CALL VideoOffsetY
                                                                                
                                        
                        LDI  00H        ; load byte counter
                        PHI  RD
                        PLO  RD

BL_Loop:                LDI  00H
                        STR  RF
                        INC  RF
                        INC  RD
                                        
                        GLO  RD
                        
                        SDI  40H        ;do 64 times (6 rows of pixels x 8 bytes per row                                        
                                        ; + 2 rows to overwrite existing text on line below.)                           
                        LBNZ BL_Loop    
                                        
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; Advance cursor to next tab stop: 08H, 10H, 18H, 20H, 28H, 30H, 38H, 00H (NextLine)
;
; Note: Safe - This function does not access video data
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================

TabCursor:              GLO  RE                 ; get cursorX value
                        ADI  08H                ; advance 8 pixels, 2 avg char widths
                        ANI  78H                ; mask off lower 3 bits (truncate to 8)
                        PLO  RE                 ; set the x cursor to begining of line (zero) 

                        SDI  38H                ; check to see if we went past last tab stop
                        BGE  TAB_Exit           ; If not, we're done
                        
                        CALL NextLine           ; If we went over go to next line
                        
                                                                
TAB_Exit:               RETURN
;------------------------------------------------------------------------------------------
; =========================================================================================
; Move cursor back one position and delete the character
;
; Note: *** UNSAFE *** This function does not check before accessing video data.
;               Must call WaitForSafeUpdate function before calling this function.

;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
; 
; Internals:
; RF.0          Width of average character to back up
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================

Backspace:              LDI  04H                ; average charcter width = 4 pixels
                        PLO  RF                 ; RD.0 has width to back pu
                        CALL LeftCursor         ; Move cursor back one character                
                        
                        CALL BlankCharacter     ; erase the previous character  
                                                                
                        RETURN
;------------------------------------------------------------------------------------------


; =========================================================================================
; Create mask for blanking character bits in video buffer
;
; Note: *Internal* - Used for removing character pixels
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
; RC.0          X Offset bit value
; RC.1          X Offset byte value
;
; Internals:
; RD.0          Counter for calculating Mask
;
; Returns:
; RD.1          Mask for video bit values X byte
; =========================================================================================
CreateMask:             LDI  00FFH              ; load bit mask
                        PHI  RD         
                        GLO  RC                 ; put the X offset bit value in counter
                        PLO  RD                  
                        
CM_Test:                BZ   CM_Done            ; keep going to counter exhausted
                        GHI  RD                 ; get the mask byte
                        SHR                     ; shift once for each bit offset
                        PHI  RD                 ; save mask value
                        DEC  RD                 ; decrement counter
                        GLO  RD                 ; test byte for zero
                        BR   CM_Test
                        
CM_Done:                GHI  RD                 ; get mask value
                        XRI  00FFH              ; invert all the bits for ANDing
                        PHI  RD                 ; put bit mask back in RD.1


                        RETURN
;------------------------------------------------------------------------------------------


; =========================================================================================
; Advance cursor to begining of the next line. 
;
; Note: Safe - This function does not access video data
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================

NextLine:               LDI  00H                ; load zero and save as cursorX
                        PLO  RE                 ; set the x cursor to begining of line (zero) 

                        GHI  RE                 ; advance y cursor to point to next line                                                                        
                        ADI  06H                ; each line is 6 pixels high
                        PHI  RE                 ; update cursorY 

                IF Resolution == "64x128"       
                        SDI  78H                ; check to see if we are past the end           
                        BGE NL_Exit             ; DF = 1 means haven't gone past 120 y pixels                                                   
                        
                        LDI  04H                ; go back to top line
                        PHI  RE                 ; update cursorY                
                ENDIF
                        
                IF Resolution == "64x64"        
                        SDI  3CH                ; check to see if we are past the end
                        BGE NL_Exit             ; DF = 1 means haven't gone past 60 y pixels                            
                        
                        LDI  02H                ; go back to top line
                        PHI  RE                 ; update cursorY                
                ENDIF
                        
                IF Resolution == "64x32"        
                        SDI  1EH                ; check to see if we are past the end
                        BGE NL_Exit             ; DF = 1 means haven't gone past 30 y pixels                            
                        
                        LDI  01H                ; go back to top line
                        PHI  RE                 ; update cursorY
                ENDIF
                                                                
NL_Exit:                RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; Advance cursor down to next line without changing x location
;
; Note: *** UNSAFE *** This function does not check before accessing video data.
;               Must call WaitForSafeUpdate function before calling this function.
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================

DownCursor:             GHI  RE                 ; move y by 6 pixels
                        ADI  06H
                        PHI  RE                 ; save y
                        
                IF Resolution == "64x128"                                                                                       
                        SDI  78H                ; check y value to see if we went past 120
                        BGE  DC_Blank           ; if not, erase the next line                   

                        LDI  04H                ; if so, move back to first line at top of console
                        PHI  RE                 ; save y
                ENDIF
                
                IF Resolution == "64x64"                                                                                        
                        SDI  3CH                ; check y value to see if we went past 60
                        BGE  DC_Blank           ; if not, erase the next line
                        
                        LDI  02H                ; if so, move back to first line at top of console
                        PHI  RE                 ; save y
                ENDIF
                        
                IF Resolution == "64x32"        
                        SDI  1EH                ; check y value to see if we went past 30
                        BGE  DC_Blank           ; if not, erase the next line
                        
                        LDI  01H                ; if so, move back to first line at top of console
                        PHI  RE                 ; save y        
                ENDIF
                        
DC_Blank:               CALL BlankLine          ; erase existing text
                        
                                                                
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; Clear character pixels from the current cursor location
;
; Note: *** UNSAFE *** This function does not check before accessing video data.
;               Must call WaitForSafeUpdate function before calling this function.
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
; Internal:
; RF            Pointer to video buffer
; RD.1          Mask for video bit values X byte
; RD.0          Counter
; RC.0          X Offset bit value
; RC.1          X Offset byte value
; =========================================================================================

BlankCharacter:         CALL VideoOffsetY       ; set pointer to video at y location
                        CALL VideoOffsetX       ; set pointer to video at x,y location

                        GLO  RE                 ; check x location
                        BNZ  BCH_GetMask        ; if inside line, calculate masks
                        
                        CALL BlankLine          ; if we are the begining, just clear the line
                        BR   BCH_Done                   
                                                
BCH_GetMask:            CALL CreateMask         ; get the mask for video bits

                        LDI  00H                ; initialize counter 
                        PLO  RD                 
                        

BCH_Blank:              GHI  RD                 ; get mask and put at M(X)
                        STXD
                        IRX
                        
                        LDN  RF                 ; load video byte
                        AND                     ; and with mask                 
                        STR  RF                 ; put it back in memory
                        
                        GHI  RC                 ; get the byte offset value
                        SDI  07H                ; check for last byte
                        BZ   BCH_LastByte       ; don't blank next byte after last byte
                        
                        LDI  00H                ; blank out next byte after byte 0 to 6
                        INC  RF                 ; set video pointer to next byte
                        STR  RF                 ; blank out any remaining pixels
                        DEC  RF                 ; set video ptr back to x byte
                        
BCH_LastByte:           INC  RD                 ; increment counter
                        GLO  RD                 ; check if done 5 times
                        SDI  05H                
                        BZ   BCH_Done           
                        
                        GLO  RF                 ; Adjust pointer to next line of character
                        ADI  08H                ; each line is 8 bytes 
                        PLO  RF                 ; save low byte and adjust hi byte with carry
                        
                        GHI  RF
                        ADCI 00H                
                        PHI  RF                 ; video pointer now points to next line of character
                        BR   BCH_Blank          ; do next line
                        
BCH_Done:               RETURN
;------------------------------------------------------------------------------------------


; =========================================================================================
; Move cursor backwards a number of pixel widths
;
; Note: Safe - This function does not access video data
;
; Parameters:
; RF.0          Width to back up cursor
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================

LeftCursor:             GLO  RE                 ; 
                        BZ   LC_PreviousLine    ; if begining of line, go back one line
                        
                        STXD                    ; store x location it in M(X)
                        IRX
                        
                        GLO  RF                 ; get the pixel width
                        
                        SD                      ; move x back RD.0 pixels
                        PLO  RE                 ; save x                                                                                
                        BGE  LC_Exit            ; if positive or zero, we are done
                        
                        LDI  00H                ; don't back up before begining of line
                        PLO  RE
                        BR   LC_Exit            
                        
LC_PreviousLine:        GHI  RE
                        SMI  06H                ; back up one line
                        PHI  RE
                        BL   LC_Home            ; but don't go beyond home
                        
                        LDI  40H                ; set M(X) to end of line
                        STXD                    ; store eol in M(X)
                        IRX
                        
                        GLO  RF                 ; get the pixel width
                        SD                      ; back up from eol                      
                        PLO  RE         
                        BR   LC_Exit
                        
LC_Home:        IF Resolution == "64x128"
                        LDI  04H                ; set y to first line
                        PHI  RE
                ENDIF
                
                IF Resolution == "64x64"
                        LDI  02H                ; set y to first line
                        PHI  RE
                ENDIF
                
                IF Resolution == "64x32"        
                        LDI  01H                ; set y to first line
                        PHI  RE
                ENDIF
                        LDI  00H                ; set x to beginning
                        PLO  RE

LC_Exit:                RETURN
;------------------------------------------------------------------------------------------


; =========================================================================================
; Move cursor forwards a number of pixel widths
;
; Note: Safe - This function does not access video data
;
; Parameters:
; RF.0          Width to advance cursor
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================

RightCursor:            GLO  RF                 ; advance the x coordinate by the
                        STXD                    ; width of the character + 1
                        IRX                     ; store width in M(X)
                        
                        GLO  RE
                        ADD
                        ADI  01H
                        PLO  RE
                                        
                        SDI  3CH                ; check x value to see if we went past 60
                        BGE  RC_Exit
                                        
                        LDI  00H                ; set x for beginning of next line and adjust y
                        PLO  RE
                                                                
                        GHI  RE                 ; move y by 6 pixels
                        ADI  06H
                        PHI  RE

                IF Resolution == "64x128"               
                        SDI  78H                ; check y value to see if we went past 120
                        BGE  RC_Exit
                                                
                        LDI  04H                ; if so move back to first line at top of console
                        PHI  RE 
                ENDIF                                   
                
                IF Resolution == "64x64"                
                        SDI  3CH                ; check y value to see if we went past 60
                        BGE  RC_Exit
                        
                        LDI  02H                ; if so move back to first line at top of console
                        PHI  RE 
                ENDIF
                
                IF Resolution == "64x32"        
                        SDI  1EH                ; check y value to see if we went past 30
                        BGE  RC_Exit
                                                
                        LDI  01H                ; if so move back to first line at top of console
                        PHI  RE 
                ENDIF

RC_Exit:                RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; Move cursor back one pixel position and clear the column
;
; Note: *** UNSAFE *** This function does not check before accessing video data.
;               Must call WaitForSafeUpdate function before calling this function.
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
; 
; Internals:
; RF.0          Width of to back up
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================

Rubout:                 LDI  01H                ; rubout one column of pixels
                        PLO  RF                 ; pixel width to back up
                        CALL LeftCursor         ; Move cursor back one character                
                        
                        CALL BlankCharacter     ; erase the previous pixel column       
                                                                
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; Move cursor forward one pixel position
;
; Note: Safe - This function does not access video data
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
; 
; Internals:
; RF.0          Width of character (zero)
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================
UnitSeparator:          LDI  00H                ; put zero as character width
                        PLO  RF                 
                        
                        CALL RightCursor        ; advance cursor 0+1 pixel column
                        
                        RETURN
; =========================================================================================
; Clear line and position cursror at the begining of the current line. 
;
; Note: *** UNSAFE *** This function does not check before accessing video data.
;               Must call WaitForSafeUpdate function before calling this function.
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
;
; Return:
; RE.0          Updated X coordinate
; RE.1          Updated Y coordinate
; =========================================================================================

CancelLine:             LDI  00H                ; load zero and save as cursorX
                        PLO  RE                 ; set the x cursor to begining of line (zero) 

                        CALL BlankLine          ; clear the line
                        
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; ClearScreen - Blank the video screen and home the cursor.
;
; Note: Safe - This function checks the video status before accessing video data
;
; Internal:
; RF.1          zero value to fill screen
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
; =========================================================================================

ClearScreen:            CALL WaitForSafeUpdate  ;Wait for DMA to complete before clearing
                        
                        LDI  00H                ; clear screen
                        PHI  RF
                        CALL FillScreen
                        
                        LDI  00H                ; set x location to left margin                 
                        PLO  RE
                        
                IF Resolution == "64x128"
                        LDI  04H                ; set y location to top line                    
                        PHI  RE
                ENDIF
                
                IF Resolution == "64x64"
                        LDI  02H                ; set y location to top line                    
                        PHI  RE
                ENDIF
                
                IF Resolution == "64x32"
                        LDI  01H                ; set y location to top line                    
                        PHI  RE
                ENDIF
                        CALL SetCursor          ; send cursor home
                                        
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; GetChar - Get Character from Hex Input.  Wait for Input press and read Ascii character
;               from data bus.
;
; Note: Safe - This function does not access video data
;
; Returns:
; RC.0          Ascii character read from hex input
; =========================================================================================

GetChar:                BN4  GetChar            ; Wait for Input press

                        INP  4                  ; Input stores byte in M(X)
                                        
                        ANI  007FH              ; Ascii is only 7 bits
                        PLO  RC
                        
GC_Release:             B4   GC_Release         ; Wait for Input release

                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; WriteHexOutput - Write a value out to the hex display
;
; Note: Safe - This function does not access video data
;
; Parameters:
; RC.0          Value to be shown on the hex display 
; =========================================================================================

WriteHexOutput:         GLO  RC         ; Get byte to display
                        STR  R2         ; Put byte on the stack
                        
                        OUT  4          ; Show it. This increments stack pointer,
                        DEC  R2         ; so back up stack pointer to point to the end.
                                        
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; ReadHexInput - Read a byte from Hex Input.  Wait for Input press and read from data bus.
;
; Note: Safe - This function does not access video data
;
; Returns:
; RC.0          Byte read from hex input
; =========================================================================================
ReadHexInput:           BN4  ReadHexInput       ; Wait for Input press

                        INP  4                  ; Input stores byte in M(X)                                     
                        PLO  RC                 ; Save byte for return
                        
RHI_Release:            B4   RHI_Release        ; Wait for Input release

                        RETURN                  ; return
;------------------------------------------------------------------------------------------

; =========================================================================================
; WaitForInput - Wait for Input key press and release.  No data is read.
;
; Note: Safe - This function does not access video data
;
; Returns:
;
; =========================================================================================

WaitForInput:           BN4  WaitForInput       ; Wait for Input press

                        
WFI_Release:            B4   WFI_Release        ; Wait for Input release

                        RETURN                  ; return
;------------------------------------------------------------------------------------------


; =========================================================================================
; PutChar - Put a character on the screen and advance the cursor
;
; Note: Safe - This function checks the video status before accessing video data
;
; Parameters:
; RC.0          ASCII code of the character (20 - 5F)
;
; Internal:
; RC.1          Temporary values
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
; RF.0          Width of character from drawCharacter
; =========================================================================================
PutChar:                CALL WaitForSafeUpdate
                        
                        CALL WriteChar
                        
                IF BackBuffer <> "OFF"
                        CALL CopyBackBuffer     ; update SWAP or COPY buffer
                ENDIF   
                                        
                        RETURN
;------------------------------------------------------------------------------------------


; =========================================================================================
; HandleControlChar - Process a control character and move the cursor on screen
;
; Note: *** UNSAFE *** This function does not check before accessing video data.
;               Must call WaitForSafeUpdate function before calling this function.
;
; Parameters:
; RC.0          ASCII code of the character (20 - 5F)
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character

; Internals:
; RC.1          Temporary values
; RF.0          Width of character 
;
; Returns:
; RE.0          Updated X coordinate of the character
; RE.1          Updated Y coordinate of the character
; =========================================================================================
HandleControlChar:      GLO  RC                 ; get the character
                        SDI  0AH                ; check for newline
                        BZ   HCC_NewLine
                                                                                
                        GLO  RC                 ; get the character
                        SDI  0DH                ; check for carriage return
                        BZ   HCC_NewLine
                        
                        GLO  RC                 ; get the character
                        SDI  0CH                ; check for form feed
                        BZ   HCC_FormFeed

                        GLO  RC                 ; get the character
                        SDI  04H                ; check for end of transmission
                        BZ   HCC_FormFeed
                        
                        GLO  RC                 ; get the character
                        SDI  09H                ; check for tab
                        BZ   HCC_Tab
                        
                        GLO  RC                 ; get the character
                        SDI  0BH                ; check for vertical tab
                        BZ   HCC_VTab
                        
                        GLO  RC                 ; get the character
                        SDI  08H                ; check for backspace
                        BZ   HCC_Backspace      
                        
                        GLO  RC                 ; get the character 
                        SDI  7FH                ; check for del
                        BZ   HCC_Del
                        
                        GLO  RC                 ; get the character
                        SDI  18H                ; check for cancel the line
                        BZ   HCC_Cancel
                        
                        GLO  RC                 ; get character         
                        SDI  1FH                ; check for unit separator
                        BZ   HCC_Unit
                        
HCC_Unit:               CALL UnitSeparator      ; advance cursor 1 pixel column space
                        BR   HCC_Exit           
                        
                        BR   HCC_Exit           ; ignore everything else

HCC_Cancel:             CALL CancelLine         ; erase the current line
                        BR   HCC_Exit

HCC_Del:                CALL Rubout             ; del backs up and rubs out one column                  
                        BR   HCC_Exit
                        
HCC_Backspace:          CALL Backspace          ; move cursor back and delete a character
                        BR   HCC_Exit           

HCC_Tab:                CALL TabCursor          ; move to next tab stop
                        BR   HCC_Exit
                        
HCC_VTab:               CALL DownCursor         ; move to next line, same x position
                        BR   HCC_Exit

HCC_FormFeed:           CALL ClearScreen        ; form feed clears the screen                   
                        BR   HCC_Exit           
                                                                                
HCC_NewLine:            CALL NextLine           ; go to next line and end                       
                        BR   HCC_Exit
                                                        
HCC_Exit:               RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; WriteChar - Write a character on the screen and advance the cursor
;
; Note: *** UNSAFE *** This function does not check before accessing video data.
;               Must call WaitForSafeUpdate function before calling this function.
;
; Parameters:
; RC.0          ASCII code of the character (20 - 5F)
;
; Internal:
; RC.1          Temporary values
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
; RF.0          Width of character from drawCharacter
; =========================================================================================

WriteChar:              CALL GetCursor
                                                                
                        GLO  RE                 ; get the x location
                                                                                                        
                        BNZ  WC_SetChar         ; check for beginning of new line
                        CALL BlankLine          ; if at begining, blank the line
                        
WC_SetChar:             GLO  RC                 ; check for DEL the only control char
                        SDI  7FH                ; that is greater than 20H
                        BZ   WC_Control         
                                                                                                                        
                        GLO  RC                 ; get the character
                        SMI  20H                ; check for any printable character
                        BGE  WC_Draw            
                                                                                
WC_Control:             CALL HandleControlChar  ; everthing else is a control character
                        BR   WC_UpdateCursor    ; save cursor changes after control char
                                
WC_Draw:                GLO  RE                 ; push RE with cursor location onto the stack
                        STXD
                        GHI  RE
                        STXD 
                        
                        CALL DrawCharacter      ; write the chracter
                                                                
                        IRX                                     
                        LDXA
                        PHI  RE                 ; restore RE with cursor location
                        LDX
                        PLO  RE                         
                        
                        CALL RightCursor        ; advance cursor by character width + 1
                        
WC_UpdateCursor:        CALL SetCursor
                                        
WC_Exit:                RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; PutString - Read characters from a string and write to video until a null is read.
; Parameters:
; RF    - pointer to String
;
; Note: Safe - This function checks the video status before accessing video data
;
; Internal:
; RC.0  - character value read from input
; =========================================================================================

PutString:              CALL WaitForSafeUpdate  

PS_WriteString:         LDN  RF                 ; get character, exit if 0 (null)
                        PLO  RC
                        BZ   PS_Exit
                        INC  RF
                                        
                        GLO  RF                 ; push RF onto the stack
                        STXD
                        GHI  RF
                        STXD
                
                                        
                        CALL WriteChar          ; write character to video
                                                ; ok to use write since we know it's safe
                        
                        IRX                     ; restore RF from stack
                        LDXA
                        PHI  RF
                        LDX
                        PLO  RF
                                        
                        BR PS_WriteString       ; continue with next character until null
                        

PS_Exit:        IF BackBuffer <> "OFF"
                        CALL CopyBackBuffer     ; update SWAP or COPY buffer
                ENDIF   

                        RETURN
;------------------------------------------------------------------------------------------
; =========================================================================================
; SetCursor - Save the Cursor value into memory
;
; Note: Safe - This function does not access video data
;
; Parameters:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
;
; Internal:
; RD            Pointer to CursorY and CursorX
; =========================================================================================
SetCursor:              LOAD RD, CursorX        ; set the x cursor                                                      
                        GLO  RE                 ; get character x location
                        STR  RD                 ; save the x cursor value       
                                                                                        
                        LOAD RD, CursorY        ; set the y cursor                                                                                                      
                        GHI  RE                 ; get character y location
                        STR  RD                 ; save the y cursor value                                                                                               
                                        
                        RETURN
;------------------------------------------------------------------------------------------

; =========================================================================================
; GetCursor - Read the Cursor value from memory
; 
; Note: Safe - This function does not access video data
:
; Parameters:
;
; Internal:
; RD            Pointer to CursorY and CursorX
;
; Returns:
; RE.0          X coordinate of the character
; RE.1          Y coordinate of the character
; =========================================================================================
GetCursor:              LOAD RD, CursorX        ; get the x cursor                                                      
                        LDN  RD                 ; load the x cursor value                                       
                        PLO  RE                 ; set character x location
                        
                        LOAD RD, CursorY        ; get the y cursor                                                                              
                        LDN  RD                 ; load the y cursor value                                                                                       
                        PHI  RE                 ; set character y location
                                        
                        RETURN
;------------------------------------------------------------------------------------------



                                        ENDIF