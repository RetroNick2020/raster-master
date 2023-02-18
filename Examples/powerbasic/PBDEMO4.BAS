'* *************************************************************** *
'* pbdemo4.bas VGA Palette Demo for QuickBASIC                     *
'*                                                                 *
'* remappalette commands were created by Exporting palette from    *
'* Raster Master. Palette->Export->PowerBasic->Palette Commands    *
'* *************************************************************** *

SCREEN 9
LINE (0, 0)-(319, 199), 1, BF

FOR I = 0 TO 15
  LINE (I * 20, 20)-(I * 20 + 19, 180), I, BF
NEXT I

COLOR 15
LOCATE 16, 4
PRINT "Press Enter key to change palette"

INPUT a$

' Power/Turbo BASIC Palette Commands,  Size= 16 Colors= 16 Format=Color Index
Palette 0, 32
Palette 1, 33
Palette 2, 34
Palette 3, 35
Palette 4, 36
Palette 5, 37
Palette 6, 52
Palette 7, 39
Palette 8, 28
Palette 9, 29
Palette 10, 30
Palette 11, 31
Palette 12, 46
Palette 13, 47
Palette 14, 55
Palette 15, 31

INPUT a$

