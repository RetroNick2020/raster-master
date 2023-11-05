'* *************************************************************** *
'* demo4.bas VGA Palette Demo for BAM (Basic Anywhere Machine      *
'*                                                                 *
'* palette commands were created by Exporting palette from         *
'* Raster Master. Palette->Export->BAM->Palette Commands           *
'* *************************************************************** *

SCREEN 12 'SCREEN 13 for 256 color images
LINE (0, 0)-(319, 199), 1, BF

FOR I = 0 TO 15
  LINE (I * 20, 20)-(I * 20 + 19, 180), I, BF
NEXT I

COLOR 15
LOCATE 16, 4
PRINT "Press a key to change palette"

INPUT a$
SCREEN 12
' BAM Basic Palette Commands,  Size= 48 Colors= 16 Format=8 Bit 
Palette 0, _BGR(0,105,89)
Palette 1, _BGR(170,80,68)
Palette 2, _BGR(97,170,97)
Palette 3, _BGR(170,97,0)
Palette 4, _BGR(125,0,113)
Palette 5, _BGR(170,0,76)
Palette 6, _BGR(0,125,170)
Palette 7, _BGR(170,117,170)
Palette 8, _BGR(85,149,85)
Palette 9, _BGR(255,133,85)
Palette 10, _BGR(85,255,165)
Palette 11, _BGR(161,255,36)
Palette 12, _BGR(85,85,157)
Palette 13, _BGR(255,190,255)
Palette 14, _BGR(85,255,198)
Palette 15, _BGR(153,165,255)

LINE (0, 0)-(319, 199), 1, BF

FOR I = 0 TO 15
  LINE (I * 20, 20)-(I * 20 + 19, 180), I, BF
NEXT I

INPUT a$