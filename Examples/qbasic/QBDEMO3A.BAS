'* ********************************************************************* *
'* qbdemo3a.bas For MS QBasic (interpeter - not the compiler)            *
'*                                                                       *
'* QBMouse was created by Exporting image as Mouse Shape data statements *
'* from Raster Master.                                                   *
'*                                                                       *
'* Start QB with QB.EXE /L                                               *
'* ********************************************************************* *

DECLARE SUB Mouse (m1%, m2%, m3%, m4%)
DECLARE SUB MouseShape (m1%, m2%, m3%, m4%)
DECLARE SUB MouseShow ()
DECLARE FUNCTION MouseInit% ()
TYPE RegTypeX
  ax AS INTEGER
  bx AS INTEGER
  cx AS INTEGER
  dx AS INTEGER
  BP AS INTEGER
  SI AS INTEGER
  DI AS INTEGER
  Flags AS INTEGER
  DS AS INTEGER
  es AS INTEGER
END TYPE
CONST FALSE = 0, TRUE = NOT FALSE
DECLARE SUB INTERRUPTX (IntNo%, Inreg AS RegTypeX, OutReg AS RegTypeX)
DEFINT A-Z
DIM QBMouse(32)

FOR i = 0 TO 31
    READ QBMouse(i)
NEXT i

SCREEN 7 'SCREEN 13 for 256 color images
LINE (0, 0)-(319, 199), 1, BF

FOR i = 0 TO 15
  LINE (i * 20, 20)-(i * 20 + 19, 180), i, BF
NEXT i

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


'-----------------------------------------------------------------------
' The machine code of the interrupt procedure for InterruptX
'-----------------------------------------------------------------------
InterruptXASM:
' Number of bytes
DATA  190
' Hexadecimal representation of machine code
DATA 55,8B,EC,8B,5E,0C,8B,17,0A,F6
DATA 74,07,C7,07,FF,FF,E9,A7,00,8B
DATA 5E,06,8B,1F,2E,88,97,77,00,32
DATA C0,80,FA,25,74,05,80,FA,26,75
DATA 02,0C,02,50,1E,06,56,57,9C,8B
DATA 76,0A,80,FA,20,7C,05,80,FA,30
DATA 7C,0A,81,7C,08,FF,FF,74,03,8B
DATA 6C,08,8B,44,0E,25,D5,0F,50,8B
DATA 04,8B,5C,02,8B,4C,04,8B,54,06
DATA 8B,7C,0C,FF,74,0A,81,7C,12,FF
DATA FF,74,03,8E,44,12,81,7C,10,FF
DATA FF,74,03,8E,5C,10,5E,9D,CD,00
DATA 55,8B,EC,9C,83,C5,0E,F6,46,FE
DATA 02,74,02,45,45,1E,56,8E,5E,FC
DATA 8B,76,08,89,04,89,5C,02,89,4C
DATA 04,89,54,06,8F,44,0A,89,7C,0C
DATA 8F,44,10,8C,44,12,8F,44,0E,8F
DATA 44,08,F6,46,FE,02,74,02,44,44
DATA 9D,5F,5E,07,1F,58,5D,CA,08,00

'-----------------------------------------------------------------------
' Example: get current video mode
'-----------------------------------------------------------------------
'DIM r AS RegTypeX
'r.ax = &HF00
'InterruptX &H10, r, r
'VideoMode = (r.ax AND &HFF)
'PRINT "Video mode is "; VideoMode
'END

'Hans Lunsing,           Fido     : 2:281/607.214, 2:282/610.12
'                        Internet : jlunsing@doge.nl

SUB INTERRUPTX (IntNo AS INTEGER, Inreg AS RegTypeX, OutReg AS RegTypeX) STATIC
'-----------------------------------------------------------------------
' Interrupt procedure. Works in the same way as its QB 4.5 counterpart.
'-----------------------------------------------------------------------

IF NOT MachineCode% THEN
  ' First time dimension string array to hold machine code
  RESTORE InterruptXASM
  READ nASMBYTES%
  REDIM ASMBuffer(0 TO nASMBYTES% - 1) AS STRING * 1
END IF

' Get address of machine code
DEF SEG = VARSEG(ASMBuffer(0))
Offset% = VARPTR(ASMBuffer(0))

IF NOT MachineCode% THEN
  ' First time load string array with machine code
  FOR i% = 0 TO nASMBYTES% - 1
    READ Code$
    POKE Offset% + i%, VAL("&H" + Code$)
  NEXT i%
  ' Indicate availability of machine code
  MachineCode% = TRUE
END IF

' Call interrupt.
' The first Offset% parameter is used by the machine code modifying it self,
' so don't leave it out.
CALL ABSOLUTE(IntNo%, Inreg, OutReg, Offset%, Offset%)

DEF SEG
END SUB

SUB Mouse (m1, m2, m3, m4)
  DIM InRegs AS RegTypeX
  InRegs.ax = m1
  InRegs.bx = m2
  InRegs.cx = m3
  InRegs.dx = m4
  INTERRUPTX &H33, InRegs, InRegs
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
  InRegs.es = m4
  INTERRUPTX &H33, InRegs, InRegs
END SUB

SUB MouseShow
  m1 = 1
  CALL Mouse(m1, m2, m3, m4)
END SUB

