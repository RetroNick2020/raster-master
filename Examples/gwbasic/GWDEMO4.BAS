100 '* *************************************************************** *
110 '* gwdemo4.bas EGA Palette Demo for GWBASIC                        *
120 '*                                                                 *
130 '* PALETTE commands were created by Exporting palette from         *
140 '* Raster Master. Palette->Export->GWBASIC->Palette Commands       *
150 '* *************************************************************** *
160 SCREEN 9 
170 LINE (0, 0)-(319, 199), 1, BF
180 FOR I = 0 TO 15:LINE (I * 20, 20)-(I * 20 + 19, 180), I, BF:NEXT I
190 COLOR 15
200 LOCATE 16, 4
210 PRINT "Press a key to change palette"
220 INPUT a$
1000 ' GWBASIC/PC-BASIC Palette Commands,  Size= 16 Colors= 16 Format=Color Index 
1010 Palette 0, 32
1020 Palette 1, 33
1030 Palette 2, 34
1040 Palette 3, 35
1050 Palette 4, 36
1060 Palette 5, 37
1070 Palette 6, 52
1080 Palette 7, 39
1090 Palette 8, 28
1100 Palette 9, 29
1110 Palette 10, 30
1120 Palette 11, 31
1130 Palette 12, 46
1140 Palette 13, 47
1150 Palette 14, 55
1160 Palette 15, 31
1170 INPUT a$

