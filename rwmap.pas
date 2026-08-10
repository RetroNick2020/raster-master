//=============================================================================
// CHANGE LOG (Claude edits - newest first)
//-----------------------------------------------------------------------------
// 2026-08-03  PATH LINES - file IO
//   * Map file v5. Each map now stores a path count followed by that many
//     PathRec, written after the hitboxes and in the same shape.
//
// 2026-08-03  MAP LAYERS - phase 2 (file IO + export)
//   * Map file is now v4. LayerCount/CurrentLayer/layer names ride along
//     inside MapPropsRec, so no new block was needed - only the tile stream
//     gained an outer layer loop.
//   * ReadMapF allocates every layer before reading, because SetMapSize runs
//     before SetMapProps and therefore only knows about layer 0.
//   * ReadMap/ReadMaps now report why a load failed via LastMapReadStatus.
//     Previously a version mismatch silently did nothing - with the v3->v4
//     break that would have been every existing map file.
//   * Text/RES exports: header gained a 5th value (layer count) and the tile
//     stream is layer major. MapFormat 1 = Simple exports layer 0 only,
//     MapFormat 2 = Layered exports every layer.
//   * JSON export now emits a "layers" array - see WriteMapJSONToText.
//=============================================================================

unit rwmap;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, LazFileUtils,gwbasic, mapcore,rmcodegen;

const
  //MapExportFormatRec.MapFormat values. 0 = do not export.
  //Only ever tested as > 0 elsewhere, so adding Layered breaks nothing.
  MapFormatSimple  = 1;   //layer 0 only - identical to the pre v4 output
  MapFormatLayered = 2;   //every layer, layer major, layer count in header

  //LastMapReadStatus values
  MapReadOK         = 0;
  MapReadBadSig     = 1;  //not a Raster Master map file at all
  MapReadOldVersion = 2;  //made by an older build - cannot be loaded
  MapReadNewVersion = 3;  //made by a newer build - cannot be loaded

var
  //Set by ReadMap/ReadMaps. The UI checks this to explain a failed load.
  LastMapReadStatus : integer = MapReadOK;

Procedure ReadMap(filename : string);
Procedure ReadMaps(filename : string);
Procedure ReadAllMapsF(var F : File;MapCount : integer;insertmode : boolean);
Procedure ReadMapF(var F : File;index : integer);

Procedure WriteMap(filename : string);
Procedure WriteMaps(filename : string);
Procedure WriteAllMapsF(var F : File);
Procedure WriteMapF(var F : File; index : integer);

procedure ExportMap(filename : string; Lan : integer;UseClipArea : boolean);
procedure WriteMapsCodeToBuffer(var F : Text);
procedure ResExportMaps(var F:File);

//Exposed so the RES writer can size a map resource using the SAME layer count
//the exporter will actually write.
function ExportLayerCount(index : integer) : integer;

implementation

//Number of layers an export should emit for this map. Simple format stays
//at one layer so existing game code keeps loading the base terrain exactly
//as it always did.
function ExportLayerCount(index : integer) : integer;
var
  EP : MapExportFormatRec;
begin
  MapCoreBase.GetMapExportProps(index,EP);
  if EP.MapFormat = MapFormatLayered then
    ExportLayerCount:=MapCoreBase.GetLayerCount(index)
  else
    ExportLayerCount:=1;
end;

procedure ExportPascalMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps   : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
  nlayers : integer;
  ca : MapClipAreaRec;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);

 if UseClipArea and (MapCoreBase.GetMapClipStatus(index)=1) then
 begin
   MapCoreBase.GetMapClipAreaCoords(index,ca);
   mwidth:=ca.x2-ca.x+1;
   mheight:=ca.y2-ca.y+1;
 end;

 nlayers:=ExportLayerCount(index);
 //+5 header values: width, height, tilewidth, tileheight, layercount
 size:=nlayers*mwidth*mheight+5;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,PascalLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,'(* Pascal Map Code Created By Raster Master *)');
 Writeln(mc.FTextPtr^,'(* Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' Layers=',nlayers,' *)');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Size   = ',size,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Width  = ',mwidth,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Height = ',mheight,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Tile_Width  = ',MapProps.tilewidth,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Tile_Height = ',MapProps.tileheight,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Layers = ',nlayers,';');
 Writeln(mc.FTextPtr^,'  ',ImageName,' : array[0..',size-1,'] of integer = (');
end;

procedure ExportCMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps   : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
  nlayers : integer;
  ca : MapClipAreaRec;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);

 if UseClipArea and (MapCoreBase.GetMapClipStatus(index)=1) then
 begin
   MapCoreBase.GetMapClipAreaCoords(index,ca);
   mwidth:=ca.x2-ca.x+1;
   mheight:=ca.y2-ca.y+1;
 end;

 nlayers:=ExportLayerCount(index);
 //+5 header values: width, height, tilewidth, tileheight, layercount
 size:=nlayers*mwidth*mheight+5;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,CLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,'/* C Map Code Created By Raster Master */');
 Writeln(mc.FTextPtr^,'/* Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' Layers=',nlayers,' */');
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Size   ',size);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Width  ',mwidth);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Height ',mheight);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Tile_Width  ',MapProps.tilewidth);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Tile_Height ',MapProps.tileheight);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Layers ',nlayers);
 Writeln(mc.FTextPtr^,'  ','int ',Imagename, '[',size,']  = {');
end;

procedure ExportBasicMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps    : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
  nlayers : integer;
  ca : MapClipAreaRec;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);

 if UseClipArea and (MapCoreBase.GetMapClipStatus(index)=1) then
 begin
   MapCoreBase.GetMapClipAreaCoords(index,ca);
   mwidth:=ca.x2-ca.x+1;
   mheight:=ca.y2-ca.y+1;
 end;

 nlayers:=ExportLayerCount(index);
 //+5 header values: width, height, tilewidth, tileheight, layercount
 size:=nlayers*mwidth*mheight+5;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,BasicLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,ImageName+'MapLabel:');
 Writeln(mc.FTextPtr^,#39,' Basic Map Code Created By Raster Master');
 Writeln(mc.FTextPtr^,#39,' Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' Layers=',nlayers);
 Writeln(mc.FTextPtr^,#39,' ',Imagename);
end;

procedure ExportBasicLNMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps    : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
  nlayers : integer;
  ca : MapClipAreaRec;
begin
 //SetGWStartLineNumber(1000);
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);

 if UseClipArea and (MapCoreBase.GetMapClipStatus(index)=1) then
 begin
   MapCoreBase.GetMapClipAreaCoords(index,ca);
   mwidth:=ca.x2-ca.x+1;
   mheight:=ca.y2-ca.y+1;
 end;

 nlayers:=ExportLayerCount(index);
 //+5 header values: width, height, tilewidth, tileheight, layercount
 size:=nlayers*mwidth*mheight+5;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,BasicLNLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' Basic Map Code Created By Raster Master');
 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' Layers=',nlayers);
 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' ',Imagename);
end;

//same code for languages - only header is different
procedure ExportMapMain(var mc : CodeGenRec; index : integer;UseClipArea : boolean);
var
  MapProps : MapPropsRec;
  i,j,l : integer;
  Tile  : TileRec;
  mwidth,mheight : integer;
  nlayers : integer;
  ca : MapClipAreaRec;
  startx,starty : integer;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);
 startx:=0;
 starty:=0;

 if UseClipArea and (MapCoreBase.GetMapClipStatus(index)=1) then
 begin
   MapCoreBase.GetMapClipAreaCoords(index,ca);
   mwidth:=ca.x2-ca.x+1;
   mheight:=ca.y2-ca.y+1;
   startx:=ca.x;
   starty:=ca.y;
 end;

 nlayers:=ExportLayerCount(index);

 //header: the first four values keep the exact meaning and order they had
 //before layers existed, so a reader can share the same parsing code and
 //simply pick up one extra value.
 MWWriteInteger(mc,mwidth);
 MWWriteInteger(mc,mheight);
 MWWriteInteger(mc,MapProps.tilewidth);
 MWWriteInteger(mc,MapProps.tileheight);
 MWWriteInteger(mc,nlayers);

 //layer major: layer 0 is written complete before layer 1 starts, so a
 //consumer that only wants the base terrain can read width*height values
 //and stop.
 for l:=0 to nlayers-1 do
 begin
   for j:=starty to starty+mheight-1 do
   begin
     for i:=startx to startx+mwidth-1 do
     begin
       MapCoreBase.GetMapTileL(index,l,i,j,Tile);
       {$I-}
       MWWriteInteger(mc,Tile.ImageIndex);
       {$I+}
       if IORESULT<>0 then exit;
     end;
   end;
 end;
end;


procedure ExportJSMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps   : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
  nlayers : integer;
  ca : MapClipAreaRec;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);

 if UseClipArea and (MapCoreBase.GetMapClipStatus(index)=1) then
 begin
   MapCoreBase.GetMapClipAreaCoords(index,ca);
   mwidth:=ca.x2-ca.x+1;
   mheight:=ca.y2-ca.y+1;
 end;

 nlayers:=ExportLayerCount(index);
 //+5 header values: width, height, tilewidth, tileheight, layercount
 size:=nlayers*mwidth*mheight+5;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,JSLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,'// JavaScript Map Code Created By Raster Master');
 Writeln(mc.FTextPtr^,'// Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' Layers=',nlayers);
 Writeln(mc.FTextPtr^,'const ',ImageName,'Map = [');
end;

//writes the map as a pure JSON data descriptor - dims, tile size, tile
//index rows, and hitboxes. shared by the export menu and the map
//properties / buffer export paths.
procedure WriteMapJSONToText(var F : Text; index : integer; ImageName : string; UseClipArea : boolean);
var
  MapProps : MapPropsRec;
  Tile : TileRec;
  HB : HitBoxRec;
  ca : MapClipAreaRec;
  i, j, k, l, sx, sy, mwidth, mheight, hbcount, nlayers : integer;
  pcount, written, segcount, segwritten, dirn, steps : integer;
  PathProps : PathRec;
  line : string;

  function JBool(b : boolean) : string;
  begin
    if b then JBool:='true' else JBool:='false';
  end;

  //JSON strings must not carry raw quotes or backslashes - layer names are
  //user typed, so they get escaped rather than trusted.
  function JStr(const s : string) : string;
  var
    k : integer;
  begin
    JStr:='';
    for k:=1 to Length(s) do
    begin
      if (s[k] = '"') or (s[k] = '\') then JStr:=JStr+'\';
      JStr:=JStr+s[k];
    end;
  end;
begin
  MapCoreBase.GetMapProps(index, MapProps);
  mwidth:=MapCoreBase.GetMapWidth(index);
  mheight:=MapCoreBase.GetMapHeight(index);
  sx:=0;
  sy:=0;

  if UseClipArea and (MapCoreBase.GetMapClipStatus(index)=1) then
  begin
    MapCoreBase.GetMapClipAreaCoords(index, ca);
    sx:=ca.x;
    sy:=ca.y;
    mwidth:=ca.x2-ca.x+1;
    mheight:=ca.y2-ca.y+1;
  end;

  Writeln(F,'{');
  Writeln(F,'  "name": "',ImageName,'",');
  Writeln(F,'  "width": ',mwidth,',');
  Writeln(F,'  "height": ',mheight,',');
  Writeln(F,'  "tileWidth": ',MapProps.tilewidth,',');
  Writeln(F,'  "tileHeight": ',MapProps.tileheight,',');

  nlayers:=ExportLayerCount(index);
  Writeln(F,'  "layerCount": ',nlayers,',');

  //One entry per layer, bottom of the draw order first, each with its own
  //rows of tile indexes. A single layer map yields a one element array.
  Writeln(F,'  "layers": [');
  for l:=0 to nlayers-1 do
  begin
    Writeln(F,'    {');
    Writeln(F,'      "name": "',JStr(MapCoreBase.GetLayerName(index,l)),'",');
    Writeln(F,'      "visible": ',JBool(MapCoreBase.GetLayerVisible(index,l)),',');
    Writeln(F,'      "locked": ',JBool(MapCoreBase.GetLayerLocked(index,l)),',');
    Writeln(F,'      "tiles": [');
    for j:=0 to mheight-1 do
    begin
      line:='        [';
      for i:=0 to mwidth-1 do
      begin
        MapCoreBase.GetMapTileL(index, l, sx+i, sy+j, Tile);
        line:=line+IntToStr(Tile.ImageIndex);
        if i < mwidth-1 then line:=line+',';
      end;
      line:=line+']';
      if j < mheight-1 then line:=line+',';
      Writeln(F,line);
    end;
    Writeln(F,'      ]');
    if l < nlayers-1 then Writeln(F,'    },') else Writeln(F,'    }');
  end;
  Writeln(F,'  ],');

  //hitboxes
  hbcount:=MapCoreBase.GetHitBoxCount(index);
  Writeln(F,'  "hitBoxes": [');
  for i:=0 to hbcount-1 do
  begin
    MapCoreBase.GetHitBox(index, i, HB);
    line:='    {"id": '+IntToStr(HB.id)+', "value": '+IntToStr(HB.value)+
          ', "x": '+IntToStr(HB.x)+', "y": '+IntToStr(HB.y)+
          ', "x2": '+IntToStr(HB.x2)+', "y2": '+IntToStr(HB.y2)+'}';
    if i < hbcount-1 then line:=line+',';
    Writeln(F,line);
  end;
  Writeln(F,'  ],');

  //paths. Only ACTIVE paths are exported - "visible" is an editor flag and
  //must never decide what ends up in a build.
  //
  //Each waypoint carries both the tile coordinate and the pixel centre. The
  //pixel value is precomputed here so the runtime never multiplies, and the
  //per segment step is the 8 direction unit vector, so following the path is
  //a signed add per frame with no fixed point maths.
  pcount:=0;
  for i:=0 to MapCoreBase.GetPathCount(index)-1 do
    if MapCoreBase.GetPathActive(index,i) then inc(pcount);

  Writeln(F,'  "paths": [');
  written:=0;
  for i:=0 to MapCoreBase.GetPathCount(index)-1 do
  begin
    if not MapCoreBase.GetPathActive(index,i) then continue;
    MapCoreBase.GetPath(index,i,PathProps);

    Writeln(F,'    {');
    Writeln(F,'      "name": "',MapCoreBase.GetPathName(index,i),'",');
    Writeln(F,'      "closed": ',LowerCase(BoolToStr(PathProps.closed,true)),',');
    case PathProps.mode of
      PathModeOnce     : Writeln(F,'      "mode": "once",');
      PathModePingPong : Writeln(F,'      "mode": "pingpong",');
    else
      Writeln(F,'      "mode": "loop",');
    end;
    Writeln(F,'      "speed": ',PathProps.speed,',');
    Writeln(F,'      "pointCount": ',PathProps.PointCount,',');

    Writeln(F,'      "points": [');
    for j:=0 to PathProps.PointCount-1 do
    begin
      line:='        {"tx": '+IntToStr(PathProps.Points[j].x)+
            ', "ty": '+IntToStr(PathProps.Points[j].y)+
            ', "px": '+IntToStr(PathProps.Points[j].x*MapProps.tilewidth +
                                MapProps.tilewidth div 2)+
            ', "py": '+IntToStr(PathProps.Points[j].y*MapProps.tileheight +
                                MapProps.tileheight div 2)+
            ', "delay": '+IntToStr(PathProps.Points[j].delay)+
            ', "id": '+IntToStr(PathProps.Points[j].id)+'}';
      if j < PathProps.PointCount-1 then line:=line+',';
      Writeln(F,line);
    end;
    Writeln(F,'      ],');

    //one entry per segment: unit step plus how many tiles to walk
    Writeln(F,'      "segments": [');
    segwritten:=0;
    if PathProps.closed then segcount:=PathProps.PointCount
                        else segcount:=PathProps.PointCount-1;
    for j:=0 to segcount-1 do
    begin
      k:=j+1;
      if k >= PathProps.PointCount then k:=0;   //closing segment
      dirn:=MapCoreBase.DirectionBetween(PathProps.Points[j].x,PathProps.Points[j].y,
                                         PathProps.Points[k].x,PathProps.Points[k].y);
      //a zero length segment (two identical waypoints) has no direction and
      //is skipped - so the separator must be decided by what has actually
      //been written, not by the loop index, or the last entry can be left
      //with a trailing comma and the JSON becomes invalid
      if dirn < 0 then continue;
      steps:=abs(PathProps.Points[k].x-PathProps.Points[j].x);
      if abs(PathProps.Points[k].y-PathProps.Points[j].y) > steps then
        steps:=abs(PathProps.Points[k].y-PathProps.Points[j].y);

      if segwritten > 0 then Writeln(F,',');
      Write(F,'        {"dir": ',dirn,
              ', "dx": ',PathDirX[dirn],
              ', "dy": ',PathDirY[dirn],
              ', "tiles": ',steps,
              ', "pixels": ',steps*MapProps.tilewidth,'}');
      inc(segwritten);
    end;
    if segwritten > 0 then Writeln(F);   //terminate the last segment line
    Writeln(F,'      ]');

    inc(written);
    if written < pcount then Writeln(F,'    },') else Writeln(F,'    }');
  end;
  Writeln(F,'  ]');
  Writeln(F,'}');
end;

procedure ExportMap(filename : string;Lan : Integer;UseClipArea : boolean);
var
  mc : CodeGenRec;
  index : integer;
  ImageName : String;
  F : Text;
begin
 SetGWStartLineNumber(1000);
 MWInit(mc,F);
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 {$I-}
  Assign(F,Filename);
  Rewrite(F);
  {$I+}
  if IORESULT<>0 then exit;

  index:=MapCoreBase.GetCurrentMap;

  if MapLanIsJSON(Lan) then
  begin
    //pure JSON data descriptor - bypasses the code generator entirely
    WriteMapJSONToText(F,index,ImageName,UseClipArea);
    {$I-}
    close(F);
    {$I+}
    exit;
  end;

  if MapLanIsBasic(Lan) then ExportBasicMapHeader(mc,index,ImageName,UseClipArea)
  else if MapLanIsBasicLN(Lan) then ExportBasicLNMapHeader(mc,index,ImageName,UseClipArea)
  else if MapLanIsC(Lan) then ExportCMapHeader(mc,index,ImageName,UseClipArea)
  else if MapLanIsPascal(Lan) then ExportPascalMapHeader(mc,index,ImageName,UseClipArea)
  else if MapLanIsJS(Lan) then ExportJSMapHeader(mc,index,ImageName,UseClipArea);

  ExportMapMain(mc,index,UseClipArea);

  if MapLanIsBasic(Lan) or MapLanIsBasicLN(Lan) then Writeln(F)
  else if MapLanIsC(Lan) then Writeln(F,'};')
  else if MapLanIsPascal(Lan) then Writeln(F,');')
  else if MapLanIsJS(Lan) then Writeln(F,'];');
  {$I-}
  close(F);
{$I+}
end;


procedure WriteMapsCodeToBuffer(var F : Text);
var
  mc : CodeGenRec;
  ImageName : String;
  i : integer;
  MapCount: integer;
  Lan : integer;
  ExportProps : MapExportFormatRec;
begin
  MapCount:=MapCoreBase.GetMapCount;
  for i:=0 to MapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i,ExportProps);
    if (ExportProps.Lan > 0) and (ExportProps.MapFormat > 0) then
    begin
      MWInit(mc,F);
      Lan:=ExportProps.Lan;
      Imagename:=ExportProps.Name;

      if MapLanIsJSON(Lan) then
      begin
        WriteMapJSONToText(F,i,ImageName,False);
        continue;
      end;

      if MapLanIsBasic(Lan) then ExportBasicMapHeader(mc,i,ImageName,False)
      else if MapLanIsBasicLN(Lan) then ExportBasicLNMapHeader(mc,i,ImageName,false)
      else if MapLanIsC(Lan) then ExportCMapHeader(mc,i,ImageName,false)
      else if MapLanIsPascal(Lan) then ExportPascalMapHeader(mc,i,ImageName,false)
      else if MapLanIsJS(Lan) then ExportJSMapHeader(mc,i,ImageName,false);

      ExportMapMain(mc,i,false);

      if MapLanIsBasic(Lan) or MapLanIsBasicLN(Lan) then Writeln(F)
      else if MapLanIsC(Lan) then Writeln(F,'};')
      else if MapLanIsPascal(Lan) then Writeln(F,');')
      else if MapLanIsJS(Lan) then Writeln(F,'];');
    end;
  end;
end;

//Classify a file header so the UI can say something useful instead of the
//load silently doing nothing - which is what happened before, and would now
//happen for every pre v4 map file.
function ClassifyMapHeader(const head : MapHeaderRec) : integer;
begin
  if head.SIG <> RMMapSig then
    ClassifyMapHeader:=MapReadBadSig
  else if head.version < RMMapVersion then
    ClassifyMapHeader:=MapReadOldVersion
  else if head.version > RMMapVersion then
    ClassifyMapHeader:=MapReadNewVersion
  else
    ClassifyMapHeader:=MapReadOK;
end;

Procedure ReadMaps(filename : string);
var
  head  : MapHeaderRec;
  F : File;
begin
 Assign(F,filename);
 {$I-}
 Reset(F,1);
 Blockread(F,head,sizeof(head));
 {$I+}
 if IORESULT <>0 then exit;

 LastMapReadStatus:=ClassifyMapHeader(head);
 if LastMapReadStatus = MapReadOK then
 begin
   ReadAllMapsF(F,head.MapCount,false);
 end;
 close(f);
end;

Procedure ReadMap(filename : string);
var
  head  : MapHeaderRec;
  F : File;
  index : integer;
begin
 index:=MapCoreBase.GetCurrentMap;
 Assign(F,filename);
 {$I-}
 Reset(F,1);
 Blockread(F,head,sizeof(head));
 {$I+}
 if IORESULT <>0 then exit;

 LastMapReadStatus:=ClassifyMapHeader(head);
 if LastMapReadStatus = MapReadOK then
 begin
   ReadMapF(F,index); //just read one map
 end;
 close(f);
end;



Procedure ReadAllMapsF(var F : File;MapCount : integer;insertmode : boolean);
var
 i : integer;
 cmapcount : integer;
begin
 if insertmode then
 begin
   cmapcount:=MapCoreBase.GetMapCount;
   MapCoreBase.SetMapCount(cmapcount+MapCount);
 end
 else
 begin
   MapCoreBase.SetMapCount(MapCount);
   cmapCount:=0;
 end;

 For i:=0 to MapCount-1 do
 begin
     ReadMapF(F,i+cmapcount);
 end;
end;

Procedure ReadMapF(var F : File;index : integer);
var
 LineBuf      : array[0..255] of TileRec;
 MapProps     : MapPropsRec;
 ExportProps  : MapExportFormatRec;
 HBProps      : HitBoxRec;
 HBCount      : integer;
 PathProps    : PathRec;
 PathCount    : integer;
 i,j,l        : integer;
 nlayers      : integer;
begin
 Blockread(F,MapProps,sizeof(MapProps));
 Blockread(F,ExportProps,sizeof(ExportProps));
 Blockread(f,HBCount,sizeof(HBCount));

 MapCoreBase.SetMapSize(index,MapProps.width,MapProps.height);
 MapCoreBase.SetMapProps(index,MapProps);
 MapCoreBase.SetMapExportProps(index,ExportProps);

 //SetMapSize runs before SetMapProps and so only ever allocates layer 0.
 //Now that the real layer count is in place, make sure every layer has a
 //tile grid before we start reading into it.
 nlayers:=MapCoreBase.GetLayerCount(index);
 for l:=0 to nlayers-1 do
   MapCoreBase.AllocLayer(index,l);

 MapCoreBase.SetHitBoxCount(index,HBCount);

 //read Tiles - layer major, matching WriteMapF
 for l:=0 to nlayers-1 do
 begin
   for j:=0 to MapProps.height-1 do
   begin
     {$I-}
     blockread(f,LineBuf,MapProps.width*sizeof(TileRec));
     {$I+}
     if IORESULT <>0 then exit;
     for i:=0 to MapProps.width-1 do
     begin
       MapCoreBase.SetMapTileL(index,l,i,j,LineBuf[i]);
     end;
   end;
 end;

 //if JHCount < 1 then exit;

 for i:= 0 to HBCount-1 do
 begin
   {$I-}
   blockread(f,HBProps,sizeof(HBProps));
   {$I+}
   if IORESULT <>0 then exit;
   MapCoreBase.SetHitBox(index,i,HBProps);
 end;

 //paths - same shape as the hitboxes: a count then that many records, so
 //only the paths actually used take up space in the file
 {$I-}
 blockread(f,PathCount,sizeof(PathCount));
 {$I+}
 if IORESULT <>0 then exit;
 MapCoreBase.SetPathCount(index,PathCount);

 for i:= 0 to PathCount-1 do
 begin
   {$I-}
   blockread(f,PathProps,sizeof(PathProps));
   {$I+}
   if IORESULT <>0 then exit;
   MapCoreBase.SetPath(index,i,PathProps);
 end;
end;

Procedure WriteMapF(var F : File; index : integer);

var
 width,height : integer;
 LineBuf      : array[0..255] of TileRec;
 MapProps     : MapPropsRec;
 ExportProps  : MapExportFormatRec;
 HBProps      : HitBoxRec;
 HBCount      : integer;
 PathProps    : PathRec;
 PathCount    : integer;
 i,j,l        : integer;
 nlayers      : integer;
begin
 width:=MapCoreBase.GetMapWidth(index);
 height:=MapCoreBase.GetMapHeight(index);
 nlayers:=MapCoreBase.GetLayerCount(index);

 MapCoreBase.GetMapProps(index,MapProps);
 MapCoreBase.GetMapExportProps(index,ExportProps);
 BlockWrite(F,MapProps,sizeof(MapProps));
 BlockWrite(F,ExportProps,sizeof(ExportProps));
 //write hitboxes
 HBCount:=MapCoreBase.GetHitBoxCount(index);
 blockwrite(f,HBCount,sizeof(HBCount));   //we write the count even if 0 otherwise we don't know when we are reading data back in

 //write Tiles - layer major. The layer count itself already travelled with
 //MapProps, so nothing extra needs writing here.
 for l:=0 to nlayers-1 do
 begin
   for j:=0 to height -1 do
   begin
     for i:=0 to width-1 do
     begin
       MapCoreBase.GetMapTileL(index,l,i,j,LineBuf[i]);
     end;
     {$I-}
     blockwrite(f,LineBuf,width*sizeof(TileRec));
     {$I+}
     if IORESULT <>0 then exit;
   end;
 end;

 //if JHCount < 1 then exit;

 for i:= 0 to HBCount-1 do
 begin
   MapCoreBase.GetHitBox(index,i,HBProps);
   {$I-}
   blockwrite(f,HBProps,sizeof(HBProps));
   {$I+}
   if IORESULT <>0 then exit;
 end;

 //paths - count first even when zero, or the reader cannot tell where the
 //next map begins
 PathCount:=MapCoreBase.GetPathCount(index);
 {$I-}
 blockwrite(f,PathCount,sizeof(PathCount));
 {$I+}
 if IORESULT <>0 then exit;

 for i:= 0 to PathCount-1 do
 begin
   MapCoreBase.GetPath(index,i,PathProps);
   {$I-}
   blockwrite(f,PathProps,sizeof(PathProps));
   {$I+}
   if IORESULT <>0 then exit;
 end;
end;

Procedure WriteAllMapsF(var F : File);
var
 i : integer;
 count : integer;
begin
 count:=MapCoreBase.GetMapCount;
 For i:=0 to count-1 do
 begin
     WriteMapF(F,i);
 end;
end;

Procedure WriteMaps(filename : string);
var
  head  : MapHeaderRec;
  F : File;
begin
 head.MapCount:=MapCoreBase.GetMapCount;
 head.SIG:=RMMapSig;   // Raster Master Map
 head.version:=RMMapVersion;   // v1 added in R46

 Assign(F,filename);
 {$I-}
 Rewrite(F,1);
 Blockwrite(F,head,sizeof(head));
 {$I+}
 if IORESULT <>0 then exit;
 WriteAllMapsF(F);
 close(f);
end;


Procedure WriteMap(filename : string);
var
  head  : MapHeaderRec;
  F : File;
  index : integer;
begin
 index:=MapCoreBase.GetCurrentMap;
 head.MapCount:=1;
 head.SIG:=RMMapSig;   // Raster Master Map
 head.version:=RMMapVersion;   // v1 added in R46 , v2 added R47

 Assign(F,filename);
 {$I-}
 Rewrite(F,1);
 Blockwrite(F,head,sizeof(head));
 {$I+}
 if IORESULT <>0 then exit;
 WriteMapF(F,index);
 close(f);
end;


procedure ResExportMaps(var F:File);
var
  MapProps  : MapPropsRec;
  ExportProps  : MapExportFormatRec;
  i,j,l,index : integer;
  Tile  : TileRec;
  mwidth,mheight : integer;
  nlayers : integer;
  MapCount : integer;
  Line     : array[0..255] of smallint;
begin
 MapCount:=MapCoreBase.GetMapCount;

 for index:=0 to MapCount-1 do
 begin
   MapCoreBase.GetMapProps(index,MapProps);
   MapCoreBase.GetMapExportProps(index,ExportProps);
   if ExportProps.MapFormat > 0 then
   begin
     mwidth:=MapCoreBase.GetExportWidth(index);
     mheight:=MapCoreBase.GetExportHeight(index);
     nlayers:=ExportLayerCount(index);
     Line[0]:=mwidth;
     Line[1]:=mheight;
     Line[2]:=MapProps.tilewidth;
     Line[3]:=MapProps.tileheight;
     Line[4]:=nlayers;
     Blockwrite(F,Line,5*sizeof(smallint));  //write the header

     for l:=0 to nlayers-1 do
     begin
       for j:=0 to mheight -1 do
       begin
         for i:=0 to mwidth-1 do
         begin
           MapCoreBase.GetMapTileL(index,l,i,j,Tile);
           Line[i]:=Tile.ImageIndex;
         end;
         {$I-}
         Blockwrite(F,Line,mwidth*sizeof(smallint));
         {$I+}
         if IORESULT<>0 then exit;
       end;
     end;
   end;
 end;
end;

end.

