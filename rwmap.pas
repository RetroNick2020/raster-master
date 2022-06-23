unit rwmap;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, LazFileUtils, mapcore;

Procedure ReadMap(filename : string);
Procedure ReadMaps(filename : string);
Procedure ReadAllMapsF(var F : File;MapCount : integer;insertmode : boolean);
Procedure ReadMapF(var F : File;index : integer);

Procedure WriteMap(filename : string);
Procedure WriteMaps(filename : string);
Procedure WriteAllMapsF(var F : File);
Procedure WriteMapF(var F : File; index : integer);

procedure ExportPascalMap(filename : string);
procedure ExportCMap(filename : string);
procedure ExportBasicMap(filename : string);

const
 BasicLan = 1;
 CLan     = 2;
 PascalLan= 3;

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
                      FText           : Text;     //text file handle
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

procedure MWInit(var mc : MapCodeRec;filename : string);
begin
  MWSetIndent(mc,10);
  MWSetIndentOnFirstLine(mc,true);
  MWSetValuesPerLine(mc,10);
  MWSetValuesTotal(mc,0);
  MWSetValueFormat(mc,ValueFormatDecimal);
  MWSetLan(mc,PascalLan);

  mc.VC:=0;
  mc.VCL:=0;
  mc.LineCount:=0;
end;

procedure MWWriteLineFeed(var mc : MapCodeRec);
begin
 if (mc.VC=mc.ValuesTotal) then exit;
 if mc.VCL = mc.ValuesPerLine then
 begin
    WriteLn(mc.FText);
    mc.VCL:=0;
    inc(mc.LineCount);
 end;
end;

procedure MWWriteData(var mc : MapCodeRec);
begin
  if mc.LanId<>BasicLan then exit;
  //to do - write line numbers if gwbasic
  if mc.VCL = 0 then Write(mc.FText,'DATA ');
end;

procedure MWWriteIndent(var mc : MapCodeRec);
begin
 if mc.LanId=BasicLan then exit;
 if (mc.VCL = 0) then
 begin
  if (mc.IndentOnFirst = false) and (mc.LineCount=0) then exit;
  Write(mc.FText,' ':mc.InDentSize);
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
     Write(mc.FText,',');
   end
   else if (mc.VCL=mc.ValuesPerLine)  then  //end of line but not last value
   begin
     if (mc.LanId<>BasicLan) then Write(mc.FText,','); //if not basic write a comma
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
 MWWriteData(mc);       //basiclan data statements -  lanid should be basiclan
 MWWriteIndent(mc);    // method will decide if indent needed

 inc(mc.VC);
 inc(mc.VCL);

 if  mc.ValueFormat = ValueFormatDecimal then
 begin
   Write(mc.FText,value);
 end
 else if mc.ValueFormat = ValueFormatHex then
 begin
   Write(mc.FText,ByteToHEx(value,mc.LanId));
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
 MWWriteData(mc);       //basiclan data statements -  lanid should be basiclan
 MWWriteIndent(mc);    // method will decide if indent needed

 inc(mc.VC);
 inc(mc.VCL);

 if  mc.ValueFormat = ValueFormatDecimal then
 begin
   Write(mc.FText,value);
 end
 else if mc.ValueFormat = ValueFormatHex then
 begin
   Write(mc.FText,IntegerToHex(value,mc.LanId));
 end;

 MWWriteComma(mc);     // method will decide if comma needed
 MWWriteLineFeed(mc);  // method will decide if line feed needed
end;



procedure ExportPascalMap(filename : string);
var
  mc : MapCodeRec;
  index : integer;
  i,j : integer;
  props : MapPropsRec;
  Tile  : TileRec;
  size : longint;
  ImageName : String;
begin
 {$I-}
  Assign(mc.FText,Filename);
  Rewrite(mc.FText);
  {$I+}
  if IORESULT<>0 then exit;

  index:=MapCoreBase.GetCurrentMap;
  MapCoreBase.GetMapProps(index,props);
  size:=props.width*props.height+4;

  MWInit(mc,filename);
  MWSetValuesTotal(mc,size);
  MWSetLan(mc,PascalLan);

  MWSetValueFormat(mc,ValueFormatDecimal);

  Writeln(mc.FText,'(* Pascal Map Code *)');
  Writeln(mc.FText,'(* Size =',size,' Width=',props.width,' Height=',props.height,' Tile Width=',
          props.tilewidth,' Tile Height=',props.tileheight,' *)');

  Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
  Writeln(mc.FText,'  ',ImageName,' : array[0..',size-1,'] of integer = (');

  MWWriteInteger(mc,props.width);
  MWWriteInteger(mc,props.height);
  MWWriteInteger(mc,props.tilewidth);
  MWWriteInteger(mc,props.tileheight);

  for j:=0 to props.height -1 do
  begin
    for i:=0 to props.width-1 do
    begin
      MapCoreBase.GetMapTile(index,i,j,Tile);
      {$I-}
      MWWriteInteger(mc,Tile.ImageIndex);
      {$I+}
      if IORESULT<>0 then exit;
    end;
  end;
  Writeln(mc.FText,');');
  {$I-}
  close(mc.Ftext);
{$I+}
end;

procedure ExportCMap(filename : string);
var
  mc : MapCodeRec;
  index : integer;
  i,j : integer;
  props : MapPropsRec;
  Tile  : TileRec;
  size : longint;
  ImageName : String;
begin
 {$I-}
  Assign(mc.FText,Filename);
  Rewrite(mc.FText);
  {$I+}
  if IORESULT<>0 then exit;

  index:=MapCoreBase.GetCurrentMap;
  MapCoreBase.GetMapProps(index,props);
  size:=props.width*props.height+4;

  MWInit(mc,filename);
  MWSetValuesTotal(mc,size);
  MWSetLan(mc,CLan);

  MWSetValueFormat(mc,ValueFormatDecimal);

  Writeln(mc.FText,'/* C Map Code */');
  Writeln(mc.FText,'/* Size =',size,' Width=',props.width,' Height=',props.height,' Tile Width=',
          props.tilewidth,' Tile Height=',props.tileheight,' */');

  Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
  Writeln(mc.FText,'  ','int ',Imagename, '[',size,']  = {');

  MWWriteInteger(mc,props.width);
  MWWriteInteger(mc,props.height);
  MWWriteInteger(mc,props.tilewidth);
  MWWriteInteger(mc,props.tileheight);

  for j:=0 to props.height -1 do
  begin
    for i:=0 to props.width-1 do
    begin
      MapCoreBase.GetMapTile(index,i,j,Tile);
      {$I-}
      MWWriteInteger(mc,Tile.ImageIndex);
      {$I+}
      if IORESULT<>0 then exit;
    end;
  end;
  Writeln(mc.FText,'};');
  {$I-}
  close(mc.Ftext);
{$I+}
end;

procedure ExportBasicMap(filename : string);
var
  mc : MapCodeRec;
  index : integer;
  i,j : integer;
  props : MapPropsRec;
  Tile  : TileRec;
  size : longint;
  ImageName : String;
begin
 {$I-}
  Assign(mc.FText,Filename);
  Rewrite(mc.FText);
  {$I+}
  if IORESULT<>0 then exit;

  index:=MapCoreBase.GetCurrentMap;
  MapCoreBase.GetMapProps(index,props);
  size:=props.width*props.height+4;

  MWInit(mc,filename);
  MWSetValuesTotal(mc,size);
  MWSetLan(mc,BasicLan);

  MWSetValueFormat(mc,ValueFormatDecimal);

  Writeln(mc.FText,#39,' Basic Map Code');
  Writeln(mc.FText,#39,' Size =',size,' Width=',props.width,' Height=',props.height,' Tile Width=',
          props.tilewidth,' Tile Height=',props.tileheight);

  Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
  Writeln(mc.FText,#39,' ',Imagename);

  MWWriteInteger(mc,props.width);
  MWWriteInteger(mc,props.height);
  MWWriteInteger(mc,props.tilewidth);
  MWWriteInteger(mc,props.tileheight);

  for j:=0 to props.height -1 do
  begin
    for i:=0 to props.width-1 do
    begin
      MapCoreBase.GetMapTile(index,i,j,Tile);
      {$I-}
      MWWriteInteger(mc,Tile.ImageIndex);
      {$I+}
      if IORESULT<>0 then exit;
    end;
  end;
  Writeln(mc.FText);
  {$I-}
  close(mc.Ftext);
{$I+}
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
 i,j : integer;
begin
 Blockread(F,MapProps,sizeof(MapProps));
 MapCoreBase.SetMapProps(index,MapProps);
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
 i,j : integer;
begin
 width:=MapCoreBase.GetMapWidth(index);
 height:=MapCoreBase.GetMapHeight(index);

 MapCoreBase.GetMapProps(index,MapProps);
 BlockWrite(F,MapProps,sizeof(MapProps));

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
 head.version:=RMMapVersion;   // v1 added in R46

 Assign(F,filename);
 {$I-}
 Rewrite(F,1);
 Blockwrite(F,head,sizeof(head));
 {$I+}
 if IORESULT <>0 then exit;
 WriteMapF(F,index);
 close(f);
end;


end.

