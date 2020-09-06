# 1802PixieVideoTTY
Basic TTY terminal function for CDP1861 Pixie Video Display written in 1802 Assembly code.

This code provides support for a basic teletype (TTY) terminal functions on an 1861 Pixie Video display
driven by an 1802 Cosmac microprocessor.  It has been tested with the 1802 Membership Card by Lee Hart 
with the [MCard1802TeensyPixieVideo](https://github.com/fourstix/MCard1802TeensyPixieVideo) CDP1861 simulator.
The code is based on Richard Dienstknecht's original graphics code that was posted in the [Cosmac Elf Group on Groups.io.](https://groups.io/g/cosmacelf)

The code is assembled with the [Macro Assembler AS](http://john.ccac.rwth-aachen.de:8000/as/) by Alfred Arnold,


Repository Contents
-------------------
* **/src/asm/**  -- Assembly code source files for the 1802PixieVideoTTY functions.
  * StdDefs.asm - standard definitions used in assembly source files
  * Initialize.asm - initialization functions and includes
  * Buffers.asm - definitions for video buffers and variables used by the program
  * Graphics1861.asm - graphics routines for drawing on the CDP1861 display
  * Text1861.asm - routines to draw text characters on screen
  * Fonts.asm - font table for text
  * Tty1861.asm	- teletype terminal functions for the CDP1861 display
  * Padding.asm	- optional padding definitions to prevent page boundary errors in user code.
* **/src/asm/BasicTerminal/** 
  * BasicTerminal.asm - Use TTY functions to echo ASCII characters typed into the hex keypad onto 
  the CDP1861 display in 64x64 resolution using GetChar and PutChar functions.
* **/src/asm/HelloWorld/** 
  * HelloWorld.asm - Write a greeting in 64x32 resolution to the display when the Input button is pressed using the PutChar function.
  **/src/asm/PutString/** 
  * PutString.asm - Write strings to the display in 64x64 resoulution using the PutString function.
* **/src/asm/StringBuffer/** 
  * StringBuffer.asm - Load up to 31 characters typed into the hex keypad into a buffer until null (00) is typed in, then write the string to the display.
* **/src/asm/FullDemo/** 
  * FullDemo.asm - The original graphics demo redone using the TTY functions using PutString instead of DrawString.
* **/examples/**  -- Assembled example files for the 1802PixieVideoTTY functions, including list, hex and binary files.
* **/examples/BasicTerminal/** 
  * BasicTerminal - Use TTY functions to echo ASCII characters typed into the hex keypad onto 
  the CDP1861 display in 64x64 resolution using GetChar and PutChar functions.
* **/examples/HelloWorld/** 
  * HelloWorld - Write a greeting in 64x32 resolution to the display when the Input button is pressed using the PutChar function.
  **/examples/PutString/** 
  * PutString - Write strings to the display in 64x64 resoulution using the PutString function.
* **/examples/StringBuffer/** 
  * StringBuffer - Load up to 31 characters typed into the hex keypad into a buffer until null (00) is typed in, then write the string to the display.
* **/examples/FullDemo/** 
  * FullDemo - The original graphics demo redone using the TTY functions using PutString instead of DrawString.  
* **/src/org/**  
  * LibTest - Original 1861 graphics code library functions written by Richard Dienstknecht  
* **/pics** -- example pictures for readme

Usage Notes
-----------
* **Video Resolution** 
* Resolutions of 64x64 and 64x32 are supported and tested.
* The 64x128 resolution is supported but has not been fully tested because of a lack of hardware.
* **BeginTerminal** 
* This function initializes system variables used by other TTY Terminal functions.
* The BeginTerminal function must be called before any any other Terminal functions.
* **VideoOn** 
* Turns pixie video on (input port 1) and sets a flag used by other TTY Terminal functions
* This function must be used to turn the video on.
* **VideoOff**
* Turns pixie video off (output port 1) and clears a flag used by other TTY Terminal functions
* This function must be used to turn the video off.
* **WaitForSafeUpdate**
* Checks the CDP1861 video status and waits for DMA to complete before returning.
* When this function returns it is safe to make updates to the video.
* There will be time for about 8000 instruction cycles (at 2MHz) before the next DMA occurs. 
* All Get/Put/Clear terminal functions call this function before making any changes to video data.
* **ClearScreen**
* Blanks the video display and homes the cursor.
* Safe - This function checks the video status before accessing video data
* **GetChar**
* Gets Character from Hex Input
* Waits for an Input press and reads Ascii character from data bus.
* Safe - This function checks the video status before accessing video data
* **PutChar**
* Puts a character on the display and advances the cursor
* Safe - This function checks the video status before accessing video data.
* **PutString**
* Reads characters from a string and writes to display until a null is read.
* Safe - This function checks the video status before accessing video data.
* **WaitForInput**
* Waits for Input key press and release.  No data is read.
* Safe - This function does not access video data.
* **ReadHexInput**
* Reads a byte from Hex Input.
* Waits for Input press and reads (input port 4) from the data bus.
* Safe - This function does not access video data.
* **WriteHexOutput**
* Writes a value out to the hex display.
* Write a byte of data (output port 4) to the data bus.
* Safe - This function does not access video data.
* **Other Functions**
* Please see the source code comments before using other functions.
* Some internal functions are unsafe, unless WaitForSafeUpdate is called immediately before.

Control Characters
------------------
The following control characters are supported.


<table class="table table-hover table-striped table-bordered">
  <tr align="center">   
   <th>ASCII Name</th>
   <th>Hex Value</th>
   <th colspan="3" >Description</th>
  </tr>
  <tr align="center">   
   <td>Backspace</td>
   <td>0x08</td>
   <td  colspan="3" >Move the cursor back one average character width (8 pixels) and delete the character.</td>
  </tr>
  <tr align="center">   
  <td>Tab</td>
     <td>0x09</td>
     <td  colspan="3">Advance cursor to next tab stop, located every 2 average character widths (16 pixels).</td>
  </tr>
  <tr align="center">   
  <td>New Line</td>
     <td>0x0A</td>
     <td  colspan="3">Advance cursor to begining of the next line.</td>
  </tr>
  <tr align="center">   
  <td>Vertical Tab</td>
     <td>0x0B</td>
     <td  colspan="3">Advance cursor down to next line without changing the x location.</td>
  </tr>
  <tr align="center">   
  <td>Form Feed</td>
       <td>0x0C</td>
       <td  colspan="3">Clear the display and home the cursor.</td>
    </tr>
  <tr align="center">     
  <td>Carriage Return</td>
     <td>0x0D</td>
     <td  colspan="3">Advance cursor to begining of the next line.</td>
  </tr>
  <tr align="center">     
  <td>Cancel</td>
     <td>0x18</td>
     <td  colspan="3">Move cursor back to the begining of the current line and erase all characters in the line.</td>
  </tr>
  <tr align="center">     
    <td>Unit Separator</td>
       <td>0x1F</td>
       <td  colspan="3">Advance cursor one pixel width. Can be used after backspacing a narrow character to restore spacing.</td>
    </tr>
  <tr align="center">       
  <td>Delete</td>
     <td>0x7F</td>
     <td  colspan="3">Move cursor back one pixel width and delete the pixel column. Can be used after backspacing over a wide character to rubout remaining pixels.</td>
  </tr>
</table>

Examples
--------
<table class="table table-hover table-striped table-bordered">
  <tr align="center">
   <td><img width=300 src="https://github.com/fourstix/1802PixieVideoTTY/blob/master/pics/FullDemo1.jpg"></td>
   <td><img width=300 src="https://github.com/fourstix/1802PixieVideoTTY/blob/master/pics/FullDemo2.jpg"></td> 
  </tr>
  <tr align="center">
    <td>FullDemo showing Text in 64x64 resolution.</td>
    <td>Full Demo showing Sprites in 64x64 resolution.</td>
  </tr>
  <tr align="center">
   <td><img width=300 src="https://github.com/fourstix/1802PixieVideoTTY/blob/master/pics/HelloWorld.jpg""></td>
   <td><img width=300 src="https://github.com/fourstix/1802PixieVideoTTY/blob/master/pics/BasicTerminal.jpg""></td> 
  </tr>
  <tr align="center">
    <td>HelloWorld Demo running in 64x32 resolution</td>
    <td>BasicTerminal Demo in 64x64 resolution showing ASCII text typed into Hex Keypad.</td>
  </tr>
  <tr align="center">
   <td><img width=300 src="https://github.com/fourstix/1802PixieVideoTTY/blob/master/pics/PutString.jpg""></td>
   <td><img width=300 src="https://github.com/fourstix/1802PixieVideoTTY/blob/master/pics/StringBuffer.jpg""></td> 
  </tr>
  <tr align="center">
    <td>PutString Demo running in 64x64 resolution</td>
    <td>StringBuffer Demo in 64x32 resolution showing ASCII strings typed into the Hex Keypad.</td>
  </tr>   
</table>

License Information
-------------------

This code is public domain under the MIT License, but please buy me a beer
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.

This code is based on a graphics code library written by Richard Dienstknecht

1861 Graphics Code Library
Copyright (c) 2020 by Richard Dienstknecht

Macro Assembler AS
Copyright (c) 1996-2020 by Alfred Arnold
  
The 1802 Membership Card Microcomputer 
Copyright (c) 2006-2020  by Lee A. Hart.
 
Many thanks to the original authors for making their designs and code avaialble as open source.
 
This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

The MIT License (MIT)

Copyright (c) 2020 by Gaston Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**