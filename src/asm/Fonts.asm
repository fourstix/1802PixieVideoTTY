
; *********************************************************************************************
; Copyright (c) 2020 
; by Richard Dienstknecht
;
; Changes:
; Gaston Williams, July, 2020 - Put Font definations into separate file 
; Gaston Williams, August, 2020 - Changed DEL to 1 pixel wide space
;
; Font definition
;
; The font has 96 printable characters, and requires 288 bytes of memory.
;
; The characters are encoded in standard ASCII, beginning with 20H and ending at 7FH. Each
; character has a height of 5 pixels and a variable width of 1 - 5 pixels. 
;
; In order to save memory, the patterns of two characters have been combined into one. Without
; this, the complete 96 character font would have required 480 bytes. The 'left' character
; stands for the lower even ASCII code, the 'right' one for the following
; uneven ASCII code. The DrawCharacter subroutine will either mask the left character or
; shift the right one over to the position of the left one when a character is drawn.
;
; Each line defines two characters of variable width, together no more than 8 pixels. The
; first byte contains the width of each character. The upper four bits hold the width of
; the left character in the pattern, the lower four bits hold the width of the right character.
;
; The following five bytes contain the bit patterns of the characters. Beginning at the left
; (most significant) bit, the pattern of the left character (up to its specified width) is 
; immediately followed by the bits of the right character. Any remaining bits to the right 
; (if both characters together are less than 8 pixels wide) must be set to 0. 
; **********************************************************************************************

Font:	        db  0011H, 0040H, 0040H, 0040H, 0000H, 0040H		; space and !
		db  0035H, 00AAH, 00BFH, 000AH, 001FH, 000AH		; " and #
		db  0033H, 0074H, 00C4H, 0048H, 0070H, 00D4H		; $ and %
		db  0041H, 0048H, 00A8H, 0040H, 00A0H, 00D0H		; & and '
		db  0022H, 0060H, 0090H, 0090H, 0090H, 0060H		; ( and )
		db  0033H, 0000H, 00A8H, 005CH, 00A8H, 0000H		; * and +
		db  0022H, 0000H, 0000H, 0030H, 0040H, 0080H		; , and -
		db  0013H, 0010H, 0010H, 0020H, 0040H, 00C0H		; . and /
		db  0033H, 0048H, 00B8H, 00A8H, 00A8H, 005CH		; 0 and 1
		db  0033H, 00D8H, 0024H, 0048H, 0084H, 00F8H		; 2 and 3
		db  0033H, 003CH, 00B0H, 00F8H, 0024H, 0038H		; 4 and 5
		db  0033H, 005CH, 0084H, 00C4H, 00A8H, 0048H		; 6 and 7		
		db  0033H, 0048H, 00B4H, 004CH, 00A4H, 0048H		; 8 and 9
		db  0012H, 0000H, 0020H, 0080H, 0020H, 00C0H		; : and ;		
		db  0032H, 0020H, 0058H, 0080H, 0058H, 0020H		; < and =
		db  0033H, 0088H, 0054H, 0024H, 0048H, 0088H		; > and ?
		db  0033H, 0048H, 00F4H, 009CH, 00B4H, 0054H		; @ and A
		db  0033H, 00CCH, 00B0H, 00D0H, 00B0H, 00CCH		; B and C
		db  0033H, 00DCH, 00B0H, 00B8H, 00B0H, 00DCH		; D and E
		db  0033H, 00ECH, 0090H, 00D0H, 0094H, 008CH		; F and G
		db  0033H, 00BCH, 00A8H, 00E8H, 00A8H, 00BCH		; H and I
		db  0033H, 0034H, 0034H, 0038H, 00B4H, 0054H		; J and K
		db  0035H, 0091H, 009BH, 0095H, 0091H, 00F1H		; L and M
		db  0043H, 009EH, 00DAH, 00BAH, 009AH, 009EH		; N and O
		db  0034H, 00DEH, 00B2H, 00D2H, 0096H, 009EH		; P and Q
		db  0033H, 00CCH, 00B0H, 00C8H, 00A4H, 00B8H		; R and S
		db  0033H, 00F4H, 0054H, 0054H, 0054H, 005CH		; T and U
		db  0035H, 00B1H, 00B1H, 00B1H, 00B5H, 004AH		; V and W
		db  0033H, 00B4H, 00B4H, 0048H, 00A8H, 00A8H		; X and Y
		db  0032H, 00F8H, 0030H, 0050H, 0090H, 00F8H		; Z and [
		db  0032H, 0098H, 0088H, 0048H, 0028H, 0038H		; \ and ]
		db  0033H, 0040H, 00A0H, 0000H, 0000H, 001CH		; ^ and _
		db  0023H, 0040H, 0098H, 0028H, 0028H, 0018H		; ' and a
		db  0033H, 0080H, 00CCH, 00B0H, 00B0H, 00CCH		; b and c
		db  0033H, 0020H, 006CH, 00B4H, 00B8H, 006CH		; d and e
		db  0023H, 0058H, 00A8H, 00F0H, 0088H, 00B0H		; f and g
		db  0031H, 0090H, 0080H, 00D0H, 00B0H, 00B0H		; h and i
		db  0023H, 0060H, 0028H, 0070H, 0068H, 00A8H		; j and k
		db  0025H, 0080H, 0094H, 00AAH, 00AAH, 006AH		; l and m
		db  0033H, 0000H, 00C8H, 00B4H, 00B4H, 00A8H		; n and o
		db  0033H, 0000H, 00CCH, 00B4H, 00CCH, 0084H		; p and q
		db  0023H, 0000H, 0058H, 00B0H, 0088H, 00B0H		; r and s
		db  0023H, 0080H, 00E8H, 00A8H, 00A8H, 0058H		; t and u
		db  0035H, 0000H, 00B1H, 00B5H, 00B5H, 004AH		; v and w
		db  0033H, 0000H, 00B4H, 004CH, 0044H, 00A8H		; x and y
		db  0033H, 000CH, 00E8H, 0030H, 0048H, 00ECH		; z and {
		db  0013H, 00E0H, 00A0H, 0090H, 00A0H, 00E0H		; | and }
		db  0041H, 0000H, 0050H, 00A0H, 0000H, 0000H		; ~ and DEL
;------------------------------------------------------------------------------------------