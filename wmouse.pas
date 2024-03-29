unit wmouse;

{$mode objfpc}

interface

uses
  Classes, SysUtils,LazFileUtils,rmxgfcore,rwxgf,gwbasic;

Function WriteMShapeToCode(x,y,LanType,imageid : word;filename:string):word;
Function WriteMShapeToFile(x,y : word;filename:string):word;
function GetMouseShapeSize : longint;

Function WriteMShapeCodeToBuffer(var data :BufferRec;x,y,Lan,imageId : word; imagename:string):word;
Function WriteMShapeToBuffer(x,y  : word;var F : File):word;

implementation

type
  MouseShapeType = array[1..32] of Word;

function GetMouseShapeSize : longint;
begin
  GetMouseShapeSize:=sizeof(MouseShapeType);
end;

function bin2dec (s : string) : longint;
var
  tmp : longint;
  p : byte;
begin
  tmp := 0;
  for p := 1 to length(s) do
  begin
    inc(tmp,longint(ord(s[length(s)])-48) shl pred(p));
    dec(s[0]);
  end;
  bin2dec := tmp;
end;

//the width and height will always 16x16 - we just need the starting x,y cords
Procedure CreateMouseShape(x,y : integer; Var MouseShape : MouseShapeType);
Var
  i,j : integer;
  MImage,MMask : String[16];
  count : integer;
  pixColor    : integer;
begin
  count:=1;
  For j:=1 to 16 do
  begin
     MImage :='1111111111111111';
     MMask  :='0000000000000000';

     For i:=1 to 16 do
     begin
      pixColor:=GetPixel(x+i-1,y+j-1);
      If pixColor = 0 then   // 0 is black
       begin
         MImage[i]:='0';
         MMask[i]:='0';
       end
       else if pixColor=3 then  //3 is white
       begin
         MImage[i]:='0';
         MMask[i]:='1';
       end
       else if pixColor=2 then  // 2 pink / tranparent
       begin
         MImage[i]:='1';
         MMask[i]:='0';
       end
       else
       begin                    // 1 is cyan   XOR the bits on this part of the mouse shape
         MImage[i]:='1';
         MMask[i]:='1';
       end;
     end;
     MouseShape[Count]:=Bin2Dec(MImage);
     MouseShape[Count+16]:=Bin2Dec(MMask);
     Inc(count);
   end;
end;

Function GetMouseShapeLineStr(x, y : word) : string;
var
  pixColor : integer;
  TextImage : String[16];
  i : integer;
begin
   TextImage:='                ';
   for i:=1 to 16 do
   begin
      pixColor:=GetPixel(x+i-1,y);
       If pixColor = 0 then   // 0 is black
       begin
         TextImage[i]:='*';
       end
       else if pixColor=3 then  //3 is white
       begin
         TextImage[i]:='#';
        end
       else if pixColor=2 then  // 2 pink / tranparent
       begin
         TextImage[i]:=' ';
       end
       else
       begin                    // 1 is cyan   XOR the bits on this part of the mouse shape
        TextImage[i]:='X';
       end;
   end;
   GetMouseShapeLineStr:=TextImage;
end;

Function WriteBasicMShapeCodeToBuffer(var data :BufferRec;x,y,Lan : word; imagename:string):word;
var
  Size      : longword;
  BWriter   : BitPlaneWriterProc;
  MShape    : MouseShapeType;
  MSData    : array[1..64] of byte;
  i         : integer;
begin
 CreateMouseShape(x,y,MShape);
 if Lan = GWLan then  BWriter:=@BitplaneWriterGWBasicCode else BWriter:=@BitplaneWriterBasicCode;
 Size:=GetMouseShapeSize;

 {$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 for i:=0 to 15 do
 begin
  writeln(data.ftext,LineCountToStr(Lan),#39,' ',GetMouseShapeLineStr(x,y+i));
 end;

 writeln(data.ftext,LineCountToStr(Lan),#39,' BASIC, Size= ', Size div 2,' Width= 16 Height= 16');
 writeln(data.ftext,LineCountToStr(Lan),#39,' DOS Mouse Shape ');
 writeln(data.ftext,LineCountToStr(Lan),#39,' ',Imagename);
 Move(MShape,MSData,sizeof(MSData));
 for i:=1 to 64 do
 begin
   BWriter(MSData[i],data,1);
 end;
 BWriter(0,data,2);  //flush it
// writeln(data.ftext);

{$I+}
 WriteBasicMShapeCodeToBuffer:=IORESULT;
end;


Function WritePascalMShapeCodeToBuffer(var data :BufferRec;x,y,Lan,imageId : word; imagename:string):word;
var
  Size      : longword;
  BWriter   : BitPlaneWriterProc;
  MShape    : MouseShapeType;
  MSData    : array[1..64] of byte;
  i         : integer;
begin
 CreateMouseShape(x,y,MShape);
 BWriter:=@BitplaneWriterPascalCode;
 Size:=GetMouseShapeSize;

 {$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 for i:=0 to 15 do
 begin
  writeln(data.ftext,'(* ',GetMouseShapeLineStr(x,y+i),' *)');
 end;

 writeln(data.ftext,'(*',' Pascal, Size= ', Size ,' Width= 16 Height= 16  ','*)');
 writeln(data.ftext,'(*',' DOS Mouse Shape ','*)');
  writeln(data.ftext,' ',Imagename,'_Size = ',size,';');
 writeln(data.ftext,' ',Imagename,'_Width = 16',';');
 writeln(data.ftext,' ',Imagename,'_Height = 16',';');
 writeln(data.ftext,' ',Imagename,'_Colors = 4',';');
 writeln(data.ftext,' ',Imagename,'_Id = ',imageId,';');

 writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of byte = (');
 Move(MShape,MSData,sizeof(MSData));
 for i:=1 to 64 do
 begin
   BWriter(MSData[i],data,1);
 end;
 BWriter(0,data,2);  //flush it
// writeln(data.ftext);

{$I+}
 WritePascalMShapeCodeToBuffer:=IORESULT;
end;

Function WriteCMShapeCodeToBuffer(var data :BufferRec;x,y,Lan,imageId : word; imagename:string):word;
var
  Size      : longword;
  BWriter   : BitPlaneWriterProc;
  MShape    : MouseShapeType;
  MSData    : array[1..64] of byte;
  i         : integer;
begin
 CreateMouseShape(x,y,MShape);
 BWriter:=@BitplaneWriterCCode;
 Size:=GetMouseShapeSize;

 {$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 for i:=0 to 15 do
 begin
  writeln(data.ftext,'/* ',GetMouseShapeLineStr(x,y+i),' */');
 end;

 writeln(data.ftext,'/*',' C, Size= ', Size ,' Width= 16 Height= 16  ','*/');
 writeln(data.ftext,'/*',' DOS Mouse Shape ','*/');
 writeln(data.ftext,' #define ',Imagename,'_Size ',size);
 writeln(data.ftext,' #define ',Imagename,'_Width ',16);
 writeln(data.ftext,' #define ',Imagename,'_Height ',16);
 writeln(data.ftext,' #define ',Imagename,'_Colors ',4);
 Writeln(data.ftext,' #define ',ImageName,'_Id ',imageId);
 writeln(data.ftext,' ','char ',Imagename, '[',size,']  = {');
 Move(MShape,MSData,sizeof(MSData));
 for i:=1 to 64 do
 begin
   BWriter(MSData[i],data,1);
 end;
 BWriter(0,data,2);  //flush it
// writeln(data.ftext);

{$I+}
 WriteCMShapeCodeToBuffer:=IORESULT;
end;

Function WriteMShapeCodeToBuffer(var data :BufferRec;x,y,Lan,imageId : word; imagename:string):word;
begin
   case Lan of TPLan,QPLan,FPLan: WriteMShapeCodeToBuffer:=WritePascalMShapeCodeToBuffer(data,x,y,Lan,Imageid,imagename);
                   TCLan,QCLan: WriteMShapeCodeToBuffer:=WriteCMShapeCodeToBuffer(data,x,y,Lan,imageId,imagename);
                   GWLan,QBLan,FBinQBModeLan,PBLan: WriteMShapeCodeToBuffer:=WriteBasicMShapeCodeToBuffer(data,x,y,Lan,imagename);
   end;
end;

//write a single file
Function WriteMShapeToCode(x,y,LanType,imageId : word;filename:string):word;
var
 data      : BufferRec;
 imagename : String;
begin
 SetCoreActive;   // we are getting data from core object RMCoreBase
 SetGWStartLineNumber(1000);
 assign(data.fText,filename);
{$I-}
 rewrite(data.fText);

 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 case LanType of
                 TPLan,QPLan,FPLan: WritePascalMShapeCodeToBuffer(data,x,y,LanType,imageid,imagename);
                 TCLan,QCLan: WriteCMShapeCodeToBuffer(data,x,y,LanType,imageid,imagename);
                 GWLan,QBLan,FBinQBModeLan,PBLan: WriteBasicMShapeCodeToBuffer(data,x,y,LanType,imagename);
 end;
 close(data.fText);
 {$I+}
 WriteMShapeToCode:=IOResult;
end;

Function WriteMShapeToBuffer(x,y : word;var F : File):word;
var
   MShape    : MouseShapeType;

begin
  CreateMouseShape(x,y,MShape);
 {$I-}
  Blockwrite(F,MShape,sizeof(MShape));
 {$I+}
 WriteMShapeToBuffer:=IOResult;
end;

Function WriteMShapeToFile(x,y : word;filename:string):word;
var
  F      : File;
  MShape : MouseShapeType;
begin
 CreateMouseShape(x,y,MShape);
 Assign(F,filename);
{$I-}
  Rewrite(F,1);
  Blockwrite(F,MShape,sizeof(MShape));
  Close(F);
{$I+}
WriteMShapeToFile:=IOResult;
end;

end.

