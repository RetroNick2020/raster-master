{$mode objfpc}{$H+}
{$PACKRECORDS 1}

Unit RMAmigaRWXGF;
 Interface
   uses RMCore,RWXGF,SysUtils,FileUtil,Bits;

Function WriteAmigaBasicObject(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
Function WriteAmigaBasicObjectData(x,y,x2,y2 : word;filename:string;SaveAsSprite : Boolean):word;
Function WriteAmigaBasicXGF(x,y,x2,y2 : word;filename:string):word;
Function WriteAmigaBasicXGFData(x,y,x2,y2 : word;filename:string):word;
Implementation

type
 linebuftype = array[0..1023] of byte;


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
                datalist   : array[1..128] of Byte;
                count  : integer;
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
       buffer.Count:=0;
   end
   else if action = 1 then
   begin
       inc(Buffer.count);
       buffer.datalist[Buffer.count]:=inByte;
       if Buffer.count = 128 then
       begin
           Blockwrite(buffer.f,Buffer.datalist,128);
           Buffer.count:=0;
       end;
   end
   else if action = 2 then
   begin
       if Buffer.count > 0 then
       begin
           Blockwrite(buffer.f,Buffer.datalist,buffer.count);
           Buffer.count:=0;
       end;
   end;
end;


procedure ObjectBitplaneWriterDataStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
   if action = 0 then
   begin
       buffer.Count:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.count);
       buffer.datalist[buffer.count]:=inbyte;
       if buffer.count = 10 then                      //every 10 bytes write to data statement
       begin
           //write the data statement
           write(buffer.ftext,'DATA ');
           for i:=1 to 10 do
           begin
             write(buffer.ftext,'&H',HexStr(buffer.datalist[i],2));
             if i < 10 then write(buffer.ftext,',');
           end;
           writeln(buffer.ftext);
           buffer.count:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
     if buffer.count > 0 then
     begin
       write(buffer.ftext,'DATA ');
       for i:=1 to buffer.count do
       begin
         write(buffer.ftext,'&H',HexStr(buffer.datalist[i],2));
         if i < buffer.count then write(buffer.ftext,',');
       end;
       writeln(buffer.ftext);
       buffer.count:=0;
     end;
   end;
end;

procedure XGFBitplaneWriterDataStatements(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
   if action = 0 then
   begin
       buffer.Count:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.count);
       buffer.datalist[buffer.count]:=inbyte;
       if buffer.count = 20 then                      //every 10 bytes write to data statement
       begin
           //write the data statement
           write(buffer.ftext,'DATA ');
           for i:=0 to 9 do
           begin
             write(buffer.ftext,'&H',HexStr(buffer.datalist[i*2+1],2),HexStr(buffer.datalist[i*2+2],2));
             if i < 9 then write(buffer.ftext,',');
           end;
           writeln(buffer.ftext);
           buffer.count:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
     if buffer.count > 0 then
     begin
       write(buffer.ftext,'DATA ');
       for i:=0 to ((buffer.count+1) div 2)-1 do
       begin
         write(buffer.ftext,'&H',HexStr(buffer.datalist[i*2+1],2),HexStr(buffer.datalist[i*2+2],2));
         if i < (((buffer.count+1) div 2)-1) then write(buffer.ftext,',');
       end;
       writeln(buffer.ftext);
       buffer.count:=0;
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
 j,i       : integer;
 width,height : word;
 pixcolor : integer;
 plane    : integer;
 bitposition: integer;
 minBytesPerLine    : integer;
 BitPlaneCount : integer;
 ColorCount    : integer;
 bwcount : integer;
begin
 ColorCount:=GetMaxColor+1;
 BitPlaneCount:=GetBitPlaneCount;

 width:=x2-x+1;
 Height:=y2-y+1;
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




begin
end.

