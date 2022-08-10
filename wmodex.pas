unit wmodex;
interface
 uses SysUtils,LazFileUtils,bits,rwxgf,rmxgfcore;

 type
   linebuftype = array[0..2047] of byte;


 procedure WriteLBMToBuffer(x,y,x2,y2 : word;var data : BufferRec);  // to binary file
 procedure WritePBMToBuffer(x,y,x2,y2 : word;var data : BufferRec);  // to binary file

 function WriteTPLBMCodeToBuffer(var data : BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;
 function WriteTPPBMCodeToBuffer(var data : BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;

 Function  WriteTCLBMCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;
 Function WriteTCPBMCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;



 Function WriteLBMToCode(x,y,x2,y2,LanType : word;filename:string):word;
 Function WriteLBMToFile(x,y,x2,y2 : word;filename:string):word;

 Function WritePBMToCode(x,y,x2,y2,LanType : word;filename:string):word;
 Function WritePBMToFile(x,y,x2,y2 : word;filename:string):word;


 function BPLModeX(width : integer) : integer;
 Procedure SinglePlaneToModeXPlane(var sp,mp : linebuftype; width : integer);

 function GetLBMPBMImageSize(width,height : integer) : longint;


implementation

function GetLBMPBMImageSize(width,height : integer) : longint;
begin
 GetLBMPBMImageSize:=width*height+2;
end;

Procedure WriteLBMBuffer(BitPlaneWriter  : BitPlaneWriterProc;var data :BufferRec; x,y,x2,y2 : word);
var
 width    : Byte;
 height   : Byte;
 i,j    : word;
 PixelCol   : byte;
begin
 Width:=x2-x+1;
 if width < 4 then width:=4;

 Height:=y2-y+1;

 BitplaneWriter(width,data,1);
 BitplaneWriter(height,data,1);

 for j:=0 to height-1 do
 begin
   for i:=0 to Width-1 do
   begin
     pixelCol:=GetPixel(x+i,y+j);
     BitplaneWriter(pixelCol,data,1);
   end;
 end;
 BitplaneWriter(0,data,2);  //flush it
end;


Procedure WritePBMBuffer(BitPlaneWriter  : BitPlaneWriterProc;var data :BufferRec; x,y,x2,y2 : word);
var
 width    : Byte;
 height   : Byte;
 i,j,r    : word;
 PixelCol   : byte;
begin
 Width:=x2-x+1;
 if width < 4 then width:=4;
 Height:=y2-y+1;

 BitplaneWriter(width div 4,data,1);
 BitplaneWriter(height,data,1);

 for r:=0 to 3 do
 begin
   for j:=0 to height-1 do
   begin
     for i:=0 to (width div 4)-1 do
     begin
       pixelCol:=GetPixel(x+i*4+r,y+j);
       BitplaneWriter(pixelCol,data,1);
     end;
   end;
 end;

 BitplaneWriter(0,data,2);  //flush it
end;

Function WriteTPPBMCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longint;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;
begin
 BWriter:=@BitplaneWriterPascalCode;

 width:=x2-x+1;
 height:=y2-y+1;

 nColors:=GetMaxColor+1;
 Size:=width*height+2;
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'(* Turbo Pascal DOS XLIB PBM Bitmap Created By Raster Master *)');
 writeln(data.ftext,'(* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' *)');
 writeln(data.ftext,' ',Imagename,'_Size = ',size,';');
 writeln(data.ftext,' ',Imagename,'_Width = ',width,';');
 writeln(data.ftext,' ',Imagename,'_Height = ',height,';');
 writeln(data.ftext,' ',Imagename,'_Colors = ',nColors,';');
 writeln(data.ftext,' ',Imagename,'_Id = ',imageId,';');
 writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of byte = (');
 WritePBMBuffer(BWriter,data,x,y,x2,y2);
 writeln(data.ftext);

{$I+}
 WriteTPPBMCodeToBuffer:=IORESULT;
end;


Function  WriteTPLBMCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longint;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;
begin
 BWriter:=@BitplaneWriterPascalCode;

 width:=x2-x+1;
 height:=y2-y+1;

 nColors:=GetMaxColor+1;
 Size:=width*height+2;
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'(* Turbo Pascal DOS XLIB LBM Bitmap Code Created By Raster Master *)');
 writeln(data.ftext,'(* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' *)');
 writeln(data.ftext,' ',Imagename,'_Size = ',size,';');
 writeln(data.ftext,' ',Imagename,'_Width = ',width,';');
 writeln(data.ftext,' ',Imagename,'_Height = ',height,';');
 writeln(data.ftext,' ',Imagename,'_Colors = ',nColors,';');
 writeln(data.ftext,' ',Imagename,'_Id = ',imageId,';');
 writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of byte = (');
 WriteLBMBuffer(BWriter,data,x,y,x2,y2);
 writeln(data.ftext);

{$I+}
 WriteTPLBMCodeToBuffer:=IORESULT;
end;


Function WriteTCPBMCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longint;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;
begin
 BWriter:=@BitplaneWriterCCode;

 width:=x2-x+1;
 height:=y2-y+1;

 nColors:=GetMaxColor+1;
 Size:=width*height+2;
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'/* Turbo C DOS XLIB PBM Bitmap Created By Raster Master */');
 writeln(data.ftext,'/* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' */');
 writeln(data.ftext,' #define ',Imagename,'_Size ',size);
 writeln(data.ftext,' #define ',Imagename,'_Width ',width);
 writeln(data.ftext,' #define ',Imagename,'_Height ',height);
 writeln(data.ftext,' #define ',Imagename,'_Colors ',nColors);
 writeln(data.ftext,' #define ',ImageName,'_Id ',imageId);
 writeln(data.ftext,' ','char ',Imagename, '[',size,']  = {');
 writePBMBuffer(BWriter,data,x,y,x2,y2);
 writeln(data.ftext);

{$I+}
 WriteTCPBMCodeToBuffer:=IORESULT;
end;


Function  WriteTCLBMCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longint;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;
begin
 BWriter:=@BitplaneWriterCCode;

 width:=x2-x+1;
 height:=y2-y+1;

 nColors:=GetMaxColor+1;
 Size:=width*height+2;
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'/* Turbo C DOS XLIB LBM Bitmap Created By Raster Master */');
 writeln(data.ftext,'/* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' */');
 writeln(data.ftext,' #define ',Imagename,'_Size ',size);
 writeln(data.ftext,' #define ',Imagename,'_Width ',width);
 writeln(data.ftext,' #define ',Imagename,'_Height ',height);
 writeln(data.ftext,' #define ',Imagename,'_Colors ',nColors);
 writeln(data.ftext,' #define ',ImageName,'_Id ',imageId);

 writeln(data.ftext,' ','char ',Imagename, '[',size,']  = {');

 WriteLBMBuffer(BWriter,data,x,y,x2,y2);
 writeln(data.ftext);

{$I+}
 WriteTCLBMCodeToBuffer:=IORESULT;
end;



Function WriteLBMToCode(x,y,x2,y2,LanType : word;filename:string):word;
var
 data      : BufferRec;
 imagename : String;
 imageid   : word;
begin
 SetCoreActive;   // we are getting data from core object RMCoreBase
 imageid:=GetThumbIndex;
 assign(data.fText,filename);
{$I-}
 rewrite(data.fText);

 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 case LanType of TPLan: WriteTPLBMCodeToBuffer(data,x,y,x2,y2,imageid,imagename);
                 TCLan: WriteTCLBMCodeToBuffer(data,x,y,x2,y2,imageid,imagename);


 end;
 close(data.fText);
 {$I+}
 WriteLBMToCode:=IOResult;

end;

Function WriteLBMToFile(x,y,x2,y2 : word;filename:string):word;
var
 data      : BufferRec;
begin
SetCoreActive;   // we are getting data from core object RMCoreBase
Assign(data.f,filename);
{$I-}
 Rewrite(data.f,1);
 BitPlaneWriterFile(0,data,0);
 WriteLBMBuffer(@BitPlaneWriterFile,data,x,y,x2,y2);
 Close(data.f);
{$I+}
 WriteLBMToFile:=IOResult;
end;

Function WritePBMToCode(x,y,x2,y2,LanType : word;filename:string):word;
 var
  data      : BufferRec;
  imagename : String;
  imageid   : word;
 begin
  SetCoreActive;   // we are getting data from core object RMCoreBase
  imageid:=GetThumbIndex;
  assign(data.fText,filename);
 {$I-}
  rewrite(data.fText);

  Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
  case LanType of TPLan: WriteTPPBMCodeToBuffer(data,x,y,x2,y2,imageid,imagename);
                  TCLan: WriteTCPBMCodeToBuffer(data,x,y,x2,y2,imageid,imagename);
  end;
  close(data.fText);
  {$I+}
  WritePBMToCode:=IOResult;
end;



Function WritePBMToFile(x,y,x2,y2 : word;filename:string):word;
var
 data      : BufferRec;
begin
SetCoreActive;   // we are getting data from core object RMCoreBase
Assign(data.f,filename);
{$I-}
 Rewrite(data.f,1);
 BitPlaneWriterFile(0,data,0);
 WritePBMBuffer(@BitPlaneWriterFile,data,x,y,x2,y2);
 Close(data.f);
{$I+}
 WritePBMToFile:=IOResult;
end;


procedure WriteLBMToBuffer(x,y,x2,y2 : word;var data : BufferRec);  // to binary file
begin
  WriteLBMBuffer(@BitPlaneWriterFile,data,x,y,x2,y2);
end;


procedure WritePBMToBuffer(x,y,x2,y2 : word;var data : BufferRec);  // to binary file
begin
  WritePBMBuffer(@BitPlaneWriterFile,data,x,y,x2,y2);
end;
























(*
                        +--+--+--+--+-------------------------+
Plane 3                 |10|00|00|00|...                      |
                   +--+--+--+--+-------------------------+    |
Plane 2            |00|00|00|00|...                      |    |
              +--+--+--+--+-------------------------+    |
Plane 1       |11|00|00|00|...                      |    |
         +--+--+--+--+-------------------------+    |
Plane 0  |01|00|00|00|...                      |    |
         ---------------------------------------
The above diagram is not very good, but it should convey the general idea 
behind what is termed PLANAR memory addressing. This is the method used 
by Mode X and also by EGA/VGA 16 colour modes, so theory on this type of 
addressing should be fairly abundant. In the diagram, the pixel at 
coordinates (0,0) has a colour value of 10001101 in binary or 141 in decimal. 
Notice how this value is spread across the four video planes; 
bits 0&1 are on plane 0, bits 2&3 are on plane 1, 4&5 on plane 2, etc. 
The next pixel (at coordinates (1,0)) has bits 0&1 back on plane 0 and are 
stored directly after the first pixel's bits 0&1.
*)

function GetBitPairs(inByte,bp : byte) : byte;
var
 myPair : byte;
begin
  Case bp of 1:begin
                 myPair:=inByte SHR 6;
               end;
             2:begin
                 myPair:=(inByte SHL 2) SHR 6;
               end;    
             3:begin
                 myPair:=(inByte SHL 4) SHR 6;
               end;    
             4:begin
                 myPair:=(inByte SHL 6) SHR 6;
               end;    
  end;
  GetBitPairs:=myPair;
end;

(*
Function BitOn(Position,Testbyte : Byte) : Boolean;
Procedure SetBit(Position, Value : Byte; Var Changebyte : Byte);
*)
procedure SetBitPairs(Var dest : byte; bp, v : byte);
begin
 Case bp of 1:begin
                  if Biton(0,v) then SetBit(6,1,dest);
                  if Biton(1,v) then SetBit(7,1,dest);
               end;
             2:begin
                  if Biton(0,v) then SetBit(4,1,dest);
                  if Biton(1,v) then SetBit(5,1,dest);
               end;    
             3:begin
                  if Biton(0,v) then SetBit(2,1,dest);
                  if Biton(1,v) then SetBit(3,1,dest);
               end;    
             4:begin
                  if Biton(0,v) then SetBit(0,1,dest);
                  if Biton(1,v) then SetBit(1,1,dest);
               end;    
  end;
end;
(* Bytes Per Line for Single Plane *)
function BPLModeX(width : integer) : integer;
begin
  BPLModeX:=((width+3) * 2) div 8;
end;

Procedure SinglePlaneToModeXPlane(var sp,mp : linebuftype; width : integer);
var
 i   : integer;
 col : byte;
 p0,p1,p2,p3 : byte;
 BPL0,BPL1,BPL2,BPL3 : integer;
 bpc,bpOffset : integer;
begin
 BPL0:=0;
 BPL1:=BPLModeX(width);
 BPL2:=BPL1*2;
 BPL3:=BPL1*3;
 
 bpc:=1;
 bpOffset:=0;
 for i:=0 to width-1 do
 begin
   col:=sp[i];
   p3:=GetBitPairs(col,1); (* XX000000  *)
   p2:=GetBitPairs(col,2); (* 00XX0000  *)
   p1:=GetBitPairs(col,3); (* 0000XX00  *)
   p0:=GetBitPairs(col,4); (* 000000XX  *)

   SetBitPairs(mp[BPL0+bpOffset],bpc,p0); (* Plain 0 *)
   SetBitPairs(mp[BPL1+bpOffset],bpc,p1); (* Plain 1 *)
   SetBitPairs(mp[BPL2+bpOffset],bpc,p2); (* Plain 2 *)
   SetBitPairs(mp[BPL3+bpOffset],bpc,p3); (* Plain 3 *)

   inc(bpc);
   if bpc > 4 then 
   begin
     bpc:=1;
     inc(bpOffset);
   end;  
 end;  
end;

begin
end.


