'Sokoban for QBasic\QuickBasic
'Raster Master Sprite\Map Editor was used to create/assemble graphics/map

DEFINT A-Z

DECLARE SUB InitPalette ()
DECLARE SUB ReadBoard ()
DECLARE SUB ReadFloor ()
DECLARE SUB ReadCrateMarker ()
DECLARE SUB ReadCrate ()
DECLARE SUB ReadPusher ()
DECLARE SUB ReadWall ()
DECLARE SUB DrawBoard ()
DECLARE SUB MoveLeft ()
DECLARE SUB MoveRight ()
DECLARE SUB MoveUp ()
DECLARE SUB MoveDown ()

DECLARE SUB DrawItem (bx, by)
DECLARE FUNCTION CanMoveLeft ()
DECLARE FUNCTION CanMoveRight ()
DECLARE FUNCTION CanMoveUp ()
DECLARE FUNCTION CanMoveDown ()
DECLARE FUNCTION PlayerWin ()

DECLARE SUB GoLeft ()
DECLARE SUB GoRight ()
DECLARE SUB GoUp ()
DECLARE SUB GoDown ()

DECLARE SUB DrawPusher ()

DIM SHARED board(16, 16), crateboard(16, 16)
DIM SHARED pusherleft(66), pusherright(66), pusherup(66), pusherdown(66), crate(66), cratemarker(66), wall(66), floor(66)
DIM SHARED emptyblock, wallblock, crateblock, floorblock, pusherleftblock, pusherrightblock
DIM SHARED pusherupblock, pusherdownblock, cratemarkerblock, playerleft, playerright
DIM SHARED playerup, playerdown, playerdirection
DIM SHARED playmode, x, y, i, j, level
DIM SHARED maxcol, maxrow, tilewidth, tileheight

KEYUP$ = CHR$(0) + CHR$(72)
KEYLEFT$ = CHR$(0) + CHR$(75)
KEYRIGHT$ = CHR$(0) + CHR$(77)
KEYDOWN$ = CHR$(0) + CHR$(80)

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
x = 1
y = 0
level = 1

'we read these values from the map data
maxcol = 0
maxrow = 0
tileheight = 0
tileheight = 0

SCREEN 7
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
PRINT "Level:"; level


WHILE playmode
 k$ = INKEY$
 IF k$ = KEYLEFT$ THEN
  MoveLeft
 ELSEIF k$ = KEYRIGHT$ THEN
  MoveRight
 ELSEIF k$ = KEYUP$ THEN
  MoveUp
 ELSEIF k$ = KEYDOWN$ THEN
  MoveDown
 ELSEIF k$ = "q" THEN
  playmode = 0
 END IF

 IF PlayerWin THEN
    level = level + 1
    SLEEP 2
    LOCATE 5, 25
    PRINT "Level:"; level
    CALL ReadBoard
    CALL DrawBoard
    CALL DrawPusher
    IF level > 2 THEN playmode = 0
 END IF
WEND

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


crateLabel:
' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' crate
DATA &H0010,&H0010,&H0000,&H0000,&HFFFF,&HFFFF,&H0000,&HFC3F,&HFFFF,&H03C0
DATA &H0000,&HFE7F,&HFFFF,&H0180,&H0000,&H0660,&H07E0,&H0180,&H0000,&H3667
DATA &H37E7,&H0180,&H0000,&H766E,&H77EE,&H0180,&H0000,&HE66C,&HE7EC,&H0180
DATA &H0000,&HC669,&HC7E9,&H0180,&H0000,&H9663,&H97E3,&H0180,&H0000,&H3667
DATA &H37E7,&H0180,&H0000,&H766E,&H77EE,&H0180,&H0000,&HE66C,&HE7EC,&H0180
DATA &H0000,&H0660,&H07E0,&H0180,&H0000,&HFE7F,&HFFFF,&H0180,&H0000,&HFC3F
DATA &HFFFF,&H03C0,&H0000,&H0000,&HFFFF,&HFFFF


crateMarkerLabel:
' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' crateb
DATA &H0010,&H0010,&H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H3C3C,&HFFFF,&HFFFF
DATA &H0000,&H3E7C,&HFFFF,&HFFFF,&H0000,&H0660,&HFFFF,&HFFFF,&H0000,&H0660
DATA &HFFFF,&HFFFF,&H0000,&H0660,&HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF
DATA &H0000,&H8001,&HFFFF,&HFFFF,&H0000,&H8001,&HFFFF,&HFFFF,&H0000,&H0000
DATA &HFFFF,&HFFFF,&H0000,&H0660,&HFFFF,&HFFFF,&H0000,&H0660,&HFFFF,&HFFFF
DATA &H0000,&H0660,&HFFFF,&HFFFF,&H0000,&H3E7C,&HFFFF,&HFFFF,&H0000,&H3C3C
DATA &HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF


wallLabel:
' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' wall
DATA &H0010,&H0010,&H0000,&H0000,&H0000,&HFFFF,&H0BFD,&HFBFD,&HFBFD,&H0402
DATA &HFBFD,&HFBFD,&HFBFD,&H0402,&HFBFD,&HFBFD,&HFBFD,&H0402,&H0000,&H0000
DATA &H0000,&HFFFF,&HD02F,&HDFEF,&HDFEF,&H2010,&HDFEF,&HDFEF,&HDFEF,&H2010
DATA &HDFEF,&HDFEF,&HDFEF,&H2010,&H0000,&H0000,&H0000,&HFFFF,&H0BFD,&HFBFD
DATA &HFBFD,&H0402,&HFBFD,&HFBFD,&HFBFD,&H0402,&HFBFD,&HFBFD,&HFBFD,&H0402
DATA &H0000,&H0000,&H0000,&HFFFF,&HD02F,&HDFEF,&HDFEF,&H2010,&HDFEF,&HDFEF
DATA &HDFEF,&H2010,&HDFEF,&HDFEF,&HDFEF,&H2010

FloorLabel:
' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' floor
DATA &H0010,&H0010,&H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF
DATA &H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000
DATA &HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF
DATA &H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000
DATA &HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF
DATA &H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF,&H0000,&H0000
DATA &HFFFF,&HFFFF,&H0000,&H0000,&HFFFF,&HFFFF


PusherLeftLabel:
' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' pusherl
DATA &H0010,&H0010,&H0000,&H0000,&HFFFF,&HFFFF,&HE007,&H0000,&HFFFF,&HFFFF
DATA &HF00F,&H0000,&HFFFF,&HFFFF,&HF81F,&H000C,&HFFFF,&HFFFF,&HFC3F,&H0008
DATA &HFFFF,&HFFFF,&HFE7F,&H0000,&HFFFF,&HFFFF,&HFE7F,&H0000,&HFFFF,&HFFFF
DATA &HFE7F,&H0000,&HFFFF,&HFFFF,&HFE7F,&H0000,&HFFFF,&HFFFF,&HFE7B,&H0000
DATA &HFF7B,&H0100,&HFE03,&H0000,&HFF03,&H0100,&HFC7F,&H0000,&HFFFF,&H0380
DATA &HF81F,&H0000,&HFFFF,&H07E0,&HF00F,&H0000,&HFFFF,&H0FF0,&HE007,&H0000
DATA &HFFFF,&H1FF8,&H0000,&H0000,&HFFC0,&HFFC0


PusherRightLabel:
' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' pusherr
DATA &H0010,&H0010,&H0000,&H0000,&HFFFF,&HFFFF,&HE007,&H0000,&HFFFF,&HFFFF
DATA &HF00F,&H0000,&HFFFF,&HFFFF,&HF81F,&H3000,&HFFFF,&HFFFF,&HFC3F,&H1000
DATA &HFFFF,&HFFFF,&HFE7F,&H0000,&HFFFF,&HFFFF,&HFE7F,&H0000,&HFFFF,&HFFFF
DATA &HFE7F,&H0000,&HFFFF,&HFFFF,&HFE7F,&H0000,&HFFFF,&HFFFF,&HDE7F,&H0000
DATA &HDEFF,&H0080,&HC07F,&H0000,&HC0FF,&H0080,&HFE3F,&H0000,&HFFFF,&H01C0
DATA &HF81F,&H0000,&HFFFF,&H07E0,&HF00F,&H0000,&HFFFF,&H0FF0,&HE007,&H0000
DATA &HFFFF,&H1FF8,&H0000,&H0000,&H03FF,&H03FF


PusherUpLabel:
' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' pusheru
DATA &H0010,&H0010,&H0000,&H0000,&HFC3F,&HFC3F,&HE007,&H0000,&HFE7F,&HFE7F
DATA &HF00F,&H0000,&HFE7F,&HFE7F,&HF81F,&H0000,&HFE7F,&HFE7F,&HFC3F,&H0000
DATA &HFE7F,&HFE7F,&HFE7F,&H0000,&HFE7F,&HFE7F,&HFE7F,&H0000,&HFE7F,&HFE7F
DATA &HFE7F,&H0000,&HFE7F,&HFE7F,&HFE7F,&H0000,&HFFFF,&HFFFF,&HFE7F,&H0000
DATA &HFFFF,&H0180,&HFE7F,&H0000,&HFFFF,&H0180,&HFC7F,&H0000,&HFFFF,&H0380
DATA &HF81F,&H0000,&HFFFF,&H07E0,&HF00F,&H0000,&HFFFF,&H0FF0,&HE007,&H0000
DATA &HFFFF,&H1FF8,&H0000,&H0000,&H8FF1,&H8FF1


PusherDownLabel:
' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' pusherd
DATA &H0010,&H0010,&H0000,&H0000,&H8FF1,&H8FF1,&HE007,&H0000,&HFFFF,&HFFFF
DATA &HF00F,&H0000,&HFFFF,&HFFFF,&HF81F,&H0000,&HFFFF,&HFFFF,&HFC7F,&H0000
DATA &HFFFF,&HFFFF,&HFE7F,&H0000,&HFFFF,&HFFFF,&HFE7F,&H0000,&HFFFF,&HFFFF
DATA &HFE7F,&H0000,&HFFFF,&H0180,&HFE7F,&H0000,&HFE7F,&H0000,&HFE7F,&H0000
DATA &HFE7F,&H0000,&HFE7F,&H0000,&HFE7F,&H0000,&HFC3F,&H0000,&HFE7F,&H0240
DATA &HF81F,&H0000,&HFE7F,&H0660,&HF00F,&H0000,&HFE7F,&H0E70,&HE007,&H0000
DATA &HFE7F,&H1E78,&H0000,&H0000,&HFC3F,&HFC3F


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
  FOR i = 0 TO 65
    READ crate(i)
  NEXT i
END SUB

SUB ReadCrateMarker
  RESTORE crateMarkerLabel
  FOR i = 0 TO 65
    READ cratemarker(i)
  NEXT i
END SUB

SUB ReadFloor
  RESTORE FloorLabel
  FOR i = 0 TO 65
    READ floor(i)
  NEXT i
END SUB

SUB ReadPusher
  RESTORE PusherLeftLabel
  FOR i = 0 TO 65
    READ pusherleft(i)
  NEXT i

  RESTORE PusherRightLabel
  FOR i = 0 TO 65
    READ pusherright(i)
  NEXT i

  RESTORE PusherUpLabel
  FOR i = 0 TO 65
    READ pusherup(i)
  NEXT i

  RESTORE PusherDownLabel
  FOR i = 0 TO 65
    READ pusherdown(i)
  NEXT i
END SUB

SUB ReadWall
  RESTORE wallLabel
  FOR i = 0 TO 65
    READ wall(i)
  NEXT i
END SUB

