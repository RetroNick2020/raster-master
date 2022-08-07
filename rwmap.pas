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

procedure ExportMap(filename : string; Lan : integer);
procedure WriteMapsCodeToBuffer(var F : Text);
procedure ResExportMaps(var F:File);




implementation



procedure ExportPascalMapHeader(var mc : CodeGenRec; index : integer;ImageName : string);
var
  MapProps   : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);

 size:=mwidth*mheight+4;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,PascalLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,'(* Pascal Map Code Created By Raster Master *)');
 Writeln(mc.FTextPtr^,'(* Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' *)');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Size   =  ',size,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Width  = ',mwidth,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Height =',mheight,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Tile_Width  = ',MapProps.tilewidth,';');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_Tile_Height = ',MapProps.tileheight,';');
 Writeln(mc.FTextPtr^,'  ',ImageName,' : array[0..',size-1,'] of integer = (');
end;

procedure ExportCMapHeader(var mc : CodeGenRec; index : integer;ImageName : string);
var
  MapProps   : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);

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

procedure ExportBasicMapHeader(var mc : CodeGenRec; index : integer;ImageName : string);
var
  MapProps    : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);


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

procedure ExportBasicLNMapHeader(var mc : CodeGenRec; index : integer;ImageName : string);
var
  MapProps    : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
begin
 //SetGWStartLineNumber(1000);

 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);


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
procedure ExportMapMain(var mc : CodeGenRec; index : integer);
var
  MapProps : MapPropsRec;
  i,j : integer;
  Tile  : TileRec;
  mwidth,mheight : integer;
begin
 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);

 MWWriteInteger(mc,mwidth);
 MWWriteInteger(mc,mheight);
 MWWriteInteger(mc,MapProps.tilewidth);
 MWWriteInteger(mc,MapProps.tileheight);

 for j:=0 to mheight -1 do
 begin
   for i:=0 to mwidth-1 do
   begin
     MapCoreBase.GetMapTile(index,i,j,Tile);
     {$I-}
     MWWriteInteger(mc,Tile.ImageIndex);
     {$I+}
     if IORESULT<>0 then exit;
   end;
 end;
end;


procedure ExportMap(filename : string;Lan : Integer);
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
  Case Lan of BasicLan:ExportBasicMapHeader(mc,index,ImageName);
            BasicLnLan:ExportBasicLNMapHeader(mc,index,ImageName);
                  CLan:ExportCMapHeader(mc,index,ImageName);
             PascalLan:ExportPascalMapHeader(mc,index,ImageName);
  End;
  ExportMapMain(mc,index);
  Case Lan of BasicLan,BasicLNLan:Writeln(F);
                             CLan:Writeln(F,'};');
                        PascalLan:Writeln(F,');');
  End;
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

      Case Lan of BasicLan,FBBasicLan,QB64BasicLan,AQBBasicLan:ExportBasicMapHeader(mc,i,ImageName);
                BasicLnLan:ExportBasicLNMapHeader(mc,i,ImageName);
                      CLan:ExportCMapHeader(mc,i,ImageName);
                 PascalLan:ExportPascalMapHeader(mc,i,ImageName);
      End;
      ExportMapMain(mc,i);
      Case Lan of BasicLan,FBBasicLan,QB64BasicLan,AQBBasicLan,BasicLNLan:Writeln(F);
                      CLan:Writeln(F,'};');
                 PascalLan:Writeln(F,');');
      End;
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
 i,j : integer;
begin
 Blockread(F,MapProps,sizeof(MapProps));
 Blockread(F,ExportProps,sizeof(ExportProps));

 MapCoreBase.SetMapSize(index,MapProps.width,MapProps.height);
 MapCoreBase.SetMapProps(index,MapProps);
 MapCoreBase.SetMapExportProps(index,ExportProps);

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
end;

Procedure WriteMapF(var F : File; index : integer);

var
 width,height : integer;
 LineBuf      : array[0..255] of TileRec;
 MapProps     : MapPropsRec;
 ExportProps  : MapExportFormatRec;
 i,j : integer;
begin
 width:=MapCoreBase.GetMapWidth(index);
 height:=MapCoreBase.GetMapHeight(index);

 MapCoreBase.GetMapProps(index,MapProps);
 MapCoreBase.GetMapExportProps(index,ExportProps);
 BlockWrite(F,MapProps,sizeof(MapProps));
 BlockWrite(F,ExportProps,sizeof(ExportProps));

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

