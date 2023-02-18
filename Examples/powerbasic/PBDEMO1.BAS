'* ************************************************************ *
'* pbdemo1.bas For PowerBASIC                                   *
'*                                                              *
'* PB.XGF was created by Exporting image as put file            *
'* from Raster Master.                                          *
'* ************************************************************ *
 DEFINT A-Z
 OPEN "PB.XGF" FOR BINARY AS #1
 myArraySize = LOF(1) / 2
 DIM myImage(myArraySize)
 FOR i = 0 TO myArraySize-1
   GET #1, , myImage(i)
 NEXT i
 CLOSE #1

 SCREEN 7
 LINE (0, 0)-(319, 199), 1, BF
 PUT (0, 0), myImage, PSET