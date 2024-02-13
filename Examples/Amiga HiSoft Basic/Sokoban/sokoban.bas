'Sokoban for Amiga HiSoft Basic
'Raster Master Sprite\Map Editor was used to create/assemble graphics/map

DEFINT A-Z

DECLARE SUB InitPalette
DECLARE SUB ReadBoard
DECLARE SUB ReadFloor
DECLARE SUB ReadCrateMarker
DECLARE SUB ReadCrate 
DECLARE SUB ReadPusher 
DECLARE SUB ReadWall
DECLARE SUB DrawBoard 
DECLARE SUB MoveLeft 
DECLARE SUB MoveRight 
DECLARE SUB MoveUp 
DECLARE SUB MoveDown 

DECLARE SUB DrawItem (bx, by)
DECLARE FUNCTION CanMoveLeft 
DECLARE FUNCTION CanMoveRight 
DECLARE FUNCTION CanMoveUp
DECLARE FUNCTION CanMoveDown
DECLARE FUNCTION PlayerWin

DECLARE SUB GoLeft
DECLARE SUB GoRight
DECLARE SUB GoUp 
DECLARE SUB GoDown 

DECLARE SUB DrawPusher 

DIM SHARED board(16, 16), crateboard(16, 16)
DIM SHARED pusherleft(67), pusherright(67), pusherup(67), pusherdown(67), crate(67), cratemarker(67), wall(67), floor(67)
DIM SHARED emptyblock, wallblock, crateblock, floorblock, pusherleftblock, pusherrightblock
DIM SHARED pusherupblock, pusherdownblock, cratemarkerblock, playerleft, playerright
DIM SHARED playerup, playerdown, playerdirection
DIM SHARED playmode, x, y, i, j, level
DIM SHARED maxcol, maxrow, tilewidth, tileheight


emptyblock = -1
wallblock = 0
crateblock = 2
floorblock = 4
pusherleftblock = 5
pusherrightblock = 6
pusherupblock = 7
pusherdownblock = 8

cratemarkerblock = 1

playerleft = 0
playerright = 1
playerup = 2
playerdown = 3
playerdirection = playerright

playmode = 1
x = 0
y = 0
level = 1

'we read these values from the map data
maxcol = 0
maxrow = 0
tileheight = 0
tileheight = 0

 SCREEN 1,300,190,4,1
 WINDOW 2,"Sokoban",(1,1)-(275,170),15,1

CALL InitPalette
CALL ReadBoard
CALL ReadPusher
CALL ReadWall
CALL ReadCrate
CALL ReadCrateMarker
CALL ReadFloor
CALL DrawBoard
CALL DrawPusher

LOCATE 5, 25
COLOR 11
PRINT "Level:"; level


WHILE playmode
 SLEEP
 k$ = INKEY$

 IF k$=CHR$(28) THEN 
    MoveUp
 ELSEIF k$=CHR$(29) THEN 
    MoveDown
 ELSEIF k$=CHR$(30) THEN 
    MoveRight
 ELSEIF k$=CHR$(31) THEN 
    MoveLeft
 ELSEIF k$="q" OR k$="Q" THEN
    playmode=0
 END IF

 IF PlayerWin THEN
    level = level + 1
    IF level < 3 THEN 
      'SLEEP 2
      LOCATE 5, 25
      PRINT "Level:"; level
      CALL ReadBoard
      CALL DrawBoard
      CALL DrawPusher
    ELSE
     playmode = 0
    END IF
 END IF   
WEND
WINDOW CLOSE 1
SCREEN CLOSE 1

END


boardMapLabel1:
' Basic Map Code Created By Raster Master
' Size =103 Width=11 Height=9 Tile Width=32 Tile Height=32
' board3
DATA 11,9,16,16,0,0,0,0,0,0
DATA 0,0,0,0,0,0,4,0,1,4
DATA 4,4,4,4,1,0,0,4,0,0
DATA 0,0,4,4,4,0,0,0,4,1
DATA 0,4,2,4,0,4,0,0,0,4
DATA 4,0,4,4,4,2,4,4,0,0
DATA 4,4,0,0,0,0,4,4,4,0
DATA 0,4,4,4,2,5,4,4,4,4
DATA 0,0,4,4,4,4,4,0,0,4
DATA 4,0,0,0,0,0,0,0,0,0
DATA 0,0,0

boardMapLabel2:
' Basic Map Code Created By Raster Master
' Size =103 Width=11 Height=9 Tile Width=16 Tile Height=16
' map2
DATA 11,9,16,16,0,0,0,0,0,0
DATA 0,0,0,0,0,0,1,4,4,4
DATA 4,4,4,4,4,0,0,4,4,4
DATA 4,4,0,4,0,1,0,0,0,4
DATA 0,0,4,2,2,0,4,0,0,4
DATA 4,1,0,6,0,4,0,4,0,0
DATA 4,4,4,4,4,4,4,2,4,0
DATA 0,4,4,0,0,4,0,0,0,4
DATA 0,0,4,4,4,4,4,4,4,4
DATA 4,0,0,0,0,0,0,0,0,0
DATA 0,0,0

boardMapLabel3:
'add more levels here
RETURN

boardMapLabel4:
'add more levels here

RETURN
'add more levels here

boardMapLabel5:
RETURN


CrateLabel:
' AmigaBASIC PUT Image, Size= 67 Width= 16 Height= 16 Colors= 16
' Crate
DATA &H0010,&H0010,&H0004,&HFFFF,&HC003,&H8001,&H8001,&H8001,&H8001,&H8001
DATA &H8001,&H8001,&H8001,&H8001,&H8001,&H8001,&H8001,&HC003,&HFFFF,&HFFFF
DATA &HC003,&H8001,&H9FF9,&H98C9,&H9189,&H9319,&H9639,&H9C69,&H98C9,&H9189
DATA &H9319,&H9FF9,&H8001,&HC003,&HFFFF,&H0000,&H0000,&H0000,&H1FF8,&H18C8
DATA &H1188,&H1318,&H1638,&H1C68,&H18C8,&H1188,&H1318,&H1FF8,&H0000,&H0000
DATA &H0000,&H0000,&H3FFC,&H7FFE,&H6006,&H6736,&H6E76,&H6CE6,&H69C6,&H6396
DATA &H6736,&H6E76,&H6CE6,&H6006,&H7FFE,&H3FFC,&H0000


CrateMarkerLabel:
' AmigaBASIC PUT Image, Size= 67 Width= 16 Height= 16 Colors= 16
' CrateMarker
DATA &H0010,&H0010,&H0004,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF
DATA &HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF
DATA &HC3C3,&H83C1,&H9FF9,&H9FF9,&H9FF9,&HFFFF,&HFE7F,&HFE7F,&HFFFF,&H9FF9
DATA &H9FF9,&H9FF9,&H83C1,&HC3C3,&HFFFF,&H0000,&H3C3C,&H7C3E,&H6006,&H6006
DATA &H6006,&H0000,&H0180,&H0180,&H0000,&H6006,&H6006,&H6006,&H7C3E,&H3C3C
DATA &H0000,&H0000,&H3C3C,&H7C3E,&H6006,&H6006,&H6006,&H0000,&H0180,&H0180
DATA &H0000,&H6006,&H6006,&H6006,&H7C3E,&H3C3C,&H0000


WallLabel:
' AmigaBASIC PUT Image, Size= 67 Width= 16 Height= 16 Colors= 16
' Wall
DATA &H0010,&H0010,&H0004,&HFFFF,&H0204,&H0204,&H0204,&HFFFF,&H1020,&H1020
DATA &H1020,&HFFFF,&H0204,&H0204,&H0204,&HFFFF,&H1020,&H1020,&H1020,&HFFFF
DATA &HFF0F,&HFFFF,&HFFFF,&HFFFF,&H3FF0,&HFFFF,&HFFFF,&HFFFF,&HFF0F,&HFFFF
DATA &HFFFF,&HFFFF,&H3FF0,&HFFFF,&HFFFF,&HFFFF,&H02F4,&H0204,&H0204,&HFFFF
DATA &HD02F,&H1020,&H1020,&HFFFF,&H02F4,&H0204,&H0204,&HFFFF,&HD02F,&H1020
DATA &H1020,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000


FloorLabel:
' AmigaBASIC PUT Image, Size= 67 Width= 16 Height= 16 Colors= 16
' Floor
DATA &H0010,&H0010,&H0004,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF
DATA &HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF
DATA &HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF
DATA &HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&H0000,&H0000,&H0000,&H0000,&H0000
DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000



PusherLeftLabel:
' AmigaBASIC PUT Image, Size= 67 Width= 16 Height= 16 Colors= 16
' PusherLeft
DATA &H0010,&H0010,&H0004,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF
DATA &HFFFF,&HFBFF,&H7BFF,&H03FF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HC0FF,&HFFFF
DATA &HF81F,&HF00F,&HEC07,&HC803,&H8001,&H8001,&H8001,&H8401,&H8401,&HFC01
DATA &H8003,&HE007,&HF00F,&HF81F,&HFFFF,&H0000,&H0000,&H0000,&H0000,&H0000
DATA &H0000,&H0000,&H0000,&H0400,&HFFFE,&HFFFE,&H7FFC,&H1FF8,&H0FF0,&H07E0
DATA &H3F00,&H0000,&H0000,&H0000,&H0C00,&H0800,&H0000,&H0000,&H0000,&H0000
DATA &H7BFE,&H03FE,&H7FFC,&H1FF8,&H0FF0,&H07E0,&H0000



PusherRightLabel:
' AmigaBASIC PUT Image, Size= 67 Width= 16 Height= 16 Colors= 16
' PusherRight
DATA &H0010,&H0010,&H0004,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF
DATA &HFFFF,&HFFDF,&HFFDE,&HFFC0,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFF03,&HFFFF
DATA &HF81F,&HF00F,&HE037,&HC013,&H8001,&H8001,&H8001,&H8021,&H8021,&H803F
DATA &HC001,&HE007,&HF00F,&HF81F,&HFFFF,&H0000,&H0000,&H0000,&H0000,&H0000
DATA &H0000,&H0000,&H0000,&H0020,&H7FFF,&H7FFF,&H3FFE,&H1FF8,&H0FF0,&H07E0
DATA &H00FC,&H0000,&H0000,&H0000,&H0030,&H0010,&H0000,&H0000,&H0000,&H0000
DATA &H7FDE,&H7FC0,&H3FFE,&H1FF8,&H0FF0,&H07E0,&H0000


PusherUpLabel:
' AmigaBASIC PUT Image, Size= 67 Width= 16 Height= 16 Colors= 16
' PusherUp
DATA &H0010,&H0010,&H0004,&H3FFC,&H7FFE,&H7FFE,&H7FFE,&H7FFE,&H7FFE,&H7FFE
DATA &H7FFE,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HF18F,&HFFFF
DATA &HF81F,&HF00F,&HE007,&HC003,&H8001,&H8001,&H8001,&H8001,&H8001,&H8001
DATA &H8003,&HE007,&HF00F,&HF81F,&HFFFF,&HC003,&H8001,&H8001,&H8001,&H8001
DATA &H8001,&H8001,&H8001,&H0000,&H7FFE,&H7FFE,&H7FFC,&H1FF8,&H0FF0,&H07E0
DATA &H0E70,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
DATA &H7FFE,&H7FFE,&H7FFC,&H1FF8,&H0FF0,&H07E0,&H0000


PusherDownLabel:
' AmigaBASIC PUT Image, Size= 67 Width= 16 Height= 16 Colors= 16
' PusherDown
DATA &H0010,&H0010,&H0004,&HF18F,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF,&HFFFF
DATA &HFFFF,&H7FFE,&H7FFE,&H7FFE,&H7FFE,&H7FFE,&H7FFE,&H7FFE,&H3FFC,&HFFFF
DATA &HF81F,&HF00F,&HE007,&H8003,&H8001,&H8001,&H8001,&H8001,&H8001,&H8001
DATA &HC003,&HE007,&HF00F,&HF81F,&HFFFF,&H0E70,&H07E0,&H0FF0,&H1FF8,&H7FFC
DATA &H7FFE,&H7FFE,&H0000,&H8001,&H8001,&H8001,&H8001,&H8001,&H8001,&H8001
DATA &HC003,&H0000,&H07E0,&H0FF0,&H1FF8,&H7FFC,&H7FFE,&H7FFE,&H0000,&H0000
DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000



FUNCTION CanMoveDown
 IF (y < maxrow) AND board(x, y + 1) = floorblock THEN
  CanMoveDown = 1
 ELSEIF (y < maxrow) AND board(x, y + 1) = cratemarkerblock THEN
  CanMoveDown = 1
 ELSEIF (y < (maxrow - 1)) AND (crateboard(x, y + 1) = crateblock) AND ((board(x, y + 2) = floorblock) OR (board(x, y + 2) = cratemarkerblock)) THEN
  CanMoveDown = 1
 ELSE
  CanMoveDown = 0
 END IF
END FUNCTION

FUNCTION CanMoveLeft
 CanMoveLeft = 0
 IF (x > 0) AND board(x - 1, y) = floorblock THEN
  CanMoveLeft = 1
 ELSEIF (x > 0) AND board(x - 1, y) = cratemarkerblock THEN
  CanMoveLeft = 1
 ELSEIF (x > 1) AND (crateboard(x - 1, y) = crateblock) THEN
  IF board(x - 2, y) = floorblock OR board(x - 2, y) = cratemarkerblock THEN CanMoveLeft = 1
 END IF
END FUNCTION

FUNCTION CanMoveRight
 IF (x < maxcol) AND board(x + 1, y) = floorblock THEN
  CanMoveRight = 1
 ELSEIF (x < maxcol) AND board(x + 1, y) = cratemarkerblock THEN
  CanMoveRight = 1
 ELSEIF (x < (maxcol - 1)) AND (crateboard(x + 1, y) = crateblock) AND ((board(x + 2, y) = floorblock) OR (board(x + 2, y) = cratemarkerblock)) THEN
  CanMoveRight = 1
 ELSE
  CanMoveRight = 0
 END IF
END FUNCTION

FUNCTION CanMoveUp
 CanMoveUp = 0
 IF (y > 0) AND board(x, y - 1) = floorblock THEN
  CanMoveUp = 1
 ELSEIF (y > 0) AND board(x, y - 1) = cratemarkerblock THEN
  CanMoveUp = 1
 ELSEIF (y > 1) AND (crateboard(x, y - 1) = crateblock) THEN
  IF (board(x, y - 2) = floorblock) OR (board(x, y - 2) = cratemarkerblock) THEN CanMoveUp = 1
 END IF
END FUNCTION

SUB DrawBoard
  FOR j = 0 TO maxrow
   FOR i = 0 TO maxcol
     CALL DrawItem(i, j)
   NEXT i
  NEXT j
END SUB

SUB DrawItem (bx, by)
   IF board(bx, by) = wallblock THEN
     PUT (bx * tilewidth, by * tileheight), wall, PSET
   ELSEIF crateboard(bx, by) = crateblock THEN
     PUT (bx * tilewidth, by * tileheight), crate, PSET
   ELSEIF board(bx, by) = cratemarkerblock THEN
     PUT (bx * tilewidth, by * tileheight), cratemarker, PSET
   ELSEIF board(bx, by) = floorblock THEN
     PUT (bx * tilewidth, by * tileheight), floor, PSET
   END IF
END SUB

SUB DrawPusher
  IF playerdirection = playerleft THEN
    PUT (x * tilewidth, y * tileheight), pusherleft, PSET
  ELSEIF playerdirection = playerright THEN
    PUT (x * tilewidth, y * tileheight), pusherright, PSET
  ELSEIF playerdirection = playerup THEN
    PUT (x * tilewidth, y * tileheight), pusherup, PSET
  ELSEIF playerdirection = playerdown THEN
    PUT (x * tilewidth, y * tileheight), pusherdown, PSET
  END IF
END SUB

SUB GoDown
 playerdirection = playerdown
 IF (board(x, y + 1) = floorblock) OR (board(x, y + 1) = cratemarkerblock) THEN
    CALL DrawItem(x, y)
    y = y + 1
 ELSEIF crateboard(x, y + 1) = crateblock THEN
    crateboard(x, y + 1) = emptyblock
    crateboard(x, y + 2) = crateblock
    board(x, y + 1) = floorblock
    board(x, y + 2) = emptyblock
    CALL DrawItem(x, y + 2)
    CALL DrawItem(x, y)
    y = y + 1
 END IF
 DrawPusher
END SUB

SUB GoLeft
 playerdirection = playerleft
 IF (board(x - 1, y) = floorblock) OR (board(x - 1, y) = cratemarkerblock) THEN
    CALL DrawItem(x, y)
    x = x - 1
 ELSEIF crateboard(x - 1, y) = crateblock THEN
    crateboard(x - 1, y) = emptyblock
    crateboard(x - 2, y) = crateblock
    board(x - 1, y) = floorblock
    board(x - 2, y) = emptyblock
    CALL DrawItem(x - 2, y)
    CALL DrawItem(x, y)
    x = x - 1
 END IF
 DrawPusher
END SUB

SUB GoRight
 playerdirection = playerright
 IF (board(x + 1, y) = floorblock) OR (board(x + 1, y) = cratemarkerblock) THEN
    CALL DrawItem(x, y)
    x = x + 1
 ELSEIF crateboard(x + 1, y) = crateblock THEN
    crateboard(x + 1, y) = emptyblock
    crateboard(x + 2, y) = crateblock
    board(x + 1, y) = floorblock
    board(x + 2, y) = emptyblock
    CALL DrawItem(x + 2, y)
    CALL DrawItem(x, y)
    x = x + 1
 END IF
 CALL DrawPusher
END SUB

SUB GoUp
 playerdirection = playerup
 IF (board(x, y - 1) = floorblock) OR (board(x, y - 1) = cratemarkerblock) THEN
    CALL DrawItem(x, y)
    y = y - 1
 ELSEIF crateboard(x, y - 1) = crateblock THEN
    crateboard(x, y - 1) = emptyblock
    crateboard(x, y - 2) = crateblock
    board(x, y - 1) = floorblock
    board(x, y - 2) = emptyblock
    CALL DrawItem(x, y - 2)
    CALL DrawItem(x, y)
    y = y - 1
 END IF
 DrawPusher
END SUB

SUB InitPalette
' AmigaBASIC Palette Commands,  Size= 48 Colors= 16 Format=1 Percent 
Palette 0, 0.00, 0.00, 0.00
Palette 1, 0.27, 0.13, 0.20
Palette 2, 0.54, 0.60, 0.74
Palette 3, 0.94, 0.67, 0.40
Palette 4, 0.74, 0.80, 0.87
Palette 5, 0.13, 0.20, 0.27
Palette 6, 0.47, 0.20, 0.20
Palette 7, 0.33, 0.40, 0.47
Palette 8, 0.74, 0.40, 0.27
Palette 9, 0.80, 0.54, 0.33
Palette 10, 1.00, 0.74, 0.54
Palette 11, 1.00, 1.00, 1.00
Palette 12, 0.27, 0.87, 0.74
Palette 13, 0.94, 0.27, 0.20
Palette 14, 0.87, 0.60, 0.40
Palette 15, 1.00, 0.47, 0.40
END SUB

SUB MoveDown
  IF CanMoveDown THEN
     GoDown
  END IF
END SUB

SUB MoveLeft
  IF CanMoveLeft THEN
     GoLeft
  END IF
END SUB

SUB MoveRight
  IF CanMoveRight THEN
     GoRight
  END IF
END SUB

SUB MoveUp
  IF CanMoveUp THEN
     GoUp
  END IF
END SUB

FUNCTION PlayerWin
  count = 0
  match = 0
  FOR j = 0 TO maxrow
    FOR i = 0 TO maxcol
      IF board(i, j) = cratemarkerblock THEN
        count = count + 1
        IF crateboard(i, j) = crateblock THEN
          match = match + 1
        END IF
      END IF
    NEXT i
  NEXT j
  IF count = match THEN PlayerWin = 1 ELSE PlayerWin = 0
END FUNCTION

SUB ReadBoard
IF level = 1 THEN
    RESTORE boardMapLabel1
  ELSEIF level = 2 THEN
    RESTORE boardMapLabel2
  ELSEIF level = 3 THEN
    RESTORE boardMapLabel3
  ELSEIF level = 4 THEN
    RESTORE boardMapLabel4
  ELSEIF level = 5 THEN
    RESTORE boardMapLabel5
  END IF

  READ maxcol, maxrow, tilewidth, tileheight
  maxcol = maxcol - 1
  maxrow = maxrow - 1

  FOR j = 0 TO maxrow
   FOR i = 0 TO maxcol
     READ tile
     IF tile = crateblock THEN
        crateboard(i, j) = crateblock
        board(i, j) = emptyblock
     ELSEIF (tile = pusherleftblock) THEN
       x = i
       y = j
       playerdirection = playerleft
       board(i, j) = floorblock
     ELSEIF (tile = pusherrightblock) THEN
       x = i
       y = j
       playerdirection = playerright
       board(i, j) = floorblock
     ELSEIF (tile = pusherupblock) THEN
       x = i
       y = j
       playerdirection = playerup
       board(i, j) = floorblock
     ELSEIF (tile = pusherdownblock) THEN
       x = i
       y = j
       playerdirection = playerdown
       board(i, j) = floorblock
     ELSE
       board(i, j) = tile
       crateboard(i, j) = emptyblock
     END IF
   NEXT i
  NEXT j

END SUB

SUB ReadCrate
  RESTORE crateLabel
  FOR i = 0 TO 66
    READ crate(i)
  NEXT i
END SUB

SUB ReadCrateMarker
  RESTORE crateMarkerLabel
  FOR i = 0 TO 66
    READ cratemarker(i)
  NEXT i
END SUB

SUB ReadFloor
  RESTORE FloorLabel
  FOR i = 0 TO 66
    READ floor(i)
  NEXT i
END SUB

SUB ReadPusher
  RESTORE PusherLeftLabel
  FOR i = 0 TO 66
    READ pusherleft(i)
  NEXT i

  RESTORE PusherRightLabel
  FOR i = 0 TO 66
    READ pusherright(i)
  NEXT i

  RESTORE PusherUpLabel
  FOR i = 0 TO 66
    READ pusherup(i)
  NEXT i

  RESTORE PusherDownLabel
  FOR i = 0 TO 66
    READ pusherdown(i)
  NEXT i
END SUB

SUB ReadWall
  RESTORE wallLabel
  FOR i = 0 TO 66
    READ wall(i)
  NEXT i
END SUB

