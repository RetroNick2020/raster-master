100 '* ************************************************************ *
120 '* gwdemo5.bas For GWBASIC                                      *
130 '*                                                              *
140 '* GW.BSV was created by Exporting image as put file            *
150 '* from Raster Master and converted to a BSAVE file using       *
160 '* BIN2BSV QB.XGF QB.BSV
170 '* ************************************************************ *
180 DEFINT A-Z
190 DIM myImage(258)
200 BLOAD "GW.BSV", VARPTR(myImage(0))
210 SCREEN 7 
220 LINE (0, 0)-(319, 199), 1, BF
230 PUT (0, 0), myImage, PSET
240 LOCATE 15,1
