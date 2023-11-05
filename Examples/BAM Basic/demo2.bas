'* **************************************************************** *'
'* demo2.bas For BAM (Basic Anywhere Machine)                       *'
'*                                                                  *'
'* cross was created by Exporting image as Put+Mask data statements *'
'* from Raster Master.                                              *'
'* **************************************************************** *'

DEFINT A-Z
DIM Cross(258), CrossMask(258)

FOR I = 0 TO 257
    READ Cross(I)
NEXT I
FOR I = 0 TO 257
    READ CrossMask(I)
NEXT I


SCREEN 7 'SCREEN 13 for 256 color images
LINE (0, 0)-(319, 199), 1, BF

FOR I = 0 TO 15
  LINE (I * 20, 20)-(I * 20 + 19, 180), I, BF
NEXT I

PUT (30, 100), Cross, PSET
PUT (70, 100), Cross, PRESET
PUT (110, 100), Cross, AND
PUT (150, 100), Cross, OR
PUT (190, 100), Cross, XOR

'* using the CrossMask and cross image together with AND and OR operators we make it transparent *
PUT (230, 100), CrossMask, AND
PUT (230, 100), Cross, OR

' BAM Put Bitmap Code Created By Raster Master
' Size= 258 Width= 32 Height= 32 Colors= 16
' Image12
DATA 32,32,0,0,0,17408,68,0,0,0
DATA 0,0,0,17408,68,0,0,0,0,0
DATA 0,17408,68,0,0,0,0,0,0,17408
DATA 68,0,0,0,0,0,0,17408,68,0
DATA 0,0,0,0,0,17408,68,0,0,0
DATA 0,0,0,17408,68,0,0,0,0,0
DATA 0,17408,68,0,0,0,0,0,0,17408
DATA 68,0,0,0,0,0,0,17408,68,0
DATA 0,0,0,0,0,17408,68,0,0,0
DATA 0,0,0,17408,68,0,0,0,0,0
DATA 0,17408,68,0,0,0,0,0,0,17408
DATA 68,0,0,0,17476,17476,17476,17476,17476,17476
DATA 17476,17476,17476,17476,17476,17476,17476,17476,17476,17476
DATA 17476,17476,17476,17476,17476,17476,17476,17476,17476,17476
DATA 17476,17476,17476,17476,17476,17476,0,0,0,17408
DATA 68,0,0,0,0,0,0,17408,68,0
DATA 0,0,0,0,0,17408,68,0,0,0
DATA 0,0,0,17408,68,0,0,0,0,0
DATA 0,17408,68,0,0,0,0,0,0,17408
DATA 68,0,0,0,0,0,0,17408,68,0
DATA 0,0,0,0,0,17408,68,0,0,0
DATA 0,0,0,17408,68,0,0,0,0,0
DATA 0,17408,68,0,0,0,0,0,0,17408
DATA 68,0,0,0,0,0,0,17408,68,0
DATA 0,0,0,0,0,17408,68,0,0,0
DATA 0,0,0,17408,68,0,0,0

' BAM Put Bitmap Code Created By Raster Master
' Size= 258 Width= 32 Height= 32 Colors= 16
' Image12Mask
DATA 32,32,-1,-1,-1,255,-256,-1,-1,-1
DATA -1,-1,-1,255,-256,-1,-1,-1,-1,-1
DATA -1,255,-256,-1,-1,-1,-1,-1,-1,255
DATA -256,-1,-1,-1,-1,-1,-1,255,-256,-1
DATA -1,-1,-1,-1,-1,255,-256,-1,-1,-1
DATA -1,-1,-1,255,-256,-1,-1,-1,-1,-1
DATA -1,255,-256,-1,-1,-1,-1,-1,-1,255
DATA -256,-1,-1,-1,-1,-1,-1,255,-256,-1
DATA -1,-1,-1,-1,-1,255,-256,-1,-1,-1
DATA -1,-1,-1,255,-256,-1,-1,-1,-1,-1
DATA -1,255,-256,-1,-1,-1,-1,-1,-1,255
DATA -256,-1,-1,-1,0,0,0,0,0,0
DATA 0,0,0,0,0,0,0,0,0,0
DATA 0,0,0,0,0,0,0,0,0,0
DATA 0,0,0,0,0,0,-1,-1,-1,255
DATA -256,-1,-1,-1,-1,-1,-1,255,-256,-1
DATA -1,-1,-1,-1,-1,255,-256,-1,-1,-1
DATA -1,-1,-1,255,-256,-1,-1,-1,-1,-1
DATA -1,255,-256,-1,-1,-1,-1,-1,-1,255
DATA -256,-1,-1,-1,-1,-1,-1,255,-256,-1
DATA -1,-1,-1,-1,-1,255,-256,-1,-1,-1
DATA -1,-1,-1,255,-256,-1,-1,-1,-1,-1
DATA -1,255,-256,-1,-1,-1,-1,-1,-1,255
DATA -256,-1,-1,-1,-1,-1,-1,255,-256,-1
DATA -1,-1,-1,-1,-1,255,-256,-1,-1,-1
DATA -1,-1,-1,255,-256,-1,-1,-1

