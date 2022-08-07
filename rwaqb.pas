unit rwaqb;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,LazFileUtils,rmcodegen,rmxgfcore;

Function WriteAQBBitMapCodeToFile(x,y,x2,y2 : integer;filename:string):word;
Function WriteAQBBitMapCodeToBuffer(Var F : Text;x,y,x2,y2 : integer;imagename:string):word;
function nColorsToBitPlanes(nColors : integer) : integer;


implementation

function nColorsToBitPlanes(nColors : integer) : integer;
var
 BP : integer;
begin
 BP:=0;
 Case nColors of 2:BP:=1;
                 4:BP:=2;
                 8:BP:=3;
                16:BP:=4;
                32:BP:=5;
                64:BP:=6;
               128:BP:=7;
               256:BP:=8;
 end;
 nColorsToBitPlanes:=BP;
end;

Function WriteAQBBitMapCodeToBuffer(Var F : Text;x,y,x2,y2 : integer;imagename:string):word;
var
  width,height : integer;
  Depth : integer;
  size : longword;
  mc   : CodeGenRec;
  i,j  : integer;
  PixelColor : integer;
begin
 MWInit(mc,F);
 MWSetLan(mc,BasicLan);
 MWSetValuesPerLine(mc,20);
 MWSetValueFormat(mc,ValueFormatHex);

 width:=x2-x+1;
 height:=y2-y+1;
 depth:=nColorsToBitPlanes(GetMaxColor+1);
 Size:=width*height;
 MWSetValuesTotal(mc,Size);

 writeln(F,#39,' Amiga AQB BitMap Image, Size= ', Size,' Width= ',width,' Height= ',height, ' Depth= ',depth);
 writeln(F,#39,' ',Imagename);

 For j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
      PixelColor:=GetPixel(i,j);
      MWWriteByte(mc,PixelColor);
   end;
 end;

 writeln(f);
 WriteAQBBitMapCodeToBuffer:=IORESULT;
end;

Function WriteAQBBitMapCodeToFile(x,y,x2,y2 : integer;filename:string):word;
var
  F : Text;
  Imagename : string;
begin
 SetCoreActive;
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 Assign(F,filename);
{$I-}
 Rewrite(F);
 WriteAQBBitMapCodeToBuffer(F,x,y,x2,y2,imagename);
 Close(F);
{$I+}
 WriteAQBBitMapCodeToFile:=IORESULT;
end;
end.

