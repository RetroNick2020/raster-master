DECLARE SUB MouseShape (m1%, m2%, m3%, m4%)
DECLARE SUB Mouse (m1%, m2%, m3%, m4%)
DECLARE SUB MouseShow ()
DECLARE FUNCTION MouseInit% ()
'* ********************************************************************* *'
'* qbdemo3.bas For MS QuickBasic                                         *'
'*                                                                       *'
'* QBMouse was created by Exporting image as Mouse Shape data statements *'
'* from Raster Master.                                                   *'
'*                                                                       *'
'* Start QB with QB.EXE /L                                               *'
'* ********************************************************************* *'
'$INCLUDE: 'QB.BI'

DEFINT A-Z
DIM QBMouse(32)
COMMON QBMouse()  'make sure to make QBMouse common

FOR I = 0 TO 31
    READ QBMouse(I)
NEXT I

SCREEN 7 'SCREEN 13 for 256 color images
LINE (0, 0)-(319, 199), 1, BF

FOR I = 0 TO 15
  LINE (I * 20, 20)-(I * 20 + 19, 180), I, BF
NEXT I

CALL MouseShape(7, 7, VARPTR(QBMouse(0)), VARSEG(QBMouse(0)))
MouseShow
INPUT a$

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
  DIM InRegs AS RegType
  InRegs.ax = m1
  InRegs.bx = m2
  InRegs.cx = m3
  InRegs.dx = m4
  CALL INTERRUPT(&H33, InRegs, InRegs)
  m1 = InRegs.ax
  m2 = InRegs.bx
  m3 = InRegs.cx
  m4 = InRegs.dx
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

SUB MouseShape (m1, m2, m3, m4)
  DIM InRegs AS RegTypeX
  InRegs.ax = 9
  InRegs.bx = m1
  InRegs.cx = m2
  InRegs.dx = m3
  InRegs.ES = m4
  CALL INTERRUPTX(&H33, InRegs, InRegs)
END SUB

SUB MouseShow
  m1 = 1
  CALL Mouse(m1, m2, m3, m4)
END SUB

