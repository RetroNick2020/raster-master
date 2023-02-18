100 '* ************************************************************ *
110 '* gwdemo1.bas For GWBASIC                                      *
120 '*                                                              *
130 '* GW.XGF was created by Exporting image as put file            *
140 '* from Raster Master.                                          *
150 '* ************************************************************ *
160 DEFINT A-Z
170 OPEN "R",#1,"GW.XGF",2
180 myArraySize = LOF(1) / 2
190 DIM myImage(myArraySize)
200 FIELD #1, 2 as C$
210 FOR I=0 to (myArraySize-1):GET #1:myImage(I)=CVI(C$):next I
250 CLOSE#1
240 SCREEN 7                     
250 LOCATE 10,1     
260 LINE (0, 0)-(319, 199), 1, BF
270 PUT (0, 0), myImage, PSET
