'* *************************************************************** *
'* qbdemo4.bas VGA Palette Demo for QuickBASIC                     *
'*                                                                 *
'* palette commands were created by Exporting palette from         *
'* Raster Master. Palette->Export->QuickBasic->Palette Commands    *
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

' QuickBASIC Palette Commands,  Size= 48 Colors= 16 Format=6 Bit
PALETTE 0, 21
PALETTE 1, 2752539
PALETTE 2, 10782
PALETTE 3, 2763297
PALETTE 4, 54
PALETTE 5, 2752564
PALETTE 6, 5432
PALETTE 7, 2763316
PALETTE 8, 1381668
PALETTE 9, 4134187
PALETTE 10, 1392432
PALETTE 11, 4144940
PALETTE 12, 1387327
PALETTE 13, 4140351
PALETTE 14, 3161919
PALETTE 15, 4143420

INPUT a$

