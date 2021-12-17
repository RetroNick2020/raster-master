'* ************************************************************ *
'* Demo1.bas For QuickBASIC                                     *
'*                                                              *
'* QGCAR.XGF was created by saving the image as QP/QB (Binary)  *
'* from Raster Master.                                          *
'* ************************************************************ *

 OPTION BASE 1
 DEFINT A-Z
      
 OPEN "QGCAR.XGF" FOR BINARY AS #1
 myArraySize = LOF(1) / 2
 DIM myImage(myArraySize)
 FOR i = 1 TO myArraySize
   GET #1, , myImage(i)
 NEXT i
 CLOSE #1

 SCREEN 7                          'SCREEN 13 for 256 color images
 LINE (0, 0)-(319, 199), 1, BF
 PUT (0, 0), myImage, PSET
