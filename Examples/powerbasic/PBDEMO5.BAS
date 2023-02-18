'* ************************************************************ *
'* pbdemo5.bas For PowerBASIC                                   *
'*                                                              *
'* PB.BSV was created by Exporting image as put file            *
'* from Raster Master and converted to a BSAVE file using       *
'* BIN2BSV PB.XGF PB.BSV                                        *
'* ************************************************************ *
 DEFINT A-Z
 DIM myImage(258)

 DEF SEG = VARSEG(myImage(0))
 BLOAD "pb.bsv", VARPTR(myImage(0))
 DEF SEG       ' Restore default BASIC segment.

 SCREEN 7
 LINE (0, 0)-(319, 199), 1, BF
 PUT (0, 0), myImage, PSET
