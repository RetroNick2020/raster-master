unit rwmap;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, LazFileUtils,gwbasic, mapcore,rmcodegen;

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

implementation

procedure ExportPascalMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps   : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
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

 size:=mwidth*mheight+4;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,PascalLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,'(* Pascal Map Code Created By Raster Master *)');
 Writeln(mc.FTextPtr^,'(* Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' *)');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Size   = ',size,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Width  = ',mwidth,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Height = ',mheight,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Tile_Width  = ',MapProps.tilewidth,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Tile_Height = ',MapProps.tileheight,';');
 Writeln(mc.FTextPtr^,'  ',ImageName,' : array[0..',size-1,'] of integer = (');
end;

procedure ExportCMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps   : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
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

 size:=mwidth*mheight+4;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,CLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,'/* C Map Code Created By Raster Master */');
 Writeln(mc.FTextPtr^,'/* Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' */');
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Size   ',size);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Width  ',mwidth);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Height ',mheight);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Tile_Width  ',MapProps.tilewidth);
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_Tile_Height ',MapProps.tileheight);
 Writeln(mc.FTextPtr^,'  ','int ',Imagename, '[',size,']  = {');
end;

procedure ExportBasicMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps    : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
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

 size:=mwidth*mheight+4;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,BasicLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,ImageName+'MapLabel:');
 Writeln(mc.FTextPtr^,#39,' Basic Map Code Created By Raster Master');
 Writeln(mc.FTextPtr^,#39,' Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight);
 Writeln(mc.FTextPtr^,#39,' ',Imagename);
end;

procedure ExportBasicLNMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps    : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
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

 size:=mwidth*mheight+4;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,BasicLNLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' Basic Map Code Created By Raster Master');
 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight);
 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' ',Imagename);
end;

//same code for languages - only header is different
procedure ExportMapMain(var mc : CodeGenRec; index : integer;UseClipArea : boolean);
var
  MapProps : MapPropsRec;
  i,j : integer;
  Tile  : TileRec;
  mwidth,mheight : integer;
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

 MWWriteInteger(mc,mwidth);
 MWWriteInteger(mc,mheight);
 MWWriteInteger(mc,MapProps.tilewidth);
 MWWriteInteger(mc,MapProps.tileheight);

 for j:=starty to starty+mheight-1 do
 begin
   for i:=startx to startx+mwidth-1 do
   begin
     MapCoreBase.GetMapTile(index,i,j,Tile);
     {$I-}
     MWWriteInteger(mc,Tile.ImageIndex);
     {$I+}
     if IORESULT<>0 then exit;
   end;
 end;
end;


procedure ExportJSMapHeader(var mc : CodeGenRec; index : integer;ImageName : string;UseClipArea : boolean);
var
  MapProps   : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
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

 size:=mwidth*mheight+4;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,JSLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,'// JavaScript Map Code Created By Raster Master');
 Writeln(mc.FTextPtr^,'// Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight);
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
  i, j, sx, sy, mwidth, mheight, hbcount : integer;
  line : string;
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

  //tiles as rows of image indexes
  Writeln(F,'  "tiles": [');
  for j:=0 to mheight-1 do
  begin
    line:='    [';
    for i:=0 to mwidth-1 do
    begin
      MapCoreBase.GetMapTile(index, sx+i, sy+j, Tile);
      line:=line+IntToStr(Tile.ImageIndex);
      if i < mwidth-1 then line:=line+',';
    end;
    line:=line+']';
    if j < mheight-1 then line:=line+',';
    Writeln(F,line);
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

 if  (head.SIG = RMMapSig) and (head.version = RMMapVersion) then
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

 if  (head.SIG = RMMapSig) and (head.version = RMMapVersion) then
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
 i,j : integer;
begin
 Blockread(F,MapProps,sizeof(MapProps));
 Blockread(F,ExportProps,sizeof(ExportProps));
 Blockread(f,HBCount,sizeof(HBCount));

 MapCoreBase.SetMapSize(index,MapProps.width,MapProps.height);
 MapCoreBase.SetMapProps(index,MapProps);
 MapCoreBase.SetMapExportProps(index,ExportProps);

 MapCoreBase.SetHitBoxCount(index,HBCount);

 //read Tiles
 for j:=0 to MapProps.height-1 do
 begin
   {$I-}
   blockread(f,LineBuf,MapProps.width*sizeof(TileRec));
   {$I+}
   if IORESULT <>0 then exit;
   for i:=0 to MapProps.width-1 do
   begin
     MapCoreBase.SetMapTile(index,i,j,LineBuf[i]);
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

end;

Procedure WriteMapF(var F : File; index : integer);

var
 width,height : integer;
 LineBuf      : array[0..255] of TileRec;
 MapProps     : MapPropsRec;
 ExportProps  : MapExportFormatRec;
 HBProps      : HitBoxRec;
 HBCount      : integer;
 i,j : integer;
begin
 width:=MapCoreBase.GetMapWidth(index);
 height:=MapCoreBase.GetMapHeight(index);

 MapCoreBase.GetMapProps(index,MapProps);
 MapCoreBase.GetMapExportProps(index,ExportProps);
 BlockWrite(F,MapProps,sizeof(MapProps));
 BlockWrite(F,ExportProps,sizeof(ExportProps));
 //write hitboxes
 HBCount:=MapCoreBase.GetHitBoxCount(index);
 blockwrite(f,HBCount,sizeof(HBCount));   //we write the count even if 0 otherwise we don't know when we are reading data back in

 //write Tiles
 for j:=0 to height -1 do
 begin
   for i:=0 to width-1 do
   begin
     MapCoreBase.GetMapTile(index,i,j,LineBuf[i]);
   end;
   {$I-}
   blockwrite(f,LineBuf,width*sizeof(TileRec));
   {$I+}
   if IORESULT <>0 then exit;
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
  i,j,index : integer;
  Tile  : TileRec;
  mwidth,mheight : integer;
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
     Line[0]:=mwidth;
     Line[1]:=mheight;
     Line[2]:=MapProps.tilewidth;
     Line[3]:=MapProps.tileheight;
     Blockwrite(F,Line,4*sizeof(smallint));  //write the header

     for j:=0 to mheight -1 do
     begin
       for i:=0 to mwidth-1 do
       begin
         MapCoreBase.GetMapTile(index,i,j,Tile);
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

end.

