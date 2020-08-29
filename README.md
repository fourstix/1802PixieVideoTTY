# 1802PixieVideoTTY
Basic TTY terminal function for CDP1861 Pixie Video Display written in 1802 Assembly code.

This code provides support for a basic teletype (TTY) terminal functions on an 1861 Pixie Video disaply
driven by an 1802 Cosmac microprocessor.  It has been tested with the 1802 Membership Card by Lee Hart 
with the MCard1802TeensyPixieVideo  CDP1861 simulator.  The code is based on Richard Dienstknecht's original 
graphics code that was posted in the [Cosmac Elf Group on Groups.io.](https://groups.io/g/cosmacelf)


Repository Contents
-------------------
* **/src/asm/**  -- Assembly code source files for the 1802PixieVideoTTY functions.
  * StdDefs.asm 	- standard definitions used in assembly source files
  * Initialize.asm 	- initialization functions and includes
  * Buffers.asm 	- definitions for video buffers and variables used by the program
  * Graphics1861.asm	- graphics routines for drawing on the CDP1861 display
  * Text1861.asm	- routines to draw text characters on screen
  * Fonts.asm		- font table for text
  * Tty1861.asm		- teletype terminal functions for the CDP1861 display
  * Padding.asm		- optional padding definitions to prevent page boundary errors in user code.
  **/src/asm/BasicTerminal/** 
  * BasicTerminal.asm - Use TTY functions to echo ASCII characters typed into the hex keypad onto 
  	the CDP1861 display in 64x64 resolution using GetChar and PutChar functions.
  **/src/asm/HelloWorld/** 
  * HelloWorld.asm - Write a greeting in 64x32 resolution to the display when the Input button is pressed using the PutChar function.
  **/src/asm/PutString/** 
  * PutString.asm - Write strings to the display in 64x64 resoulution using the PutString function.
   **/src/asm/StringBuffer/** 
  * StringBuffer.asm - Load up to 31 characters typed into the hex keypad into a buffer until null (00) is typed in, then write the string to the display.
  **/src/asm/FullDemo/** 
  * FullDemo.asm - The original graphics demo redone using the TTY functions using PutString instead of DrawString.
  *   
* **/src/org/**  
  * LibTest - Original graphics assembly functions written by Richard Dienstknecht  
* **/pics** -- example pictures for readme



License Information
-------------------

This code is public domain under the MIT License, but please buy me a beer
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.
  
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