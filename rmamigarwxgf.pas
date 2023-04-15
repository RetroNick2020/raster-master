{$mode objfpc}{$H+}
{$PACKRECORDS 1}

Unit rmamigarwxgf;
 Interface
   uses rmcore,rwxgf,rmxgfcore,SysUtils,LazFileUtils,bits;

procedure InitBufferRec(var Buffer : BufferRec);
function GetABXImageSize(width,height,ncolors : integer) : longint;
function GetBobDataSize(width,height,nColors: integer;vsprite : boolean) : longint;
function GetAmigaBitMapSize(width,height,ncolors : integer) : longint;

Function WriteAmigaBasicBobBuffer(x,y,x2,y2 : word;var data : bufferRec;SaveAsSprite : Boolean):word;
Function WriteAmigaBasicBobDataBuffer(x,y,x2,y2 : word;var data : bufferRec;imagename:string;SaveAsSprite : Boolean):word;

Function WriteAmigaBasicBobFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
Function WriteAmigaBasicBobDataFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;

Function WriteAmigaBasicXGFBuffer(x,y,x2,y2 : word;var data : bufferRec):word;

Function WriteAmigaBasicXGFDataBuffer(x,y,x2,y2,mask : word;var data : bufferRec;imagename:string):word;

//Function WriteAmigaBasicXGFDataBuffer(x,y,x2,y2 : word;var data : bufferRec;imagename:string):word;

Function WriteAmigaBasicXGFFile(x,y,x2,y2 : word;filename:string):word;
Function WriteAmigaBasicXGFDataFile(x,y,x2,y2 : word;filename:string):word;
Function WriteAmigaBasicXGFPlusMaskDataFile(x,y,x2,y2 : word;filename:string):word;


Function WriteAmigaPascalBobCodeToFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
Function WriteAmigaCBobCodeToFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;

Function WriteAmigaBobBuffer(x,y,x2,y2 : word;var data : bufferRec;SaveAsSprite : Boolean):word;
Function WriteAmigaBobFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;

Function WriteAmigaCBobCodeToBuffer(x,y,x2,y2 : word;imagename:string;var data : BufferRec; SaveAsSprite : Boolean):word;
Function WriteAmigaPascalBobCodeToBuffer(x,y,x2,y2 : word;imagename:string;var data : BufferRec; SaveAsSprite : Boolean):word;


Implementation

type
 linebuftype = array[0..2047] of byte;


 //Amiga Basic BitMap header for PUT / GET Image functions
 ABBitMapHeader = Record
                   Width     : word;
                   Height    : word;
                   BitPlanes : word;
                  end;

 ABBobHeader = Record
//                  fVSprite=1                'This will be a sprite
//                  SAVEBACK=8                '8 = Save background, 0 = Leave copy of image when drawing
//                  OVERLAY=16                '0 = solid, 16 = Transparent flag
//                  Flags=SAVEBACK+OVERLAY+fVSprite
                    ColorSet  : Longword; //     ObjectImage$=MKL$(0) 'ColorSet
                    DataSet   : Longword; //    ObjectImage$=ObjectImage$+MKL$(0) 'DataSet
                    Bitplanes : Longword; //    ObjectImage$=ObjectImage$+MKI$(0)+MKI$(2)  '2 Bitplanes
                    Width     : Longword; //     ObjectImage$=ObjectImage$+MKI$(0)+MKI$(ImageBuf(pad%))  'Width is 16 pixels
                    Height    : Longword; //     ObjectImage$=ObjectImage$+MKI$(0)+MKI$(ImageBuf(pad%+1))  'Height
                    Flags     : Word;     //     ObjectImage$=ObjectImage$+MKI$(Flags)
                    PlanePick : Word;     // ObjectImage$=ObjectImage$+MKI$(3)                    '(PlanePick)  planePick def 15
                    PlaneOfOff :Word;     //  ObjectImage$=ObjectImage$+MKI$(0)  'planeOnOff

 end;

 ABSpritePalette = Record
                                      //' Sprite Colors - Change Color Values
                     Color1 : word;   // ObjectImage$=ObjectImage$+MKI$(&HFFF)  '&HFFF is White - Color 1
                     Color2 : word;    // ObjectImage$=ObjectImage$+MKI$(0)      '0 is Black - Color 2
                     Color3 : word;    // ObjectImage$=ObjectImage$+MKI$(&H080)  '&HF80 is Orange &HF0F is pink - Color 3
 end;



 //Action 0 = init ncounter/buffer,Action 1 = write byte to buffer, action 2= flush buffer
 //Erorr returns file write error
 BitPlaneWriterProc = procedure(inByte : Byte; var Buffer : BufferRec; action : integer);

 Function LongToLE(myLongWord : LongWord) : LongWord;
 var
  Temp : array[1..4] of Byte;
 begin
   Move(myLongWord,Temp,sizeof(Temp));
   LongToLE := (Temp[1] shl 24) + (Temp[2] shl 16) + (Temp[3] shl 8) + Temp[4];
 end;

 Function WordToLE(myWord : Word) : Word; // if its little endian to will become big endian vice versa
 begin
   WordToLE:=LO(myWord) SHL 8 + HI(myWord);
 end;

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
 end;
 nColorsToBitPlanes:=BP;
end;

function GetAmigaBitMapSize(width,height,ncolors : integer) : longint;
var
 bp : integer;
begin
 bp:=nColorsToBitPlanes(nColors);
 GetAmigaBitMapSize:=((width+15) div 16)*2*height*bp;
end;

//image size for Put Image
function GetABXImageSize(width,height,ncolors : integer) : longint;
begin
   GetABXImageSize:=GetAmigaBitMapSize(width,height,ncolors) + sizeof(ABBitMapHeader);
end;

//image size for Bobs and VSprite
function GetBobDataSize(width,height,nColors : integer;vsprite : boolean) : longint;
var
 bitplanes : integer;
begin
 bitplanes:=nColorsToBitplanes(nColors);
 GetBobDataSize:=(((width+15) div 16)*2)*height*bitplanes+sizeof(ABBobHeader);
 if vsprite then inc(GetBobDataSize,sizeof(ABSpritePalette));
end;

procedure InitBufferRec(var Buffer : BufferRec);
begin
  buffer.bufCount:=0;
  buffer.error:=0;
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


procedure ObjectBitplaneWriterDataStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
{$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.Error:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.bufcount);
       buffer.buflist[buffer.bufcount]:=inbyte;
       if buffer.bufcount = 10 then                      //every 10 bytes write to data statement
       begin
           //write the data statement
           write(buffer.ftext,'DATA ');
           for i:=1 to 10 do
           begin
             write(buffer.ftext,'&H',HexStr(buffer.buflist[i],2));
             if i < 10 then write(buffer.ftext,',');
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
       for i:=1 to buffer.bufcount do
       begin
         write(buffer.ftext,'&H',HexStr(buffer.buflist[i],2));
         if i < buffer.bufcount then write(buffer.ftext,',');
       end;
       writeln(buffer.ftext);
       buffer.bufcount:=0;
     end;
   end;
{$I+}
   buffer.Error:=IORESULT;
end;

procedure XGFBitplaneWriterDataStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
{$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.Error:=0;
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
             write(buffer.ftext,'&H',HexStr(buffer.buflist[i*2+1],2),HexStr(buffer.buflist[i*2+2],2));
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
         write(buffer.ftext,'&H',HexStr(buffer.buflist[i*2+1],2),HexStr(buffer.buflist[i*2+2],2));
         if i < (((buffer.bufcount+1) div 2)-1) then write(buffer.ftext,',');
       end;
       writeln(buffer.ftext);
       buffer.bufcount:=0;
     end;
   end;
   {$I+}
   buffer.Error:=IORESULT;
end;


function GetBitPlaneCount : integer;
var
 ColorCount : integer;
begin
 ColorCount:=GetMaxColor+1;
 GetBitPlaneCount:=0;
 Case ColorCount of 2:GetBitplaneCount:=1;
                    4:GetBitPlaneCount:=2;
                    8:GetBitPlaneCount:=3;
                    16:GetBitPlaneCount:=4;
                    32:GetBitPlaneCount:=5;
 end;
end;

function CreateBitPlanes(x,y,x2,y2 : word; BitPlaneWriter  : BitPlaneWriterProc; var data :BufferRec) : word;
var
 lineBuf :linebuftype;
 counter : integer;
 j,i     : integer;
 width   : word;
 pixcolor : integer;
 plane    : integer;
 bitposition: integer;
 minBytesPerLine    : integer;
 BitPlaneCount : integer;
 bwcount : integer;
begin
 //ColorCount:=GetMaxColor+1;
 BitPlaneCount:=GetBitPlaneCount;

 width:=x2-x+1;
// Height:=y2-y+1;
 minBytesPerLine:=((width+15) div 16)*2;

 For plane:=1 to BitPlaneCount do
 begin
   For j:=y to y2 do
   begin
     counter:=0;
     fillchar(linebuf,sizeof(linebuf),0);
     bitposition:=0;
     for i:=x to x2 do
     begin
//        pixcolor:=RMCoreBase.GetPixel(i,j);
        pixColor:=GetPixel(i,j);

        inc(bitposition);
        if (pixcolor = 1) and (plane=1) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 2) and (plane=2) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 3) and ((plane=1) or (plane=2)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 4) and (plane=3) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 5) and ((plane=1) or (plane=3)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 6) and ((plane=2) or (plane=3)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 7) and ((plane=1) or (plane=2) or (plane=3))then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 8) and (plane=4) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 9) and ((plane=1) or (plane=4)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 10) and ((plane=2) or (plane=4)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 11) and ((plane=1) or (plane=2) or (plane=4)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 12) and ((plane=3) or (plane=4)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 13) and ((plane=1) or (plane=3) or (plane=4)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 14) and ((plane=2) or (plane=3) or (plane=4)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 15) and ((plane=1) or (plane=2) or (plane=3) or (plane=4)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 16) and (plane=5) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 17) and ((plane=1) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 18) and ((plane=2) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 19) and ((plane=1) or (plane=2) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 20) and ((plane=3) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 21) and ((plane=1) or (plane=3) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 22) and ((plane=2) or (plane=3) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 23) and ((plane=1) or (plane=2) or (plane=3) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 24) and ((plane=4) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 25) and ((plane=1) or (plane=4) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 26) and ((plane=2) or (plane=4) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 27) and ((plane=1) or (plane=2) or (plane=4) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 28) and ((plane=3) or (plane=4) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 29) and ((plane=1) or (plane=3) or (plane=4) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 30) and ((plane=2) or (plane=3) or (plane=4) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);
        if (pixcolor = 31) and ((plane=1) or (plane=2) or (plane=3) or (plane=4) or (plane=5)) then setbit(8-bitposition,1,linebuf[counter]);

        if bitposition=8 then
        begin
          bitposition:=0;
          inc(counter);
        end;
     end;  //end i
     for bwcount:=0 to minBytesPerLine-1 do
     begin
       BitPlaneWriter(linebuf[bwcount],data,1);  //based on the bitplane writer this will be saved as binary or outputed as text data statements
       if data.Error<>0 then
       begin
          CreateBitPlanes:=data.Error;
          exit;
       end;
     end;
   end; // end j
 end;  // end plane
end;

Procedure CreateHeader(var Header : ABBobHeader; x,y,x2,y2 : word;SaveAsSprite : Boolean);
var
 fVSprite : Word;
 SaveBack : Word;
 Overlay  : Word;
 Flags    : Word;
 Width,Height : Word;
 BPCount   : Word;
begin
 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;
 //fVSprite=1  'This will be a sprite - 0 it will be a Bob
 fVSprite:=0;
 if (SaveAsSprite=true) AND (width = 16) AND (BPCount=2) then fVSprite:=1;
 SaveBack:=8;   //   '8 = Save background, 0 = Leave copy of image when drawing
 Overlay:=16;   //   '0 = solid, 16 = Transparent flag
 Flags:=SAVEBACK+OVERLAY+fVSprite;
 Header.Flags:=WordToLE(Flags);
 Header.ColorSet:=0;
 Header.DataSet:=0;
 Header.Bitplanes:=LongToLE(BPCount);
 Header.Width:=LongToLE(width);
 Header.Height:=LongToLE(height);

 if fVSprite = 1 then
   Header.PlanePick:=WordToLE(3)
 else Header.PlanePick:=WordToLE(GetMaxColor);
 Header.PlaneOfOff:=0;
end;

Procedure CreateVSpritePalette(var SpritePal : ABSpritePalette);
var
 TR1,TR2,TR3 : TRMColorRec;
 color1,color2,color3 : word;
begin
 GetColor(1,TR1);
 GetColor(2,TR2);
 GetColor(3,TR3);
 Color1:=(EightToFourBit(TR1.r) SHL 8) + (EightToFourBit(TR1.g) SHL 4) + EightToFourBit(TR1.b);
 Color2:=(EightToFourBit(TR2.r) SHL 8) + (EightToFourBit(TR2.g) SHL 4) + EightToFourBit(TR2.b);
 Color3:=(EightToFourBit(TR3.r) SHL 8) + (EightToFourBit(TR3.g) SHL 4) + EightToFourBit(TR3.b);
 SpritePal.Color1:=WordToLE(Color1);
 SpritePal.Color2:=WordToLE(Color2);
 SpritePal.Color3:=WordToLE(Color3);
end;




Procedure spTOmp(var singlePlane : LineBufType ;
                 var multiplane  : LineBufType;
                 PixelWidth,BytesPerPlane,nPlanes : Word);

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


// for vsprite - the bitplanes alternate between Bitplate 1, Bitplane 2 for each line of bitmap
Procedure CreateSpriteBitPlanes(x,y,x2,y2 : word; BitPlaneWriter  : BitPlaneWriterProc; var data :BufferRec);
var
 lineBuf,spritebuf :linebuftype;
 j,i     : integer;
 width   : word;
 minBytesPerLine    : integer;
 bwcount : integer;
 xpos : integer;
begin
 width:=x2-x+1;
 minBytesPerLine:=((width+15) div 16)*2;

 For j:=y to y2 do
 begin
   fillchar(linebuf,sizeof(linebuf),0);
   xpos:=0;
   for i:=x to x2 do
   begin
     linebuf[xpos]:=RMCoreBase.GetPixel(i,j);
     inc(xpos);
   end;

   spTOmp(LineBuf,spritebuf,width,minBytesPerLine,2);

   for bwcount:=0 to minBytesPerLine*2-1 do  // 2 plitplanes for 4 color sprites
   begin
     BitPlaneWriter(Spritebuf[bwcount],data,1);  //based on the bitplane writer this will be saved as binary or outputed as text data statements
   end;
 end; // end j
end;



procedure SpriteBitplaneWriterConstStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
begin
{$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.arraysize:=0;
       buffer.ByteWriteCount:=0;
       buffer.Error:=0;;
   end
   else if action = 1 then
   begin
       inc(buffer.bufcount);
       buffer.buflist[buffer.bufcount]:=inbyte;
       if buffer.bufcount = 8 then                      //every 8 bytes write to 2 const lines
       begin
         //write the const value
         write(buffer.ftext,'  ','$',HexStr(buffer.buflist[1],2),HexStr(buffer.buflist[2],2),
                            HexStr(buffer.buflist[3],2),HexStr(buffer.buflist[4],2));

         writeln(buffer.ftext,',');

         write(buffer.ftext,'  ','$',HexStr(buffer.buflist[5],2),HexStr(buffer.buflist[6],2),
                            HexStr(buffer.buflist[7],2),HexStr(buffer.buflist[8],2));
         inc(buffer.ByteWriteCount,8);
         if buffer.ByteWriteCount < (buffer.ArraySize*4) then writeln(buffer.ftext,',');
         //writeln(buffer.ftext);
         buffer.bufcount:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
       if buffer.bufcount = 8 then                  //check if there is another line of sprite data
       begin
         //write the const value
         write(buffer.ftext,'  ','$',HexStr(buffer.buflist[1],2),HexStr(buffer.buflist[2],2),
                            HexStr(buffer.buflist[3],2),HexStr(buffer.buflist[4],2));

         writeln(buffer.ftext,',');

         write(buffer.ftext,'  ','$',HexStr(buffer.buflist[5],2),HexStr(buffer.buflist[6],2),
                            HexStr(buffer.buflist[7],2),HexStr(buffer.buflist[8],2));
         inc(buffer.ByteWriteCount,8);
       end;
       writeln(buffer.ftext,');');
       buffer.bufcount:=0;
  end;
 {$I+}
  buffer.Error:=IORESULT;
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
       buffer.Error:=0;
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
           writeln(buffer.ftext);
           buffer.bufcount:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
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




Function WriteAmigaPascalConst(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
  Width,height : Word;
  data :BufferRec;
  BPCount : word;
  size : longword;
  Imagename : string;
  BWriter : BitPlaneWriterProc;

begin
 if SaveAsSprite then
 begin
     BWriter:=@SpriteBitplaneWriterConstStatements;
  //   BWriter:=@BitplaneWriterConstStatements;

 end
 else
 begin
   BWriter:=@BitplaneWriterConstStatements;
 end;

 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;

 BWriter(0,data,0);  //init the data record

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);

 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 Size:=(((width+15) div 16)*2)*height*BPCount;

 if SaveAsSprite then Size:=Size div 4;
 data.ArraySize:=Size;

 writeln(data.ftext,'(* Amiga Pascal, Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',GetMaxColor+1,' *)');
 if SaveAsSprite then
 begin
     writeln(data.ftext,'(* VSprite Bitmap *)');
     writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of longint = (');
     CreateSpriteBitPlanes(x,y,x2,y2,BWriter,data);

     (*
     for j:=y to y2 do
     begin
       CreateBitPlanes(x,j,x2,j,BWriter,data);
     end;
     *)
 end
 else
 begin
   writeln(data.ftext,'(* BOB Bitmap *)');
   writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of byte = (');
   CreateBitPlanes(x,y,x2,y2,BWriter,data);
 end;

 BWriter(0,data,2);  //flush it
 Close(data.ftext);
{$I+}
 if data.Error<>0 then
   WriteAmigaPascalConst:=data.Error
 else
   WriteAmigaPascalConst:=IORESULT;
end;

(*
WORD chip bob_data1[2 * 2 * GEL_SIZE] =
   {
   /* plane 1 */
   0xffff, 0x0003, 0xfff0, 0x0003, 0xfff0, 0x0003, 0xffff, 0x0003,
   /* plane 2 */
   0x3fff, 0xfffc, 0x3ff0, 0x0ffc, 0x3ff0, 0x0ffc, 0x3fff, 0xfffc
   };
 *)

procedure BitplaneWriterCWORDStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
{$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.arraysize:=0;
       buffer.ByteWriteCount:=0;
       buffer.Error:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.bufcount);
       buffer.buflist[buffer.bufcount]:=inbyte;
       if buffer.bufcount = 16 then                      //every 16 bytes write to line
       begin
           //write the const value
           write(buffer.ftext,'  ');
           for i:=0 to 7 do
           begin
             write(buffer.ftext,'0x',LowerCase(HexStr(buffer.buflist[i*2+1],2)),LowerCase(HexStr(buffer.buflist[i*2+2],2)));
             inc(buffer.ByteWriteCount);
             if buffer.ByteWriteCount < buffer.ArraySize then write(buffer.ftext,',');
           end;
           if buffer.ByteWriteCount < buffer.ArraySize then writeln(buffer.ftext);
           buffer.bufcount:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
      if buffer.bufcount > 0 then
      begin
        //if odd(buffer.bufcount) then inc(buffer.bufcount); // should not be odd but if it is
        write(buffer.ftext,'  ');
        for i:=0 to (buffer.bufcount div 2)-1 do
        begin
          write(buffer.ftext,'0x',LowerCase(HexStr(buffer.buflist[i*2+1],2)),LowerCase(HexStr(buffer.buflist[i*2+2],2)));
          inc(buffer.ByteWriteCount);
          if buffer.ByteWriteCount < buffer.ArraySize then write(buffer.ftext,',');
        end;
      end;
      writeln(buffer.ftext,'};');
      buffer.bufcount:=0;
   end;
   {$I+}
   buffer.Error:=IORESULT;
end;

procedure BitplaneWriterPascalWORDStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
{$I-}
   if action = 0 then
   begin
       buffer.bufCount:=0;
       buffer.arraysize:=0;
       buffer.ByteWriteCount:=0;
       buffer.Error:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.bufcount);
       buffer.buflist[buffer.bufcount]:=inbyte;
       if buffer.bufcount = 16 then                      //every 16 bytes write to line
       begin
           //write the const value
           write(buffer.ftext,'  ');
           for i:=0 to 7 do
           begin
             write(buffer.ftext,'$',HexStr(buffer.buflist[i*2+1],2),HexStr(buffer.buflist[i*2+2],2));
             inc(buffer.ByteWriteCount);
             if buffer.ByteWriteCount < buffer.ArraySize then write(buffer.ftext,',');
           end;
           if buffer.ByteWriteCount < buffer.ArraySize then writeln(buffer.ftext);
           buffer.bufcount:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
      if buffer.bufcount > 0 then
      begin
        //if odd(buffer.bufcount) then inc(buffer.bufcount); // should not be odd but if it is
        write(buffer.ftext,'  ');
        for i:=0 to (buffer.bufcount div 2)-1 do
        begin
          write(buffer.ftext,'$',HexStr(buffer.buflist[i*2+1],2),HexStr(buffer.buflist[i*2+2],2));
          inc(buffer.ByteWriteCount);
          if buffer.ByteWriteCount < buffer.ArraySize then write(buffer.ftext,',');
        end;
      end;
      writeln(buffer.ftext,');');
      buffer.bufcount:=0;
   end;
   {$I+}
   buffer.Error:=IORESULT;
end;



Function WriteAmigaBasicBobBuffer(x,y,x2,y2 : word;var data : bufferRec;SaveAsSprite : Boolean):word;
var
  Header : ABBobHeader;
  SPal   : ABSpritePalette;
  Width : Word;
  TempBuf : array[1..26] of Byte;
  i,BPCount : word;
begin
 CreateHeader(Header, x,y,x2,y2,SaveAsSprite);

 Move(Header,TempBuf,sizeof(TempBuf));
 BitplaneWriterFile(0,data,0);  //init the data record

 For i:=1 to SizeOf(TempBuf) do
 begin
   BitplaneWriterFile(tempBuf[i],data,1);
 end;

 CreateBitPlanes(x,y,x2,y2,@BitplaneWriterFile,data);
 if data.Error <> 0 then
 begin
   WriteAmigaBasicBobBuffer:=data.Error;
   exit;
 end;

 width:=x2-x+1;
 BPCount:=GetBitPlaneCount;
 if (SaveAsSprite=true) AND (width = 16) AND (BPCount=2) then
 begin
   //write Palette for VSprite
    CreateVSpritePalette(SPal);
    Move(SPal,TempBuf,sizeof(SPal));
    For i:=1 to SizeOf(SPal) do
    begin
      BitplaneWriterFile(tempBuf[i],data,1);
    end;
 end;
 BitplaneWriterFile(0,data,2);  //flush it
 WriteAmigaBasicBobBuffer:=data.Error;
end;


Function WriteAmigaBasicBobFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
 data  : BufferRec;
begin
SetCoreActive;  //pull data from RMCore
Assign(data.f,filename);
{$I-}
Rewrite(data.f,1);
WriteAmigaBasicBobBuffer(x,y,x2,y2,data,SaveAsSprite);
if data.error <> 0 then
begin
   WriteAmigaBasicBobFile:=data.Error;
   exit;
end;

Close(data.f);
{$I+}
WriteAmigaBasicBobFile:=IORESULT;
end;

Function WriteAmigaBasicBobDataBuffer(x,y,x2,y2 : word;var data : bufferRec;imagename:string;SaveAsSprite : Boolean):word;
var
  Header : ABBobHeader;
  SPal   : ABSpritePalette;
  Width,height : Word;
  TempBuf : array[1..26] of Byte;
  i : word;
  DataNameStr : string;
  isVSprite : Boolean;
  nColors   : integer;
begin
 width:=x2-x+1;
 height:=y2-y+1;
 nColors:=GetMaxColor+1;

 isVSprite:=false;
 if (SaveAsSprite=true) AND (width = 16) AND (nColors=4) then isVSprite:=true;

 CreateHeader(Header, x,y,x2,y2,SaveAsSprite);
 Move(Header,TempBuf,sizeof(TempBuf));

 ObjectBitplaneWriterDataStatements(0,data,0);  //init the data record
 if data.Error<>0 then
 begin
    WriteAmigaBasicBobDataBuffer:=data.Error;
    exit;
 end;

 if isvsprite then
   DataNameStr:='VSprite'
 else
   DataNameStr:='Bob';

 writeln(data.ftext,#39,' AmigaBASIC ',DataNameStr,' Size= ', GetBobDataSize(width,height,nColors,isVSprite),' Width= ',width,' Height= ',height, ' Colors= ',GetMaxColor+1);

 writeln(data.ftext,#39,' ',Imagename);
 For i:=1 to SizeOf(TempBuf) do
 begin
   ObjectBitplaneWriterDataStatements(tempBuf[i],data,1);
 end;

 CreateBitPlanes(x,y,x2,y2,@ObjectBitplaneWriterDataStatements,data);
 if data.Error<>0 then
 begin
    WriteAmigaBasicBobDataBuffer:=data.Error;
    exit;
 end;

 if IsVSprite then
 begin
   //write Palette for VSprite
    CreateVSpritePalette(SPal);
    Move(SPal,TempBuf,sizeof(SPal));
    For i:=1 to SizeOf(SPal) do
    begin
      ObjectBitplaneWriterDataStatements(tempBuf[i],data,1);
    end;
 end;
 ObjectBitplaneWriterDataStatements(0,data,2);  //flush it
 WriteAmigaBasicBobDataBuffer:=data.Error;
end;

Function WriteAmigaBasicBobDataFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
  data :BufferRec;
  ImageName : string;
  Error : word;
begin
 SetCoreActive;  //pull data from RMCore
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));

 Assign(data.ftext,filename);
 {$I-}
 Rewrite(data.ftext);
 Error:=WriteAmigaBasicBobDataBuffer(x,y,x2,y2,data,imagename,SaveAsSprite);
 if Error<>0 then
 begin
    WriteAmigaBasicBobDataFile:=Error;
    exit;
 end;
 Close(data.ftext);
 {$I+}
 WriteAmigaBasicBobDataFile:=IORESULT;
end;

Function WriteAmigaBasicXGFDataBuffer(x,y,x2,y2,mask : word;var data : bufferRec;imagename:string):word;
var
  Header :  ABBitMapHeader;
  Width,height : Word;
  TempBuf : array[1..6] of Byte;
  i,BPCount : word;
  size : longword;
  omask : integer;
begin
 omask:=GetMaskMode;
 SetMaskMode(Mask);

 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;

 Header.width:=WordToLE(width);
 Header.height:=WordToLe(height);
 Header.BitPlanes:=WordToLE(BPCount);

 Move(Header,TempBuf,sizeof(TempBuf));
 XGFBitplaneWriterDataStatements(0,data,0);  //init the data record
 if data.Error<>0 then
 begin
    WriteAmigaBasicXGFDataBuffer:=data.Error;
    SetMaskMode(omask);
    exit;
 end;

 Size:=((((width+15) div 16)*2)*height*BPCount+sizeof(Header)) div 2;

 writeln(data.ftext,#39,' AmigaBASIC PUT Image, Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',GetMaxColor+1);
 writeln(data.ftext,#39,' ',Imagename);

 For i:=1 to SizeOf(TempBuf) do
 begin
   XGFBitplaneWriterDataStatements(tempBuf[i],data,1);
 end;

 CreateBitPlanes(x,y,x2,y2,@XGFBitplaneWriterDataStatements,data);
 XGFBitplaneWriterDataStatements(0,data,2);  //flush it

 SetMaskMode(omask);
 WriteAmigaBasicXGFdataBuffer:=data.Error;
end;

Function WriteAmigaBasicXGFDataFile(x,y,x2,y2 : word;filename:string):word;
var
  data :BufferRec;
  imagename : string;
  Error : word;
begin
 SetCoreActive;  //pull data from RMCore
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);
 Error:=WriteAmigaBasicXGFDataBuffer(x,y,x2,y2,0,data,Imagename);
 if Error<>0 then
 begin
   WriteAmigaBasicXGFDataFile:=Error;
   exit;
 end;

 Close(data.ftext);
{$I+}
 WriteAmigaBasicXGFDataFile:=IORESULT;
end;

Function WriteAmigaBasicXGFPlusMaskDataFile(x,y,x2,y2 : word;filename:string):word;
var
  data :BufferRec;
  imagename : string;
  Error : word;
begin
 SetCoreActive;  //pull data from RMCore
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);
 Error:=WriteAmigaBasicXGFDataBuffer(x,y,x2,y2,0,data,Imagename);
 Error:=WriteAmigaBasicXGFDataBuffer(x,y,x2,y2,1,data,Imagename+'Mask');
 if Error<>0 then
 begin
   WriteAmigaBasicXGFPlusMaskDataFile:=Error;
   exit;
 end;

 Close(data.ftext);
{$I+}
 WriteAmigaBasicXGFPlusMaskDataFile:=IORESULT;
end;



Function WriteAmigaBasicXGFBuffer(x,y,x2,y2 : word;var data :BufferRec):word;
var
  Header :  ABBitMapHeader;
  Width,height : Word;
  TempBuf : array[1..6] of Byte;
  i,BPCount : word;
begin
 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;

 Header.width:=WordToLE(width);
 Header.height:=WordToLe(height);
 Header.BitPlanes:=WordToLE(BPCount);

 Move(Header,TempBuf,sizeof(TempBuf));
 BitplaneWriterFile(0,data,0);  //init the data record
 if data.Error<>0 then
 begin
   WriteAmigaBasicXGFBuffer:=data.Error;
   exit;
 end;

 For i:=1 to SizeOf(TempBuf) do
 begin
   BitplaneWriterFile(tempBuf[i],data,1);
 end;

 {$I-}
 CreateBitPlanes(x,y,x2,y2,@BitplaneWriterFile,data);
 if data.Error<>0 then
 begin
   WriteAmigaBasicXGFBuffer:=data.error;
   exit;
 end;
 BitplaneWriterFile(0,data,2);  //flush it
 {$I+}
 WriteAmigaBasicXGFBuffer:=IORESULT;
end;

Function WriteAmigaBasicXGFFile(x,y,x2,y2 : word;filename:string):word;
var
  data :BufferRec;
  Error : word;
begin
 Assign(data.f,filename);
{$I-}
 Rewrite(data.f,1);
 Error:=WriteAmigaBasicXGFBuffer(x,y,x2,y2,data);
 if Error<>0 then
 begin
   WriteAmigaBasicXGFFile:=Error;
   exit;
 end;
 Close(data.f);
{$I+}
 WriteAmigaBasicXGFFile:=IORESULT;
end;


Function WriteAmigaBobBuffer(x,y,x2,y2 : word;var data : bufferRec;SaveAsSprite : Boolean):word;
begin
 if SaveAsSprite then
   CreateSpriteBitPlanes(x,y,x2,y2,@BitplaneWriterFile,data)
 else
  CreateBitPlanes(x,y,x2,y2,@BitplaneWriterFile,data);

 WriteAmigaBobBuffer:=data.Error;
end;

Function WriteAmigaBobFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
 data  : BufferRec;
begin
SetCoreActive;  //pull data from RMCore
Assign(data.f,filename);
{$I-}
Rewrite(data.f,1);
InitBufferRec(data);  //init the data record
WriteAmigaBobBuffer(x,y,x2,y2,data,SaveAsSprite);
if data.error <> 0 then
begin
   WriteAmigaBobFile:=data.Error;
   exit;
end;

Close(data.f);
{$I+}
WriteAmigaBobFile:=IORESULT;
end;

Function WriteAmigaPascalBobCodeToBuffer(x,y,x2,y2 : word;imagename:string;var data : BufferRec; SaveAsSprite : Boolean):word;
var
  Width,height : Word;
  BPCount : word;
  size : longword;
  BWriter : BitPlaneWriterProc;
  nColors : integer;
begin
 BWriter:=@BitplaneWriterPascalWORDStatements;

 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;

 BWriter(0,data,0);  //init the data record

 Size:=((((width+15) div 16)*2)*height*BPCount) div 2;
 data.ArraySize:=Size;
 nColors:=GetMaxColor+1;
 if SaveAsSprite then
 begin
   writeln(data.ftext,'(* Amiga Pascal VSprite Bitmap Code Created By Raster Master *)');
   writeln(data.ftext,'(* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' *)');
   writeln(data.ftext,' ',Imagename,'_Size = ',size,';');
   writeln(data.ftext,' ',Imagename,'_Width = ',width,';');
   writeln(data.ftext,' ',Imagename,'_Height = ',height,';');
   writeln(data.ftext,' ',Imagename,'_Colors = ',nColors,';');
//   writeln(data.ftext,' ',Imagename,'_Id = ',imageId,';');
   writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of WORD = (');
   CreateSpriteBitPlanes(x,y,x2,y2,BWriter,data);
 end
 else
 begin
   writeln(data.ftext,'(* Amiga Pascal BOB Bitmap Code Created By Raster Master *)');
   writeln(data.ftext,'(* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' *)');
   writeln(data.ftext,' ',Imagename,'_Size = ',size,';');
   writeln(data.ftext,' ',Imagename,'_Width = ',width,';');
   writeln(data.ftext,' ',Imagename,'_Height = ',height,';');
   writeln(data.ftext,' ',Imagename,'_Colors = ',nColors,';');
//   writeln(data.ftext,' ',Imagename,'_Id = ',imageId,';');
   writeln(data.ftext,' ',Imagename, ' : array[0..',size-1,'] of WORD = (');
   CreateBitPlanes(x,y,x2,y2,BWriter,data);
 end;

 BWriter(0,data,2);  //flush it

 WriteAmigaPascalBobCodeToBuffer:=data.Error;
end;

Function WriteAmigaPascalBobCodeToFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
  data :BufferRec;
imagename : string;
begin
 SetCoreActive;   // we are getting data from core object RMCoreBase
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);
 WriteAmigaPascalBobCodeToBuffer(x,y,x2,y2,imagename,data,saveassprite);

 Close(data.ftext);
{$I+}
 if data.Error<>0 then
   WriteAmigaPascalBobCodeToFile:=data.Error
 else
   WriteAmigaPascalBobCodeToFile:=IORESULT;

end;


Function WriteAmigaCBobCodeToBuffer(x,y,x2,y2 : word;imagename:string;var data : BufferRec; SaveAsSprite : Boolean):word;
var
  Width,height : Word;
  BPCount : word;
  size : longword;
  nColors : integer;
  BWriter : BitPlaneWriterProc;
begin
 BWriter:=@BitplaneWriterCWORDStatements;

 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;

 BWriter(0,data,0);  //init the data record

 Size:=((((width+15) div 16)*2)*height*BPCount) div 2;
 data.ArraySize:=Size;
 nColors:=GetMaxColor+1;

 if SaveAsSprite then
 begin
   writeln(data.ftext,'/* Amiga C VSprite Bitmap Code Created By Raster Master */');
   writeln(data.ftext,'/* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' */');
   writeln(data.ftext,' #define ',Imagename,'_Size ',size);
   writeln(data.ftext,' #define ',Imagename,'_Width ',width);
   writeln(data.ftext,' #define ',Imagename,'_Height ',height);
   writeln(data.ftext,' #define ',Imagename,'_Colors ',nColors);
//   Writeln(data.ftext,' #define ',ImageName,'_Id ',imageId);
   writeln(data.ftext,'/* rename __chip to chip if using SAS compiler. remove __chip if compiler does not support it */');
   writeln(data.ftext,' ','WORD __chip ',Imagename, '[',size,']  = {');
   CreateSpriteBitPlanes(x,y,x2,y2,BWriter,data);
 end
 else
 begin
   writeln(data.ftext,'/* Amiga C Bob Bitmap Code Created By Raster Master */');
   writeln(data.ftext,'/* Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',nColors,' */');
   writeln(data.ftext,' #define ',Imagename,'_Size ',size);
   writeln(data.ftext,' #define ',Imagename,'_Width ',width);
   writeln(data.ftext,' #define ',Imagename,'_Height ',height);
   writeln(data.ftext,' #define ',Imagename,'_Colors ',nColors);
//   Writeln(data.ftext,' #define ',ImageName,'_Id ',imageId);
   writeln(data.ftext,' ','WORD __chip ',Imagename, '[',size,']  = {');
   CreateBitPlanes(x,y,x2,y2,BWriter,data);
 end;

 BWriter(0,data,2);  //flush it

 WriteAmigaCBobCodeToBuffer:=data.Error;
end;




Function WriteAmigaCBobCodeToFile(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
  data :BufferRec;
  Imagename : string;
begin
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);
 WriteAmigaCBobCodeToBuffer(x,y,x2,y2,imagename,data,saveassprite);
 Close(data.ftext);
{$I+}
 if data.Error<>0 then
   WriteAmigaCBobCodeToFile:=data.Error
 else
   WriteAmigaCBobCodeToFile:=IORESULT;
end;

begin
end.

