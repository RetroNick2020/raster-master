'* ************************************************************ *
'* fbres1.bas For FreeBASIC                                     *
'*                                                              *
'* Images were created by using Raster Master RES export options*
'* ************************************************************ *
#lang "qb"

DIM shape(514) as integer,shapemask(514) as integer
DIM I as integer
DIM a as string

RESTORE Image1Label
FOR I = 0 TO 513
  READ shape(I)
NEXT I

FOR I = 0 TO 513
  READ shapemask(I)
NEXT I

SCREEN 7                        'SCREEN 13 for 256 color images
LINE (0, 0)-(319, 199), 1, BF
PUT (50, 50), shapemask, and
PUT (50, 50), shape, or

input a
#include "shapes.inc"
