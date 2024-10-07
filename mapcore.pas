unit mapcore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Const
  MaxListSize = 100;
  ZSizeDefaults : array of integer = (8,16,32,64,128,256);
  DefMaxMapWidth = 256;
  DefMaxMapHeight = 256;

  RMMapSig = 'RMM';
  RMMapVersion = 2;

  TileClear = -1;
  TileMissing = -2;


type

  TileRec = packed Record
              ImageUID : TGUID;
              ImageIndex : integer;
  end;

  MapClipBoardRec = Record
                   width,height : integer;  //width of copy / paste buffer
                   Status       : integer;  // 1 = data has been copied to buffer - do not paste if status is 0
                   Tile         : array[0..255,0..255] of TileRec;
                 end;

  MapHeaderRec = packed Record
                    SIG      : array[1..3] of char;
                    version  : word;
                    MapCount : word;
  end;


   MapClipAreaRec = Record
                     x,y,x2,y2 : integer;
                     status    : integer;
   end;

   MapScrollPosRec = Record
                     HorizPos : integer;
                     VirtPos  : integer;
   end;

  MapPropsRec = packed Record
             width : integer;
             height : integer;
             tilewidth : integer;
             tileheight : integer;
             ZoomTilewidth : integer;
             ZoomTileheight : integer;
             ZoomSize : integer;

             DrawTool : integer;
             TileMode : integer;
             GridStatus : integer; //0 = 0ff - 1=on
             ClipArea   : MapClipAreaRec;
             ScrollPos  : MapScrollPosRec;
  end;




  MapExportFormatRec = Packed Record
             Name            : String[20]; // user = RES file used in name/description, in Text output used in array name, for palettes we add pal to name
             Lan             : integer; // auto -ahould be for what compiler eg PascalLan,BasicLan,CLan
             MapFormat       : integer; // user - 0 = do not export, Map Format, 1 = Simple format
             Width           : integer; // map width overwrite - if not 0 use this value as width
             Height          : integer; // map height overwrite - if not 0 use this value as height
 end;

  MapRec = packed Record
             Props       : MapPropsRec;
             ExportProps : MapExportFormatRec;
             Tile : array of array of TileRec;
  end;

  TMapCoreBase = Class
                    Map        : array of MapRec;
                    UndoMap    : array of MapRec;
                    ClipBoard  : MapClipBoardRec;

                    CurrentMap : integer;
                    MapCount   : integer;

                    constructor Create;
                    procedure Init;


                    procedure SetListSize(size : integer);
                    procedure SetMapSize(index, mwidth,mheight : integer);
                    procedure ResizeMapSize(index, mwidth,mheight : integer);
                    procedure SetMapTileSize(index, twidth,theight : integer);
                    procedure SetZoomMapTileSize(index, twidth,theight : integer);

                    procedure SetMapScrollVertPos(index, value : integer);
                    function GetMapScrollVertPos(index : integer) : integer;
                    procedure SetMapScrollHorizPos(index, value : integer);
                    function GetMapScrollHorizPos(index : integer) : integer;
                    procedure SetMapDrawTool(index, value : integer);
                    function GetMapDrawTool(index : integer) : integer;
                    procedure SetMapGridStatus(index, value : integer);
                    function GetMapGridStatus(index : integer) : integer;
                    procedure SetMapClipStatus(index,mode : integer);
                    function  GetMapClipStatus(index : integer) : integer;
                    procedure GetMapClipAreaCoords(index : integer;var ca : MapClipAreaRec);
                    procedure  SetMapClipAreaCoords(index : integer;var ca : MapClipAreaRec);

                    procedure SetMapTileMode(index, value : integer);
                    function GetMapTileMode(index : integer) : integer;

                    Procedure Hflip(index,x,y,x2,y2: integer);
                    Procedure VFlip(index,x,y,x2,y2 : integer);
                    Procedure ScrollLeft(index,x,y,x2,y2 : integer);
                    Procedure ScrollRight(index,x,y,x2,y2 : integer);
                    Procedure ScrollUp(index,x,y,x2,y2 : integer);
                    Procedure ScrollDown(index,x,y,x2,y2 : integer);

                    Procedure CopyToUndo(index : integer);
                    Procedure Undo(index : integer);

                    procedure GetMapProps(index : integer;var props : MapPropsRec);
                    procedure SetMapProps(index : integer; props : MapPropsRec);

                    function GetExportHeight(index : integer) : integer;
                    function GetExportWidth(index : integer) : integer;
                    function GetExportName(index : integer) : string;

                    function GetExportMapCount : integer;

                    procedure GetMapExportProps(index : integer;var props : MapExportFormatRec);
                    procedure SetMapExportProps(index : integer; props : MapExportFormatRec);
                    procedure ClearExportProperties(index : integer);

                    function GetMapWidth(index : integer) : integer;
                    function GetMapHeight(index : integer) : integer;

                    function GetMapPageWidth(index : integer) : integer;  // in pixels
                    function GetMapPageHeight(index : integer) : integer; // in pixels

                    function GetZoomMapPageWidth(index : integer) : integer;  // in pixels
                    function GetZoomMapPageHeight(index : integer) : integer; // in pixels

                    function GetMapTileWidth(index : integer) : integer;
                    function GetMapTileHeight(index : integer) : integer;
                    function GetMapTileIndex(index,x,y : integer) : integer;

                    function GetZoomMapTileWidth(index : integer) : integer;
                    function GetZoomMapTileHeight(index : integer) : integer;

                    function GetZoomTileSize(ZoomSize : integer) : integer;

                    procedure SetMapTile(index,x,y : integer;var  Tile : TileRec);
                    procedure GetMapTile(index,x,y : integer;var Tile : TileRec);

                    procedure InitClipBoard;
                    procedure CopyToClipBoard(index,x,y,x2,y2 : integer);
                    procedure PasteFromClipBoard(index,x,y,x2,y2 : integer);

                    procedure SetCurrentMap(index : integer);
                    function GetCurrentMap : integer;

                    function GetMapCount : integer;
                    procedure SetMapCount(count : integer);

                    procedure DeleteMap(index : integer);
                    procedure InsertMap(index : integer);
                    procedure AddMap;
                    procedure CloneMap;


                    procedure SetZoomSize(index,size : integer);
                    function GetZoomSize(index : integer) : integer;

                    procedure ClearMap(index,value : integer);

              end;

var
 MapCoreBase : TMapCoreBase;

implementation


constructor TMapCoreBase.Create;
begin
  Init;
end;

procedure TMapCoreBase.Init;
begin
 SetCurrentMap(0);
 SetListSize(MaxListSize);
 SetZoomSize(0,4);
 //  SetMapSize(0,DefMaxMapWidth,DefMaxMapHeight);
 SetMapSize(0,16,16);
 SetMapTileSize(0,64,64);
 SetMapCount(1);
 SetMapGridStatus(0,1); //grid on
 SetMapClipStatus(0,0); //clip off
 SetMapDrawTool(0,1);  //pencil
 SetMapTileMode(0,1); //draw
 SetMapScrollVertPos(0,0);
 SetMapScrollHorizPos(0,0);
 CopyToUndo(0);     //copy map 0 to undo - to init it
 InitClipBoard;

end;

procedure TMapCoreBase.SetListSize(size : integer);
begin
 Setlength(Map,size);
 Setlength(UndoMap,size);
end;

Procedure TMapCoreBase.CopyToUndo(index : integer);
var
 i,j : integer;
begin
 for i:=0 to Map[index].Props.width-1 do
 begin
   for j:=0 to Map[index].Props.height-1 do
   begin
     UndoMap[index].Tile[i,j]:=Map[index].Tile[i,j];
   end;
 end;
end;

Procedure TMapCoreBase.Undo(index : integer);
var
 i,j : integer;
 TTile : TileRec;
begin
 for i:=0 to Map[index].Props.width-1 do
 begin
   for j:=0 to Map[index].Props.height-1 do
   begin
     TTile:=Map[index].Tile[i,j];
     Map[index].Tile[i,j]:=UndoMap[index].Tile[i,j];
     UndoMap[index].Tile[i,j]:=TTile;
   end;
 end;
end;

procedure TMapCoreBase.InitClipBoard;
begin
  ClipBoard.Status:=0;
end;

procedure TMapCoreBase.CopyToClipBoard(index,x,y,x2,y2 : integer);
var
 i,j   : integer;
 width,height : integer;
begin
 width:=abs(x2-x+1);
 if width > 256 then width:=256;
 height:=abs(y2-y+1);
 if height > 256 then height:=256;

 for i:=0 to width-1 do
 begin
   for j:=0 to height-1 do
   begin
     ClipBoard.Tile[i,j]:=Map[index].Tile[x+i,y+j];
   end;
 end;
 ClipBoard.width:=width;
 ClipBoard.height:=height;
 ClipBoard.Status:=1;
end;


procedure TMapCoreBase.PasteFromClipboard(index,x,y,x2,y2 : integer);
var
 i,j   : integer;
 width,height : integer;
begin
 if ClipBoard.Status = 0 then exit;
 width:=abs(x2-x+1);
 if ClipBoard.width < width then width:=ClipBoard.width;
 height:=abs(y2-y+1);
 if ClipBoard.height < height then height:=ClipBoard.height;

 for i:=0 to width-1 do
 begin
   for j:=0 to height-1 do
   begin
     Map[index].Tile[i+x,j+y]:=ClipBoard.Tile[i,j];
   end;
 end;
end;

procedure TMapCoreBase.SetZoomSize(index,size : integer);
begin
 Map[index].Props.ZoomSize:=size;
end;

function TMapCoreBase.GetZoomSize(index : integer) : integer;
begin
 GetZoomSize:=Map[index].Props.ZoomSize;
end;

procedure TMapCoreBase.GetMapExportProps(index : integer;var props : MapExportFormatRec);
begin
  props:=Map[index].ExportProps;
end;

procedure TMapCoreBase.SetMapExportProps(index : integer; props : MapExportFormatRec);
begin
  Map[index].ExportProps:=props;
end;

function TMapCoreBase.GetExportMapCount : integer;
var
 i : integer;
 Exportcount : integer;
begin
 ExportCount:=0;
 for i:=0 to GetMapCount-1 do
 begin
   if Map[i].ExportProps.MapFormat > 0 then inc(ExportCount);
 end;
 GetExportMapCount:=ExportCount;
end;

//if there is a custom width property (not 0) and less then props width
function TMapCoreBase.GetExportWidth(index : integer) : integer;
var
 width : integer;
begin
  Width:=Map[index].Props.Width;
  if (Map[index].ExportProps.Width > 0) AND (Map[index].ExportProps.Width < Map[index].Props.Width) then
  begin
     Width:=Map[index].ExportProps.Width;
  end;
  GetExportWidth:=Width;
end;

//if there is a custom height property (not 0) and less then props height
function TMapCoreBase.GetExportHeight(index : integer) : integer;
var
  height : integer;
begin
 Height:=Map[index].Props.Height;
 if (Map[index].ExportProps.Height > 0) AND (Map[index].ExportProps.Height < Map[index].Props.Height) then
 begin
    Height:=Map[index].ExportProps.Height;
 end;
 GetExportHeight:=Height;
end;

function TMapCoreBase.GetExportName(index : integer) : string;
begin
  result:=Map[index].ExportProps.Name;
end;


procedure TMapCoreBase.ClearExportProperties(index : integer);
begin
  Map[index].ExportProps.MapFormat:=0;
  Map[index].ExportProps.Lan:=0;
  Map[index].ExportProps.width:=0;
  Map[index].ExportProps.height:=0;
  Map[index].ExportProps.name:='Map'+IntToStr(index+1);
end;

procedure TMapCoreBase.SetMapSize(index, mwidth,mheight : integer);
begin
 Map[index].Props.width:=mwidth;
 Map[index].Props.height:=mheight;
 ClearExportProperties(index);

 SetLength(Map[index].Tile,DefMaxMapWidth,DefMaxMapHeight);
 SetLength(UndoMap[index].Tile,DefMaxMapWidth,DefMaxMapHeight);

 ClearMap(index,TileClear);
end;

procedure TMapCoreBase.ResizeMapSize(index, mwidth,mheight : integer);
begin
  Map[index].Props.width:=mwidth;
  Map[index].Props.height:=mheight;
end;


procedure TMapCoreBase.SetMapScrollVertPos(index, value : integer);
begin
  Map[index].Props.ScrollPos.VirtPos:=value;
end;

function TMapCoreBase.GetMapScrollVertPos(index : integer) : integer;
begin
  result:=Map[index].Props.ScrollPos.VirtPos;
end;

procedure TMapCoreBase.SetMapTileMode(index, value : integer);
begin
  Map[index].Props.TileMode:=value;
end;

function TMapCoreBase.GetMapTileMode(index : integer) : integer;
begin
  result:=Map[index].Props.TileMode;
end;



procedure TMapCoreBase.SetMapScrollHorizPos(index, value : integer);
begin
  Map[index].Props.ScrollPos.HorizPos:=value;
end;

function TMapCoreBase.GetMapScrollHorizPos(index : integer) : integer;
begin
  result:=Map[index].Props.ScrollPos.HorizPos;
end;

procedure TMapCoreBase.SetMapDrawTool(index, value : integer);
begin
  Map[index].Props.DrawTool:=value;
end;

function TMapCoreBase.GetMapDrawTool(index : integer) : integer;
begin
  result:=Map[index].Props.DrawTool;
end;

procedure TMapCoreBase.SetMapGridStatus(index, value : integer);
begin
  Map[index].Props.GridStatus:=value;
end;

function TMapCoreBase.GetMapGridStatus(index : integer) : integer;
begin
  result:=Map[index].Props.GridStatus;
end;



procedure TMapCoreBase.SetMapClipStatus(index,mode : integer);
begin
   Map[index].Props.ClipArea.status:=mode;
end;

function TMapCoreBase.GetMapClipStatus(index : integer) : integer;
begin
  result:=Map[index].Props.ClipArea.status;
end;

procedure TMapCoreBase.GetMapClipAreaCoords(index : integer;var ca : MapClipAreaRec);
begin
 if Map[index].Props.ClipArea.status = 1 then
 begin
   ca:=Map[index].Props.ClipArea;
 end
 else                //no select region so we return the entire map area
 begin
   ca.x:=0;
   ca.y:=0;
   ca.x2:=Map[index].Props.Width-1;
   ca.y2:=Map[index].Props.Height-1;
 end;
end;

procedure  TMapCoreBase.SetMapClipAreaCoords(index : integer;var ca : MapClipAreaRec);
var
  temp : integer;
begin
  if ca.x > ca.x2 then
  begin
    temp:=ca.x;
    ca.x:=ca.x2;
    ca.x2:=temp;
  end;
  if ca.y > ca.y2 then
  begin
    temp:=ca.y;
    ca.y:=ca.y2;
    ca.y2:=temp;
  end;
  Map[index].Props.ClipArea:=ca;
end;

Procedure TMapCoreBase.Hflip(index,x,y,x2,y2: integer);
Var
 i,j : integer;
 L   : integer;
 C,C2 : TileRec;
   A  : integer;
begin
  L :=(x2-x) Div 2;
  A :=x2;
  For i:=x to (x2-L-1) do
  begin
    For j:=y to y2 do
    begin
     GetMapTile(index,i,j,C);
     GetMapTile(index,A,j,C2);
     SetMapTile(index,i,j,C2);
     SetMapTile(index,A,j,C);
    end;
    Dec(A);
  end;

end;

Procedure TMapCoreBase.VFlip(index,x,y,x2,y2 : integer);
Var
 i,j : integer;
 L   : integer;
 C,C2 : TileRec;
 A  : integer;
begin
  L :=(y2-y) Div 2;
  A :=y2;
  For j:=y to (y2-L-1) do
  begin
    For i:=x to x2 do
    begin
     GetMapTile(index,i,j,C);
     GetMapTile(index,i,A,C2);
     SetMapTile(index,i,j,C2);
     SetMapTile(index,i,A,C);
    end;
    Dec(A);
  end;
end;

Procedure TMapCoreBase.ScrollLeft(index,x,y,x2,y2 : integer);
Var
 i,j : integer;
   c,d : TileRec;
begin
 For j:=y to y2 do
 begin
   GetMapTile(index,x,j,d);
   For i:=x+1 to x2 do
   begin
     GetMapTile(index,i,j,c);
     SetMapTile(index,i-1,j,c);
   end;
   SetMapTile(index,x2,J,d);
 end;
end;

Procedure TMapCoreBase.ScrollRight(index,x,y,x2,y2 : integer);
Var
 i,j : integer;
   c,d : TileRec;
begin
 For j:=y to y2 do
 begin
   GetMapTile(index,x2,j,d);
   For i:=x2-1 downto x do
   begin
     GetMapTile(index,i,j,c);
     SetMapTile(index,i+1,j,c);
   end;
     SetMapTile(index,x,j,d);
 end;
end;

Procedure TMapCoreBase.ScrollUp(index,x,y,x2,y2 : integer);
Var
 i,j : integer;
   c,d : TileRec;
begin
 For i:=x to x2 do
 begin
   GetMapTile(index,i,y,d);
   For j:=y to y2-1 do
   begin
     GetMapTile(index,i,j+1,c);
     SetMapTile(index,i,j,c);
   end;
   SetMapTile(index,i,y2,d);
 end;
end;

Procedure TMapCoreBase.ScrollDown(index,x,y,x2,y2 : integer);
Var
 i,j  : integer;
   c,d : TileRec;
begin
 For i:=x to x2 do
 begin
   GetMapTile(index,i,y2,d);
   For j:=y2  downto y+1 do
   begin
     GetMapTile(index,i,j-1,c);
     SetMapTile(index,i,j,c);
   end;
   SetMapTile(index,i,y,d);
 end;
end;

procedure TMapCoreBase.ClearMap(index, value : integer);
var
 i,j : integer;
begin
 For j:=0 to DefMaxMapWidth-1 do
 begin
   For i:=0 to DefMaxMapHeight-1 do
  begin
//       Map[index].Tile[i,j].ImageUID:='';
       Map[index].Tile[i,j].ImageIndex:=value;
   end;
 end;
end;

procedure TMapCoreBase.SetMapTileSize(index, twidth,theight : integer);
var
  zsize : integer;
begin
  Map[index].Props.TileWidth:=twidth;
  Map[index].Props.TileHeight:=theight;
  zsize:=GetZoomTileSize(Map[index].Props.ZoomSize);
  SetZoomMapTileSize(index,zsize,zsize);
end;

procedure TMapCoreBase.SetZoomMapTileSize(index, twidth,theight : integer);
begin
  Map[index].Props.ZoomTileWidth:=twidth;
  Map[index].Props.ZoomTileHeight:=theight;
end;


//returns how big the tile will be when zoom is applied
function TMapCoreBase.GetZoomTileSize(ZoomSize : integer) : integer;
var
 i : integer;
 size : integer;
begin
 size:=8;
 for i:=1 to ZoomSize-1 do
 begin
   size:=size+size;
 end;
 GetZoomTileSize:=size;
end;


procedure TMapCoreBase.GetMapProps(index : integer;var props : MapPropsRec);
begin
   props:=Map[index].Props;
end;

procedure TMapCoreBase.SetMapProps(index : integer; props : MapPropsRec);
begin
   Map[index].Props:=props;
end;

function TMapCoreBase.GetMapWidth(index : integer) : integer;
begin
  GetMapWidth:=Map[index].Props.width;
end;

function TMapCoreBase.GetMapHeight(index : integer) : integer;
begin
  GetMapHeight:=Map[index].Props.height;
end;

function TMapCoreBase.GetZoomMapTileWidth(index : integer) : integer;
begin
  GetZoomMapTileWidth:=Map[index].Props.ZoomTilewidth;
end;

function TMapCoreBase.GetZoomMapTileHeight(index : integer) : integer;
begin
  GetZoomMapTileHeight:=Map[index].Props.ZoomTileHeight;
end;


function TMapCoreBase.GetMapPageWidth(index : integer) : integer;
begin
  GetMapPageWidth:=Map[index].Props.width*Map[index].Props.TileWidth;
end;

function TMapCoreBase.GetMapPageHeight(index : integer) : integer;
begin
  GetMapPageHeight:=Map[index].Props.height*Map[index].Props.TileHeight;
end;

function TMapCoreBase.GetZoomMapPageWidth(index : integer) : integer;
begin
  GetZoomMapPageWidth:=Map[index].Props.width*Map[index].Props.ZoomTileWidth;
end;

function TMapCoreBase.GetZoomMapPageHeight(index : integer) : integer;
begin
  GetZoomMapPageHeight:=Map[index].Props.height*Map[index].Props.ZoomTileHeight;
end;


function TMapCoreBase.GetMapTileWidth(index : integer) : integer;
begin
  GetMapTileWidth:=Map[index].Props.TileWidth;
end;

function TMapCoreBase.GetMapTileHeight(index : integer) : integer;
begin
  GetMapTileHeight:=Map[index].Props.TileHeight;
end;

function TMapCoreBase.GetMapTileIndex(index,x,y : integer) : integer;
begin
 if (x < 0) or (x >= Map[index].Props.width) or (y < 0) or (y >= Map[index].Props.height) then
   result:=-1000
 else
   result:=Map[index].Tile[x,y].ImageIndex;
end;

procedure TMapCoreBase.SetMapTile(index,x,y : integer; var Tile : TileRec);
begin
 if (x < 0) or (x >= Map[index].Props.width) or (y < 0) or (y >= Map[index].Props.height) then exit;
 Map[index].Tile[x,y]:=Tile;
 //  Move(Tile,Map[index].Tile[x,y],sizeof(Tile));
end;

procedure TMapCoreBase.GetMapTile(index,x,y : integer;var Tile : TileRec);
begin
 if (x < 0) or (x >= Map[index].Props.width) or (y < 0) or (y >= Map[index].Props.height) then exit;
 Tile:=Map[index].Tile[x,y];
 // Move(Map[index].Tile[x,y],Tile,sizeof(Tile));
end;

procedure TMapCoreBase.SetCurrentMap(index : integer);
begin
  CurrentMap:=index;
end;

function TMapCoreBase.GetCurrentMap : integer;
begin
  GetCurrentMap:=CurrentMap;
end;

function TMapCoreBase.GetMapCount : integer;
begin
  GetMapCount:=MapCount;
end;

procedure TMapCoreBase.SetMapCount(count : integer);
begin
  MapCount:=count;
end;

//makes index ares available to clear and resize to place map in location
procedure TMapCoreBase.InsertMap(index : integer);
var
 i : integer;
begin
 if (index < 0) OR (index > (MapCount-1)) then exit;
 inc(MapCount);
 for i:=MapCount-1 downto index+1 do
 begin
    Map[i]:=Map[i-1];
 end;
end;

procedure TMapCoreBase.DeleteMap(index : integer);
var
 i : integer;
begin
 if (index < 0)  then exit;
 for i:=index to MapCount-2  do
 begin
   Map[i]:=Map[i+1];
 end;
 SetMapSize(MapCount-1,0,0);
 dec(MapCount);
end;

procedure TMapCoreBase.AddMap;  //adds image to end of list - there must atleast one map
var
 props : MapPropsRec;
 ExportProps : MapExportFormatRec;
 Lan,Format  : integer;
begin
 if (MapCount=0) or (MapCount >= MaxListSize) then exit;
 inc(MapCount);

 //copy properties from map 0
 GetMapProps(0,props);
 SetMapProps(MapCount-1,props);
 SetMapSize(MapCount-1,props.width,props.height);


 //copy Lan and Format settings from Map 0
 GetMapExportProps(0,ExportProps);
 Lan:=ExportProps.Lan;
 Format:=ExportProps.MapFormat;
 GetMapExportProps(MapCount-1,ExportProps);
 ExportProps.Lan:=Lan;
 ExportProps.MapFormat:=Format;
 SetMapExportProps(MapCount-1,ExportProps);
end;

procedure TMapCoreBase.CloneMap;  //clones current map
var
 props : MapPropsRec;
 ExportProps : MapExportFormatRec;
 i,j : integer;
 Tile : TileRec;
begin
 if (MapCount=0) or (MapCount >= MaxListSize) then exit;
 inc(MapCount);

 //copy properties from current map
 GetMapProps(CurrentMap,props);
 SetMapProps(MapCount-1,props);
 SetMapSize(MapCount-1,props.width,props.height);

 //copy Lan and Format settings from current Map
 GetMapExportProps(CurrentMap,ExportProps);
 SetMapExportProps(MapCount-1,ExportProps);

 For j:=0 to props.height-1 do
 begin
   For i:=0 to props.width-1 do
   begin
    GetMapTile(CurrentMap,i,j,Tile);
    SetMapTile(MapCount-1,i,j,Tile);
   end;
 end;
end;

begin
  MapCoreBase:=TMapCoreBase.Create;
end.

