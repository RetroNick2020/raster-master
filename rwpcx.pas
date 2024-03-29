{$mode TP}
Unit rwpcx;

Interface
uses
  bits,RMCore,Dialogs,SysUtils;
Function ReadPcxImg(x,y,x2,y2,Pal,pm : Word;Filename : string): word;
Function SavePcxImg(x,y,x2,y2 : Word;Filename : String): Word;
Implementation

Type

   PaletteT = Array[0..255,0..2] of Byte;
   PcxPalette = Array[0..255,0..2] of Byte;

   PCXHeaderRec = Record
        Manufacturer: byte;     (* Always 10 for PCX file *)

        Version: byte;          (* 2 - old PCX - no palette (not used anymore),
                                   3 - no palette,
                                   4 - Microsoft Windows - no palette (only in
                                      old files, new Windows version uses 3),
                                   5 - with palette *)

        Encoding: byte;         (* 1 is PCX, it is possible that we may add
                                  additional encoding methods in the future *)

        Bits_per_pixel: byte;   (* Number of bits to represent a pixel
                                  (per plane) - 1, 2, 4, or 8 *)

        Xmin: integer;          (* Image window dimensions (inclusive) *)
        Ymin: integer;          (* Xmin, Ymin are usually zero (not always) *)
        Xmax: integer;
        Ymax: integer;

        Hdpi: integer;          (* Resolution of image (dots per inch) *)
        Vdpi: integer;          (* Set to scanner resolution - 300 is default *)

        ColorMap: array [0..15, 0..2] of byte;
                                (* RGB palette data (16 colors or less)
                                   256 color palette is appended to end of file *)

        Reserved: byte;         (* (used to contain video mode)
                                   now it is ignored - just set to zero *)

        Nplanes: byte;          (* Number of planes *)

        Bytes_per_line_per_plane: integer;   (* Number of bytes to allocate
                                                for a scanline plane.
                                                MUST be an an EVEN number!
                                                Do NOT calculate from Xmax-Xmin! *)

        PaletteInfo: integer;   (* 1 = black & white or color image,
                                   2 = grayscale image - ignored in PB4, PB4+
                                   palette must also be set to shades of gray! *)

        HscreenSize: Integer;   (* added for PC Paintbrush IV Plus ver 1.0,  *)
        VscreenSize: Integer;   (* PC Paintbrush IV ver 1.02 (and later)     *)
                                (* I know it is tempting to use these fields
                                   to determine what video mode should be used
                                   to display the image - but it is NOT
                                   recommended since the fields will probably
                                   just contain garbage. It is better to have
                                   the user install for the graphics mode he
                                   wants to use... *)

        Filler: array [74..127] of Byte;
    end;

Const
   MaxWidth    = 2048;    (* arbitrary - maximum width (in bytes) of a PCX image *)
   CompressNum = $C0;  (* this is the upper two bits that indicate a count *)
   MaxBlock    = 4096;




type
   BlockArray     = Array [0..MaxBlock]  of Byte;
   UncpLine       = Array [0..MaxWidth]  of Byte;
   CompressedLine = Array[0..MaxWidth*2] of Byte;

var
   BlockData: ^BlockArray;             (* 4k data buffer                     *)
   NextByte : Integer;                 (* index into file buffer in ReadByte *)
   Index    : Integer;                 (* PCXline index - where to put Data  *)
   Data     : byte;                    (* PCX compressed data byte           *)

   myPcx : PcxHeaderRec;
   myPal : PcxPalette;
Function BytesPerRow(width : word) : Word;
begin
 BytesPerRow :=(width+7) div 8;
end;



Procedure GetPcxInfo(Filename : string; Var PcxH : PcxHeaderRec;Var Pal : PaletteT);
Var
 F     : File;
 Error : Word;
Begin
{$I-}
 Assign(F,Filename);
 Reset(F,1);
 BlockRead(F,PcxH,sizeof(PcxH));
 If (PcxH.Bits_Per_Pixel = 8) and (PcxH.Version=5) then
 begin
   Seek(F,FileSize(F)-768);
   BlockRead(F,Pal,SizeOf(Pal));
 end
 else
 begin
   Move(PcxH.ColorMap,Pal,48);
 end;
 Close(F);
 Error:=IORESULT;
{$I+}
end;


Function ValidPcxFile(Filename : string) : Boolean;
Var
  MyPcxHeader : PcxHeaderRec;
  F           : File;
  Error       : Word;
Begin
{$I-}
 Assign(F,Filename);
 Reset(F,1);
 BlockRead(F,MyPcxHeader,sizeof(MyPcxHeader));
 Close(F);
 ValidPcxFile:=false;
 If MyPcxHeader.Manufacturer = 10 then
 begin
   ValidPcxFile:=true;
 end;
 Error:=IORESULT;
{$I+}
end;

Function GetNPcxColors(Var PcxH : PcxHeaderRec) : Word;
begin
 GetNPcxColors:=0;
 if (PcxH.Bits_Per_Pixel=1)      And (pcxH.nplanes=1) then
 begin
    GetNPcxColors:=2;
 end
 Else if (PcxH.Bits_Per_Pixel=2) And (pcxH.nplanes=1) then
 begin
    GetNPcxColors:=4;
 end
 Else if (PcxH.Bits_Per_Pixel=1) And (pcxH.nplanes=3) then
 begin
    GetNPcxColors:=8;
 end
 Else if (PcxH.Bits_Per_Pixel=1) And (pcxH.nplanes=4) then
 begin
    GetNPcxColors:=16;
 end
 Else if (PcxH.Bits_Per_Pixel=8) And (pcxH.nplanes=1) then
 begin
    GetNPcxColors:=256;
 end;
end;


Function GetPcxWidth(Var PcxH : PcxHeaderRec) : Word;
begin
 GetPcxWidth:=PcxH.Xmax-PcxH.Xmin+1;
end;

Function GetPcxHeight(Var PcxH : PcxHeaderRec) : Word;
begin
 GetPcxHeight:=PcxH.Ymax-PcxH.Ymin+1;
end;

Function PcxPaletteExists(Var PcxH : PcxHeaderRec) : Boolean;
begin
  PcxPaletteExists:=false;
  if PcxH.Version > 4 then
  begin
     PcxPaletteExists:=true;
  end;
end;

Procedure ReadHeader(Var F : File;Var Header : PcxHeaderRec);
begin
{$I-}
 BlockRead (F, Header, 128);
 Index := 0;
 NextByte := MaxBlock;
{$I+}
end;


Function Compressline(Var Uline:UncpLine;Var CLine : CompressedLine;BytesPerLine : Word) : Word;
Var
 cp        : Word;
 count     : Word;
 repeatNum : Word;
begin
 Cp:=0;
 Count:=0;
 Repeat
   repeatNum:=0;
   repeat
     inc(repeatNum);
   until (repeatNum+count=BytesPerLine) OR
         (uline[count+repeatNum-1] <> uline[count+repeatNum]) OR (repeatNum>62);

   if (repeatNum > 1) then
   begin
     Cline[Cp]:=repeatNum;
     inc(cline[Cp],192);
     inc(Cp);
     Cline[Cp]:=Uline[count];
     inc(count,repeatNum);
     inc(Cp);
   end
   else if (uline[count] > 127) then
   begin
     Cline[Cp]:=repeatNum;
     inc(cline[Cp],192);
     inc(Cp);
     Cline[Cp]:=uline[count];
     inc(count,repeatNum);
     inc(Cp);
   end
   else
   begin
     Cline[Cp]:=uline[count];
     inc(Cp);
     inc(count,repeatNum);
   end;
 Until (count=BytesPerLine) OR (count=BytesPerLine-1);

 if count=BytesPerLine-1 then
 begin
   repeatNum:=1;
   if uline[count] > 127  then
   begin
     Cline[Cp]:=repeatNum;
     inc(Cline[Cp],192);
     inc(Cp);
     Cline[Cp]:=uline[count];
     inc(count,repeatNum);
     inc(Cp);
   end
   else
   begin
     Cline[Cp]:=uline[count];
     inc(Cp);
     inc(count,repeatNum);
   end;
 end;
 compressline:=Cp;
end;


Procedure ReadByte(Var F : File);
var
 NumBlocksRead : Integer;
begin
 if NextByte = MaxBlock then
 begin
{$I-}
   BlockRead (F, BlockData^,MaxBlock,NumBlocksRead);
{$I+}
   NextByte:=0;
 end;
 Data:=BlockData^[NextByte];
 Inc(NextByte);
End;

Procedure ReadPCXLine(Var F : File;Var Uline : Uncpline;BytesPerLine : Word);
Var
 Count : Word;
begin
 If Index <> 0 then
 begin
   FillChar(Uline [0], Index, data);
 end;
 While (Index < BytesPerLine) do
 begin
   ReadByte(F);
   If (Data and $C0) = CompressNum then
   begin
     Count:=(Data AND $3F);
     ReadByte(F);
     FillChar(Uline [Index],Count,Data);
     Inc(Index,Count);
     end
   else
   begin
     Uline[Index]:=Data;
     Inc(Index);
   end;
 end;
 Dec(Index,BytesPerLine);
end;

Procedure MonoTOsp(Var pPlane : UncpLine;Var splane : uncpLine;
                  BPL : Word);
var
 cb,i,j : Word;
begin
 cb:=0;
 FillChar(splane,sizeof(splane),0);
 For i:=0 to BPL-1 do
 begin
    For j:=7 downto 0 do
    begin
      if Biton(j,pplane[i]) then splane[cb+(7-j)]:=1;
    end;
   inc(cb,8);
 end;
end;

Procedure spToMono(Var splane : uncpLine;Var monoPlane : UncpLine;
                  BPL : Word);
var
 cb,i,j : Word;
 x : integer;
begin
 cb:=0;
 x:=0;
 FillChar(monoplane,sizeof(monoplane),0);
 For i:=0 to BPL-1 do
 begin
    For j:=7 downto 0 do
    begin
      //if Biton(j,pplane[i]) then splane[cb+(7-j)]:=1;
       if  splane[x] = 1 then  SetBit(j,1,monoplane[i]);
        inc(x);

    end;
   // monoplane[i]:=254;
   inc(cb,8);
 end;
end;


Procedure packTOsp(Var pPlane : UncpLine;Var splane : uncpLine;
                  BPL : Word);
var
 cb,i : Word;
begin
 cb:=0;
 For i:=0 to BPL-1 do
 begin

   splane[cb]:=pplane[i] shr 6;

   splane[cb+1]:=pplane[i] shl 2;
   splane[cb+1]:=splane[cb+1] shr 6;

   splane[cb+2]:=pplane[i]  shl 4;
   splane[cb+2]:=splane[cb+2] shr 6;

   splane[cb+3]:=pplane[i] shl 6;
   splane[cb+3]:=splane[cb+3] shr 6;

   inc(cb,4);
  end;
end;

Procedure spTOpack(Var splane : uncpLine;var pPlane : UncpLine;
                  BPL : Word);
var
 cb,i : Word;
begin
 cb:=0;
 For i:=0 to BPL-1 do
 begin
   pplane[i] := (splane[cb] shl 6) + (splane[cb+1] shl 4) + (splane[cb+2] shl 2) + (splane[cb+3]);
   inc(cb,4);
  end;
end;




Procedure mpTOsp(Var mPlane : UncpLine;Var splane : uncpLine;
                 ImgOff2,ImgOff3,ImgOff4 : Word);
Var
 i,j    : Word;
 xpos : Word;
 Col  : Word;
begin
 xpos:=0;
 FillChar(splane,SizeOf(sPlane),0);
 For i:=0 to ImgOff2-1 do
 begin
   For j:=7 downto 0 do
   begin
     Col:=0;
     if biton(j,mPlane[i]) then
     begin
       Inc(Col,1);
     end;

     if biton(j,mPlane[i+ImgOff2]) then
     begin
       Inc(Col,2);
     end;

     if biton(j,mPlane[i+ImgOff3]) then
     begin
       Inc(Col,4);
     end;

     if biton(j,mPlane[i+ImgOff4]) then
     begin
       Inc(Col,8);
     end;

     Splane[xpos]:=Col;
     Inc(xpos);
   end;
 end;
end;

Procedure spTOmp(Var sPlane : UncpLine;Var mplane : uncpLine;
                  ImgOff2,ImgOff3,ImgOff4 : Word);
Var
 xp,cp,cl : Word;
 i,j,x    : Word;
begin
 xp:=0;
 cp:=0;
 FillChar(mPlane,SizeOf(mplane),0);
  for x:=0 to ImgOff2-1 do
    begin
      for j:=0 to 7 do
      begin
            cl:=sPlane[xp+j];
            if biton(3,cl) then setbit((7-j),1,mplane[ImgOff4+cp]);
            if biton(2,cl) then setbit((7-j),1,mplane[ImgOff3+cp]);
            if biton(1,cl) then setbit((7-j),1,mplane[ImgOff2+cp]);
            if biton(0,cl) then setbit((7-j),1,mplane[cp]);
      end;
      inc(cp);
      inc(xp,8);
    end;
end;


Procedure spTOmp2(Var sPlane : UncpLine;Var mplane : uncpLine;
                  ImgOff2 : Word);
Var
 xp,cp,cl : Word;
 i,j,x    : Word;
begin
 xp:=0;
 cp:=0;
 FillChar(mPlane,SizeOf(mplane),0);
  for x:=0 to ImgOff2-1 do
    begin
      for j:=0 to 7 do
      begin
            cl:=sPlane[xp+j];
           // if biton(3,cl) then setbit((7-j),1,mplane[ImgOff4+cp]);
           // if biton(2,cl) then setbit((7-j),1,mplane[ImgOff3+cp]);
            if biton(1,cl) then setbit((7-j),1,mplane[ImgOff2+cp]);
            if biton(0,cl) then setbit((7-j),1,mplane[cp]);
      end;
      inc(cp);
      inc(xp,8);
    end;
end;


function GetMaxColor : integer;
begin
 //GetMaxColor:=15;
 GetMaxColor:=RMCoreBase.Palette.GetColorCount -1;
end;

Function ReadPcxImg(x,y,x2,y2,Pal,pm : Word;Filename : string): word;
var
 PcxPal         : PaletteT;
 PcxFile        : File;
 Header         : PcxHeaderRec;
 Uline          : UncpLine;
 BitPlane2      : Word;
 BitPlane3      : Word;
 BitPlane4      : Word;
 BytesPerLine   : Word;
 i,j,Ln         : Word;
 myWidth        : Word;
 myHeight       : Word;
 Fwidth         : Word;
 FHeight        : Word;

 Error          : Word;
 Colors        : Word;
 Temp           : Byte;
 uncomLine      : uncpLine;
 cr             : TRMColorRec;
Begin
 ReadPcxImg:=0;

{$I-}
 Assign(PcxFile, Filename);
 Reset(PcxFile, 1);
 BlockRead(PcxFile, Header, 128);
 Error:=IORESULT;

 If Error <> 0 Then
 begin
   ReadPcxImg:=Error;
   Exit;
 end;

 Index:=0;
 NextByte:=MaxBlock;
 Colors:=GetNPcxColors(Header);
 FHeight:=GetPcxHeight(Header);
 FWidth :=GetPCxWidth(Header);
 myWidth:=(x2-x+1);
 myHeight:=(y2-y+1);

 if Fwidth < myWidth then myWidth:=FWidth;
 if FHeight < myHeight then myHeight:=Fheight;





 If (Colors<>2) AND (Colors<>4) AND (Colors<>16) AND (Colors<>256) then
 begin
   ReadPcxImg:=1000;
   Close(PcxFile);
   Error:=IORESULT;
   Exit;
 end
 Else if (Header.Manufacturer<>10) then
 begin
   ReadPcxImg:=1000;
   Close(PcxFile);
   Error:=IORESULT;
   Exit;
 end;



 GetMem(BlockData,SizeOf(BlockArray));
 if Colors=2 then
 begin
   BytesPerLine:=Header.Bytes_per_line_per_plane;
  // ShowMessage('Bytes_per_line_per_plane = '+IntToStr(Header.Bytes_per_line_per_plane)+'Bits_per_pixel= '+intTostr(  Header.Bits_per_pixel)+' nplanes = '+intTostr(  Header.Nplanes));
    Header.Bits_per_pixel:=1;
   Header.Nplanes:=1;

   For Ln:=1 to myHeight do
   begin
     ReadPCXLine(PcxFile,Uline,BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       ReadPcxImg:=Error;
       Close(PcxFile);
       Error:=IORESULT;
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     MonoTOsp(Uline,uncomline,BytesPerLine);
     For i:=1 to myWidth do
     begin
//        IconImage[x+i-1,Ln+y-1]:=Uncomline[i-1];
          RMCoreBase.PutPixel(x+i-1,Ln+y-1,Uncomline[i-1]);
     end;
   end;
 end
 else if Colors=4 then
 begin
   BytesPerLine:=Header.Bytes_per_line_per_plane;
   // ShowMessage('Header.Bytes_per_line_per_plane = '+IntToStr(Header.Bytes_per_line_per_plane));
   For Ln:=1 to myHeight do
   begin
     ReadPCXLine(PcxFile,Uline,BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       ReadPcxImg:=Error;
       Close(PcxFile);
       Error:=IORESULT;
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     PackTOsp(Uline,uncomline,BytesPerLine);
     For i:=1 to myWidth do
     begin
       // IconImage[x+i-1,Ln+y-1]:=Uncomline[i-1];
        RMCoreBase.PutPixel(x+i-1,Ln+y-1,Uncomline[i-1]);
     end;
   end;
 end
 else If Colors = 16 then
 begin
   BytesPerLine:=(Header.Bytes_per_line_per_plane SHL 2);
   BitPlane2:=(BytesPerLine SHR 2);
   BitPlane3:=(BytesPerLine SHR 1);
   BitPlane4:=(BytesPerLine SHR 2) * 3;
   For Ln:=1 to myHeight do
   begin
     ReadPCXLine(PcxFile,Uline,BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       REadPcxImg:=Error;
       Close(PcxFile);
       Error:=IORESULT;
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     mpTosp(Uline,uncomLine,BitPlane2,BitPlane3,BitPlane4);
     For i:=1 to myWidth do
     begin
        //IconImage[x+i-1,Ln+y-1]:=Uncomline[i-1];
        RMCoreBase.PutPixel(x+i-1,Ln+y-1,Uncomline[i-1]);
     end;
   end;
 end
 else if (Colors=256) then
 begin
   BytesPerLine:=Header.Bytes_per_line_per_plane;
   For Ln:=1 to myHeight do
   begin
     ReadPCXLine(PcxFile,Uline,BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       ReadPcxImg:=Error;
       Close(PcxFile);
       Error:=IORESULT;
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     For i:=1 to myWidth do
     begin
        //IconImage[x+i-1,Ln+y-1]:=Uline[i-1];
        RMCoreBase.PutPixel(x+i-1,Ln+y-1,Uline[i-1]);
     end;
   end;
   If GetMaxColor=15 then
   begin
//     ReduceTo16;
   end;
 end;
 Close(PcxFile);
 FreeMem(BlockData,SizeOf(BlockArray));
{$I+}
   GetPcxInfo(filename,Header,PcxPal);
   Colors:=GetNPcxColors(Header);

   If (Pal=1) and (CanLoadPaletteFile(pm)) and (Colors > 0) then     //we do not load palette for mono and cga or if we are select/clip open mode pal=0
   begin
   if pm=PaletteModeEGA then       //if we are in ega palette mode we need to be able to remap rgb color ega64 palette
   begin                           //if not we skip setting that color
     for i:=0 to Colors-1 do
     begin
       cr.r:=PcxPal[i,0];
       cr.g:=PcxPal[i,1];
       cr.b:=PcxPal[i,2];
       MakeRGBToEGACompatible(cr.r,cr.g,cr.b,cr.r,cr.g,cr.b);
       RMCoreBase.Palette.SetColor(i,cr);
     end;
   end
   else if isAmigaPaletteMode(pm) then
   begin
     for i:=0 to Colors-1 do
     begin
      cr.r:=FourToEightBit(EightToFourBit(PcxPal[i,0]));
      cr.g:=FourToEightBit(EightToFourBit(PcxPal[i,1]));
      cr.b:=FourToEightBit(EightToFourBit(PcxPal[i,2]));
      RMCoreBase.Palette.SetColor(i,cr);
     end;
   end
   else if (pm=PaletteModeVGA) or (pm=PaletteModeVGA256) then
   begin
     for i:=0 to Colors-1 do
     begin
       cr.r:=SixToEightBit(EightToSixBit(PcxPal[i,0]));   //we bitshift because if palette was saved when PaletteModeXga or PaletteModeXga256
       cr.g:=SixToEightBit(EightToSixBit(PcxPal[i,1]));   //we will have invalid values
       cr.b:=SixToEightBit(EightToSixBit(PcxPal[i,2]));
       RMCoreBase.Palette.SetColor(i,cr);
    //   SetColor(i,cr);
      end;
   end
   else if (pm=PaletteModeXGA) or (pm=PaletteModeXGA256) then
   begin
     for i:=0 to Colors-1 do
     begin
       cr.r:=PcxPal[i,0];
       cr.g:=PcxPal[i,1];
       cr.b:=PcxPal[i,2];
       RMCoreBase.Palette.SetColor(i,cr);
//       SetColor(i,cr);
     end;
   end;
 end;
end;

//Function BytesPerRow(width : word) : Word;
//begin
// BytesPerRow :=(width+7) div 8;
//end;

Function ImageSize(x,y,x2,y2 : word) : word;
var
 width ,  height : integer;
  bpl : integer;
  colorcount : integer;
begin
  width:=x2-x+1;
  height:=y2-y+1;
  bpl:=(width+7) div 8;
//bpl:=width;
  colorcount:=RMCoreBase.Palette.GetColorCount;

  if colorcount = 8 then
  begin
     colorcount:=16;
  end
  else if colorcount=32 then
  begin
    colorcount:=256;
  end;

   if colorcount= 16 then
   begin
     ImageSize:=(bpl*4)*height+6;
   end
   else if colorcount = 256 then
   begin
     ImageSize:=width + 6;
   end
   else if colorcount = 4 then
   begin
     ImageSize:=bpl div 4 + 6;
   end
    else if colorcount = 2 then
   begin
       if odd(bpl) then inc(bpl);
     ImageSize:=bpl+6;
   end;
end;

Function SavePcxImg(x,y,x2,y2 : Word;Filename : String): Word;
var
 PcxPal         : PaletteT;
 PcxFile        : File;
 Header         : PcxHeaderRec;
 ULine          : UncpLine;
 CLine          : CompressedLine;
 Cbytes         : Word;
 BitPlane2      : Word;
 BitPlane3      : Word;
 BitPlane4      : Word;
 BytesPerLine   : Word;
 i,j,Ln         : Word;
 myWidth        : Word;
 myHeight       : Word;
 Error          : Word;
 NColors        : Word;
 Temp           : Byte;
 splane         : uncpLine;
Begin
 SavePcxImg:=0;
 NColors:=GetMaxColor+1;
 //NColors:=16;
 if NColors=8 then  (* promote amiga color modes to next available formats *)
 begin
     NColors:=16;
 end
 else if NColors = 32 then
 begin
     NColors:=256;
 end;

 If (Ncolors<>16) AND (Ncolors<>256) ANd (NColors<>4) AND (NColors<>2) Then
 begin
   SavePcxImg:=3;
   Exit;
 end;

 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
 BytesPerLine:=ImageSize(1,1,myWidth,1)-6;


 FillChar(Header,SizeOf(Header),0);
 Header.Manufacturer:=10;
 Header.Version:=5;
 Header.Encoding:=1;
 Header.PaletteInfo:=1;
 Header.Xmax:=myWidth-1;
 Header.Ymax:=myHeight-1;

 If NColors=16 Then
 begin
   Header.Bits_per_pixel:=1;
   Header.Nplanes:=4;
   Header.Bytes_per_line_per_plane:=BytesPerLine SHR 2;
 end
 else if NColors=256 then
 begin
   Header.Bits_per_pixel:=8;
   Header.Nplanes:=1;
   Header.Bytes_per_line_per_plane:=BytesPerLine;
 end
 else if NColors = 4 then
 begin
   Header.Bits_per_pixel:=2;
   Header.Nplanes:=1;
   Header.Bytes_per_line_per_plane:=(mywidth+3) div 4;
   BytesPerLine:=(mywidth+3) div 4;
 end
 else if NColors = 2 then
 begin
   BytesPerLine:=(mywidth+7) div 8;
   if odd(BytesPerLine) then inc(BytesPerLine);
   Header.Bits_per_pixel:=1;
   Header.Nplanes:=1;
   Header.Bytes_per_line_per_plane:=BytesPerLine;
 end;


 //GrabPaletteList(PcxPal,GetMaxColor+1);
 For i:=0 to GetMaxColor do
 begin
   PcxPal[i,0]:=RMCoreBase.Palette.GetRed(i);
   PcxPal[i,1]:=RMCoreBase.Palette.GetGreen(i);
   PcxPal[i,2]:=RMCoreBase.Palette.GetBlue(i);
 end;

 Move(PcxPal,header.colormap,16*3);

{$I-}
 Assign(PcxFile, Filename);
 Rewrite(PcxFile, 1);
 BlockWrite(PcxFile, Header, 128);
 Error:=IORESULT;

 If Error <> 0 Then
 begin
   SavePcxImg:=Error;
   Exit;
 end;

 If NColors=16 then
 begin
   BitPlane2:=(BytesPerLine SHR 2);
   BitPlane3:=(BytesPerLine SHR 1);
   BitPlane4:=(BytesPerLine SHR 2) * 3;
 end;
 If NColors=16 then
 begin
   For Ln:=y to y2 do
   begin
     For i:=1 to myWidth do
     begin
//       splane[i-1]:=IconImage[i+x-1,Ln];
       splane[i-1]:= RMCoreBase.GetPixel(i+x-1,Ln);
     end;
     spTOmp(splane,uline,BitPlane2,BitPlane3,BitPlane4);
     Cbytes:=CompressLine(Uline,Cline,BytesPerLine);
     BlockWrite(PcxFile,Cline,Cbytes);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       SavePcxImg:=Error;
       Close(PcxFile);
       Error:=IORESULT;
       Exit;
     end;
   end;
 end
 else if NColors = 256   then
 begin
   For Ln:=y to y2 do
   begin
     For i:=1 to myWidth do
     begin
//       splane[i-1]:=IconImage[i+x-1,Ln];
         splane[i-1]:=RMCoreBase.GetPixel(i+x-1,Ln);

     end;
     Cbytes:=CompressLine(Splane,Cline,BytesPerLine);
     BlockWrite(PcxFile,Cline,Cbytes);
     Error:=IORESULT;
     If Error<>0 then
     begin
       SavePcxImg:=Error;
       Close(PcxFile);
       Error:=IORESULT;
       Exit;
     end;
   end;
   Temp:=$C;
   BlockWrite(PcxFile,Temp,1);
   BlockWrite(PcxFile,PcxPal,Sizeof(PcxPal));
 end
 else if NColors = 4   then
 begin
  For Ln:=y to y2 do
  begin
    For i:=1 to myWidth do
    begin
//       splane[i-1]:=IconImage[i+x-1,Ln];
        splane[i-1]:=RMCoreBase.GetPixel(i+x-1,Ln);
    end;
    spTOpack(splane,uline,bytesperline);
    Cbytes:=CompressLine(uline,Cline,BytesPerLine);
    BlockWrite(PcxFile,Cline,Cbytes);
    Error:=IORESULT;
    If Error<>0 then
    begin
      SavePcxImg:=Error;
      Close(PcxFile);
      Error:=IORESULT;
      Exit;
    end;
  end;
 end
 else if NColors = 2   then
 begin
  For Ln:=y to y2 do
  begin
    For i:=1 to myWidth do
    begin
//       splane[i-1]:=IconImage[i+x-1,Ln];
        splane[i-1]:=RMCoreBase.GetPixel(i+x-1,Ln);
    end;
    spTOMono(splane,uline,bytesperline);
    Cbytes:=CompressLine(uline,Cline,BytesPerLine);
    BlockWrite(PcxFile,Cline,Cbytes);
    Error:=IORESULT;
    If Error<>0 then
    begin
      SavePcxImg:=Error;
      Close(PcxFile);
      Error:=IORESULT;
      Exit;
    end;
  end;
  Temp:=$C;
  BlockWrite(PcxFile,Temp,1);
  BlockWrite(PcxFile,PcxPal,Sizeof(PcxPal));
end;

 Close(PcxFile);
{$I+}
end;

begin
end.
