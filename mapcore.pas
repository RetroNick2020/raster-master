//=============================================================================
// CHANGE LOG (Claude edits - newest first)
//-----------------------------------------------------------------------------
// 2026-08-03  MAP LAYERS - phase 1 (data model)
//   * RMMapVersion 3 -> 4. BREAKING: v3 files can no longer be read.
//   * Added MaxMapLayers (fixed cap) and TLayerInfoRec (name/visible/locked).
//   * MapPropsRec gained LayerCount, CurrentLayer, Layers[] and a Reserved
//     block. Because MapPropsRec is BlockWrite/BlockRead wholesale, layer
//     state is saved and loaded with no extra file IO code.
//   * MapClipAreaRec / MapScrollPosRec are now packed (they were plain
//     records nested inside a packed record - harmless today because they
//     are all-integer, but it would bite the moment a byte was added).
//   * MapRec.Tile is now indexed by layer. Layer tile arrays are allocated
//     lazily, so a 1 layer map uses exactly the memory it used before.
//   * GetMapTile/SetMapTile/GetMapTileIndex keep their old signatures and
//     now act on the map's CurrentLayer, so every existing call site keeps
//     working unchanged. The new ...L variants take an explicit layer and
//     are for the renderer, the file writer and the exporters.
//=============================================================================

unit mapcore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Const
  MaxListSize = 100;
  MaxHitBoxes = 100;
  ZSizeDefaults : array of integer = (8,16,32,64,128,256);
  DefMaxMapWidth = 256;
  DefMaxMapHeight = 256;

  RMMapSig = 'RMM';
  RMMapVersion = 5;   // v5 = path lines. v4 = layers. BREAKING each time.

  //Fixed layer cap. Deliberately small: typical maps use 2-3 layers, and an
  //unbounded count would only make the UI confusing and the renderer slow.
  MaxMapLayers = 8;

  //Path lines. Fixed arrays like the hitboxes, so path data saves with the
  //same single BlockWrite and needs no variable length parsing.
  //Multi level undo for maps. A level snapshots only the map's ACTUAL width
  //x height across the layers in use - not the full 256x256 allocation - so a
  //32x32 two layer map costs about 40KB a level rather than 2.6MB.
  MaxMapUndoLevels = 16;

  MaxPaths      = 32;
  MaxPathPoints = 64;

  //PathRec.mode - how a follower walks the path
  PathModeOnce     = 0;   //run to the end and stop
  PathModeLoop     = 1;   //jump back to the first point
  PathModePingPong = 2;   //walk back down the list

  //8 direction snap results (index into PathDirX/PathDirY below)
  PathDirE  = 0;
  PathDirNE = 1;
  PathDirN  = 2;
  PathDirNW = 3;
  PathDirW  = 4;
  PathDirSW = 5;
  PathDirS  = 6;
  PathDirSE = 7;

  //Screen space: y grows downward, so N is -1. Exported movement can use
  //these directly as per frame steps - that is the whole point of snapping
  //to 8 directions, every step is a signed add with no fixed point maths.
  PathDirX : array[0..7] of integer = ( 1, 1, 0,-1,-1,-1, 0, 1);
  PathDirY : array[0..7] of integer = ( 0,-1,-1,-1, 0, 1, 1, 1);

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
                      LayerCount   : integer;  //how many layers were copied
                      //true when only one layer was copied. Such a paste goes
                      //to the DESTINATION's current layer, so a layer can be
                      //copied from one layer and pasted onto another.
                      SingleLayer  : boolean;
                      //One grid per layer. Dynamic rather than a fixed
                      //[0..7,0..255,0..255] array, which would sit at 10MB
                      //resident for a clipboard that is usually a few tiles.
                      Tile         : array[0..MaxMapLayers-1] of array of array of TileRec;
                    end;

  MapHeaderRec = packed Record
                   SIG      : array[1..3] of char;
                   version  : word;
                   MapCount : word;
                 end;


   MapClipAreaRec = packed Record
                      x,y,x2,y2 : integer;
                      status    : integer;
                    end;

   MapScrollPosRec = packed Record
                       HorizPos : integer;
                       VirtPos  : integer;
                     end;

   //Per layer metadata. Fixed size so it can live inside MapPropsRec and be
   //written with the same single BlockWrite the props already use.
   TLayerInfoRec = packed Record
                     Name     : string[31];           //32 bytes
                     Visible  : boolean;              // 1
                     Locked   : boolean;              // 1
                     Reserved : array[0..5] of byte;  // 6  -> 40 total
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

                  //--- layers (added v4) ---
                  LayerCount   : integer;
                  CurrentLayer : integer;
                  Layers       : array[0..MaxMapLayers-1] of TLayerInfoRec;

                  //Spare space so future additions (parallax factor, layer
                  //type, ...) do not force another file format break.
                  Reserved     : array[0..63] of byte;
                end;




  MapExportFormatRec = Packed Record
                         Name            : String[20]; // user = RES file used in name/description, in Text output used in array name, for palettes we add pal to name
                         Lan             : integer; // auto -ahould be for what compiler eg PascalLan,BasicLan,CLan
                         MapFormat       : integer; // user - 0 = do not export, Map Format, 1 = Simple format
                         Width           : integer; // map width overwrite - if not 0 use this value as width
                         Height          : integer; // map height overwrite - if not 0 use this value as height
                       end;

  HitBoxRec = packed Record
                active    : boolean;
                id,value  : integer;   //not used currently but in future we can specify what kind of hitbox area it is.
                x,y,x2,y2 : integer;   //right now meant for collision detection (walls, water, fire). this can already be done by checking tile id but this allows checking an entire region instead of tile Image Index
              end;

  HitBoxesRec = packed Record
                  HitBoxCount : integer;
                  HitBoxes : array[0..MaxHitBoxes-1] of HitBoxRec;
                end;

  //One waypoint. Coordinates are TILE coordinates, not pixels - that matches
  //the hitboxes and survives a change to the map's tile size. Pixel centres
  //are worked out at export time, so the runtime never multiplies.
  PathPointRec = packed Record
                   x,y   : integer;   //tile coordinate of the waypoint
                   delay : integer;   //frames to pause on arrival (0 = none)
                   id    : integer;   //user event/trigger id, unused for now
                   spare : integer;   //reserved
                 end;

  PathRec = packed Record
              //active = real data, and is what export honours.
              //visible = editing aid only. Keep these separate: hiding a path
              //to draw over that area must never drop it from a build.
              active     : boolean;
              visible    : boolean;
              closed     : boolean;   //last point joins back to the first
              mode       : integer;   //PathModeOnce / Loop / PingPong
              speed      : integer;   //default step speed, 0 = unset
              id,value   : integer;   //spare, mirrors HitBoxRec
              Name       : string[15];
              PointCount : integer;
              Points     : array[0..MaxPathPoints-1] of PathPointRec;
            end;

  PathsRec = packed Record
               PathCount : integer;
               Paths : array[0..MaxPaths-1] of PathRec;
             end;

  //One undo snapshot. Not part of MapRec: MapRec is BlockWrite'd to file, so
  //anything added there would change the file format.
  TMapUndoLevel = Record
                    Tiles      : array[0..MaxMapLayers-1] of array of array of TileRec;
                    HitBoxes   : HitBoxesRec;
                    Paths      : PathsRec;
                    LayerCount : integer;
                    Width      : integer;
                    Height     : integer;
                  end;

  //Clipboards for copying a single layer, hitbox or path - separate from the
  //tile clipboard so copying a layer never clobbers a copied region.
  //SrcMap is remembered because pasting back into the SAME map has to behave
  //differently from pasting into another one.
  TLayerClip = Record
                 Valid   : boolean;
                 SrcMap  : integer;
                 W,H     : integer;
                 Name    : string[31];
                 Visible : boolean;
                 Locked  : boolean;
                 Tiles   : array of array of TileRec;
               end;

  THitBoxClip = Record
                  Valid  : boolean;
                  SrcMap : integer;
                  HB     : HitBoxRec;
                end;

  TPathClip = Record
                Valid  : boolean;
                SrcMap : integer;
                P      : PathRec;
              end;

  TMapUndoStack = Record
                    Levels    : array[0..MaxMapUndoLevels-1] of TMapUndoLevel;
                    Scratch   : TMapUndoLevel;
                    Head      : integer;
                    Depth     : integer;
                    RedoDepth : integer;
                  end;


  MapRec = packed Record
             Props       : MapPropsRec;
             ExportProps : MapExportFormatRec;
             HitBoxProps : HitBoxesRec;
             PathProps   : PathsRec;
             //One tile grid per layer. Only layers 0..Props.LayerCount-1 are
             //allocated - see AllocLayer - so unused layers cost nothing.
             Tile        : array[0..MaxMapLayers-1] of array of array of TileRec;
           end;



  TMapCoreBase = Class
                    Map        : array of MapRec;
                    UndoMap    : array of MapRec;
                    //One undo ring per map. Kept out of MapRec because
                    //MapRec is written straight to file.
                    MapUndo    : array of TMapUndoStack;
                    ClipBoard  : MapClipBoardRec;
                    LayerClip  : TLayerClip;
                    HitBoxClip : THitBoxClip;
                    PathClip   : TPathClip;

                    CurrentMap : integer;
                    MapCount   : integer;

                    constructor Create;
                    procedure Init;
                    procedure InitHitBox;


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
                    Procedure Redo(index : integer);
                    Procedure ClearUndo(index : integer);
                    function  CanUndo(index : integer) : boolean;
                    function  CanRedo(index : integer) : boolean;
                    Procedure CaptureUndoLevel(index : integer;var L : TMapUndoLevel);
                    Procedure RestoreUndoLevel(index : integer;var L : TMapUndoLevel);

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

                    //--- layers (v4) ---------------------------------------
                    //--- path lines -----------------------------------------
                    procedure ClearPaths(index : integer);
                    function  GetPathCount(index : integer) : integer;
                    procedure SetPathCount(index,count : integer);
                    function  AddPath(index : integer) : integer;
                    procedure DeletePath(index,p : integer);
                    function  IsValidPath(index,p : integer) : boolean;

                    procedure GetPath(index,p : integer;var Path : PathRec);
                    procedure SetPath(index,p : integer;var Path : PathRec);

                    function  GetPathActive(index,p : integer) : boolean;
                    procedure SetPathActive(index,p : integer;value : boolean);
                    function  GetPathVisible(index,p : integer) : boolean;
                    procedure SetPathVisible(index,p : integer;value : boolean);
                    function  GetPathClosed(index,p : integer) : boolean;
                    procedure SetPathClosed(index,p : integer;value : boolean);
                    function  GetPathMode(index,p : integer) : integer;
                    procedure SetPathMode(index,p,value : integer);
                    function  GetPathName(index,p : integer) : string;
                    procedure SetPathName(index,p : integer;const value : string);

                    function  GetPathPointCount(index,p : integer) : integer;
                    procedure GetPathPoint(index,p,pt : integer;var Point : PathPointRec);
                    procedure SetPathPoint(index,p,pt : integer;var Point : PathPointRec);
                    function  AddPathPoint(index,p,x,y : integer) : integer;
                    procedure DeletePathPoint(index,p,pt : integer);

                    //Move a whole path or hitbox. Whole object only: shifting
                    //every waypoint by the same amount keeps every segment on
                    //its 8 direction axis, whereas moving one waypoint would
                    //create an arbitrary angle that cannot be exported.
                    procedure MovePath(index,p,dx,dy : integer);
                    function  PathHitTest(index,tx,ty,tol : integer) : integer;

                    //8 direction snapping - see implementation notes
                    procedure SnapTo8(index,ax,ay,cx,cy : integer;var nx,ny : integer);
                    function  DirectionBetween(ax,ay,bx,by : integer) : integer;

                    //Builds the exported flat path array for a map. Shared by
                    //every exporter so they cannot drift apart - the layout is
                    //documented on the implementation.
                    //vals is longint, not integer: rres is {$MODE TP} where
                    //integer is 16 bit, and a var open array parameter has to
                    //match the element type exactly.
                    function  BuildPathExportArray(index : integer;
                                var vals : array of longint) : integer;
                    function  PathExportCount(index : integer) : integer;
                    //How many maps contribute a path resource. The RES header
                    //is sized from this, so it must agree with the header and
                    //data passes exactly.
                    function  GetExportPathCount : integer;

                    procedure ResetMapState(index : integer);
                    procedure AllocLayer(index,layer : integer);
                    function  IsValidLayer(index,layer : integer) : boolean;

                    function  GetLayerCount(index : integer) : integer;
                    procedure SetLayerCount(index,count : integer);
                    function  GetCurrentLayer(index : integer) : integer;
                    procedure SetCurrentLayer(index,layer : integer);

                    function  GetLayerVisible(index,layer : integer) : boolean;
                    procedure SetLayerVisible(index,layer : integer;value : boolean);
                    function  GetLayerLocked(index,layer : integer) : boolean;
                    procedure SetLayerLocked(index,layer : integer;value : boolean);
                    function  GetLayerName(index,layer : integer) : string;
                    procedure SetLayerName(index,layer : integer;const value : string);

                    function  AddLayer(index : integer) : integer;
                    procedure DeleteLayer(index,layer : integer);
                    procedure MoveLayer(index,layer,direction : integer);
                    procedure ClearLayer(index,layer,value : integer);

                    //Explicit layer tile access - for the renderer, the file
                    //writer and the exporters. Everything else should use the
                    //plain GetMapTile/SetMapTile which act on CurrentLayer.
                    procedure GetMapTileL(index,layer,x,y : integer;var Tile : TileRec);
                    procedure SetMapTileL(index,layer,x,y : integer;var Tile : TileRec);
                    function  GetMapTileIndexL(index,layer,x,y : integer) : integer;

                    function GetZoomMapTileWidth(index : integer) : integer;
                    function GetZoomMapTileHeight(index : integer) : integer;

                    function GetZoomTileSize(ZoomSize : integer) : integer;

                    procedure SetMapTile(index,x,y : integer;var  Tile : TileRec);
                    procedure GetMapTile(index,x,y : integer;var Tile : TileRec);

                    procedure InitClipBoard;
                    procedure CopyToClipBoard(index,x,y,x2,y2 : integer);
                    procedure CopyLayerToClipBoard(index,x,y,x2,y2 : integer);

                    //Copy / paste of a whole layer, hitbox or path. Paste
                    //returns the new index, or -1 if it could not be done.
                    procedure CopyLayerClip(index,layer : integer);
                    function  PasteLayerClip(index : integer) : integer;
                    function  HasLayerClip : boolean;

                    procedure CopyHitBoxClip(index,hb : integer);
                    function  PasteHitBoxClip(index : integer) : integer;
                    function  HasHitBoxClip : boolean;

                    procedure CopyPathClip(index,p : integer);
                    function  PastePathClip(index : integer) : integer;
                    function  HasPathClip : boolean;
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
                    function IsMapCustomSize(index : integer) : boolean;

                    procedure DeleteHitBox(index,HBIndex : integer);
                    procedure MoveHitBox(index,hb,dx,dy : integer);
                    function  IsValidHitBox(index,hb : integer) : boolean;
                    function  HitBoxHitTest(index,tx,ty : integer) : integer;
                    procedure AddHitBox(index,x,y,x2,y2 : integer);
                    procedure EditHitBox(index,HBIndex,x,y,x2,y2 : integer);
                    function  GetHitBoxCount(index : integer) : integer;
                    procedure SetHitBoxCount(index,count : integer);

                    procedure GetHitBox(index,HBIndex : integer;var HB : HitBoxRec);
                    procedure SetHitBox(index,HBIndex : integer;var HB : HitBoxRec);

                    procedure ClearAllHitBoxes(index : integer);
              end;

var
 MapCoreBase : TMapCoreBase;

implementation


constructor TMapCoreBase.Create;
begin
  Init;
end;

procedure TMapCoreBase.Init;
var
  m : integer;
begin
 SetCurrentMap(0);
 SetListSize(MaxListSize);

 //Clear every slot, not just map 0. Delete All routes through here, and
 //without this the previous project's hitboxes and extra layers survive.
 for m:=0 to MaxListSize-1 do
   ResetMapState(m);
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
 Setlength(MapUndo,size);
end;

//=============================================================================
// MULTI LEVEL UNDO / REDO  (maps)
//
// Same ring as the sprite editor: Undo and Redo SWAP the live map with the
// slot they step onto, so the state being left behind is always preserved.
//
// A level captures the tiles of every layer in use PLUS the hitboxes and the
// paths. Deleting a path used to be unrecoverable, because CopyToUndo only
// ever touched tiles.
//
// Only the map's actual width x height is copied, not the full 256x256
// allocation, which keeps a level at tens of KB rather than megabytes. That
// is safe because a resize clears the history.
//=============================================================================

Procedure TMapCoreBase.CaptureUndoLevel(index : integer;var L : TMapUndoLevel);
var
  i,j,l2,w,h : integer;
begin
  w:=Map[index].Props.width;
  h:=Map[index].Props.height;
  L.Width:=w;
  L.Height:=h;
  L.LayerCount:=GetLayerCount(index);
  L.HitBoxes:=Map[index].HitBoxProps;
  L.Paths:=Map[index].PathProps;

  for l2:=0 to L.LayerCount-1 do
  begin
    SetLength(L.Tiles[l2],w,h);
    for i:=0 to w-1 do
      for j:=0 to h-1 do
        L.Tiles[l2][i,j]:=Map[index].Tile[l2][i,j];
  end;
end;

Procedure TMapCoreBase.RestoreUndoLevel(index : integer;var L : TMapUndoLevel);
var
  i,j,l2 : integer;
begin
  //a level from a different size cannot be restored - the history should have
  //been cleared on resize, but refuse rather than corrupt the map if it was not
  if (L.Width <> Map[index].Props.width) or
     (L.Height <> Map[index].Props.height) then exit;

  Map[index].HitBoxProps:=L.HitBoxes;
  Map[index].PathProps:=L.Paths;

  if L.LayerCount <> GetLayerCount(index) then
    SetLayerCount(index,L.LayerCount);

  for l2:=0 to L.LayerCount-1 do
    for i:=0 to L.Width-1 do
      for j:=0 to L.Height-1 do
        Map[index].Tile[l2][i,j]:=L.Tiles[l2][i,j];
end;

Procedure TMapCoreBase.ClearUndo(index : integer);
begin
  MapUndo[index].Head:=0;
  MapUndo[index].Depth:=0;
  MapUndo[index].RedoDepth:=0;
end;

function TMapCoreBase.CanUndo(index : integer) : boolean;
begin
  CanUndo:=(MapUndo[index].Depth > 0);
end;

function TMapCoreBase.CanRedo(index : integer) : boolean;
begin
  CanRedo:=(MapUndo[index].RedoDepth > 0);
end;

Procedure TMapCoreBase.Redo(index : integer);
var
  hd : integer;
begin
  if MapUndo[index].RedoDepth = 0 then exit;

  hd:=MapUndo[index].Head;
  CaptureUndoLevel(index,MapUndo[index].Scratch);
  RestoreUndoLevel(index,MapUndo[index].Levels[hd]);
  MapUndo[index].Levels[hd]:=MapUndo[index].Scratch;

  MapUndo[index].Head:=(hd+1) mod MaxMapUndoLevels;
  inc(MapUndo[index].Depth);
  dec(MapUndo[index].RedoDepth);
end;

//Call BEFORE modifying the map: this stores the state being replaced.
Procedure TMapCoreBase.CopyToUndo(index : integer);
begin
  CaptureUndoLevel(index,MapUndo[index].Levels[MapUndo[index].Head]);
  MapUndo[index].Head:=(MapUndo[index].Head+1) mod MaxMapUndoLevels;

  if MapUndo[index].Depth < MaxMapUndoLevels-1 then inc(MapUndo[index].Depth);
  MapUndo[index].RedoDepth:=0;   //a new edit discards the redo branch
end;

Procedure TMapCoreBase.Undo(index : integer);
var
  hd : integer;
begin
  if MapUndo[index].Depth = 0 then exit;

  hd:=(MapUndo[index].Head-1+MaxMapUndoLevels) mod MaxMapUndoLevels;
  CaptureUndoLevel(index,MapUndo[index].Scratch);
  RestoreUndoLevel(index,MapUndo[index].Levels[hd]);
  MapUndo[index].Levels[hd]:=MapUndo[index].Scratch;   //leave state for Redo

  MapUndo[index].Head:=hd;
  dec(MapUndo[index].Depth);
  inc(MapUndo[index].RedoDepth);
end;


//=============================================================================
// COPY / PASTE OF A SINGLE LAYER, HITBOX OR PATH
//
// Pasting into the SAME map offsets the copy by one tile so it does not land
// exactly on top of the original and look like nothing happened. Pasting into
// a DIFFERENT map keeps the original coordinates, since that is normally the
// point - lining something up across maps.
//=============================================================================

function TMapCoreBase.HasLayerClip : boolean;
begin
  HasLayerClip:=LayerClip.Valid;
end;

procedure TMapCoreBase.CopyLayerClip(index,layer : integer);
var
  i,j : integer;
begin
  if not IsValidLayer(index,layer) then exit;

  LayerClip.SrcMap:=index;
  LayerClip.W:=Map[index].Props.width;
  LayerClip.H:=Map[index].Props.height;
  LayerClip.Name:=Map[index].Props.Layers[layer].Name;
  LayerClip.Visible:=Map[index].Props.Layers[layer].Visible;
  LayerClip.Locked:=Map[index].Props.Layers[layer].Locked;

  SetLength(LayerClip.Tiles,LayerClip.W,LayerClip.H);
  for i:=0 to LayerClip.W-1 do
    for j:=0 to LayerClip.H-1 do
      LayerClip.Tiles[i,j]:=Map[index].Tile[layer][i,j];

  LayerClip.Valid:=true;
end;

function TMapCoreBase.PasteLayerClip(index : integer) : integer;
var
  nl,i,j,w,h : integer;
  nm : string;
begin
  PasteLayerClip:=-1;
  if not LayerClip.Valid then exit;

  nl:=AddLayer(index);
  if nl < 0 then exit;              //at the layer cap

  //copy the overlapping region - the destination map may be a different size
  w:=LayerClip.W;
  if w > Map[index].Props.width then w:=Map[index].Props.width;
  h:=LayerClip.H;
  if h > Map[index].Props.height then h:=Map[index].Props.height;

  for i:=0 to w-1 do
    for j:=0 to h-1 do
      Map[index].Tile[nl][i,j]:=LayerClip.Tiles[i,j];

  if LayerClip.SrcMap = index then
    nm:=LayerClip.Name+' Copy'
  else
    nm:=LayerClip.Name+' Copy from Map '+IntToStr(LayerClip.SrcMap+1);

  Map[index].Props.Layers[nl].Name:=Copy(nm,1,31);
  Map[index].Props.Layers[nl].Visible:=LayerClip.Visible;
  Map[index].Props.Layers[nl].Locked:=LayerClip.Locked;

  PasteLayerClip:=nl;
end;

function TMapCoreBase.HasHitBoxClip : boolean;
begin
  HasHitBoxClip:=HitBoxClip.Valid;
end;

procedure TMapCoreBase.CopyHitBoxClip(index,hb : integer);
begin
  if (hb < 0) or (hb >= Map[index].HitBoxProps.HitBoxCount) then exit;
  HitBoxClip.SrcMap:=index;
  HitBoxClip.HB:=Map[index].HitBoxProps.HitBoxes[hb];
  HitBoxClip.Valid:=true;
end;

function TMapCoreBase.PasteHitBoxClip(index : integer) : integer;
var
  hbcount,ox,oy : integer;
begin
  PasteHitBoxClip:=-1;
  if not HitBoxClip.Valid then exit;
  if Map[index].HitBoxProps.HitBoxCount >= MaxHitBoxes then exit;

  //nudge by a tile when pasting back into the same map
  if HitBoxClip.SrcMap = index then begin ox:=1; oy:=1; end
                               else begin ox:=0; oy:=0; end;

  hbcount:=Map[index].HitBoxProps.HitBoxCount;
  Map[index].HitBoxProps.HitBoxes[hbcount]:=HitBoxClip.HB;
  inc(Map[index].HitBoxProps.HitBoxCount);

  //MoveHitBox clamps as a unit, so the nudge cannot push it off the map
  MoveHitBox(index,hbcount,ox,oy);

  PasteHitBoxClip:=hbcount;
end;

function TMapCoreBase.HasPathClip : boolean;
begin
  HasPathClip:=PathClip.Valid;
end;

procedure TMapCoreBase.CopyPathClip(index,p : integer);
begin
  if not IsValidPath(index,p) then exit;
  PathClip.SrcMap:=index;
  PathClip.P:=Map[index].PathProps.Paths[p];
  PathClip.Valid:=true;
end;

function TMapCoreBase.PastePathClip(index : integer) : integer;
var
  np,ox,oy : integer;
begin
  PastePathClip:=-1;
  if not PathClip.Valid then exit;

  np:=AddPath(index);
  if np < 0 then exit;              //at the path cap

  Map[index].PathProps.Paths[np]:=PathClip.P;

  if PathClip.SrcMap = index then begin ox:=1; oy:=1; end
                             else begin ox:=0; oy:=0; end;

  //MovePath clamps as a unit, so the shape and its 8 direction segments hold
  MovePath(index,np,ox,oy);

  PastePathClip:=np;
end;

procedure TMapCoreBase.InitClipBoard;
begin
  ClipBoard.Status:=0;
  ClipBoard.LayerCount:=0;
  ClipBoard.SingleLayer:=false;
  LayerClip.Valid:=false;
  HitBoxClip.Valid:=false;
  PathClip.Valid:=false;
  ClipBoard.width:=0;
  ClipBoard.height:=0;
end;

//Copies EVERY layer of the selected area, not just the active one - a region
//of a layered map is only meaningful with all of its layers.
procedure TMapCoreBase.CopyToClipBoard(index,x,y,x2,y2 : integer);
var
 i,j,l   : integer;
 width,height : integer;
begin
 width:=abs(x2-x+1);
 if width > DefMaxMapWidth then width:=DefMaxMapWidth;
 height:=abs(y2-y+1);
 if height > DefMaxMapHeight then height:=DefMaxMapHeight;

 ClipBoard.LayerCount:=GetLayerCount(index);

 for l:=0 to ClipBoard.LayerCount-1 do
 begin
   SetLength(ClipBoard.Tile[l],width,height);
   for i:=0 to width-1 do
     for j:=0 to height-1 do
       ClipBoard.Tile[l][i,j]:=Map[index].Tile[l][x+i,y+j];
 end;

 ClipBoard.width:=width;
 ClipBoard.height:=height;
 ClipBoard.SingleLayer:=false;
 ClipBoard.Status:=1;
end;

//Copies the CURRENT layer only. Pasting this puts it on whatever layer is
//current at the destination, which is what makes "copy this layer onto that
//layer" possible - the all layer copy above always lands on layers 0..n-1.
procedure TMapCoreBase.CopyLayerToClipBoard(index,x,y,x2,y2 : integer);
var
 i,j,l : integer;
 width,height : integer;
begin
 width:=abs(x2-x+1);
 if width > DefMaxMapWidth then width:=DefMaxMapWidth;
 height:=abs(y2-y+1);
 if height > DefMaxMapHeight then height:=DefMaxMapHeight;

 l:=GetCurrentLayer(index);
 SetLength(ClipBoard.Tile[0],width,height);
 for i:=0 to width-1 do
   for j:=0 to height-1 do
     ClipBoard.Tile[0][i,j]:=Map[index].Tile[l][x+i,y+j];

 ClipBoard.width:=width;
 ClipBoard.height:=height;
 ClipBoard.LayerCount:=1;
 ClipBoard.SingleLayer:=true;
 ClipBoard.Status:=1;
end;


procedure TMapCoreBase.PasteFromClipboard(index,x,y,x2,y2 : integer);
var
 i,j,l,layers   : integer;
 width,height : integer;
begin
 if ClipBoard.Status = 0 then exit;
 width:=abs(x2-x+1);
 if ClipBoard.width < width then width:=ClipBoard.width;
 height:=abs(y2-y+1);
 if ClipBoard.height < height then height:=ClipBoard.height;

 //A single layer copy goes onto the destination's CURRENT layer, so a layer
 //can be copied from one layer and pasted onto a different one.
 if ClipBoard.SingleLayer then
 begin
   l:=GetCurrentLayer(index);
   for i:=0 to width-1 do
     for j:=0 to height-1 do
       Map[index].Tile[l][i+x,j+y]:=ClipBoard.Tile[0][i,j];
   exit;
 end;

 //Otherwise paste as many layers as BOTH sides have. Copying from a 3 layer
 //map into a 2 layer one drops the top layer rather than failing or silently
 //growing the destination.
 layers:=ClipBoard.LayerCount;
 if layers > GetLayerCount(index) then layers:=GetLayerCount(index);
 if layers < 1 then layers:=1;

 for l:=0 to layers-1 do
   for i:=0 to width-1 do
     for j:=0 to height-1 do
       Map[index].Tile[l][i+x,j+y]:=ClipBoard.Tile[l][i,j];
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
var
  l : integer;
begin
 //A snapshot taken at one size cannot be restored into another. The UI warns
 //before it gets here.
 if (Map[index].Props.width <> mwidth) or (Map[index].Props.height <> mheight) then
   ClearUndo(index);

 Map[index].Props.width:=mwidth;
 Map[index].Props.height:=mheight;
 ClearExportProperties(index);

 //a brand new map starts as a single layer - identical to pre v4 behaviour
 if Map[index].Props.LayerCount < 1 then
 begin
   Map[index].Props.LayerCount:=1;
   Map[index].Props.CurrentLayer:=0;
   Map[index].Props.Layers[0].Name:='Layer 1';
   Map[index].Props.Layers[0].Visible:=true;
   Map[index].Props.Layers[0].Locked:=false;
 end;

 for l:=0 to Map[index].Props.LayerCount-1 do
   AllocLayer(index,l);

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
 i,j,l : integer;
begin
 For l:=0 to GetLayerCount(index)-1 do
 begin
   For i:=0 to DefMaxMapWidth-1 do
   begin
     For j:=0 to DefMaxMapHeight-1 do
     begin
       Map[index].Tile[l][i,j].ImageIndex:=value;
     end;
   end;
 end;
end;

procedure TMapCoreBase.SetMapTileSize(index, twidth,theight : integer);
var
  zsize : integer;
  nzwidth,nzheight : integer;
begin
  Map[index].Props.TileWidth:=twidth;
  Map[index].Props.TileHeight:=theight;

  zsize:=GetZoomSize(index);
  nzwidth:=5*zsize+twidth;
  nzheight:=5*zsize+theight;

  SetZoomMapTileSize(index,nzwidth,nzheight);
end;

procedure TMapCoreBase.SetZoomMapTileSize(index, twidth,theight : integer);
begin
  Map[index].Props.ZoomTileWidth:=twidth;
  Map[index].Props.ZoomTileHeight:=theight;
end;



//not using this function - will remove in future versions
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
 result:=GetMapTileIndexL(index,GetCurrentLayer(index),x,y);
end;

procedure TMapCoreBase.SetMapTile(index,x,y : integer; var Tile : TileRec);
begin
 SetMapTileL(index,GetCurrentLayer(index),x,y,Tile);
end;

procedure TMapCoreBase.GetMapTile(index,x,y : integer;var Tile : TileRec);
begin
 GetMapTileL(index,GetCurrentLayer(index),x,y,Tile);
end;


//=============================================================================
// LAYERS
//=============================================================================

//Return one map to a clean slate: one layer, no hitboxes. Init calls this
//for every slot, otherwise Delete All leaves the old hitboxes and the extra
//layers behind because it only ever rewrote map 0's size and flags.

//=============================================================================
// PATH LINES
//
// A path is a polyline of tile coordinates that a follower walks - a patrol
// route, a bird's flight path. Segments are constrained to 8 directions so
// each step is a signed add at runtime with no fixed point maths.
//=============================================================================

function TMapCoreBase.IsValidPath(index,p : integer) : boolean;
begin
  IsValidPath:=(p >= 0) and (p < MaxPaths) and (p < Map[index].PathProps.PathCount);
end;

procedure TMapCoreBase.ClearPaths(index : integer);
begin
  Map[index].PathProps.PathCount:=0;
end;

function TMapCoreBase.GetPathCount(index : integer) : integer;
begin
  GetPathCount:=Map[index].PathProps.PathCount;
end;

procedure TMapCoreBase.SetPathCount(index,count : integer);
begin
  if count < 0 then count:=0;
  if count > MaxPaths then count:=MaxPaths;
  Map[index].PathProps.PathCount:=count;
end;

//Returns the new path index, or -1 when the cap has been reached.
function TMapCoreBase.AddPath(index : integer) : integer;
var
  p : integer;
begin
  p:=Map[index].PathProps.PathCount;
  if p >= MaxPaths then
  begin
    AddPath:=-1;
    exit;
  end;

  FillChar(Map[index].PathProps.Paths[p],sizeof(PathRec),0);
  Map[index].PathProps.Paths[p].active:=true;
  Map[index].PathProps.Paths[p].visible:=true;
  Map[index].PathProps.Paths[p].closed:=false;
  Map[index].PathProps.Paths[p].mode:=PathModeLoop;
  Map[index].PathProps.Paths[p].Name:='Path '+IntToStr(p+1);
  Map[index].PathProps.Paths[p].PointCount:=0;

  inc(Map[index].PathProps.PathCount);
  AddPath:=p;
end;

procedure TMapCoreBase.DeletePath(index,p : integer);
var
  i : integer;
begin
  if not IsValidPath(index,p) then exit;
  for i:=p to Map[index].PathProps.PathCount-2 do
    Map[index].PathProps.Paths[i]:=Map[index].PathProps.Paths[i+1];
  dec(Map[index].PathProps.PathCount);
end;

procedure TMapCoreBase.GetPath(index,p : integer;var Path : PathRec);
begin
  if not IsValidPath(index,p) then exit;
  Path:=Map[index].PathProps.Paths[p];
end;

procedure TMapCoreBase.SetPath(index,p : integer;var Path : PathRec);
begin
  if not IsValidPath(index,p) then exit;
  Map[index].PathProps.Paths[p]:=Path;
end;

function TMapCoreBase.GetPathActive(index,p : integer) : boolean;
begin
  if not IsValidPath(index,p) then GetPathActive:=false
  else GetPathActive:=Map[index].PathProps.Paths[p].active;
end;

procedure TMapCoreBase.SetPathActive(index,p : integer;value : boolean);
begin
  if not IsValidPath(index,p) then exit;
  Map[index].PathProps.Paths[p].active:=value;
end;

function TMapCoreBase.GetPathVisible(index,p : integer) : boolean;
begin
  if not IsValidPath(index,p) then GetPathVisible:=false
  else GetPathVisible:=Map[index].PathProps.Paths[p].visible;
end;

procedure TMapCoreBase.SetPathVisible(index,p : integer;value : boolean);
begin
  if not IsValidPath(index,p) then exit;
  Map[index].PathProps.Paths[p].visible:=value;
end;

function TMapCoreBase.GetPathClosed(index,p : integer) : boolean;
begin
  if not IsValidPath(index,p) then GetPathClosed:=false
  else GetPathClosed:=Map[index].PathProps.Paths[p].closed;
end;

procedure TMapCoreBase.SetPathClosed(index,p : integer;value : boolean);
begin
  if not IsValidPath(index,p) then exit;
  Map[index].PathProps.Paths[p].closed:=value;
end;

function TMapCoreBase.GetPathMode(index,p : integer) : integer;
begin
  if not IsValidPath(index,p) then GetPathMode:=PathModeLoop
  else GetPathMode:=Map[index].PathProps.Paths[p].mode;
end;

procedure TMapCoreBase.SetPathMode(index,p,value : integer);
begin
  if not IsValidPath(index,p) then exit;
  if (value < PathModeOnce) or (value > PathModePingPong) then value:=PathModeLoop;
  Map[index].PathProps.Paths[p].mode:=value;
end;

function TMapCoreBase.GetPathName(index,p : integer) : string;
begin
  if not IsValidPath(index,p) then
    GetPathName:=''
  else
  begin
    GetPathName:=Map[index].PathProps.Paths[p].Name;
    if GetPathName = '' then GetPathName:='Path '+IntToStr(p+1);
  end;
end;

//Shifts every waypoint by dx,dy, clamped so the whole path stays on the map -
//clamping the path as a unit rather than per point is what preserves its
//shape, and therefore its 8 direction segments.
procedure TMapCoreBase.MovePath(index,p,dx,dy : integer);
var
  i,n2,minx,miny,maxx,maxy : integer;
begin
  if not IsValidPath(index,p) then exit;
  n2:=Map[index].PathProps.Paths[p].PointCount;
  if n2 = 0 then exit;

  minx:=Map[index].PathProps.Paths[p].Points[0].x;
  maxx:=minx;
  miny:=Map[index].PathProps.Paths[p].Points[0].y;
  maxy:=miny;
  for i:=1 to n2-1 do
  begin
    if Map[index].PathProps.Paths[p].Points[i].x < minx then minx:=Map[index].PathProps.Paths[p].Points[i].x;
    if Map[index].PathProps.Paths[p].Points[i].x > maxx then maxx:=Map[index].PathProps.Paths[p].Points[i].x;
    if Map[index].PathProps.Paths[p].Points[i].y < miny then miny:=Map[index].PathProps.Paths[p].Points[i].y;
    if Map[index].PathProps.Paths[p].Points[i].y > maxy then maxy:=Map[index].PathProps.Paths[p].Points[i].y;
  end;

  if minx+dx < 0 then dx:=-minx;
  if miny+dy < 0 then dy:=-miny;
  if maxx+dx > Map[index].Props.width-1  then dx:=Map[index].Props.width-1-maxx;
  if maxy+dy > Map[index].Props.height-1 then dy:=Map[index].Props.height-1-maxy;

  for i:=0 to n2-1 do
  begin
    inc(Map[index].PathProps.Paths[p].Points[i].x,dx);
    inc(Map[index].PathProps.Paths[p].Points[i].y,dy);
  end;
end;

//Which visible path has a waypoint within tol tiles of tx,ty. Returns -1 for
//none. Searched top down so the most recently added path wins an overlap.
function TMapCoreBase.PathHitTest(index,tx,ty,tol : integer) : integer;
var
  p,i : integer;
begin
  PathHitTest:=-1;
  for p:=GetPathCount(index)-1 downto 0 do
  begin
    if not Map[index].PathProps.Paths[p].visible then continue;
    for i:=0 to Map[index].PathProps.Paths[p].PointCount-1 do
      if (abs(Map[index].PathProps.Paths[p].Points[i].x-tx) <= tol) and
         (abs(Map[index].PathProps.Paths[p].Points[i].y-ty) <= tol) then
      begin
        PathHitTest:=p;
        exit;
      end;
  end;
end;

procedure TMapCoreBase.SetPathName(index,p : integer;const value : string);
begin
  if not IsValidPath(index,p) then exit;
  Map[index].PathProps.Paths[p].Name:=Copy(value,1,15);
end;

function TMapCoreBase.GetPathPointCount(index,p : integer) : integer;
begin
  if not IsValidPath(index,p) then GetPathPointCount:=0
  else GetPathPointCount:=Map[index].PathProps.Paths[p].PointCount;
end;

procedure TMapCoreBase.GetPathPoint(index,p,pt : integer;var Point : PathPointRec);
begin
  if not IsValidPath(index,p) then exit;
  if (pt < 0) or (pt >= Map[index].PathProps.Paths[p].PointCount) then exit;
  Point:=Map[index].PathProps.Paths[p].Points[pt];
end;

procedure TMapCoreBase.SetPathPoint(index,p,pt : integer;var Point : PathPointRec);
begin
  if not IsValidPath(index,p) then exit;
  if (pt < 0) or (pt >= Map[index].PathProps.Paths[p].PointCount) then exit;
  Map[index].PathProps.Paths[p].Points[pt]:=Point;
end;

//Returns the new point index, or -1 if the path is full.
function TMapCoreBase.AddPathPoint(index,p,x,y : integer) : integer;
var
  pt : integer;
begin
  AddPathPoint:=-1;
  if not IsValidPath(index,p) then exit;

  pt:=Map[index].PathProps.Paths[p].PointCount;
  if pt >= MaxPathPoints then exit;

  FillChar(Map[index].PathProps.Paths[p].Points[pt],sizeof(PathPointRec),0);
  Map[index].PathProps.Paths[p].Points[pt].x:=x;
  Map[index].PathProps.Paths[p].Points[pt].y:=y;

  inc(Map[index].PathProps.Paths[p].PointCount);
  AddPathPoint:=pt;
end;

procedure TMapCoreBase.DeletePathPoint(index,p,pt : integer);
var
  i : integer;
begin
  if not IsValidPath(index,p) then exit;
  if (pt < 0) or (pt >= Map[index].PathProps.Paths[p].PointCount) then exit;

  for i:=pt to Map[index].PathProps.Paths[p].PointCount-2 do
    Map[index].PathProps.Paths[p].Points[i]:=Map[index].PathProps.Paths[p].Points[i+1];
  dec(Map[index].PathProps.Paths[p].PointCount);
end;

//Snap the cursor to the nearest of 8 directions from the anchor point.
//
//A segment is horizontal, vertical or exactly 45 degrees, which keeps every
//exported step a signed add of -1/0/+1 - no Bresenham, no fixed point.
//The diagonal length uses (adx+ady) div 2, which is the projection of the
//cursor onto the 45 degree line, so the snap follows the mouse naturally
//instead of jumping to the shorter or longer axis.
procedure TMapCoreBase.SnapTo8(index,ax,ay,cx,cy : integer;var nx,ny : integer);
var
  dx,dy,adx,ady,len,sx,sy : integer;
begin
  dx:=cx-ax;
  dy:=cy-ay;
  adx:=abs(dx);
  ady:=abs(dy);

  if (adx = 0) and (ady = 0) then
  begin
    nx:=ax;
    ny:=ay;
    exit;
  end;

  if ady*2 <= adx then          //shallow enough to call horizontal
  begin
    nx:=cx;
    ny:=ay;
  end
  else if adx*2 <= ady then     //steep enough to call vertical
  begin
    nx:=ax;
    ny:=cy;
  end
  else                          //diagonal
  begin
    len:=(adx+ady) div 2;
    if len < 1 then len:=1;
    if dx < 0 then sx:=-1 else sx:=1;
    if dy < 0 then sy:=-1 else sy:=1;
    nx:=ax + sx*len;
    ny:=ay + sy*len;
  end;

  //keep the waypoint on the map
  if nx < 0 then nx:=0;
  if ny < 0 then ny:=0;
  if nx > Map[index].Props.width-1  then nx:=Map[index].Props.width-1;
  if ny > Map[index].Props.height-1 then ny:=Map[index].Props.height-1;
end;

//Which of the 8 directions leads from a to b. Returns -1 when the points are
//the same. Direction is always DERIVED, never stored - storing it would let
//it disagree with the points the moment one is moved.
function TMapCoreBase.DirectionBetween(ax,ay,bx,by : integer) : integer;
var
  dx,dy,i : integer;
begin
  DirectionBetween:=-1;
  dx:=bx-ax;
  dy:=by-ay;
  if (dx = 0) and (dy = 0) then exit;

  if dx > 0 then dx:=1 else if dx < 0 then dx:=-1;
  if dy > 0 then dy:=1 else if dy < 0 then dy:=-1;

  for i:=0 to 7 do
    if (PathDirX[i] = dx) and (PathDirY[i] = dy) then
    begin
      DirectionBetween:=i;
      exit;
    end;
end;

//How many paths would be exported: ACTIVE ones with at least two points.
//"visible" is an editor flag and never affects export.
function TMapCoreBase.PathExportCount(index : integer) : integer;
var
  p,c : integer;
begin
  c:=0;
  for p:=0 to GetPathCount(index)-1 do
    if Map[index].PathProps.Paths[p].active and
       (Map[index].PathProps.Paths[p].PointCount >= 2) then inc(c);
  PathExportCount:=c;
end;

//Fills vals with the flat export array and returns how many entries were
//written, or -1 if vals is too small.
//
//  [0]        NP                 number of paths
//  [1..NP]    offset of each path header, into this same array
//  header:    +0 startTileX  +1 startTileY
//             +2 startPixelX +3 startPixelY
//             +4 closed      +5 mode (0=once 1=loop 2=pingpong)
//             +6 segCount
//             +7 segments, stride 4: dx, dy, pixels, delay
//
//dx,dy come from the 8 direction set so they are always -1/0/+1, which makes
//"pixels" the exact number of one pixel steps to the next waypoint - diagonals
//included. Following a path is an add and a decrement per frame.
function TMapCoreBase.BuildPathExportArray(index : integer;
           var vals : array of longint) : integer;
var
  idx  : array[0..MaxPaths-1] of integer;
  offs : array[0..MaxPaths-1] of integer;
  npaths,total,i,j,k,p,segcount,dirn,steps,nv,tw,th : integer;

  function SegCountOf(p2 : integer) : integer;
  begin
    if Map[index].PathProps.Paths[p2].PointCount < 2 then SegCountOf:=0
    else if Map[index].PathProps.Paths[p2].closed then
      SegCountOf:=Map[index].PathProps.Paths[p2].PointCount
    else
      SegCountOf:=Map[index].PathProps.Paths[p2].PointCount-1;
  end;

  procedure Push(v : integer);
  begin
    if nv <= High(vals) then vals[nv]:=v;
    inc(nv);
  end;

begin
  BuildPathExportArray:=-1;
  tw:=GetMapTileWidth(index);
  th:=GetMapTileHeight(index);

  npaths:=0;
  for p:=0 to GetPathCount(index)-1 do
  begin
    if not Map[index].PathProps.Paths[p].active then continue;
    if SegCountOf(p) = 0 then continue;
    idx[npaths]:=p;
    inc(npaths);
    if npaths >= MaxPaths then break;
  end;
  if npaths = 0 then
  begin
    BuildPathExportArray:=0;
    exit;
  end;

  total:=1+npaths;
  for i:=0 to npaths-1 do
  begin
    offs[i]:=total;
    total:=total + 7 + SegCountOf(idx[i])*4;
  end;
  if total > Length(vals) then exit;    //caller's buffer is too small

  nv:=0;
  Push(npaths);
  for i:=0 to npaths-1 do Push(offs[i]);

  for i:=0 to npaths-1 do
  begin
    p:=idx[i];
    segcount:=SegCountOf(p);

    Push(Map[index].PathProps.Paths[p].Points[0].x);
    Push(Map[index].PathProps.Paths[p].Points[0].y);
    Push(Map[index].PathProps.Paths[p].Points[0].x*tw + tw div 2);
    Push(Map[index].PathProps.Paths[p].Points[0].y*th + th div 2);
    if Map[index].PathProps.Paths[p].closed then Push(1) else Push(0);
    Push(Map[index].PathProps.Paths[p].mode);
    Push(segcount);

    for j:=0 to segcount-1 do
    begin
      k:=j+1;
      if k >= Map[index].PathProps.Paths[p].PointCount then k:=0;
      dirn:=DirectionBetween(Map[index].PathProps.Paths[p].Points[j].x,
                             Map[index].PathProps.Paths[p].Points[j].y,
                             Map[index].PathProps.Paths[p].Points[k].x,
                             Map[index].PathProps.Paths[p].Points[k].y);
      if dirn < 0 then
      begin
        //identical waypoints - a zero length hop keeps segCount truthful
        Push(0); Push(0); Push(0);
        Push(Map[index].PathProps.Paths[p].Points[k].delay);
        continue;
      end;

      steps:=abs(Map[index].PathProps.Paths[p].Points[k].x-Map[index].PathProps.Paths[p].Points[j].x);
      if abs(Map[index].PathProps.Paths[p].Points[k].y-Map[index].PathProps.Paths[p].Points[j].y) > steps then
        steps:=abs(Map[index].PathProps.Paths[p].Points[k].y-Map[index].PathProps.Paths[p].Points[j].y);

      Push(PathDirX[dirn]);
      Push(PathDirY[dirn]);
      Push(steps*tw);
      Push(Map[index].PathProps.Paths[p].Points[k].delay);
    end;
  end;

  BuildPathExportArray:=nv;
end;

function TMapCoreBase.GetExportPathCount : integer;
var
  i,c : integer;
  EP : MapExportFormatRec;
begin
  c:=0;
  for i:=0 to MapCount-1 do
  begin
    GetMapExportProps(i,EP);
    if (EP.MapFormat > 0) and (PathExportCount(i) > 0) then inc(c);
  end;
  GetExportPathCount:=c;
end;

procedure TMapCoreBase.ResetMapState(index : integer);
begin
  Map[index].HitBoxProps.HitBoxCount:=0;
  Map[index].PathProps.PathCount:=0;
  ClearUndo(index);
  Map[index].Props.CurrentLayer:=0;
  Map[index].Props.LayerCount:=1;
  Map[index].Props.Layers[0].Name:='Layer 1';
  Map[index].Props.Layers[0].Visible:=true;
  Map[index].Props.Layers[0].Locked:=false;
  SetLayerCount(index,1);      //frees layers 1..n and their metadata
end;

function TMapCoreBase.IsValidLayer(index,layer : integer) : boolean;
begin
  //Must use GetLayerCount, NOT the raw Props.LayerCount. Any caller that
  //builds a MapPropsRec from scratch (the JSON reader does exactly this)
  //leaves LayerCount at 0, and testing the raw field would make layer 0
  //invalid - every SetMapTile would then silently do nothing and the map
  //would load completely empty.
  IsValidLayer:=(layer >= 0) and (layer < MaxMapLayers) and
                (layer < GetLayerCount(index));
end;

//Allocate the tile grid for one layer and clear it. Called on demand so a
//single layer map never pays for the other seven.
procedure TMapCoreBase.AllocLayer(index,layer : integer);
var
  i,j : integer;
begin
  if (layer < 0) or (layer >= MaxMapLayers) then exit;

  SetLength(Map[index].Tile[layer],DefMaxMapWidth,DefMaxMapHeight);
  SetLength(UndoMap[index].Tile[layer],DefMaxMapWidth,DefMaxMapHeight);

  for i:=0 to DefMaxMapWidth-1 do
    for j:=0 to DefMaxMapHeight-1 do
    begin
      Map[index].Tile[layer][i,j].ImageIndex:=TileClear;
      UndoMap[index].Tile[layer][i,j].ImageIndex:=TileClear;
    end;
end;

function TMapCoreBase.GetLayerCount(index : integer) : integer;
begin
  //Older data or a freshly zeroed record reads as 0 - treat that as 1 layer
  //so nothing ever ends up with a map that has no layers at all.
  if Map[index].Props.LayerCount < 1 then
    GetLayerCount:=1
  else
    GetLayerCount:=Map[index].Props.LayerCount;
end;

procedure TMapCoreBase.SetLayerCount(index,count : integer);
var
  i : integer;
begin
  if count < 1 then count:=1;
  if count > MaxMapLayers then count:=MaxMapLayers;

  //allocate any layer we are about to expose
  for i:=Map[index].Props.LayerCount to count-1 do
  begin
    AllocLayer(index,i);
    if Map[index].Props.Layers[i].Name = '' then
      Map[index].Props.Layers[i].Name:='Layer '+IntToStr(i+1);
    Map[index].Props.Layers[i].Visible:=true;
    Map[index].Props.Layers[i].Locked:=false;
  end;

  //release anything we are dropping - metadata as well as tiles, otherwise
  //a stale name or visibility flag reappears when the layer is re-added
  for i:=count to MaxMapLayers-1 do
  begin
    SetLength(Map[index].Tile[i],0,0);
    SetLength(UndoMap[index].Tile[i],0,0);
    Map[index].Props.Layers[i].Name:='';
    Map[index].Props.Layers[i].Visible:=true;
    Map[index].Props.Layers[i].Locked:=false;
  end;

  Map[index].Props.LayerCount:=count;
  if Map[index].Props.CurrentLayer >= count then
    Map[index].Props.CurrentLayer:=count-1;
end;

function TMapCoreBase.GetCurrentLayer(index : integer) : integer;
var
  l : integer;
begin
  l:=Map[index].Props.CurrentLayer;
  if l < 0 then l:=0;
  if l >= GetLayerCount(index) then l:=GetLayerCount(index)-1;
  GetCurrentLayer:=l;
end;

procedure TMapCoreBase.SetCurrentLayer(index,layer : integer);
begin
  if layer < 0 then layer:=0;
  if layer >= GetLayerCount(index) then layer:=GetLayerCount(index)-1;
  Map[index].Props.CurrentLayer:=layer;
end;

function TMapCoreBase.GetLayerVisible(index,layer : integer) : boolean;
begin
  if not IsValidLayer(index,layer) then
    GetLayerVisible:=false
  else
    GetLayerVisible:=Map[index].Props.Layers[layer].Visible;
end;

procedure TMapCoreBase.SetLayerVisible(index,layer : integer;value : boolean);
begin
  if not IsValidLayer(index,layer) then exit;
  Map[index].Props.Layers[layer].Visible:=value;
end;

function TMapCoreBase.GetLayerLocked(index,layer : integer) : boolean;
begin
  if not IsValidLayer(index,layer) then
    GetLayerLocked:=false
  else
    GetLayerLocked:=Map[index].Props.Layers[layer].Locked;
end;

procedure TMapCoreBase.SetLayerLocked(index,layer : integer;value : boolean);
begin
  if not IsValidLayer(index,layer) then exit;
  Map[index].Props.Layers[layer].Locked:=value;
end;

function TMapCoreBase.GetLayerName(index,layer : integer) : string;
begin
  if not IsValidLayer(index,layer) then
    GetLayerName:=''
  else
  begin
    GetLayerName:=Map[index].Props.Layers[layer].Name;
    if GetLayerName = '' then
      GetLayerName:='Layer '+IntToStr(layer+1);
  end;
end;

procedure TMapCoreBase.SetLayerName(index,layer : integer;const value : string);
begin
  if not IsValidLayer(index,layer) then exit;
  Map[index].Props.Layers[layer].Name:=Copy(value,1,31);
end;

//Returns the new layer index, or -1 when the cap has been reached.
function TMapCoreBase.AddLayer(index : integer) : integer;
var
  n : integer;
begin
  n:=GetLayerCount(index);
  if n >= MaxMapLayers then
  begin
    AddLayer:=-1;
    exit;
  end;
  SetLayerCount(index,n+1);
  AddLayer:=n;
end;

//Deleting shuffles the layers above down one, so draw order is preserved.
procedure TMapCoreBase.DeleteLayer(index,layer : integer);
var
  i,j,k,n : integer;
begin
  n:=GetLayerCount(index);
  if n <= 1 then exit;               //a map always keeps at least one layer
  if not IsValidLayer(index,layer) then exit;

  for k:=layer to n-2 do
  begin
    Map[index].Props.Layers[k]:=Map[index].Props.Layers[k+1];
    for i:=0 to DefMaxMapWidth-1 do
      for j:=0 to DefMaxMapHeight-1 do
        Map[index].Tile[k][i,j]:=Map[index].Tile[k+1][i,j];
  end;

  SetLayerCount(index,n-1);
end;

//direction: -1 moves the layer down the draw order, +1 moves it up.
procedure TMapCoreBase.MoveLayer(index,layer,direction : integer);
var
  target,i,j : integer;
  TInfo : TLayerInfoRec;
  TTile : TileRec;
begin
  target:=layer+direction;
  if not IsValidLayer(index,layer) then exit;
  if not IsValidLayer(index,target) then exit;

  TInfo:=Map[index].Props.Layers[layer];
  Map[index].Props.Layers[layer]:=Map[index].Props.Layers[target];
  Map[index].Props.Layers[target]:=TInfo;

  for i:=0 to DefMaxMapWidth-1 do
    for j:=0 to DefMaxMapHeight-1 do
    begin
      TTile:=Map[index].Tile[layer][i,j];
      Map[index].Tile[layer][i,j]:=Map[index].Tile[target][i,j];
      Map[index].Tile[target][i,j]:=TTile;
    end;

  if GetCurrentLayer(index) = layer then SetCurrentLayer(index,target);
end;

procedure TMapCoreBase.ClearLayer(index,layer,value : integer);
var
  i,j : integer;
begin
  if not IsValidLayer(index,layer) then exit;
  for i:=0 to DefMaxMapWidth-1 do
    for j:=0 to DefMaxMapHeight-1 do
      Map[index].Tile[layer][i,j].ImageIndex:=value;
end;

procedure TMapCoreBase.SetMapTileL(index,layer,x,y : integer; var Tile : TileRec);
begin
  if not IsValidLayer(index,layer) then exit;
  if (x < 0) or (x >= Map[index].Props.width) or
     (y < 0) or (y >= Map[index].Props.height) then exit;
  Map[index].Tile[layer][x,y]:=Tile;
end;

procedure TMapCoreBase.GetMapTileL(index,layer,x,y : integer;var Tile : TileRec);
begin
  if not IsValidLayer(index,layer) then exit;
  if (x < 0) or (x >= Map[index].Props.width) or
     (y < 0) or (y >= Map[index].Props.height) then exit;
  Tile:=Map[index].Tile[layer][x,y];
end;

function TMapCoreBase.GetMapTileIndexL(index,layer,x,y : integer) : integer;
begin
  if not IsValidLayer(index,layer) then
    result:=-1000
  else if (x < 0) or (x >= Map[index].Props.width) or
          (y < 0) or (y >= Map[index].Props.height) then
    result:=-1000
  else
    result:=Map[index].Tile[layer][x,y].ImageIndex;
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

 SetMapClipStatus(MapCount-1,0); //if the copy has clip enabled we need to set it off

 //copy Lan and Format settings from Map 0
 GetMapExportProps(0,ExportProps);
 Lan:=ExportProps.Lan;
 Format:=ExportProps.MapFormat;
 GetMapExportProps(MapCount-1,ExportProps);
 ExportProps.Lan:=Lan;
 ExportProps.MapFormat:=Format;
 SetMapExportProps(MapCount-1,ExportProps);
end;

//A clone is a complete duplicate: EVERY layer, plus the hitboxes and the
//paths. This used to copy through GetMapTile/SetMapTile, which act on the
//current layer only, so a multi layer map cloned as a single layer and lost
//its hitboxes and paths entirely.
procedure TMapCoreBase.CloneMap;
var
 props : MapPropsRec;
 ExportProps : MapExportFormatRec;
 i,j,l,dest : integer;
begin
 if (MapCount=0) or (MapCount >= MaxListSize) then exit;
 inc(MapCount);
 dest:=MapCount-1;

 //copy properties from current map - this carries LayerCount, so SetMapSize
 //below allocates the same number of layers on the clone
 GetMapProps(CurrentMap,props);
 SetMapProps(dest,props);
 SetMapSize(dest,props.width,props.height);

 //copy Lan and Format settings from current Map
 GetMapExportProps(CurrentMap,ExportProps);
 SetMapExportProps(dest,ExportProps);

 //hitboxes and paths are whole records - a straight assignment is enough
 Map[dest].HitBoxProps:=Map[CurrentMap].HitBoxProps;
 Map[dest].PathProps:=Map[CurrentMap].PathProps;

 //every layer, not just the active one
 for l:=0 to GetLayerCount(CurrentMap)-1 do
   For j:=0 to props.height-1 do
     For i:=0 to props.width-1 do
       Map[dest].Tile[l][i,j]:=Map[CurrentMap].Tile[l][i,j];

 //the clone starts with no undo history of its own
 ClearUndo(dest);
end;

function TMapCoreBase.IsMapCustomSize(index : integer) : boolean;
var
 width,height : integer;
begin
 width:=GetMapWidth(index);
 height:=GetMapHeight(index);
 result:=NOT((width=8) or (width=16) or (width=32) or (width=64) or (width=128) or (width=256)) and
         ((height=8) or (height=16) or (height=32) or (height=64) or (height=128) or (height=256))
end;



procedure TMapCoreBase.InitHitBox;
begin
   Map[CurrentMap].HitBoxProps.HitBoxCount:=0;
end;


function TMapCoreBase.IsValidHitBox(index,hb : integer) : boolean;
begin
  IsValidHitBox:=(hb >= 0) and (hb < Map[index].HitBoxProps.HitBoxCount);
end;

//Shifts a hitbox, clamped as a unit so its size is preserved.
procedure TMapCoreBase.MoveHitBox(index,hb,dx,dy : integer);
begin
  if (hb < 0) or (hb >= Map[index].HitBoxProps.HitBoxCount) then exit;

  with Map[index].HitBoxProps.HitBoxes[hb] do
  begin
    if x+dx < 0 then dx:=-x;
    if y+dy < 0 then dy:=-y;
    if x2+dx > Map[index].Props.width-1  then dx:=Map[index].Props.width-1-x2;
    if y2+dy > Map[index].Props.height-1 then dy:=Map[index].Props.height-1-y2;

    inc(x,dx);   inc(y,dy);
    inc(x2,dx);  inc(y2,dy);
  end;
end;

//Which hitbox contains tx,ty. Returns -1 for none. Searched top down so the
//most recently added box wins an overlap.
function TMapCoreBase.HitBoxHitTest(index,tx,ty : integer) : integer;
var
  i : integer;
begin
  HitBoxHitTest:=-1;
  for i:=Map[index].HitBoxProps.HitBoxCount-1 downto 0 do
    with Map[index].HitBoxProps.HitBoxes[i] do
      if (tx >= x) and (tx <= x2) and (ty >= y) and (ty <= y2) then
      begin
        HitBoxHitTest:=i;
        exit;
      end;
end;

procedure TMapCoreBase.DeleteHitBox(index,HBIndex : integer);
var
  i : integer;
begin
  if (HBIndex >= 0) and (HBIndex < Map[index].HitBoxProps.HitBoxCount) then
  begin
    // shift all entries after HBIndex down by one
    for i:=HBIndex to Map[index].HitBoxProps.HitBoxCount-2 do
    begin
      Map[index].HitBoxProps.HitBoxes[i]:=Map[index].HitBoxProps.HitBoxes[i+1];
    end;
    // clear the last entry
    Map[index].HitBoxProps.HitBoxes[Map[index].HitBoxProps.HitBoxCount-1].active:=false;
    Map[index].HitBoxProps.HitBoxes[Map[index].HitBoxProps.HitBoxCount-1].x:=0;
    Map[index].HitBoxProps.HitBoxes[Map[index].HitBoxProps.HitBoxCount-1].y:=0;
    Map[index].HitBoxProps.HitBoxes[Map[index].HitBoxProps.HitBoxCount-1].x2:=0;
    Map[index].HitBoxProps.HitBoxes[Map[index].HitBoxProps.HitBoxCount-1].y2:=0;
    dec(Map[index].HitBoxProps.HitBoxCount);
  end;
end;

procedure TMapCoreBase.AddHitBox(index,x,y,x2,y2 : integer);
var
  hbcount : integer;
  temp : integer;
begin
 if Map[index].HitBoxProps.HitBoxCount < MaxHitBoxes then
 begin
   // normalize coords so x<=x2 and y<=y2
   if x > x2 then begin temp:=x; x:=x2; x2:=temp; end;
   if y > y2 then begin temp:=y; y:=y2; y2:=temp; end;

   hbcount:=Map[index].HitBoxProps.HitBoxCount;
   Map[index].HitBoxProps.HitBoxes[hbcount].active:=true;
   Map[index].HitBoxProps.HitBoxes[hbcount].x:=x;
   Map[index].HitBoxProps.HitBoxes[hbcount].y:=y;
   Map[index].HitBoxProps.HitBoxes[hbcount].x2:=x2;
   Map[index].HitBoxProps.HitBoxes[hbcount].y2:=y2;
   inc(Map[index].HitBoxProps.HitBoxCount);
 end;
end;

procedure TMapCoreBase.EditHitBox(index,HBIndex,x,y,x2,y2 : integer);
var
  temp : integer;
begin
  if (HBIndex >= 0) and (HBIndex < Map[index].HitBoxProps.HitBoxCount) then
  begin
    if x > x2 then begin temp:=x; x:=x2; x2:=temp; end;
    if y > y2 then begin temp:=y; y:=y2; y2:=temp; end;
    Map[index].HitBoxProps.HitBoxes[HBIndex].x:=x;
    Map[index].HitBoxProps.HitBoxes[HBIndex].y:=y;
    Map[index].HitBoxProps.HitBoxes[HBIndex].x2:=x2;
    Map[index].HitBoxProps.HitBoxes[HBIndex].y2:=y2;
  end;
end;


function TMapCoreBase.GetHitBoxCount(index : integer) : integer;
begin
  result:=Map[index].HitBoxProps.HitBoxCount;
end;


procedure TMapCoreBase.SetHitBoxCount(index,count : integer);
begin
  Map[index].HitBoxProps.HitBoxCount:=count;
end;


procedure TMapCoreBase.GetHitBox(index,HBIndex : integer;var HB : HitBoxRec);
begin
  if (HBIndex >= 0) and (HBIndex < Map[index].HitBoxProps.HitBoxCount) then
    HB:=Map[index].HitBoxProps.HitBoxes[HBIndex];
end;

procedure TMapCoreBase.SetHitBox(index,HBIndex : integer;var HB : HitBoxRec);
begin
  Map[index].HitBoxProps.HitBoxes[HBIndex]:=HB;
end;


procedure TMapCoreBase.ClearAllHitBoxes(index : integer);
var
  i : integer;
begin
  Map[index].HitBoxProps.HitBoxCount:=0;
  for i:=0 to MaxHitBoxes-1 do
  begin
    Map[index].HitBoxProps.HitBoxes[i].active:=false;
    Map[index].HitBoxProps.HitBoxes[i].x:=0;
    Map[index].HitBoxProps.HitBoxes[i].y:=0;
    Map[index].HitBoxProps.HitBoxes[i].x2:=0;
    Map[index].HitBoxProps.HitBoxes[i].y2:=0;
  end;
end;


begin
  MapCoreBase:=TMapCoreBase.Create;
end.

