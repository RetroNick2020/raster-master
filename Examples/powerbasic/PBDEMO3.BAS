'* ********************************************************************* *
'* pbdemo3.bas For PowerBASIC                                            *
'*                                                                       *
'* PBMouse was created by Exporting image as Mouse Shape data statements *
'* from Raster Master.                                                   *
'*                                                                       *
'* ********************************************************************* *

DEFINT A-Z
DIM PBMouse(32)
%FLAGS=0
%AX=1
%BX=2
%CX=3
%DX=4
%SI=5
%DI=6
%BP=7
%DS=8
%ES=9


FOR I = 0 TO 31
    READ PBMouse(I)
NEXT I

SCREEN 7
LINE (0, 0)-(319, 199), 1, BF

FOR I = 0 TO 15
  LINE (I * 20, 20)-(I * 20 + 19, 180), I, BF
NEXT I

CALL MouseShape(7, 7, VARPTR(PBMouse(0)), VARSEG(PBMouse(0)))
MouseShow


' ****************
' **********#####*
' ****XXX***#***#*
' ***XXXXX**#***#*
' **XXXXXXX*#***#*
' **XXXXXXX*#***#*
' **XXXXXXX*#####*
' ***XXXXX********
' ****XXX***   ***
' *********     **
' *######*       *
' *#****#*       *
' *#****#*       *
' *#****#**     **
' *######***   ***
' ****************
' BASIC, Size= 32 Width= 16 Height= 16
' DOS Mouse Shape
' QBMouse
DATA &H0000,&H0000,&H0E00,&H1F00,&H3F80,&H3F80,&H3F80,&H1F00,&H0E38,&H007C
DATA &H00FE,&H00FE,&H00FE,&H007C,&H0038,&H0000,&H0000,&H003E,&H0E22,&H1F22
DATA &H3FA2,&H3FA2,&H3FBE,&H1F00,&H0E00,&H0000,&H7E00,&H4200,&H4200,&H4200
DATA &H7E00,&H0000

SUB Mouse (m1, m2, m3, m4)
  REG %AX, m1
  REG %BX, m2
  REG %CX, m3
  REG %DX, m4
  CALL INTERRUPT &H33
  m1 = REG(%AX)
  m2 = REG(%BX)
  m3 = REG(%CX)
  m4 = REG(%DX)
END SUB

SUB MouseShape (m1, m2, m3, m4)
  REG %AX, 9
  REG %BX, m1
  REG %CX, m2
  REG %DX, m3
  REG %ES, m4
  CALL INTERRUPT &H33
END SUB


SUB MouseButPos (ButStat, CurHor, CurVert)
  m1 = 3
  CALL Mouse(m1, m2, m3, m4)
  ButStat = m2
  CurHor = m3
  CurVert = m4
END SUB

FUNCTION MouseInit
   m1 = 0
   CALL Mouse(m1, m2, m3, m4)
   MouseInit = m1
END FUNCTION

SUB MouseShow
  m1 = 1
  CALL Mouse(m1, m2, m3, m4)
END SUB

