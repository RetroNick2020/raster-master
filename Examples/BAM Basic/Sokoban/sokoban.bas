'Sokoban for BAM (Basic Anywhere Machine)
'Raster Master Sprite/Map Editor was used to create/assemble graphics/map

defint a-Z

declare sub InitPalette()
declare sub ReadFloor()
declare sub ReadCrateMarker()
declare sub ReadCrate()
declare sub ReadPusher()
declare sub ReadWall()
declare sub DrawBoard()
declare sub MoveLeft()
declare sub MoveRight()
declare sub MoveUp()
declare sub MoveDown()

declare sub DrawItem(bx,by)
declare function CanMoveLeft()
declare function CanMoveRight()
declare function CanMoveUp()
declare function CanMoveDown()
declare function PlayerWin()

declare sub GoLeft()
declare sub GoRight()
declare sub GoUp()
declare sub GoDown()

declare sub DrawPusher()

dim board(16,16),crateboard(16,16)
dim pusherleft(66),pusherright(66),pusherup(66),pusherdown(66),crate(66),cratemarker(66),wall(66),floor(66)

CONST KEY_UP$ = CHR$(0)+CHR$(72)
CONST KEY_LEFT$ = CHR$(0)+CHR$(75)
CONST KEY_RIGHT$ = CHR$(0)+CHR$(77)
CONST KEY_DOWN$ = CHR$(0)+CHR$(80)

emptyblock=-1
wallblock=0
crateblock=2
floorblock=4
pusherleftblock=5
pusherrightblock=6
pusherupblock=7
pusherdownblock=8

cratemarkerblock=1

playerleft = 0
playerright =1
playerup = 2
playerdown = 3
playerdirection = playerright

playmode=1
x=1
y=0

'we read these values from the map data
maxcol=0
maxrow=0
tileheight=0
tileheight=0

screen 7
InitPalette()
gosub ReadBoard
ReadPusher()
ReadWall()
ReadCrate()
ReadCrateMarker()
ReadFloor()
DrawBoard()
DrawPusher()


while playmode
 k$=INKEY$
 if k$ = KEY_LEFT$ then MoveLeft()
 if k$ = KEY_RIGHT$ then MoveRight()
 if k$ = KEY_UP$ then MoveUp()
 if k$ = KEY_DOWN$ then MoveDown()
 if k$ = "q" then playmode = 0
 if PlayerWin() then 
    locate 5,25
    Print "You Won!"
    playmode=0
 end if   
wend

END

sub MoveLeft()
  if CanMoveLeft()  then 
     GoLeft()
  end if
end sub

sub MoveRight()
  if CanMoveRight() then 
     GoRight()
  end if
end sub

sub MoveUp()
  if CanMoveUp() then 
     GoUp()
  end if
end sub

sub MoveDown()
  if CanMoveDown() then 
     GoDown()
  end if
end sub

ReadBoard:
  restore boardMapLabel
  read maxcol,maxrow,tilewidth,tileheight
  maxcol=maxcol-1
  maxrow=maxrow-1

  for j=0 to maxrow
   for i=0 to maxcol
     read tile
     if tile = crateblock then
        crateboard(i,j)=crateblock
        board(i,j)=emptyblock
     elseif (tile=pusherleftblock) then
       x=i
       y=j
       playerdirection=playerleft
       board(i,j)=floorblock
     elseif (tile=pusherrightblock) then
       x=i
       y=j
       playerdirection=playerright
       board(i,j)=floorblock
     elseif (tile=pusherupblock) then
       x=i
       y=j
       playerdirection=playerup
       board(i,j)=floorblock
     elseif (tile=pusherdownblock) then
       x=i
       y=j
       playerdirection=playerdown
       board(i,j)=floorblock
     else  
       board(i,j)=tile
       crateboard(i,j)=EmptyBlock
     end if  
   next i
  next j
return

sub DrawBoard()
  for j=0 to maxrow
   for i=0 to maxcol
     DrawItem(i,j)
   next i
  next j
end sub

function PlayerWin()
  count=0
  match=0
  for j=0 to maxrow
    for i=0 to maxcol
      if board(i,j)=cratemarkerblock then 
        count=count+1
        if crateboard(i,j)=crateblock then
          match=match+1
        end if
      end if  
    next i
  next j
  if count=match then PlayerWin=1 else PlayerWin=0
end function

sub DrawItem(bx,by)
   if board(bx,by) = wallblock then 
     put(bx*tilewidth,by*tileheight),wall,pset
   elseif crateboard(bx,by) = crateblock then 
     put(bx*tilewidth,by*tileheight),crate,pset
   elseif board(bx,by) = cratemarkerblock then 
     put(bx*tilewidth,by*tileheight),cratemarker,pset
   elseif board(bx,by) = floorblock then 
     put(bx*tilewidth,by*tileheight),floor,pset   
   end if  
end sub

function CanMoveLeft()
 if (x > 0) and board(x-1,y) = floorblock then
  CanMoveLeft=1
 elseif (x >0) and board(x-1,y) = cratemarkerblock then
  CanMoveLeft=1
 elseif (x > 1) and (crateboard(x-1,y)=crateblock) and ((board(x-2,y)=floorblock) or (board(x-2,y)=cratemarkerblock)) then
  CanMoveLeft=1
 else
  CanMoveLeft=0
 end if
end function

function CanMoveRight()
 if (x < maxcol) and board(x+1,y) = floorblock then
  CanMoveRight=1
 elseif (x < maxcol) and board(x+1,y) = cratemarkerblock then
  CanMoveRight=1
 elseif (x < (maxcol-1)) and (crateboard(x+1,y)=crateblock) and ((board(x+2,y)=floorblock) or (board(x+2,y)=cratemarkerblock)) then
  CanMoveRight=1
 else
  CanMoveRight=0
 end if
end function

function CanMoveUp()
 if (y > 0) and board(x,y-1) = floorblock then
  CanMoveUp=1
 elseif (y >0) and board(x,y-1) = cratemarkerblock then
  CanMoveUp=1
 elseif (y > 1) and (crateboard(x,y-1)=crateblock) and ((board(x,y-2)=floorblock) or (board(x,y-2)=cratemarkerblock)) then
  CanMoveUp=1
 else
  CanMoveUp=0
 end if
end function

function CanMoveDown()
 if (y < maxrow) and board(x,y+1) = floorblock then
  CanMoveDown=1
 elseif (y < maxrow) and board(x,y+1) = cratemarkerblock then
  CanMoveDown=1
 elseif (y < (maxrow-1)) and (crateboard(x,y+1)=crateblock) and ((board(x,y+2)=floorblock) or (board(x,y+2)=cratemarkerblock)) then
  CanMoveDown=1
 else
  CanMoveDown=0
 end if
end function


sub DrawPusher()
  if playerdirection = playerleft then
    put(x*tilewidth,y*tileheight),pusherleft,pset
  elseif playerdirection = playerright then
    put(x*tilewidth,y*tileheight),pusherright,pset
  elseif playerdirection = playerup then
    put(x*tilewidth,y*tileheight),pusherup,pset
  elseif playerdirection = playerdown then
    put(x*tilewidth,y*tileheight),pusherdown,pset
  end if
end sub

sub GoLeft()
 playerdirection=playerleft
 if (board(x-1,y) = floorblock) or (board(x-1,y) = cratemarkerblock) then
    DrawItem(x,y)
    x=x-1
 elseif crateboard(x-1,y) = crateblock then
    crateboard(x-1,y)=emptyblock
    crateboard(x-2,y)=crateblock
    board(x-1,y)=floorblock
    board(x-2,y)=emptyblock
    DrawItem(x-2,y)
    DrawItem(x,y)
    x=x-1
 end if
 DrawPusher()
end sub

sub GoUp()
 playerdirection=playerup
 if (board(x,y-1) = floorblock) or (board(x,y-1) = cratemarkerblock) then
    DrawItem(x,y)
    y=y-1
 elseif crateboard(x,y-1) = crateblock then
    crateboard(x,y-1)=emptyblock
    crateboard(x,y-2)=crateblock
    board(x,y-1)=floorblock
    board(x,y-2)=emptyblock
    DrawItem(x,y-2)
    DrawItem(x,y)
    y=y-1
 end if
 DrawPusher()
end sub

sub GoRight()
 playerdirection=playerright
 if (board(x+1,y) = floorblock) or (board(x+1,y) = cratemarkerblock) then
    DrawItem(x,y)
    x=x+1
 elseif crateboard(x+1,y) = crateblock then
    crateboard(x+1,y)=emptyblock
    crateboard(x+2,y)=crateblock
    board(x+1,y)=floorblock
    board(x+2,y)=emptyblock
    DrawItem(x+2,y)
    DrawItem(x,y)
    x=x+1
 end if
 DrawPusher()
end sub

sub GoDown()
 playerdirection=playerdown
 if (board(x,y+1) = floorblock) or (board(x,y+1) = cratemarkerblock) then
    DrawItem(x,y)
    y=y+1
 elseif crateboard(x,y+1) = crateblock then
    crateboard(x,y+1)=emptyblock
    crateboard(x,y+2)=crateblock
    board(x,y+1)=floorblock
    board(x,y+2)=emptyblock
    DrawItem(x,y+2)
    DrawItem(x,y)
    y=y+1
 end if
 DrawPusher()
end sub

sub ReadWall()
  restore WallLabel
  for i=0 to 65 
    read wall(i)
  next i  
end sub

sub ReadPusher()
  restore PusherLeftLabel
  for i=0 to 65 
    read pusherleft(i)
  next i  

  restore PusherRightLabel
  for i=0 to 65 
    read pusherright(i)
  next i  

  restore PusherUpLabel
  for i=0 to 65 
    read pusherup(i)
  next i  

  restore PusherDownLabel
  for i=0 to 65 
    read pusherdown(i)
  next i  
end sub

sub ReadCrate()
  restore CrateLabel
  for i=0 to 65 
    read crate(i)
  next i  
end sub

sub ReadCrateMarker()
  restore CrateMarkerLabel
  for i=0 to 65 
    read cratemarker(i)
  next i  
end sub

sub ReadFloor()
  restore FloorLabel
  for i=0 to 65 
    read floor(i)
  next i  
end sub

sub InitPalette()
  restore PalLabel
  for i=0 to 15
    read r,g,b
    Palette i,_BGR(b,g,r)
  next i
end sub

boardMapLabel:
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

crateLabel:
' BAM Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' crate
DATA 16,16,13107,13107,13107,13107,-30669,-30584,-30584,13192
DATA -30664,-30584,-30584,-31864,-31176,26214,26214,-31896,-31176,-30616
DATA -30618,-31896,-31176,-31096,-30616,-31896,-31176,26248,-31096,-31896
DATA -31176,26758,26248,-31896,-31176,-30618,26758,-31896,-31176,-30616
DATA -30618,-31896,-31176,-31096,-30616,-31896,-31176,26248,-31096,-31896
DATA -31176,26214,26214,-31896,-30664,-30584,-30584,-31864,-30669,-30584
DATA -30584,13192,13107,13107,13107,13107

crateMarkerLabel:
' BAM Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' crate_marker
DATA 16,16,13107,13107,13107,13107,-8909,13277,-8909,13277
DATA -8899,13277,-8909,-11299,-11459,13107,13107,-11459,-11459,13107
DATA 13107,-11459,-11459,13107,13107,-11459,13107,13107,13107,13107
DATA 13107,15667,13267,13107,13107,15667,13267,13107,13107,13107
DATA 13107,13107,-11459,13107,13107,-11459,-11459,13107,13107,-11459
DATA -11459,13107,13107,-11459,-8899,13277,-8909,-11299,-8909,13277
DATA -8909,13277,13107,13107,13107,13107

wallLabel:
' BAM Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' wall
DATA 16,16,30583,30583,30583,30583,8738,29218,17476,8743
DATA 8738,29218,8738,8743,8738,29218,8738,8743,30583,30583
DATA 30583,30583,10052,8738,29218,17476,10018,8738,29218,8738
DATA 10018,8738,29218,8738,30583,30583,30583,30583,8738,29218
DATA 17476,8743,8738,29218,8738,8743,8738,29218,8738,8743
DATA 30583,30583,30583,30583,10052,8738,29218,17476,10018,8738
DATA 29218,8738,10018,8738,29218,8738

FloorLabel:
' BAM Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' floor
DATA 16,16,13107,13107,13107,13107,13107,13107,13107,13107
DATA 13107,13107,13107,13107,13107,13107,13107,13107,13107,13107
DATA 13107,13107,13107,13107,13107,13107,13107,13107,13107,13107
DATA 13107,13107,13107,13107,13107,13107,13107,13107,13107,13107
DATA 13107,13107,13107,13107,13107,13107,13107,13107,13107,13107
DATA 13107,13107,13107,13107,13107,13107,13107,13107,13107,13107
DATA 13107,13107,13107,13107,13107,13107

PusherLeftLabel:
' BAM Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' pusher
DATA 16,16,13107,13107,13107,13107,13107,4401,4881,13107
DATA 13107,4369,4369,13107,12595,4539,4369,13075,4403,4529
DATA 4369,13073,4401,4369,4369,4881,4401,4369,4369,4881
DATA 4401,4369,4369,4881,4401,4374,4369,4881,-8851,-8746
DATA -8739,-11299,26214,-8858,-8739,-11299,-8899,-8739,-8739,13277
DATA 15667,-8739,-8739,13267,13107,-8739,-8739,13107,13107,-8899
DATA -11299,13107,26163,26214,13107,13107

PusherRightLabel:
' BAM Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' pusherright
DATA 16,16,13107,13107,13107,13107,13107,4401,4881,13107
DATA 13107,4369,4369,13107,12595,4369,-17647,13075,4403,4369
DATA 6929,13073,4401,4369,4369,4881,4401,4369,4369,4881
DATA 4401,4369,4369,4881,4401,4369,24849,4881,-8899,-8739
DATA 28125,-10531,-8899,-8739,26333,26214,-8909,-8739,-8739,-11299
DATA 15667,-8739,-8739,13267,13107,-8739,-8739,13107,13107,-8899
DATA -11299,13107,13107,13107,26214,13158

PusherUpLabel:
' BAM Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' pusherup
DATA 16,16,13158,13107,13107,26163,13155,4401,4881,13875
DATA 13155,4369,4369,13875,12643,4369,4369,13843,4451,4369
DATA 4369,13841,4449,4369,4369,5649,4449,4369,4369,5649
DATA 4449,4369,4369,5649,4401,4369,4369,4881,-8899,-8739
DATA -8739,-11299,-8899,-8739,-8739,-11299,-8899,-8739,-8739,13277
DATA 15667,-8739,-8739,13267,13107,-8739,-8739,13107,13107,-8899
DATA -11299,13107,13107,25446,26166,13107

PusherDownLabel:
' BAM Put Bitmap Code Created By Raster Master
' Size= 66 Width= 16 Height= 16 Colors= 16
' pusherdown
DATA 16,16,13107,25446,26166,13107,13107,-8899,-11299,13107
DATA 13107,-8739,-8739,13107,15667,-8739,-8739,13267,-8899,-8739
DATA -8739,13277,-8899,-8739,-8739,-11299,-8899,-8739,-8739,-11299
DATA 4401,4369,4369,4881,4449,4369,4369,5649,4449,4369
DATA 4369,5649,4449,4369,4369,5649,4451,4369,4369,13841
DATA 12643,4369,4369,13843,13155,4369,4369,13875,13155,4401
DATA 4881,13875,13158,13107,13107,26163

PalLabel:
'Palette,  Size= 48 Colors= 16 Format=8 Bit
DATA 0, 0, 0
DATA 63, 38, 49
DATA 139, 155, 180
DATA 234, 165, 108
DATA 192, 203, 220
DATA 38, 43, 68
DATA 118, 59, 54
DATA 82, 96, 124
DATA 189, 108, 74
DATA 207, 130, 84
DATA 247, 194, 130
DATA 255, 255, 255
DATA 67, 225, 179
DATA 232, 69, 55
DATA 225, 154, 101
DATA 255, 112, 109