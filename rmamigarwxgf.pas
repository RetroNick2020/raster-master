{$mode objfpc}{$H+}
{$PACKRECORDS 1}

Unit rmamigarwxgf;
 Interface
   uses rmcore,rwxgf,SysUtils,LazFileUtils,bits;

Function WriteAmigaBasicObject(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
Function WriteAmigaBasicObjectData(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
Function WriteAmigaBasicXGF(x,y,x2,y2 : word;filename:string):word;
Function WriteAmigaBasicXGFData(x,y,x2,y2 : word;filename:string):word;

Function WriteAmigaPascalConst(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
Function WriteAmigaCWORD(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
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

procedure ObjectBitplaneWriterFile(inByte : Byte; var Buffer : BufferRec;action : integer);
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


procedure ObjectBitplaneWriterDataStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
   if action = 0 then
   begin
       buffer.bufCount:=0;
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
end;

procedure XGFBitplaneWriterDataStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
   if action = 0 then
   begin
       buffer.bufCount:=0;
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
end;

 //we emulator graph's getmaxcolor way of counting colors
function GetMaxColor : integer;
begin
  GetMaxColor:=RMCoreBase.Palette.GetColorCount-1;
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

Procedure CreateBitPlanes(x,y,x2,y2 : word; BitPlaneWriter  : BitPlaneWriterProc; var data :BufferRec);
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
        pixcolor:=RMCoreBase.GetPixel(i,j);
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
 RMCoreBase.Palette.GetColor(1,TR1);
 RMCoreBase.Palette.GetColor(2,TR2);
 RMCoreBase.Palette.GetColor(3,TR3);
 Color1:=(EightToFourBit(TR1.r) SHL 8) + (EightToFourBit(TR1.g) SHL 4) + EightToFourBit(TR1.b);
 Color2:=(EightToFourBit(TR2.r) SHL 8) + (EightToFourBit(TR2.g) SHL 4) + EightToFourBit(TR2.b);
 Color3:=(EightToFourBit(TR3.r) SHL 8) + (EightToFourBit(TR3.g) SHL 4) + EightToFourBit(TR3.b);
 SpritePal.Color1:=WordToLE(Color1);
 SpritePal.Color2:=WordToLE(Color2);
 SpritePal.Color3:=WordToLE(Color3);
end;

Function WriteAmigaBasicObject(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
  Header : ABBobHeader;
  SPal   : ABSpritePalette;
  Width : Word;
  TempBuf : array[1..26] of Byte;
  data :BufferRec;
  i,BPCount : word;
begin
 CreateHeader(Header, x,y,x2,y2,SaveAsSprite);

 Move(Header,TempBuf,sizeof(TempBuf));
 ObjectBitplaneWriterFile(0,data,0);  //init the data record

 Assign(data.f,filename);
{$I-}
 Rewrite(data.f,1);
 For i:=1 to SizeOf(TempBuf) do
 begin
   ObjectBitplaneWriterFile(tempBuf[i],data,1);
 end;

 CreateBitPlanes(x,y,x2,y2,@ObjectBitplaneWriterFile,data);

 width:=x2-x+1;
 BPCount:=GetBitPlaneCount;
 if (SaveAsSprite=true) AND (width = 16) AND (BPCount=2) then
 begin
   //write Palette for VSprite
    CreateVSpritePalette(SPal);
    Move(SPal,TempBuf,sizeof(SPal));
    For i:=1 to SizeOf(SPal) do
    begin
      ObjectBitplaneWriterFile(tempBuf[i],data,1);
    end;
 end;
 ObjectBitplaneWriterFile(0,data,2);  //flush it
 Close(data.f);
{$I+}

 WriteAmigaBasicObject:=IORESULT;
end;


function GetObjectDataSize(width,height,bitplanes : word;vsprite : boolean) : longint;
begin
 GetObjectDataSize:=(((width+15) div 16)*2)*height*bitplanes+sizeof(ABBobHeader);
 if vsprite then inc(GetObjectDataSize,sizeof(ABSpritePalette));
end;


Function WriteAmigaBasicObjectData(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
  Header : ABBobHeader;
  SPal   : ABSpritePalette;
  Width,height : Word;
  TempBuf : array[1..26] of Byte;
  data :BufferRec;
  i,BPCount : word;
  DataNameStr : string;
  ImageName : string;
  isVSprite : Boolean;
begin

 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;
 isVSprite:=false;
 if (SaveAsSprite=true) AND (width = 16) AND (BPCount=2) then isVSprite:=true;

 CreateHeader(Header, x,y,x2,y2,SaveAsSprite);

 Move(Header,TempBuf,sizeof(TempBuf));
 ObjectBitplaneWriterDataStatements(0,data,0);  //init the data record

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);

  if isvsprite then
    DataNameStr:='VSprite'
  else
     DataNameStr:='Bob';

Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 writeln(data.ftext,#39,' AmigaBASIC ',DataNameStr,' Size= ', GetObjectDataSize(width,height,BPCount,isVSprite),' Width= ',width,' Height= ',height, ' Colors= ',GetMaxColor+1);

 writeln(data.ftext,#39,' ',Imagename);
 For i:=1 to SizeOf(TempBuf) do
 begin
   ObjectBitplaneWriterDataStatements(tempBuf[i],data,1);
 end;

 CreateBitPlanes(x,y,x2,y2,@ObjectBitplaneWriterDataStatements,data);

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
 Close(data.ftext);
{$I+}
 WriteAmigaBasicObjectData:=IORESULT;
end;


Function WriteAmigaBasicXGF(x,y,x2,y2 : word;filename:string):word;
var
  Header :  ABBitMapHeader;

  Width,height : Word;
  TempBuf : array[1..6] of Byte;
  data :BufferRec;
  i,BPCount : word;
begin
 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;

 Header.width:=WordToLE(width);
 Header.height:=WordToLe(height);
 Header.BitPlanes:=WordToLE(BPCount);

 Move(Header,TempBuf,sizeof(TempBuf));
 ObjectBitplaneWriterFile(0,data,0);  //init the data record

 Assign(data.f,filename);
{$I-}
 Rewrite(data.f,1);
 For i:=1 to SizeOf(TempBuf) do
 begin
   ObjectBitplaneWriterFile(tempBuf[i],data,1);
 end;

 CreateBitPlanes(x,y,x2,y2,@ObjectBitplaneWriterFile,data);
 ObjectBitplaneWriterFile(0,data,2);  //flush it
 Close(data.f);
{$I+}
 WriteAmigaBasicXGF:=IORESULT;
end;


Function WriteAmigaBasicXGFData(x,y,x2,y2 : word;filename:string):word;
var
  Header :  ABBitMapHeader;

  Width,height : Word;
  TempBuf : array[1..6] of Byte;
  data :BufferRec;
  i,BPCount : word;
  size : longword;
  Imagename : string;
begin
 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;

 Header.width:=WordToLE(width);
 Header.height:=WordToLe(height);
 Header.BitPlanes:=WordToLE(BPCount);

 Move(Header,TempBuf,sizeof(TempBuf));
 XGFBitplaneWriterDataStatements(0,data,0);  //init the data record

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);

 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 Size:=((((width+15) div 16)*2)*height*BPCount+sizeof(Header)) div 2;

 writeln(data.ftext,#39,' AmigaBASIC PUT Image, Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',GetMaxColor+1);
 writeln(data.ftext,#39,' ',Imagename);

 For i:=1 to SizeOf(TempBuf) do
 begin
   XGFBitplaneWriterDataStatements(tempBuf[i],data,1);
 end;

 CreateBitPlanes(x,y,x2,y2,@XGFBitplaneWriterDataStatements,data);
 XGFBitplaneWriterDataStatements(0,data,2);  //flush it
 Close(data.ftext);
{$I+}
 WriteAmigaBasicXGFData:=IORESULT;
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
end;


procedure BitplaneWriterConstStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
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

end;



Function WriteAmigaCWORD(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
var
  Width,height : Word;
  data :BufferRec;
  BPCount : word;
  size : longword;
  Imagename : string;
  BWriter : BitPlaneWriterProc;

begin
 BWriter:=@BitplaneWriterCWORDStatements;

 width:=x2-x+1;
 height:=y2-y+1;
 BPCount:=GetBitPlaneCount;

 BWriter(0,data,0);  //init the data record

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);

 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 Size:=((((width+15) div 16)*2)*height*BPCount) div 2;
 data.ArraySize:=Size;

 writeln(data.ftext,'/* Amiga C , Size= ', Size,' Width= ',width,' Height= ',height, ' Colors= ',GetMaxColor+1,' */');
 writeln(data.ftext,'/* rename __chip to chip if using SAS compiler. remove __chip if compiler does not support it */');
 if SaveAsSprite then
 begin
     writeln(data.ftext,'/* VSprite Bitmap */');
     writeln(data.ftext,' ','WORD __chip ',Imagename, '[',size,']  = {');
     CreateSpriteBitPlanes(x,y,x2,y2,BWriter,data);
 end
 else
 begin
   writeln(data.ftext,'/* BOB Bitmap */');
   writeln(data.ftext,' ','WORD __chip ',Imagename, '[',size,']  = {');
   CreateBitPlanes(x,y,x2,y2,BWriter,data);
 end;

 BWriter(0,data,2);  //flush it
 Close(data.ftext);
{$I+}
 WriteAmigaCWORD:=IORESULT;
end;



begin
end.

