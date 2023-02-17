DECLARE SUB ReadPutImageFile (filename$, ImageBuf%(), size%)
SCREEN 7

DIM image%(258)

CALL ReadPutImageFile("truck.xgf", image%(), 258)
PUT (20, 10), image%
INPUT a$

'Reads Put Image file into array - this is the XGF Export from Raster Master
SUB ReadPutImageFile (filename$, ImageBuf%(), size%) STATIC
    pad% = LBOUND(ImageBuf%)
    OPEN "R", #1, filename$, 2
    FIELD #1, 2 AS c$
    FOR i% = pad% TO (size% + pad%) - 1
        GET #1
        ImageBuf%(i%) = CVI(c$)
    NEXT i%
    CLOSE #1
END SUB

