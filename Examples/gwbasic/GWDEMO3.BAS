100 '* ********************************************************************* *'
110 '* gwdemo3.bas For GWBASIC                                               *'
120 '*                                                                       *'
130 '* GWMouse was created by Exporting image as Mouse Shape data statements *'
140 '* from Raster Master.                                                   *'
150 '*                                                                       *'
160 '* ********************************************************************* *'
170 DEFINT A-Z
180 DIM GWMouse(32),MCODE(120)
200 I%=0:JC=0:AX%=0:BX%=0:CX%=0:DX%=0
210 MEM%=VARPTR(MCODE%(0))
220 FOR I%=1 TO  97:READ JC:POKE MEM%,JC:MEM%=MEM%+1:NEXT I%
230 FOR I = 0 TO 31:READ GWMouse(I):NEXT I
240 SCREEN 7 
250 LINE (0, 0)-(319, 199), 1, BF
260 FOR I = 0 TO 15:LINE (I * 20, 20)-(I * 20 + 19, 180), I, BF:NEXT I
270 'AX% = 0 = Init mouse -return AX% value is not zero you have a mouse, 
280 'BX return indicates number of buttons on the mouse
290 AX%=0 
300 MOUSE=VARPTR(MCODE%(0))
800 CALL MOUSE(AX%,BX%,CX%,DX%)
805 PRINT "INIT RESULT AX=";AX%;" BX=";BX%;" CX=";CX%;" DX=";DX%
810 AX%=1 'Mouse Show
815 MOUSE=VARPTR(MCODE%(0))
820 CALL MOUSE(AX%,BX%,CX%,DX%)
825 DX%=VARPTR(GWMouse(0)):AX%=9:BX%=5:CX%=5
826 MOUSE=VARPTR(MCODE%(0))
830 CALL MOUSE(AX%,BX%,CX%,DX%)
900 'PRINT "AX=";AX%;" BX=";BX%;" CX=";CX%;" DX=";DX%
910 END
1000 REM   Mouse Driver Code, Data Count = 97
1010 DATA  &H55,&H8B,&HEC,&H8B,&H76,&H0C,&H8B,&H04,&H3D,&H00,&H00,&H74,&H17,&H3D
1020 DATA  &H01,&H00,&H74,&H21,&H3D,&H02,&H00,&H74,&H1C,&H3D,&H03,&H00,&H74,&H1C
1030 DATA  &H3D,&H09,&H00,&H74,&H2B,&HEB,&H3A,&H90,&HCD,&H33,&H8B,&H76,&H0C,&H89
1040 DATA  &H1C,&H8B,&H76,&H0A,&H89,&H1C,&HEB,&H2B,&H90,&HCD,&H33,&HEB,&H26,&H90
1050 DATA  &HCD,&H33,&H8B,&H76,&H0A,&H89,&H1C,&H8B,&H76,&H08,&H89,&H0C,&H8B,&H76
1060 DATA  &H06,&H89,&H14,&HEB,&H12,&H90,&H8B,&H76,&H06,&H8B,&H14,&H8B,&H76,&H08
1070 DATA  &H8B,&H0C,&H8B,&H76,&H0A,&H8B,&H1C,&HCD,&H33,&H5D,&HCA,&H08,&H00
2000 ' ****************
2010 ' **********#####*
2020 ' ****XXX***#***#*
2030 ' ***XXXXX**#***#*
2040 ' **XXXXXXX*#***#*
2050 ' **XXXXXXX*#***#*
2060 ' **XXXXXXX*#####*
2070 ' ***XXXXX********
2080 ' ****XXX***   ***
2080 ' *********     **
2090 ' *######*       *
2080 ' *#****#*       *
2090 ' *#****#*       *
2100 ' *#****#**     **
2110 ' *######***   ***
2120 ' ****************
2130 ' BASIC, Size= 32 Width= 16 Height= 16
2140 ' DOS Mouse Shape
2150 ' GWMouse
2160 DATA &H0000,&H0000,&H0E00,&H1F00,&H3F80,&H3F80,&H3F80,&H1F00,&H0E38,&H007C
2170 DATA &H00FE,&H00FE,&H00FE,&H007C,&H0038,&H0000,&H0000,&H003E,&H0E22,&H1F22
2180 DATA &H3FA2,&H3FA2,&H3FBE,&H1F00,&H0E00,&H0000,&H7E00,&H4200,&H4200,&H4200
2190 DATA &H7E00,&H0000
