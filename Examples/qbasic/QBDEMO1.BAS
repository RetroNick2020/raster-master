'* ************************************************************ *
'* qbdemo1.bas For MS QuickBasic\QBasic                         *
'*                                                              *
'* QB.XGF was created by Exporting image as put file            *
'* from Raster Master.                                          *
'* ************************************************************ *
 DEFINT A-Z
 OPEN "QB.XGF" FOR BINARY AS #1
 myArraySize = LOF(1) / 2
 DIM myImage(myArraySize)
 FOR i = 0 TO myArraySize-1
   GET #1, , myImage(i)
 NEXT i
 CLOSE #1

 SCREEN 7                          'SCREEN 13 for 256 color images
 LINE (0, 0)-(319, 199), 1, BF
 PUT (0, 0), myImage, PSET