unit mapcore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Const
  MaxListSize = 100;
  ZSizeDefaults : array of integer = (8,16,32,64,128,256);
  DefMaxMapWidth = 64;
  DefMaxMapHeight = 64;

  RMMapSig = 'RMM';
  RMMapVersion = 1;
type

  TileRec = packed Record
              ImageUID : TGUID;
              ImageIndex : integer;
  end;

  MapHeaderRec = packed Record
                    SIG      : array[1..3] of char;
                    version  : word;
                    MapCount : word;
  end;

  MapPropsRec = packed Record
             width : integer;
             height : integer;
             tilewidth : integer;
             tileheight : integer;
             ZoomTilewidth : integer;
             ZoomTileheight : integer;

             ZoomSize : integer;

  end;

  MapRec = packed Record
             Props : MapPropsRec;
             Tile : array of array of TileRec;
  end;

  TMapCoreBase = Class
                    Map        : array of MapRec;
                    CurrentMap : integer;
                    MapCount   : integer;
                    constructor Create;


                    procedure SetListSize(size : integer);

                    procedure SetMapSize(index, mwidth,mheight : integer);
                    procedure ResizeMap(index, mwidth,mheight : integer);
                    procedure SetMapTileSize(index, twidth,theight : integer);
                    procedure SetZoomMapTileSize(index, twidth,theight : integer);

                    procedure GetMapProps(index : integer;var props : MapPropsRec);
                    procedure SetMapProps(index : integer; props : MapPropsRec);

                    function GetMapWidth(index : integer) : integer;
                    function GetMapHeight(index : integer) : integer;

                    function GetMapPageWidth(index : integer) : integer;  // in pixels
                    function GetMapPageHeight(index : integer) : integer; // in pixels

                    function GetZoomMapPageWidth(index : integer) : integer;  // in pixels
                    function GetZoomMapPageHeight(index : integer) : integer; // in pixels

                    function GetMapTileWidth(index : integer) : integer;
                    function GetMapTileHeight(index : integer) : integer;

                    function GetZoomMapTileWidth(index : integer) : integer;
                    function GetZoomMapTileHeight(index : integer) : integer;

                    function GetZoomTileSize(ZoomSize : integer) : integer;

                    procedure SetMapTile(index,x,y : integer; Tile : TileRec);
                    procedure GetMapTile(index,x,y : integer;var Tile : TileRec);

                    procedure SetCurrentMap(index : integer);
                    function GetCurrentMap : integer;

                    function GetMapCount : integer;
                    procedure SetMapCount(count : integer);

                    procedure DeleteMap(index : integer);
                    procedure InsertMap(index : integer);
                    procedure AddMap;


                    procedure SetZoomSize(index,size : integer);
                    function GetZoomSize(index : integer) : integer;

                    procedure ClearMap(index,value : integer);

              end;

var
 MapCoreBase : TMapCoreBase;

implementation


constructor TMapCoreBase.Create;
begin
  SetCurrentMap(0);
  SetListSize(MaxListSize);
  SetZoomSize(0,4);
  //  SetMapSize(0,DefMaxMapWidth,DefMaxMapHeight);
  SetMapSize(0,16,16);
  SetMapTileSize(0,64,64);
  SetMapCount(1);
end;


procedure TMapCoreBase.SetListSize(size : integer);
begin
 Setlength(Map,size);
end;

procedure TMapCoreBase.SetZoomSize(index,size : integer);
begin
 Map[index].Props.ZoomSize:=size;
end;

function TMapCoreBase.GetZoomSize(index : integer) : integer;
begin
 GetZoomSize:=Map[index].Props.ZoomSize;
end;

procedure TMapCoreBase.SetMapSize(index, mwidth,mheight : integer);
begin
 Map[index].Props.width:=mwidth;
 Map[index].Props.height:=mheight;
 SetLength(Map[index].Tile,DefMaxMapWidth,DefMaxMapHeight);
 ClearMap(index,-1);
end;

procedure TMapCoreBase.ResizeMap(index, mwidth,mheight : integer);
begin
 Map[index].Props.width:=mwidth;
 Map[index].Props.height:=mheight;
end;

procedure TMapCoreBase.ClearMap(index, value : integer);
var
 i,j : integer;
begin
 For j:=0 to DefMaxMapWidth-1 do
 begin
   For i:=0 to DefMaxMapHeight-1 do
  begin
//       Map[index].Tile[i,j].ImageUID:=0;
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


procedure TMapCoreBase.SetMapTile(index,x,y : integer; Tile : TileRec);
begin
 if (x < 0) or (x >= Map[index].Props.width) or (y < 0) or (y >= Map[index].Props.height) then exit;
 Map[index].Tile[x,y]:=Tile;
end;

procedure TMapCoreBase.GetMapTile(index,x,y : integer;var Tile : TileRec);
begin
 if (x < 0) or (x >= Map[index].Props.width) or (y < 0) or (y >= Map[index].Props.height) then exit;
 Tile:=Map[index].Tile[x,y];
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
begin
 if (MapCount=0) or (MapCount >= MaxListSize) then exit;
 inc(MapCount);

 //copy properties from map 0
 GetMapProps(0,props);
 SetMapProps(MapCount-1,props);
 SetMapSize(MapCount-1,props.width,props.height);
end;

begin
  MapCoreBase:=TMapCoreBase.Create;
end.

