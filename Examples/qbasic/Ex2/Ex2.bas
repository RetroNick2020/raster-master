DECLARE SUB SavePutImageFile (filename$, ImageBuf%(), size&)
DECLARE SUB SavePutImageAsData (filename$, ImageBuf%(), size&)
DECLARE FUNCTION ImageBufferSize& (x%, y%, x2%, y2%, ScreenMode%)
DECLARE SUB ReadPutImageFile (filename$, ImageBuf%(), size&)

SCREEN 7
COLOR , 3
LOCATE 15, 1

DIM image%(258)

CALL ReadPutImageFile("c:\temp\qb\truck.xgf", image%(), 258)
PUT (10, 10), image%
INPUT a$
LINE (9, 9)-(43, 43), 15, B
INPUT a$

size& = ImageBufferSize(0, 0, 50, 50, 7) / 2
DIM myscreen%(size&)
GET (0, 0)-(50, 50), myscreen%

'CALL SavePutImageAsData("c:\temp\screen2.bas", myscreen%(), size&)

PRINT "saving "
CALL SavePutImageFile("c:\temp\screen.xgf", myscreen%(), size&)
INPUT a$
SCREEN 9
COLOR , 3
LOCATE 15, 1
PRINT "loading"

CALL ReadPutImageFile("c:\temp\screen.xgf", myscreen%(), size&)
PUT (0, 0), myscreen%
INPUT a$




FUNCTION ImageBufferSize& (x%, y%, x2%, y2%, ScreenMode%)
  mywidth& = ABS(x2% - x%) + 1
  myheight& = ABS(y2% - y%) + 1

    SELECT CASE ScreenMode%
        CASE 1: BPPlane = 2: Planes = 1
        CASE 2, 3, 4, 11: BPPlane = 1: Planes = 1
        CASE 7, 8, 9, 12: BPPlane = 1: Planes = 4
        CASE 10: BPPlane = 1: Planes = 2
        CASE 13: BPPlane = 8: Planes = 1
        CASE ELSE: BPPlane = 0
    END SELECT
    ImageBufferSize& = 4 + INT((mywidth& * BPPlane + 7) / 8) * (myheight& * Planes) 'return the value to function name.
END FUNCTION

'Reads Put Image file into array - this is the XGF Export from Raster Master
SUB ReadPutImageFile (filename$, ImageBuf%(), size&) STATIC
    pad% = LBOUND(ImageBuf%)
    OPEN "R", #1, filename$, 2
    FIELD #1, 2 AS c$
    FOR i% = pad% TO (size& + pad%) - 1
        GET #1
        ImageBuf%(i%) = CVI(c$)
    NEXT i%
    CLOSE #1
END SUB

SUB SavePutImageAsData (filename$, ImageBuf%(), size&)
    OPEN filename$ FOR OUTPUT AS #1
    pad% = LBOUND(ImageBuf%)
    count% = 0
    endsize& = size& + pad% - 1
    LineStr$ = "'  Width= " + STR$(ImageBuf%(pad%)) + "  Height= "
    LineStr$ = LineStr$ + STR$(ImageBuf%(pad% + 1))
    LineStr$ = LineStr$ + " Size= " + STR$(size&)
    
    PRINT #1, LineStr$
    LineStr$ = ""
    FOR i% = pad% TO (size& + pad% - 1)
         h$ = HEX$(ImageBuf%(i%))
         h$ = h$ + STRING$(4 - LEN(h$), "0")
         LineStr$ = LineStr$ + "&H" + h$
         count% = count% + 1
         IF (i% <> endsize&) AND (count% <> 10) THEN LineStr$ = LineStr$ + ","
 
         IF count% = 10 THEN
            PRINT #1, "DATA " + LineStr$
            LineStr$ = ""
    
            count% = 0
         END IF
    NEXT i%
    IF count% <> 0 THEN PRINT #1, "DATA " + LineStr$
    CLOSE #1
END SUB

'Saves a Put Image that is in an array to file
'It does't matter where the Image came from - data statements, captured from screen with GET, or converted fron Bob
SUB SavePutImageFile (filename$, ImageBuf%(), size&)
    pad% = LBOUND(ImageBuf%)
    OPEN "R", #1, filename$, 2
    FIELD #1, 2 AS c$
    FOR i% = pad% TO (size& + pad% - 1)
        LSET c$ = MKI$(ImageBuf%(i%))
        PUT #1
    NEXT i%
    CLOSE #1
END SUB

