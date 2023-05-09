//{$MODE TP}
{$mode objfpc}{$H+}
{$PACKRECORDS 1}

Unit rwxgf;
 Interface
   uses SysUtils,LazFileUtils,rmcore,rmthumb,rmxgfcore,bits,gwbasic;

Const
   NoLan   = 0;
   TPLan   = 1;
   TCLan   = 2;
   QCLan   = 3;
   QBLan   = 4;
   QB64Lan = 5;

   PBLan   = 6;
   GWLan   = 7;    // also update GWLan in gbasic unit
   FPLan   = 8;

   FBinQBModeLan = 9;
   FBLan         = 10;  //modern mode - no legacy support for RGB/RGBA

   ABLan   = 11; //AmigaBasic
   APLan   = 12;
   ACLan   = 13;
   AQBLan  = 14; //Amiga APQBasic support - once we figure out how to access t_BitMap memory and stuff it with bitplane data
   QPLan   = 15; //Quick Pascal
   gccLan  = 16;
   OWLan   = 17; //Open Watcom C/C++ compiler


   NoExportFormat = 0;
   PutImageExportFormat = 1;  //for all compilers the use put/putimage

   AmigaBOBExportFormat = 2;  //Amiga specific formats
   AmigaVSpriteExportFormat = 3;
   AmigaBitMap = 4;  //for Amiga C/Pascal

   XLibLBMExportFormat = 5; //Xlib format for TC/TP
   XLibPBMExportFormat = 6;

   RGBAFuchsiaExportFormat = 7;  //originaly intended for just Raylib support - but also work in qb64/freebasic RGB formats
   RGBAIndex0ExportFormat = 8;
   RGBExportFormat = 9;

   MouseImageExportFormat = 10;



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

type
 BufferRec = Record
                f      : file;
                fText  : Text;
                Error  : word;
                buflist   : array[1..128] of Byte;
                bufcount  : integer;

                ArraySize : longword;
                ByteWriteCount : longword;
 end;

 //Action 0 = init ncounter/buffer,Action 1 = write byte to buffer, action 2= flush buffer
 BitPlaneWriterProc = Procedure(inByte : Byte; var Buffer : BufferRec; action : integer);

 Function WriteXgfToCode(x,y,x2,y2,LanType : word;filename:string):word;
 Function WriteXgfWithMaskToCode(x,y,x2,y2,LanType : word;filename:string):word;
 Function WriteXgfToFile(x,y,x2,y2,LanType : word;filename:string):word;


 procedure WriteXgfToBuffer(x,y,x2,y2,LanType,Mask : word;var data : BufferRec);  // to binary file
 procedure WriteXgfToBufferFP(x,y,x2,y2,Mask : word;var data : BufferRec);
 procedure WriteXgfToBufferFB(x,y,x2,y2,Mask : word;var data : BufferRec);
 procedure WriteXgfToBufferOW(x,y,x2,y2,Mask : word;var data : BufferRec);

 function WriteXGFCodeToBuffer(var data : BufferRec;x,y,x2,y2,LanType,Mask : word; imagename:string):word;

 function GetXImageSize(width,height,ncolors : integer) : longint;
 function GetXImageSizeFB(width,height : integer) : longint;
 function GetXImageSizeFP(width,height : integer) : longint;
 function GetXImageSizeOW(width,height,ncolors : integer) : longint;

procedure BitplaneWriterFile(inByte : Byte; var Buffer : BufferRec;action : integer);
procedure BitplaneWriterPascalCode(inByte : Byte; var Buffer : BufferRec;action : integer);
procedure BitplaneWriterCCode(inByte : Byte; var Buffer : BufferRec;action : integer);
procedure BitplaneWriterBasicCode(inByte : Byte; var Buffer : BufferRec;action : integer);
procedure BitplaneWriterGWBasicCode(inByte : Byte; var Buffer : BufferRec;action : integer);

Implementation

type
 linebuftype = array[0..2047] of byte;
 ColorMap    = Array[0..15] of Byte;
 XgfHead = Packed Record
              Width  : Word;
              Height : Word;
            End;

 //Open Watcom XGF header - slightly different than borland/MS
 XgfHeadOW = Packed Record
              Width  : Word;
              Height : Word;
              Colors : Word; // 1 = Monochrome, 2 = 4 color/GGA modes, 4 = 16 color modes, 8 = 256 color modes
             End;

 //free pascal graph - each pixel takes a Word
 XGFHeadFP = Packed Record
              Width,Height : LongInt;
              reserved     : LongInt;
 end;

 XGFHeadFB = Packed Record
              Width,Height : word;
 end;



const
 BorlandColorMap : ColorMap = (0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15); //Borland and Open Watcom 16 color remap
// MSColorMap: ColorMap = (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);


function nColorsToColorBits(nColors : integer) : integer;
var
 CB : integer;
begin
 CB:=0;
 Case nColors of 2:CB:=1;
                 4:CB:=2;
                16:CB:=4;
                256:CB:=8;
 end;
 nColorsToColorBits:=CB;
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
{$I-}
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
 {$I+}
 WriteXgfFP:=IOResult;
end;


Function WriteXgfFB(x,y,x2,y2 : word;filename:string):word;
type
 //free takes a Word

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

function GetXImageSizeOW(width,height,ncolors : integer) : longint;
begin
  GetXImageSizeOW:=GetXImageSize(width,height,ncolors)+2; //OW header contains 2 more bytes to specy Color Bits
end;

function GetXImageSizeFP(width,height : integer) : longint;
begin
  //all FP simulated Graph modes up 256 colors take word per pixel
  GetXImageSizeFP:=sizeof(XGFHeadFP)+(width*2)*height;
end;

function GetXImageSizeFB(width,height : integer) : longint;
begin
  GetXImageSizeFB:=sizeof(XGFHeadFB)+width*height;
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
                      GWLan,QBLan,QCLan,QPLan: begin
                                     If NumColors=4 then head.Width:=width*2
                                     else If NumColors=256 then head.Width:=width SHL 3
                                     else head.Width:=width;
                                     head.Height:=height;
                                   end;
  end;
end;


Procedure WriteXGFBufferFP(BitPlaneWriter  : BitPlaneWriterProc;var data :BufferRec; x,y,x2,y2 : word);
var
 myHead     : XgfHeadFP;
 mywidth    : word;
 myheight   : word;
 i,j,n      : word;
 tempBuf    : array[1..12] of byte;
 PixelCol   : word;
 wordbuf    : array[1..2] of byte;
begin
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
 myHead.Width:=myWidth;
 myHead.Height:=myHeight;
 myHead.reserved:=0;

 Move(myHead,tempBuf,sizeof(tempBuf));
 for n:=1 to 12 do
 begin
    BitplaneWriter(tempBuf[n],data,1);
 end;

 for j:=0 to myheight-1 do
 begin
   for i:=0 to myWidth-1 do
   begin
     pixelCol:=GetPixel(x+i,y+j);
     move(PixelCol,wordbuf,sizeof(wordbuf));
     BitplaneWriter(wordbuf[1],data,1);
     BitplaneWriter(wordbuf[2],data,1);
   end;
 end;
 BitplaneWriter(0,data,2);  //flush it
end;

Procedure WriteXGFBufferFB(BitPlaneWriter  : BitPlaneWriterProc;var data :BufferRec; x,y,x2,y2 : word);
var
 myHead     : XgfHeadFB;
 mywidth    : word;
 myheight   : word;
 i,j,n      : word;
 tempBuf    : array[1..4] of byte;
 PixelCol   : byte;
begin
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
 myHead.Width:=mywidth SHL 3;
 myHead.Height:=myHeight;

 Move(myHead,tempBuf,sizeof(tempBuf));
 for n:=1 to 4 do
 begin
    BitplaneWriter(tempBuf[n],data,1);
 end;

 for j:=0 to myheight-1 do
 begin
   for i:=0 to myWidth-1 do
   begin
     pixelCol:=GetPixel(x+i,y+j);
     BitplaneWriter(pixelCol,data,1);
   end;
 end;
 BitplaneWriter(0,data,2);  //flush it
end;

Procedure WriteXGFBufferOW(BitPlaneWriter  : BitPlaneWriterProc;var data :BufferRec; x,y,x2,y2 : word);
Var
 sourcelinebuf : Linebuftype;
 destlinebuf   : Linebuftype;
 Head     : XgfHeadOW;
 width    : word;
 height   : word;
 BPL        : Word;  //bytes per line for one bitplane
 BTW        : word; //bytes to write to buffer
 i,j,n      : Word;
 nColors  : Word;
 tempBuf    : array[1..6] of byte;
begin
 width:=x2-x+1;
 Height:=y2-y+1;
 nColors:=GetMaxColor+1;
 BPL:=GetBPLSize(Width,nColors);
 BTW:=BPL;

 if nColors = 16 then BTW:=BPL*4;

 Head.Width:=width;
 Head.Height:=height;
 Head.Colors:=nColorsToColorBits(nColors);
 Move(Head,tempBuf,sizeof(tempBuf));

 for n:=1 to 6 do
 begin
    BitplaneWriter(tempBuf[n],data,1);
 end;

 for j:=0 to height-1 do
 begin
   for i:=0 to Width-1 do
   begin
       sourceLineBuf[i]:=GetPixel(x+i,y+j);
   end;
   case nColors of   2:spTOmp(sourcelinebuf,destlinebuf,BPL,1);
                     4:spToPacked(sourcelinebuf,destlinebuf,BPL);
                    16:begin
                         RemapToBorland(sourcelinebuf,Width);  //OW uses the same bit plane format as Borland for 16 colors
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




Procedure WriteXGFBuffer(BitPlaneWriter  : BitPlaneWriterProc;var data :BufferRec; x,y,x2,y2,LanType : word);
Var
 sourcelinebuf : Linebuftype;
 destlinebuf   : Linebuftype;
 Head     : XgfHead;
 width    : word;
 height   : word;
 BPL        : Word;  //bytes per line for one bitplane
 BTW        : word; //bytes to write to buffer
 i,j,n      : Word;
 nColors  : Word;
 tempBuf    : array[1..4] of byte;
begin
 width:=x2-x+1;
 Height:=y2-y+1;
 nColors:=GetMaxColor+1;
 BPL:=GetBPLSize(Width,nColors);
 BTW:=BPL;

 if nColors = 16 then BTW:=BPL*4;
 //BitplaneWriter(0,data,0);
 //patch correct widht height for language/compiler - Microsoft and Borland did some wierd things to a simple bitmap format
 FixHead(Head,Width,Height,LanType);
 Move(Head,tempBuf,sizeof(tempBuf));

 for n:=1 to 4 do
 begin
    BitplaneWriter(tempBuf[n],data,1);
 end;

 for j:=0 to height-1 do
 begin
   for i:=0 to Width-1 do
   begin
       sourceLineBuf[i]:=GetPixel(x+i,y+j);
   end;
   case nColors of 2:spTOmp(sourcelinebuf,destlinebuf,BPL,1);
                     4:spToPacked(sourcelinebuf,destlinebuf,BPL);
                    16:begin
                         If (LanType=TPLan) OR (LanType=TCLan) OR (LanType=PBLan) then RemapToBorland(sourcelinebuf,Width);
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
{$I-}
  if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.error:=0;
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
{$I+}
 buffer.Error:=IORESULT;
end;


procedure BitplaneWriterPascalCode(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
 {$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.arraysize:=0;
       buffer.ByteWriteCount:=0;
       buffer.error:=0;
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
  buffer.Error:=IORESULT;
end;

procedure BitplaneWriterCCode(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
 {$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.arraysize:=0;
       buffer.ByteWriteCount:=0;
       buffer.error:=0;
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
             write(buffer.ftext,'0x',LowerCase(HexStr(buffer.buflist[i],2)));
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
         write(buffer.ftext,'0x',LowerCase(HexStr(buffer.buflist[i],2)));
         inc(buffer.ByteWriteCount);
         if buffer.ByteWriteCount < buffer.ArraySize then write(buffer.ftext,',');
       end;
       write(buffer.ftext,'};');
       writeln(buffer.ftext);
       buffer.bufcount:=0;
  end;
{$I+}
  buffer.Error:=IORESULT;
end;



procedure BitplaneWriterGWBasicCode(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
{$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.error:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.bufcount);
       buffer.buflist[buffer.bufcount]:=inbyte;
       if buffer.bufcount = 20 then                      //every 10 bytes write to data statement
       begin
           //write the data statement
           write(buffer.ftext,GetGWNextLineNumber,' DATA ');
           for i:=0 to 9 do
           begin
             write(buffer.ftext,'&H',HexStr(buffer.buflist[i*2+2],2),HexStr(buffer.buflist[i*2+1],2));
             if i < 9 then write(buffer.ftext,',');
           end;
           writeln(buffer.ftext);
           buffer.bufcount:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
     if buffer.bufcount > 0 then
     begin
       write(buffer.ftext,GetGWNextLineNumber,' DATA ');
       for i:=0 to ((buffer.bufcount+1) div 2)-1 do
       begin
         write(buffer.ftext,'&H',HexStr(buffer.buflist[i*2+2],2),HexStr(buffer.buflist[i*2+1],2));
         if i < (((buffer.bufcount+1) div 2)-1) then write(buffer.ftext,',');
       end;
       writeln(buffer.ftext);
       buffer.bufcount:=0;
     end;
   end;
   {$I+}
   buffer.Error:=IORESULT;
end;



// word size data statements - byte strean is converted to words
procedure BitplaneWriterBasicCode(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
{$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.error:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.bufcount);
       buffer.buflist[buffer.bufcount]:=inbyte;
       if buffer.bufcount = 20 then                      //every 10 bytes write to data statement
       begin
           //write the data statement
           write(buffer.ftext,'DATA ');
           for i:=0 to 9 do
           begin
             write(buffer.ftext,'&H',HexStr(buffer.buflist[i*2+2],2),HexStr(buffer.buflist[i*2+1],2));
             if i < 9 then write(buffer.ftext,',');
           end;
           writeln(buffer.ftext);
           buffer.bufcount:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
     if buffer.bufcount > 0 then
     begin
       write(buffer.ftext,'DATA ');
       for i:=0 to ((buffer.bufcount+1) div 2)-1 do
       begin
         write(buffer.ftext,'&H',HexStr(buffer.buflist[i*2+2],2),HexStr(buffer.buflist[i*2+1],2));
         if i < (((buffer.bufcount+1) div 2)-1) then write(buffer.ftext,',');
       end;
       writeln(buffer.ftext);
       buffer.bufcount:=0;
     end;
   end;
   {$I+}
   buffer.Error:=IORESULT;
end;

Function WriteTPCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;
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
 Size:=GetXImageSize(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'(* Turbo Pascal PutImage Bitmap Code Created By Raster Master *)');
 writeln(data.ftext,'(* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' *)');
 writeln(data.ftext,' ',Imagename,'_Size = ',size,';');
 writeln(data.ftext,' ',Imagename,'_Width = ',width,';');
 writeln(data.ftext,' ',Imagename,'_Height = ',height,';');
 writeln(data.ftext,' ',Imagename,'_Colors = ',nColors,';');
 writeln(data.ftext,' ',Imagename,'_Id = ',imageId,';');

 writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of byte = (');
 WriteXGFBuffer(BWriter,data,x,y,x2,y2,TPLan);
 writeln(data.ftext);

{$I+}
 WriteTPCodeToBuffer:=IORESULT;
end;


Function WriteOWCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageId : word; imagename:string):word;
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
 Size:=GetXImageSizeOW(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'/* Open Watcom C _putimage Bitmap Code Created By Raster Master */');
 writeln(data.ftext,'/* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' */');
 writeln(data.ftext,' #define ',Imagename,'_Size ',size);
 writeln(data.ftext,' #define ',Imagename,'_Width ',width);
 writeln(data.ftext,' #define ',Imagename,'_Height ',height);
 writeln(data.ftext,' #define ',Imagename,'_Colors ',nColors);
 Writeln(data.ftext,' #define ',ImageName,'_Id ',imageId);

 writeln(data.ftext,' ','char ',Imagename, '[',size,']  = {');
 WriteXGFBufferOW(BWriter,data,x,y,x2,y2);
 writeln(data.ftext);

{$I+}
 WriteOWCodeToBuffer:=IORESULT;
end;


Function WriteTCCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageId : word; imagename:string):word;
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
 Size:=GetXImageSize(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'/* Turbo C putimage Bitmap Code Created By Raster Master */');
 writeln(data.ftext,'/* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' */');
 writeln(data.ftext,' #define ',Imagename,'_Size ',size);
 writeln(data.ftext,' #define ',Imagename,'_Width ',width);
 writeln(data.ftext,' #define ',Imagename,'_Height ',height);
 writeln(data.ftext,' #define ',Imagename,'_Colors ',nColors);
 Writeln(data.ftext,' #define ',ImageName,'_Id ',imageId);

 writeln(data.ftext,' ','char ',Imagename, '[',size,']  = {');
 WriteXGFBuffer(BWriter,data,x,y,x2,y2,TCLan);
 writeln(data.ftext);

{$I+}
 WriteTCCodeToBuffer:=IORESULT;
end;

Function WriteQCCodeToBuffer(var data :BufferRec;x,y,x2,y2,ImageId : word; imagename:string):word;
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
 Size:=GetXImageSize(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'/* QuickC putimage Bitmap Code Created By Raster Master */');
 writeln(data.ftext,'/* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' */');
 writeln(data.ftext,' #define ',Imagename,'_Size ',size);
 writeln(data.ftext,' #define ',Imagename,'_Width ',width);
 writeln(data.ftext,' #define ',Imagename,'_Height ',height);
 writeln(data.ftext,' #define ',Imagename,'_Colors ',nColors);
 Writeln(data.ftext,' #define ',ImageName,'_Id ',imageId);

 writeln(data.ftext,' ','char ',Imagename, '[',size,']  = {');
 WriteXGFBuffer(BWriter,data,x,y,x2,y2,QCLan);
 writeln(data.ftext);

{$I+}
 WriteQCCodeToBuffer:=IORESULT;
end;


Function WriteQPCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageid : word; imagename:string):word;
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
 Size:=GetXImageSize(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'(* QuickPascal PutImage Bitmap Code Created By Raster Master *)');
 writeln(data.ftext,'(* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' *)');
 writeln(data.ftext,' ',Imagename,'_Size = ',size,';');
 writeln(data.ftext,' ',Imagename,'_Width = ',width,';');
 writeln(data.ftext,' ',Imagename,'_Height = ',height,';');
 writeln(data.ftext,' ',Imagename,'_Colors = ',nColors,';');
 writeln(data.ftext,' ',Imagename,'_Id = ',imageId,';');

 writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of byte = (');
 WriteXGFBuffer(BWriter,data,x,y,x2,y2,QPLan);
 writeln(data.ftext);

{$I+}
 WriteQPCodeToBuffer:=IORESULT;
end;

Function WriteFPCodeToBuffer(var data :BufferRec;x,y,x2,y2,imageId : word; imagename:string):word;
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
 Size:=GetXImageSizeFP(width,height);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,'(* FreePascal PutImage Bitmap Code Created By Raster Master *)');
 writeln(data.ftext,'(* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' *)');
 writeln(data.ftext,' ',Imagename,'_Size = ',size,';');
 writeln(data.ftext,' ',Imagename,'_Width = ',width,';');
 writeln(data.ftext,' ',Imagename,'_Height = ',height,';');
 writeln(data.ftext,' ',Imagename,'_Colors = ',nColors,';');
 writeln(data.ftext,' ',Imagename,'_Id = ',imageId,';');

 writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of byte = (');
 WriteXGFBufferFP(BWriter,data,x,y,x2,y2);
 writeln(data.ftext);

{$I+}
 WriteFPCodeToBuffer:=IORESULT;
end;


Function WriteQBCodeToBuffer(var data :BufferRec;x,y,x2,y2 : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longword;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;

begin
 BWriter:=@BitplaneWriterBasicCode;

 width:=x2-x+1;
 height:=y2-y+1;
 nColors:=GetMaxColor+1;
 Size:=GetXImageSize(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,#39,' QuickBASIC\QB64 Put Bitmap Code Created By Raster Master');
 writeln(data.ftext,#39,' Size= ', Size div 2,' Width= ',width,' Height= ',height, ' Colors= ',nColors);
 writeln(data.ftext,#39,' ',Imagename);
 WriteXGFBuffer(BWriter,data,x,y,x2,y2,QBLan);
 writeln(data.ftext);

{$I+}
 WriteQBCodeToBuffer:=IORESULT;
end;

Function WritePBCodeToBuffer(var data :BufferRec;x,y,x2,y2 : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longword;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;

begin
 BWriter:=@BitplaneWriterBasicCode;

 width:=x2-x+1;
 height:=y2-y+1;
 nColors:=GetMaxColor+1;
 Size:=GetXImageSize(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,#39,' Turbo\Power Basic Put Bitmap Code Created By Raster Master');
 writeln(data.ftext,#39,' Size= ', Size div 2,' Width= ',width,' Height= ',height, ' Colors= ',nColors);
 writeln(data.ftext,#39,' ',Imagename);
 WriteXGFBuffer(BWriter,data,x,y,x2,y2,PBLan);
 writeln(data.ftext);

{$I+}
 WritePBCodeToBuffer:=IORESULT;
end;

Function WriteGWCodeToBuffer(var data :BufferRec;x,y,x2,y2 : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longword;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;
begin
 BWriter:=@BitplaneWriterGWBasicCode;

 width:=x2-x+1;
 height:=y2-y+1;
 nColors:=GetMaxColor+1;
 Size:=GetXImageSize(width,height,nColors);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,GetGWNextLineNumber,' ',#39,' GWBASIC\PCBASIC Put Bitmap Code Created By Raster Master');
 writeln(data.ftext,GetGWNextLineNumber,' ',#39,' Size= ', Size div 2,' Width= ',width,' Height= ',height, ' Colors= ',nColors);
 writeln(data.ftext,GetGWNextLineNumber,' ',#39,' ',Imagename);
 WriteXGFBuffer(BWriter,data,x,y,x2,y2,GWLan);
 writeln(data.ftext);

{$I+}
 WriteGWCodeToBuffer:=IORESULT;
end;




Function WriteFBCodeToBuffer(var data :BufferRec;x,y,x2,y2 : word; imagename:string):word;
var
  Width,Height : Word;
  Size      : longword;
  nColors   : integer;
  BWriter   : BitPlaneWriterProc;

begin
 BWriter:=@BitplaneWriterBasicCode;

 width:=x2-x+1;
 height:=y2-y+1;
 nColors:=GetMaxColor+1;
 Size:=GetXImageSizeFB(width,height);
{$I-}
 BWriter(0,data,0);  //init the data record
 data.ArraySize:=size;

 writeln(data.ftext,#39,' Freebasic Put Bitmap Code Created By Raster Master');
 writeln(data.ftext,#39,' Size= ', Size div 2,' Width= ',width,' Height= ',height, ' Colors= ',nColors);
 writeln(data.ftext,#39,' ',Imagename);
 WriteXGFBufferFB(BWriter,data,x,y,x2,y2);
 writeln(data.ftext);

{$I+}
 WriteFBCodeToBuffer:=IORESULT;
end;

procedure WriteXgfToBuffer(x,y,x2,y2,LanType,Mask : word;var data : BufferRec);
var
 omask : integer;
begin
  omask:=GetMaskMode;
  SetMaskMode(Mask);

  BitPlaneWriterFile(0,data,0);
  WriteXGFBuffer(@BitPlaneWriterFile,data,x,y,x2,y2,LanType);
  SetMaskMode(oMask);
end;

procedure WriteXgfToBufferFB(x,y,x2,y2,Mask: word;var data : BufferRec);
var
 omask : integer;
begin
  omask:=GetMaskMode;
  SetMaskMode(Mask);
  BitPlaneWriterFile(0,data,0);
  WriteXGFBufferFB(@BitPlaneWriterFile,data,x,y,x2,y2);
  SetMaskMode(oMask);
end;

procedure WriteXgfToBufferFP(x,y,x2,y2,Mask : word;var data : BufferRec);
var
 omask : integer;
begin
  omask:=GetMaskMode;
  SetMaskMode(Mask);
  BitPlaneWriterFile(0,data,0);
  WriteXGFBufferFP(@BitPlaneWriterFile,data,x,y,x2,y2);
  SetMaskMode(oMask);
end;

procedure WriteXgfToBufferOW(x,y,x2,y2,Mask : word;var data : BufferRec);
var
 omask : integer;
begin
  omask:=GetMaskMode;
  SetMaskMode(Mask);
  BitPlaneWriterFile(0,data,0);
  WriteXGFBufferOW(@BitPlaneWriterFile,data,x,y,x2,y2);
  SetMaskMode(oMask);
end;


//write a single file
Function WriteXgfToCode(x,y,x2,y2,LanType : word;filename:string):word;
var
 data      : BufferRec;
 imagename : String;
 imageid   : word;
begin
 SetCoreActive;   // we are getting data from core object RMCoreBase
 SetGWStartLineNumber(1000);
 assign(data.fText,filename);
{$I-}
 rewrite(data.fText);
 imageid:=GetThumbIndex;
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 case LanType of TPLan: WriteTPCodeToBuffer(data,x,y,x2,y2,imageid,imagename);
                 TCLan: WriteTCCodeToBuffer(data,x,y,x2,y2,imageid,imagename);

                 QBLan: WriteQBCodeToBuffer(data,x,y,x2,y2,imagename);
                 GWLan: WriteGWCodeToBuffer(data,x,y,x2,y2,imagename);

                 QPLan: WriteQPCodeToBuffer(data,x,y,x2,y2,imageid,imagename);
                 QCLan: WriteQCCodeToBuffer(data,x,y,x2,y2,imageid,imagename);

                 OWLan: WriteOWCodeToBuffer(data,x,y,x2,y2,imageid,imagename);

                 PBLan: WritePBCodeToBuffer(data,x,y,x2,y2,imagename);

                 FBinQBModeLan: WriteFBCodeToBuffer(data,x,y,x2,y2,imagename);
                 FPLan: WriteFPCodeToBuffer(data,x,y,x2,y2,imageid,imagename);

 end;
 close(data.fText);
 {$I+}
 WriteXgfToCode:=IOResult;
end;

Function WriteXgfWithMaskToCode(x,y,x2,y2,LanType : word;filename:string):word;
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
 WriteXGFCodeToBuffer(data,x,y,x2,y2,LanType,0,imagename);
 WriteXGFCodeToBuffer(data,x,y,x2,y2,LanType,1,imagename+'Mask');  //mask

 close(data.fText);
 {$I+}
 WriteXgfWithMaskToCode:=IOResult;
end;


//write a single binary file
Function WriteXgfToFile(x,y,x2,y2,LanType : word;filename:string):word;
var
 data      : BufferRec;
begin
SetCoreActive;   // we are getting data from core object RMCoreBase
Assign(data.f,filename);
{$I-}
 Rewrite(data.f,1);
 //BitplaneWriterFile(0,data,0);
 //WriteXGFBuffer(@BitPlaneWriterFile,data,x,y,x2,y2,LanType);
 case LanType of         OWLan: WriteXGFToBufferOW(x,y,x2,y2,0,data);
                 FBinQBModeLan: WriteXGFToBufferFB(x,y,x2,y2,0,data);
                         FPLan: WriteXGFToBufferFP(x,y,x2,y2,0,data);
      else
         WriteXGFToBuffer(x,y,x2,y2,LanType,0,data);
 end;

 Close(data.f);
{$I+}
 WriteXgfToFile:=IOResult;
end;


function WriteXGFCodeToBuffer(var data : BufferRec;x,y,x2,y2,LanType,Mask : word; imagename:string):word;
var
 omask : integer;
 imageid : word;
begin
  imageId:=GetThumbIndex;
  omask:=GetMaskMode;
  SetMaskMode(Mask);
  case LanType of TPLan: WriteTPCodeToBuffer(data,x,y,x2,y2,imageid,imagename);
                  TCLan: WriteTCCodeToBuffer(data,x,y,x2,y2,imageid,imagename);

                  QBLan: WriteQBCodeToBuffer(data,x,y,x2,y2,imagename);
                  GWLan: WriteGWCodeToBuffer(data,x,y,x2,y2,imagename);

                  QPLan: WriteQPCodeToBuffer(data,x,y,x2,y2,imageid,imagename);
                  QCLan: WriteQCCodeToBuffer(data,x,y,x2,y2,imageId,imagename);

                  OWLan: WriteOWCodeToBuffer(data,x,y,x2,y2,imageid,imagename);

                  PBLan: WritePBCodeToBuffer(data,x,y,x2,y2,imagename);

                  FPLan: WriteFPCodeToBuffer(data,x,y,x2,y2,imageid,imagename);
                  FBinQBModeLan: WriteFBCodeToBuffer(data,x,y,x2,y2,imagename)
  end;
  SetMaskMode(omask);
  WriteXGFCodeToBuffer:=data.Error;
end;


begin

end.
