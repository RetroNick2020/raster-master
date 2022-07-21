unit wraylib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,LazFileUtils,rmcore,rmcodegen,rmxgfcore,rwxgf2;

procedure WriteRayLibCodeToBuffer(var F : Text; x,y,x2,y2, Lan,format : integer;ImageName : string);
procedure WriteRayLibCodeToFile(filename : string; x,y,x2,y2, Lan,format : integer);

implementation

function RayLibImageSize(width,height ,format : integer) : longint;
var
 Size : longint;
begin
 if format = 3 then Size:=3*width*height else Size:=4*width*height;
 RayLibImageSize:=Size;
end;

function GetRayLibFormatDesc(format : integer) : string;
begin
 GetRayLibFormatDesc:='';
 Case format of 1:GetRayLibFormatDesc:='RGBA - Fuchsia';
                2:GetRayLibFormatDesc:='RGBA - Index 0';
                3:GetRayLibFormatDesc:='RGB';
 end;
end;

function GetRayLibFormatValue(format : integer) : string;
begin
 GetRayLibFormatValue:='';
 Case format of 1,2:GetRayLibFormatValue:='7';  // PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
                3:GetRayLibFormatValue:='4';    // PIXELFORMAT_UNCOMPRESSED_R8G8B8
 end;
end;

procedure ExportPascalHeader(var mc : codegenrec;width,height,format : integer;ImageName : string);
var
  size : longint;
begin
 size:=RayLibImageSize(width,height,format);
 MWSetValuesTotal(mc,size);
  MWSetValuesPerLine(mc,20);
 MWSetLan(mc,PascalLan);
 MWSetValueFormat(mc,ValueFormatHex);

 Writeln(mc.FTextPtr^,'(* RayLib Pascal Image Code Created By Raster Master *)');
 Writeln(mc.FTextPtr^,'(* Size = ',size,' Format = ',GetRayLibFormatDesc(format),' Width=',width,' Height=',height,' *)');
 Writeln(mc.FTextPtr^,'  ',ImageName,'_Size = ',size,';');
 Writeln(mc.FTextPtr^,'  ',ImageName,'_Format = ', GetRayLibFormatValue(format),';');
 Writeln(mc.FTextPtr^,'  ',ImageName,'_Width = ',width,';');
 Writeln(mc.FTextPtr^,'  ',ImageName,'_Height = ',height,';');
 Writeln(mc.FTextPtr^,'  ',ImageName,' : array[0..',size-1,'] of byte = (');

end;


procedure ExportCHeader(var mc : codegenrec;width,height,format : integer;ImageName : string);
var
  size : longint;
begin
 size:=RayLibImageSize(width,height,format);
 MWSetValuesTotal(mc,size);
 MWSetValuesPerLine(mc,20);

 MWSetLan(mc,CLan);
 MWSetValueFormat(mc,ValueFormatHex);

 Writeln(mc.FTextPtr^,'/* RayLib C Image Code Created By Raster Master */');
 Writeln(mc.FTextPtr^,'/* Size = ',size,' Format = ',GetRayLibFormatDesc(format),' Width=',width,' Height=',height,' */');
 Writeln(mc.FTextPtr^,'#define ',ImageName,'_Size   ',size);
 Writeln(mc.FTextPtr^,'#define ',ImageName,'_Format ',GetRayLibFormatValue(format));
 Writeln(mc.FTextPtr^,'#define ',ImageName,'_Width  ',width);
 Writeln(mc.FTextPtr^,'#define ',ImageName,'_Height ',height);
 Writeln(mc.FTextPtr^,'static unsigned char ',Imagename, '[',size,']  = {');
end;



procedure WriteRayLibCodeToBuffer(var F : Text; x,y,x2,y2, Lan,format : integer;ImageName : string);
var
  mc : codegenrec;
  width,height : integer;
  i,j : integer;
  PixelIndex : integer;
  cr    : TRMColorRec;
  alpha  : integer;
begin
  MWInit(mc,F);
  width:=x2-x+1;
  height:=y2-y+1;

  case Lan of FPLan:ExportPascalHeader(mc,width,height,format,ImageName);
               gccLan:ExportCHeader(mc,width,height,format,ImageName);
  end;

  for j:=y to y2 do
  begin
    for i:=x to x2 do
    begin
       PixelIndex:=GetPixel(i,j);
       GetColor(PixelIndex,cr);
       alpha:=255;

       if (format = 1) then
       begin
         if (cr.r = 255) and (cr.b=255) and (cr.g=0) then   //if fuschia
         begin
           alpha:=0;        // Alpha     0 = transparent
         end;
         MWWriteByte(mc,cr.r);
         MWWriteByte(mc,cr.g);
         MWWriteByte(mc,cr.b);
         MWWriteByte(mc,alpha);
       end
       else if (format = 2) then
       begin
         if PixelIndex = 0 then
         begin
           alpha:=0;                 // transparent
         end;
         MWWriteByte(mc,cr.r);
         MWWriteByte(mc,cr.g);
         MWWriteByte(mc,cr.b);
         MWWriteByte(mc,alpha);
       end
       else   //must be format 3 - RGB
       begin
         MWWriteByte(mc,cr.r);
         MWWriteByte(mc,cr.g);
         MWWriteByte(mc,cr.b);
       end;
    end;
  end;

  Case Lan of gccLan:Writeln(F,'};');
               FPLan:Writeln(F,');');
  End;
end;


procedure WriteRayLibCodeToFile(filename : string; x,y,x2,y2, Lan,format : integer);
var
 F : Text;
 ImageName : string;
begin
 {$I-}
  Assign(F,Filename);
  Rewrite(F);
 {$I+}
  if IORESULT<>0 then exit;

  Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
  WriteRayLibCodeToBuffer(F,x,y,x2,y2,Lan,format,ImageName);

 {$I-}
  close(F);
 {$I+}
end;


end.

