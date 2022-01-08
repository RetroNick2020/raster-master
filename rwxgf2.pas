//{$MODE TP}
{$mode objfpc}{$H+}
{$PACKRECORDS 1}

Unit rwxgf2;
 Interface
   uses SysUtils,LazFileUtils,rmcore,rmthumb,rres,bits;

Const
   NoLan   = 0;
   TPLan   = 1;
   TCLan   = 2;
   QCLan   = 3;
   QBLan   = 4;
   PBLan   = 5;
   GWLan   = 6;
   FPLan   = 7;
   FBLan   = 8;
   ABLan   = 9; //AmigaBasic
   APLan   = 10;
   ACLan   = 11;

   NoExportFormat = 0;
   TPPutImageExportFormat = 1;
   ABPutExportFormat = 1;
   ABBOBExportFormat = 2;
   ABVSpriteExportFormat = 3;


   Binary2   = 1;
   Binary4   = 2;
   Binary8   = 3;
   Binary16  = 4;
   Binary32  = 5;
   Binary256 = 6;

   Source2   = 7;
   Source4   = 8;
   Source8   = 9;
   Source16  = 10;
   Source32  = 11;
   Source256 = 12;

   SPRBinary = 13;
   SPRSource = 14;

   PPRBinary = 15;
   PPRSource = 16;

   TEGLText  = 17;

   PALSource = 18;



//Function WriteXgf2(x,y,x2,y2,LanType : word;filename:string):word;
Function RESInclude(filename:string):word;
Function RESBinary(filename:string):word;


Implementation

type
 linebuftype = array[0..2047] of byte;
 ColorMap    = Array[0..15] of Byte;
 XgfHead = Record
              Width  : Word;
              Height : Word;
            End;

 BufferRec = Record
                f      : file;
                fText  : Text;
                buflist   : array[1..128] of Byte;
                bufcount  : integer;

                ArraySize : longword;
                ByteWriteCount : longword;
 end;

 //Action 0 = init ncounter/buffer,Action 1 = write byte to buffer, action 2= flush buffer
 BitPlaneWriterProc = Procedure(inByte : Byte; var Buffer : BufferRec; action : integer);

 GetMaxColorProc = function : integer;
 GetPixelProc    = function(x,y : integer) : integer;

const
 BorlandColorMap : ColorMap = (0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15);
// MSColorMap: ColorMap = (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);

var
 XThumbIndex  : integer;
 XGetPixel    : GetPixelProc;
 XGetMaxColor : GetMaxColorProc;

procedure SetThumbIndex(index : integer);
begin
 XThumbIndex:=index;
end;

function GetThumbIndex : integer;
begin
 GetThumbIndex:=XThumbIndex;
end;

function CoreGetMaxColor : integer;
begin
  CoreGetMaxColor:=RMCoreBase.Palette.GetColorCount -1;
end;

function ThumbGetMaxColor : integer;
var
 index : integer;
begin
  index:=GetThumbIndex;
  ThumbGetMaxColor:=ImageThumbBase.GetMaxColor(index);
end;

function  GetMaxColor : integer;
begin
  GetMaxColor:=XGetMaxColor();
end;

function CoreGetPixel(x,y : integer) : integer;
begin
  CoreGetPixel:=RMCoreBase.getPixel(x,y);
end;

function ThumbGetPixel(x,y : integer) : integer;
var
  index : integer;
begin
  index:=GetThumbIndex;
  ThumbGetPixel:=ImageThumbBase.GetPixel(index,x,y);
end;


procedure SetMaxColorProc(MC : GetMaxColorProc);
begin
  XGetMaxColor:=MC;
end;

procedure SetGetPixelProc(GP : GetPixelProc);
begin
  XGetPixel:=GP;
end;

Procedure SetCoreActive;
begin
 SetMaxColorProc(@CoreGetMaxColor);
 SetGetPixelProc(@CoreGetPixel);
end;

Procedure SetThumbActive;
begin
 SetMaxColorProc(@ThumbGetMaxColor);
 SetGetPixelProc(@ThumbGetPixel);
 SetThumbIndex(0);
end;

Procedure InitXGFProcs;
begin
 SetCoreActive;
end;

function GetPixel(x,y : integer) : integer;
begin
 GetPixel:=XGetPixel(x,y);
end;

Procedure spTOmp(var singlePlane : LineBufType ;
                 var multiplane  : LineBufType;
                 BytesPerPlane,nPlanes : Word);

var
 BitPlane1 : Word;
 BitPlane2 : Word;
 BitPlane3 : Word;
 BitPlane4 : Word;
 BitPlane5 : Word;
 pixelpos  : Word;
 color     : Word;
 xoffset   : Word;
 x,j       : Word;
begin
 Fillchar(multiplane,sizeof(multiplane),0);

 BitPlane1:=0;
 BitPlane2:=bytesPerPlane;
 BitPlane3:=BytesPerPlane*2;
 BitPlane4:=BytesPerPlane*3;
 BitPlane5:=BytesPerPlane*4;  //32 colors
 xoffset:=0;
 pixelpos:=0;
 for x:=0 to bytesPerPlane-1 do
 begin
   for j:=0 to 7 do
   begin
      color:=SinglePlane[xoffset+j];
      if (nPlanes > 4) AND biton(4,color) then setbit((7-j),1,multiplane[BitPlane5+pixelpos]);
      if (nPlanes > 3) AND biton(3,color) then setbit((7-j),1,multiplane[BitPlane4+pixelpos]);
      if (nPlanes > 2) AND biton(2,color) then setbit((7-j),1,multiplane[BitPlane3+pixelpos]);
      if (nPlanes > 1) AND biton(1,color) then setbit((7-j),1,multiplane[BitPlane2+pixelpos]);
      if (nPlanes > 0) AND biton(0,color) then setbit((7-j),1,multiplane[BitPlane1+pixelpos]);
    end;
   inc(pixelpos);
   inc(xoffset,8);
 end;
end;


Procedure spToPacked(var SinglePlane  : LineBufType ;
                     var PackedPlane  : LineBufType;
                         BytesPerLine : word);

var
  x,i : word;
begin
 Fillchar(PackedPlane,sizeof(PackedPlane),0);
 x:=0;
 For i:=0 to BytesPerLine-1 do
 begin
   PackedPlane[i] := (SinglePlane[x] shl 6) + (SinglePlane[x+1] shl 4) + (SinglePlane[x+2] shl 2) + SinglePlane[x+3];
   inc(x,4);
  end;
end;




Function WriteXgfFP(x,y,x2,y2 : word;filename:string):word;
type
 //free pascal graph - each pixel takes a Word
 XGFHeadFP = Record
              Width,Height : LongInt;
              reserved     : LongInt;
 end;
 linebufFP = array[0..1023] of Word;
var
 Header : XGFHeadFP;
 lineBuf:linebufFP;
 counter : integer;
 F         : File;
 Error     : Word;
 j,i       : integer;
begin
 Header.Width:=x2-x+1;
 Header.Height:=y2-y+1;
 Header.reserved:=0;
{$I+}
 Assign(F,filename);
 Rewrite(F,1);
 Blockwrite(F,Header,sizeof(Header));

 Error:=IOResult;
 if Error <> 0 then
 begin
   close(F);
   WriteXgfFP:=Error;
   exit;
 end;

 For j:=y to y2 do
 begin
   counter:=0;
   for i:=x to x2 do
   begin
      linebuf[counter]:=RMCoreBase.GetPixel(i,j);
      inc(counter);
   end;
   blockwrite(F,linebuf,header.Width*sizeof(word));
 end;

 Close(F);
 WriteXgfFP:=IOResult;
{$I+}
end;


Function WriteXgfFB(x,y,x2,y2 : word;filename:string):word;
type
 //free takes a Word
 XGFHeadFB = Record
              Width,Height : word;
 end;
 linebufFB = array[0..1023] of Byte;
var
 Header : XGFHeadFB;
 lineBuf:linebufFB;
 counter : integer;
 F         : File;
 Error     : Word;
 j,i       : integer;
 width,height : word;
begin
 width:=x2-x+1;
 Height:=y2-y+1;
 Header.Width:=width SHL 3;
 Header.Height:=height;
{$I+}
 Assign(F,filename);
 Rewrite(F,1);
 Blockwrite(F,Header,sizeof(Header));

 Error:=IOResult;
 if Error <> 0 then
 begin
   close(F);
   WriteXgfFB:=Error;
   exit;
 end;

 For j:=y to y2 do
 begin
   counter:=0;
   for i:=x to x2 do
   begin
      linebuf[counter]:=RMCoreBase.GetPixel(i,j);
      inc(counter);
   end;
   blockwrite(F,linebuf,width);
 end;

 Close(F);
 WriteXgfFB:=IOResult;
{$I+}
end;

Procedure RemapToBorland(var SinglePlane : LineBufType; width : word) ;
var
 i : word;
begin
 for i:=0 to width-1 do
 begin
   SinglePlane[i]:=BorlandColorMap[SinglePlane[i]];
 end;
end;


function GetBPLSize(width,ncolors : word) : word;
begin
  GetBPLSize:=0;
  case nColors of 2,16:GetBPLSize:=(width+7) div 8;  (* note to self - this is correct, Bytes per line for one bitplane is the same for 2 and 16 colors, but 16 colors has 4 bitplanes *)
                    4:GetBPLSize:=(width+3) div 4;
                  256:GetBPLSize:=width;
  end;
end;

function GetXImageSize(width,height,ncolors : integer) : longint;
var
  BPL : word;
begin
  GetXImageSize:=0;
  BPL:=GetBPLSize(width,ncolors);
  case nColors of 2,4,256:GetXImageSize:=BPL*height+4;
                       16:GetXImageSize:=BPL*4*height+4; (* GetBPLSize give us size for one bitplane line - 16 colors have 4 bitplanes*)
  end;
end;


// depensing on the compiler the width/height is different
Procedure FixHead(var head : XgfHead;width,height, LanType : word);
var
  numColors : word;
begin
  numColors:=GetMaxColor+1;
  Case LanType of TPLan,TCLan: begin
                                 head.Width:=width-1;
                                 head.Height:=height-1;
                              end;
                       PBLan: begin
                                head.Width:=width;
                                head.Height:=height;
                              end;
                      QBLan,QCLan: begin
                                     If NumColors=4 then head.Width:=width*2
                                     else If NumColors=256 then head.Width:=width SHL 3
                                     else head.Width:=width;
                                     head.Height:=height;
                                   end;
  end;
end;

Procedure CreateBitPlanesPC(BitPlaneWriter  : BitPlaneWriterProc;var data :BufferRec; x,y,x2,y2,LanType : word);
Var
 sourcelinebuf : Linebuftype;
 destlinebuf   : Linebuftype;
 myHead     : XgfHead;
 mywidth    : word;
 myheight   : word;
 BPL        : Word;  //bytes per line for one bitplane
 BTW        : word; //bytes to write to buffer
 i,j,n      : Word;
 NumColors  : Word;
 tempBuf    : array[1..4] of byte;
begin
 if LanType = FPLan then
 begin
//   WriteXgfToBPW:=WriteXgfToBPWFP(BitPlaneWriter,data,x,y,x2,y2,Lantype);
   exit;
 end
 else if LanType = FBLan then
 begin
//   WriteXgfToBPW:=WriteXgfToBPWFB(BitPlaneWriter,data,x,y,x2,y2,Lantype);
   exit;
 end;

 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
 numColors:=GetMaxColor+1;
 BPL:=GetBPLSize(myWidth,numColors);
 BTW:=BPL;
 if NumColors = 16 then BTW:=BPL*4;

 //patch correct widht height for language/compiler - Micrsoft and Borland did some wierd things to a simple bitmap format
 FixHead(myHead,myWidth,myHeight,LanType);
 Move(myHead,tempBuf,sizeof(tempBuf));

 //BitplaneWriter(0,data,0);  //init the data record
 for n:=1 to 4 do
 begin
    BitplaneWriter(tempBuf[n],data,1);
 end;

 for j:=0 to myheight-1 do
 begin
   for i:=0 to myWidth-1 do
   begin
       sourceLineBuf[i]:=GetPixel(x+i,y+j);
   end;
   case numColors of 2:spTOmp(sourcelinebuf,destlinebuf,BPL,1);
                     4:spToPacked(sourcelinebuf,destlinebuf,BPL);
                    16:begin
                         If (LanType=TPLan) OR (LanType=TCLan) OR (LanType=PBLan) then RemapToBorland(sourcelinebuf,myWidth);
                         spTOmp(sourcelinebuf,destlinebuf,BPL,4);
                       end;
                   256:destlinebuf:=sourcelinebuf;
   end;
   for n:=0 to BTW-1 do
   begin
     BitplaneWriter(destlinebuf[n],data,1);
   end;
 end;

 BitplaneWriter(0,data,2);  //flush it
end;

procedure BitplaneWriterFile(inByte : Byte; var Buffer : BufferRec;action : integer);
begin
   if action = 0 then
   begin
       buffer.bufCount:=0;
   end
   else if action = 1 then
   begin
       inc(Buffer.bufcount);
       buffer.buflist[Buffer.bufcount]:=inByte;
       if Buffer.bufcount = 128 then
       begin
           Blockwrite(buffer.f,Buffer.buflist,128);
           Buffer.bufcount:=0;
       end;
   end
   else if action = 2 then
   begin
       if Buffer.bufcount > 0 then
       begin
           Blockwrite(buffer.f,Buffer.buflist,buffer.bufcount);
           Buffer.bufcount:=0;
       end;
   end;
end;

procedure BitplaneWriterConstStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
 {$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.arraysize:=0;
       buffer.ByteWriteCount:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.bufcount);
       buffer.buflist[buffer.bufcount]:=inbyte;
       if buffer.bufcount = 20 then                      //every 20 bytes write to const line
       begin
           //write the const value
           write(buffer.ftext,'  ');

           for i:=1 to 20 do
           begin
             write(buffer.ftext,'$',HexStr(buffer.buflist[i],2));
             inc(buffer.ByteWriteCount);
             if buffer.ByteWriteCount < buffer.ArraySize then write(buffer.ftext,',');
           end;
           if buffer.ByteWriteCount < buffer.ArraySize then writeln(buffer.ftext);
           buffer.bufcount:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
       if buffer.bufcount > 0 then write(buffer.ftext,'  ');
       for i:=1 to buffer.bufcount do
       begin
         write(buffer.ftext,'$',HexStr(buffer.buflist[i],2));
         inc(buffer.ByteWriteCount);
         if buffer.ByteWriteCount < buffer.ArraySize then write(buffer.ftext,',');
       end;
       write(buffer.ftext,');');
       writeln(buffer.ftext);
       buffer.bufcount:=0;
  end;
{$I+}
end;

Function WriteTPArray(var data :BufferRec;x,y,x2,y2,LanType : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longword;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;
begin
 BWriter:=@BitplaneWriterConstStatements;

 width:=x2-x+1;
 height:=y2-y+1;
 nColors:=GetMaxColor+1;
 Size:=GetXImageSize(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'(* Turbo Pascal, Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' *)');
 writeln(data.ftext,'(* PutImage Bitmap *)');
 writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of byte = (');
 CreateBitPlanesPC(BWriter,data,x,y,x2,y2,LanType);
 writeln(data.ftext);

{$I+}
 WriteTPArray:=IORESULT;
end;


//write a single binary file
Function WriteXgf2(x,y,x2,y2,LanType : word;filename:string):word;
var
 data      : BufferRec;
begin
 Assign(data.f,filename);
{$I-}
 Rewrite(data.f,1);
 CreateBitPlanesPC(@BitPlaneWriterFile,data,x,y,x2,y2,LanType);
 Close(data.f);
{$I+}
 WriteXgf2:=IOResult;
end;



//write a single file
Function WriteXgfArray2(x,y,x2,y2,LanType : word;filename:string):word;
var
 data      : BufferRec;
 imagename : String;
begin
 SetCoreActive;   // we are getting data from core object RMCoreBase
 assign(data.fText,filename);
{$I-}
 rewrite(data.fText);

 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 case LanType of TPLan: WriteTPArray(data,x,y,x2,y2,LanType,imagename);
 end;
 close(data.fText);
 {$I+}
 WriteXgfArray2:=IOResult;
end;


Function RESInclude(filename:string):word;
var
 data    : BufferRec;
 EO      : ImageExportFormatRec;
 i       : integer;
 count   : integer;
 width   : integer;
 height  : integer;
begin
 SetThumbActive;   // we are getting pixel data from core object ThumbBase
 assign(data.fText,filename);
{$I-}
 rewrite(data.fText);

 count:=ImageThumbBase.GetCount;
 for i:=0 to count-1 do
 begin
   width:=ImageThumbBase.GetWidth(i);
   height:=ImageThumbBase.GetHeight(i);
   ImageThumbBase.GetExportOptions(i,EO);
   SetThumbIndex(i);  //important - otherwise the GetMaxColor and GetPixel functions will not get the right data
   if (EO.Lan=TPLan) and (EO.Image = 1) then WriteTPArray(data,0,0,width-1,height-1,EO.Lan,EO.Name);
 end;
 close(data.fText);
 {$I+}
 RESInclude:=IOResult;
end;


Function RESBinary(filename:string):word;
var
 data    : BufferRec;
 EO      : ImageExportFormatRec;
 RR      : resrec;
 RH      : resheadrec;
 i       : integer;
 count   : integer;
 width   : integer;
 height  : integer;
 nColors : integer;
 Size    : LongInt;

 HeaderSize  : LongInt;
 OffsetCount : LongInt;
 ExportCount : Integer;
 SLen        : integer;
 Error       : integer;
begin
 ExportCount:=ImageThumbBase.GetExportCount;
 if ExportCount = 0 then exit;

 SetThumbActive;   // we are getting pixel data from core object ThumbBase
 assign(data.f,filename);
{$I-}
 rewrite(data.f,1);
{$I+}
 Error:=IORESULT;
 if Error<>0 then
 begin                2
    RESBinary:=Error;
    exit;
 end;
 count:=ImageThumbBase.GetCount;
 HeaderSize:=sizeof(RH)+Exportcount*sizeof(resrec);
 OffsetCount:=HeaderSize;

 //write the signature and record count
 RH.sig:='RES';
 RH.ver:=1;
 RH.resitemcount:=Exportcount;
 {$I-}
 Blockwrite(data.f,RH,sizeof(RH));
 {$I+}
 Error:=IORESULT;
 if Error<>0 then
 begin
  RESBinary:=Error;
  exit;
 end;

 //write the header with all the correct offsets where the image is going to be located
 for i:=0 to count-1 do
 begin
   width:=ImageThumbBase.GetWidth(i);
   height:=ImageThumbBase.GetHeight(i);
   nColors:=ImageThumbBase.GetMaxColor(i)+1;
   Size:=GetXImageSize(width,height,nColors);
   ImageThumbBase.GetExportOptions(i,EO);

   //copy name field
   fillchar(RR.rid,sizeof(RR.rid),32);
   slen:=Length(EO.Name);
   if slen > 20 then slen:=20;
   Move(EO.Name[1],RR.rid,slen);

   //calc size/offset
   if EO.Image > 0  then
   begin
     RR.size:=Size;
     RR.offset:=OffsetCount;
     RR.rt:=EO.Lan*100+EO.Image; //language id * 100 + Image Type to generate resource type

     inc(OffsetCount,Size);
     {$I-}
     Blockwrite(data.f,RR,sizeof(RR));
     {$I+}
     Error:=IORESULT;
     if Error<>0 then
     begin
       RESBinary:=Error;
       exit;
     end;
   end;
 end;

 //convert and dump image
 for i:=0 to count-1 do
 begin
   width:=ImageThumbBase.GetWidth(i);
   height:=ImageThumbBase.GetHeight(i);
   ImageThumbBase.GetExportOptions(i,EO);
   SetThumbIndex(i);  //important - otherwise the GetMaxColor and GetPixel functions will not get the right data
   BitPlaneWriterFile(0,data,0);
   if (EO.Lan=TPLan) and (EO.Image = 1) then CreateBitPlanesPC(@BitPlaneWriterFile,data,0,0,width-1,height-1,EO.Lan);
 end;

 {$I-}
 close(data.f);
 {$I+}
 RESBinary:=IOResult;
end;




begin
  InitXGFProcs;
end.
