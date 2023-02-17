'* ************************************************************ *
'* qbdemo5.bas For MS QuickBasic\QBasic                         *
'*                                                              *
'* QB.BSV was created by Exporting image as put file            *
'* from Raster Master and converted to a BSAVE file using       *
'* BIN2BSV QB.XGF QB.BSV
'* ************************************************************ *
 DEFINT A-Z
 DIM myImage(258)

 DEF SEG = VARSEG(myImage(0))
 BLOAD "qb.bsv", VARPTR(myImage(0))
 DEF SEG               ' Restore default BASIC segment.

 SCREEN 7                          'SCREEN 13 for 256 color images
 LINE (0, 0)-(319, 199), 1, BF
 PUT (0, 0), myImage, PSET

