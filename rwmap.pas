unit rwmap;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, LazFileUtils, mapcore,gwbasic;

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

const
 NoLan    = 0;
 BasicLan = 1;
 BasicLNLan = 2;
 CLan     = 3;
 PascalLan= 4;

 ValueFormatDecimal = 0;
 ValueFormatHex = 1;

type
  MapCodeRec = Record
                     InDentSize      : integer; //how many characters to pad
                      IndentOnFirst   : Boolean; //indent on first line
                      ValuesPerLine   : integer; //# values seperated by comma
                      ValuesTotal     : longint; //#number of values we are going to write
                      ValueFormat     : integer;

                      VC              : integer;  //value counter - how many byte/integer written
                      VCL             : longint;  //value counter per line
                      LineCount       : integer; //line counter
                      FTextPtr        : ^Text;     //text file handle
                      LanId           : integer;
  end;



implementation

procedure MWSetIndent(var mc : MapCodeRec;isize : integer);
begin
  mc.InDentSize:=isize;
end;

procedure MWSetIndentOnFirstLine(var mc : MapCodeRec;indent : boolean);
begin
  mc.IndentOnFirst:=indent;
end;

procedure MWSetValuesPerLine(var mc : MapCodeRec;amount : integer);
begin
  mc.ValuesPerLine:=amount;
end;

procedure MWSetValuesTotal(var mc : MapCodeRec;amount : longint);
begin
  mc.ValuesTotal:=amount;
end;

procedure MWSetValueFormat(var mc : MapCodeRec;format : integer);
begin
  mc.ValueFormat:=format;
end;

procedure MWSetLan(var mc : MapCodeRec;Lan : integer);
begin
  mc.LanId:=Lan;
end;

procedure MWInit(var mc : MapCodeRec;var F : Text);
begin
 mc.FTextPtr:=@F;
 mc.VC:=0;
 mc.VCL:=0;
 mc.LineCount:=0;

 MWSetIndent(mc,10);
 MWSetIndentOnFirstLine(mc,true);
 MWSetValuesPerLine(mc,10);
 MWSetValuesTotal(mc,0);
 MWSetValueFormat(mc,ValueFormatDecimal);
 MWSetLan(mc,PascalLan);
end;

procedure MWWriteLineNumber(var mc : MapCodeRec);
begin
 if (mc.LanId<>BasicLNLan) then exit;
 if mc.VCL = 0 then
 begin
    Write(mc.FTextPtr^,GetGWNextLineNumber,' ');
 end;
end;

procedure MWWriteLineFeed(var mc : MapCodeRec);
begin
 if (mc.VC=mc.ValuesTotal) then exit;
 if mc.VCL = mc.ValuesPerLine then
 begin
    WriteLn(mc.FTextPtr^);
    mc.VCL:=0;
    inc(mc.LineCount);
 end;
end;

procedure MWWriteData(var mc : MapCodeRec);
begin
  if (mc.LanId=BasicLan) or (mc.LanId=BasicLNLan) then
  begin
    if mc.VCL = 0 then Write(mc.FTextPtr^,'DATA ');
  end;
end;

procedure MWWriteIndent(var mc : MapCodeRec);
begin
 if (mc.LanId=BasicLan) or (mc.LanId=BasicLNLan)  then exit;
 if (mc.VCL = 0) then
 begin
  if (mc.IndentOnFirst = false) and (mc.LineCount=0) then exit;
  Write(mc.FTextPtr^,' ':mc.InDentSize);
 end;
end;

procedure MWWriteComma(var mc : MapCodeRec);
begin
 if (mc.VC=mc.ValuesTotal) then
 begin
//   write(FTEXT,'END');
   exit;
 end;

 if mc.VCL > 0 then
 begin
   if (mc.VCL<mc.ValuesPerLine) then
   begin
     Write(mc.FTextPtr^,',');
   end
   else if (mc.VCL=mc.ValuesPerLine)  then  //end of line but not last value
   begin
     if (mc.LanId<>BasicLan) and (mc.LanId<>BasicLNLan) then Write(mc.FTextPtr^,','); //if not basic write a comma
   end;
 end;
end;

function ByteToHex(num : byte;LanId : integer) : string;
var
 HStr : String;
begin
 HStr:=hexstr(num,2);
 if LanId=BasicLan then HStr:='&H'+HStr;
 if LanId=PascalLan then HStr:='$'+HStr;
 if LanId=CLan then HStr:='0x'+HStr;
 ByteToHex:=HStr;
end;

procedure MWWriteByte(var mc : MapCodeRec;value : byte);
begin
 MWWriteLineNumber(mc); //line numbers - only if lan - basicLN
 MWWriteData(mc);       //basiclan data statements -  lanid should be basiclan
 MWWriteIndent(mc);    // method will decide if indent needed

 inc(mc.VC);
 inc(mc.VCL);

 if  mc.ValueFormat = ValueFormatDecimal then
 begin
   Write(mc.FTextPtr^,value);
 end
 else if mc.ValueFormat = ValueFormatHex then
 begin
   Write(mc.FTextPtr^,ByteToHEx(value,mc.LanId));
 end;

 MWWriteComma(mc);     // method will decide if comma needed
 MWWriteLineFeed(mc);  // method will decide if line feed needed
end;

function IntegerToHex(num,LanId : integer) : string;
var
 HStr : String;
begin
 HStr:=hexstr(num,4);
 if LanId=BasicLan then HStr:='&H'+HStr;
 if LanId=PascalLan then HStr:='$'+HStr;
 if LanId=CLan then HStr:='0x'+HStr;
 IntegerToHex:=HStr;
end;

procedure MWWriteInteger(var mc : MapCodeRec;value : integer);
begin
 MWWriteLineNumber(mc); //line numbers - only if lan - basicLN
 MWWriteData(mc);       //basiclan data statements -  lanid should be basiclan
 MWWriteIndent(mc);    // method will decide if indent needed

 inc(mc.VC);
 inc(mc.VCL);

 if  mc.ValueFormat = ValueFormatDecimal then
 begin
   Write(mc.FTextPtr^,value);
 end
 else if mc.ValueFormat = ValueFormatHex then
 begin
   Write(mc.FTextPtr^,IntegerToHex(value,mc.LanId));
 end;

 MWWriteComma(mc);     // method will decide if comma needed
 MWWriteLineFeed(mc);  // method will decide if line feed needed
end;


procedure ExportPascalMapHeader(var mc : MapCodeRec; index : integer;ImageName : string);
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

 Writeln(mc.FTextPtr^,'(* Pascal Map Code *)');
 Writeln(mc.FTextPtr^,'(* Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' *)');
 Writeln(mc.FTextPtr^,'  ',ImageName,' : array[0..',size-1,'] of integer = (');
end;

procedure ExportCMapHeader(var mc : MapCodeRec; index : integer;ImageName : string);
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

 Writeln(mc.FTextPtr^,'/* C Map Code */');
 Writeln(mc.FTextPtr^,'/* Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight,' */');
 Writeln(mc.FTextPtr^,'  ','int ',Imagename, '[',size,']  = {');
end;

procedure ExportBasicMapHeader(var mc : MapCodeRec; index : integer;ImageName : string);
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

 Writeln(mc.FTextPtr^,#39,' Basic Map Code');
 Writeln(mc.FTextPtr^,#39,' Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight);
 Writeln(mc.FTextPtr^,#39,' ',Imagename);
end;

procedure ExportBasicLNMapHeader(var mc : MapCodeRec; index : integer;ImageName : string);
var
  MapProps    : MapPropsRec;
  size : longint;
  mwidth,mheight : integer;
begin
 SetGWStartLineNumber(1000);

 MapCoreBase.GetMapProps(index,MapProps);
 mwidth:=MapCoreBase.GetExportWidth(index);
 mheight:=MapCoreBase.GetExportHeight(index);


 size:=mwidth*mheight+4;
 MWSetValuesTotal(mc,size);
 MWSetLan(mc,BasicLNLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' Basic Map Code');
 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' Size =',size,' Width=',mwidth,' Height=',mheight,' Tile Width=',
         MapProps.tilewidth,' Tile Height=',MapProps.tileheight);
 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' ',Imagename);
end;

//same code for languages - only header is different
procedure ExportMapMain(var mc : MapCodeRec; index : integer);
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
  mc : MapCodeRec;
  index : integer;
  ImageName : String;
  F : Text;
begin
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
  mc : MapCodeRec;
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

      Case Lan of BasicLan:ExportBasicMapHeader(mc,i,ImageName);
                BasicLnLan:ExportBasicLNMapHeader(mc,i,ImageName);
                      CLan:ExportCMapHeader(mc,i,ImageName);
                 PascalLan:ExportPascalMapHeader(mc,i,ImageName);
      End;
      ExportMapMain(mc,i);
      Case Lan of BasicLan,BasicLNLan:Writeln(F);
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

 MapCoreBase.SetMapProps(index,MapProps);
 MapCoreBase.SetMapExportProps(index,ExportProps);

 MapCoreBase.SetMapSize(index,MapProps.width,MapProps.height);
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

