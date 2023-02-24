{$mode TP}
{$PACKRECORDS 1}
Unit rwbmp;
 Interface
Function ReadBMP(x,y,x2,y2,lp,pm : Word;Filename : String) : Word;
Function WriteBMP(x,y,x2,y2 : Word;Filename : String) : Word;
Implementation
  uses SysUtils,RMCore,Dialogs,bits;

type
 bmpRec = Record
             ID              : Array[1..2] of char;
             Fsize           : LongInt;
             reserved1       : Word;
             reserved2       : Word;
             offbits         : LongInt;

             biSize          : LongInt;
             biWidth         : LongInt;
             biHeight        : Longint;
             biPlanes        : Word;
             bits            : Word;
             biCompression   : LongInt;
             biSizeImage     : LongInt;
             biXpelsPerMeter : LongInt;
             biyPelsPerMeter : LongInt;
             biClrUsed       : LongInt;
             biClrImportant  : LongInt;
          End;


 bmpRGB = Record
            blue   : byte;
            green  : byte;
            red    : byte;
            filler : byte;
          End;

 LineBufType = Array[0..1023] of Byte;


//for 2 pixels 16 colors
Procedure PackedToSingle16(Var imgLine,uline : lineBufType;bpl,width : Word);
Var
 i    :  Word;
 xp   :  Word;
begin
   xp:=0;
   for i:=0 to BPL-1 do
   begin
    uline[xp+1]:=imgLine[i] SHL 4;
    uline[xp+1]:=uline[xp+1] SHR 4;
    uline[xp]:=imgLine[i] SHR 4;
    inc(xp,2);
    if xp>=Width then exit;
   end;
end;

Procedure packedToSingle4(Var imgLine,uline : lineBufType;bpl,width : Word);
var
 cb,i : Word;
begin
 cb:=0;
 For i:=0 to BPL-1 do
 begin

   uline[cb]:=imgLine[i] shr 6;

   uline[cb+1]:=imgLine[i] shl 2;
   uline[cb+1]:=uline[cb+1] shr 6;

   uline[cb+2]:=imgLine[i]  shl 4;
   uline[cb+2]:=uline[cb+2] shr 6;

   uline[cb+3]:=imgLine[i] shl 6;
   uline[cb+3]:=uline[cb+3] shr 6;

   inc(cb,4);
  end;
end;



//for 2 pixels in 16 colors
Procedure SingleToPacked16(Var uline,imgline : lineBufType;bpl : Word);
Var
 i    :  Word;
 xp   :  Word;
begin
   xp:=0;
   for i:=0 to bpl-1 do
   begin
    imgline[i]:=(uLine[xp] SHL 4)+uline[xp+1];
    inc(xp,2);
   end;
end;

//for 4 pixels in 4 colors
Procedure SingleToPacked4(Var uline,imgline : lineBufType;bpl : Word);
Var
 i    :  Word;
 cb   :  Word;
begin
   FillChar(imgline,sizeof(imgline),0);
   cb:=0;
   for i:=0 to bpl-1 do
   begin
    imgline[i] := (uline[cb] shl 6) + (uline[cb+1] shl 4) + (uline[cb+2] shl 2) + (uline[cb+3]);
    inc(cb,4);
   end;
end;

// for 8 pixels in 2 colors
Procedure singleToPacked8(var uline,imgline : lineBufType;
                  BPL : Word);
var
 cb,i,j : Word;
 x : integer;
begin
 cb:=0;
 x:=0;
 FillChar(imgline,sizeof(imgline),0);
 For i:=0 to BPL-1 do
 begin

   For j:=7 downto 0 do
    begin
      //if Biton(j,pplane[i]) then splane[cb+(7-j)]:=1;
       if  uline[x] = 1 then  SetBit(j,1,imgline[i]);
        inc(x);

    end;
   // monoplane[i]:=254;
   inc(cb,8);
 //  imgline[i]:=254;
 end;
end;

Procedure MonoToSingle(var uline,imgline : lineBufType;
                  BPL : Word);
var
 cb,i,j : Word;
begin
 cb:=0;
 FillChar(imgline,sizeof(imgline),0);
 For i:=0 to BPL-1 do
 begin
    For j:=7 downto 0 do
    begin
      if Biton(j,uline[i]) then imgline[cb+(7-j)]:=1;
    end;
   inc(cb,8);
 end;
end;


function GetMaxColor : integer;
begin
   GetMaxColor:=RMCoreBase.Palette.GetColorCount-1;
end;

Function ReadBMP(x,y,x2,y2,lp,pm : Word;Filename : String) : Word;
Var
 mybmp    : bmpRec;
 myWidth  : Word;
 myHeight : Word;
 myColNum : Word;
 BPL      : Word;
 F        : File;
 uline,
 imgline  : lineBufType;
 bmpPal   : Array[0..255] of bmpRGB;
 //stdPal   : PaletteT;
 i,j      : Word;
 Error    : Word;
 cr       : TRMColorRec;
begin
 myHeight:=y2-y+1;
 myWidth:=x2-x+1;
{$I-}
 assign(F,filename);
 reset(F,1);

 Blockread(F,mybmp,sizeof(mybmp));

 Error:=IORESULT;
 if Error <> 0 then
 begin
   ReadBMP:=Error;
   exit;
 end;
 (*
 if NOT ((mybmp.biCompression=0) AND (mybmp.ID='BM') AND ((mybmp.bits=4) OR (mybmp.bits=8))) then
 begin
  ShowMessage('Not Valid');
  ReadBMP:=1000;
  Close(F);
  Error:=IORESULT;
  exit;
 end;
  *)
 if myHeight>mybmp.biHeight then
 begin
   myHeight:=myBmp.biHeight;
 end;

 if myWidth>mybmp.biWidth then
 begin
   myWidth:=myBmp.biWidth;
 end;

 myColNum:=1 SHL myBmp.bits;

 if myBmp.Bits=1 then
 begin
  blockread(f,bmpPal,64);
  BPL:=(myBmp.biWidth+7) Div 8;
  BPL:=((BPL+3) Div 4);
  BPL:=BPL*4;

  Seek(F,mybmp.fsize-(bpl*myHeight));
  for j:=myHeight downto 1 do
  begin
    Blockread(f,imgLine,BPL);
    Error:=IORESULT;
    if Error <> 0 then
    begin
     Close(F);
     ReadBMP:=Error;
    exit;
    end;
    MonoToSingle(imgLine,Uline,BPL);
    For i:=1 to myWidth do
    begin
      //IconImage[x+i-1,y+j-1]:=Uline[i-1];
      RMCoreBase.PutPixel(x+i-1,y+j-1,Uline[i-1]);
    end;
   end;
 end
 else if myBmp.Bits=2 then
 begin
  //ShowMessage('Reading for bits = 2');
  blockread(f,bmpPal,64);
 BPL:=(myBmp.biWidth+7) Div 2;
  BPL:=((BPL+3) Div 4);
  BPL:=BPL*4;


  Seek(F,mybmp.fsize-(bpl*myHeight));
  for j:=myHeight downto 1 do
  begin
    Blockread(f,imgLine,BPL);
    Error:=IORESULT;
    if Error <> 0 then
    begin
     Close(F);
     ReadBMP:=Error;
    exit;
    end;
   PackedToSingle4(imgLine,Uline,BPL,mywidth);
    For i:=1 to myWidth do
    begin
      //IconImage[x+i-1,y+j-1]:=Uline[i-1];
      RMCoreBase.PutPixel(x+i-1,y+j-1,Uline[i-1]);
    end;
 end;
 end
 else if myBmp.Bits=4 then
 begin
  blockread(f,bmpPal,64);
  BPL:=((myBmp.biWidth+7) div 8);
  BPL:=(BPL*8) DIV 2;
  Seek(F,mybmp.fsize-(bpl*myHeight));
  for j:=myHeight downto 1 do
  begin
    Blockread(f,imgLine,BPL);
    Error:=IORESULT;
    if Error <> 0 then
    begin
     Close(F);
     ReadBMP:=Error;
    exit;
    end;
    PackedToSingle16(imgLine,Uline,BPL,myWidth);
    For i:=1 to myWidth do
    begin
      //IconImage[x+i-1,y+j-1]:=Uline[i-1];
      RMCoreBase.PutPixel(x+i-1,y+j-1,Uline[i-1]);
    end;
 end;
 end
 else if myBmp.bits=8 then
 begin
   blockread(f,bmpPal,1024);
    Error:=IORESULT;
    if Error <> 0 then
    begin
     Close(F);
     ReadBMP:=Error;
    exit;
    end;
   BPL:=(mybmp.biWidth+3) div 4;
   BPL:=BPL*4;
   Seek(F,mybmp.fsize-(bpl*myHeight));
   for j:=myHeight downto 1 do
   begin
    Blockread(f,ULine,BPL);
    For i:=1 to myWidth do
    begin
      //IconImage[x+i-1,y+j-1]:=Uline[i-1];
      RMCoreBase.PutPixel(x+i-1,y+j-1,Uline[i-1]);
    end;
  end;
 end
 else
 begin
    ReadBMP:=1000;
    Close(F);
    Error:=IORESULT;
    exit;
 end;

 Close(f);
 if GetMaxColor < (myColNum-1) then
 begin
   myColNum:=GetMaxColor+1;
   //ReduceTo16;
 end;



  If (lp=1) and (CanLoadPaletteFile(pm)) and (myColNum > 0) then     //we do not load palette for mono and cga or if we are select/clip open mode pal=0
  begin
   if pm=PaletteModeEGA then       //if we are in ega palette mode we need to be able to remap rgb color ega64 palette
   begin                           //if not we skip setting that color
     for i:=0 to myColNum-1 do
     begin
       cr.r:=bmpPal[i].red;
       cr.g:=bmpPal[i].green;
       cr.b:=bmpPal[i].blue;
       MakeRGBToEGACompatible(cr.r,cr.g,cr.b,cr.r,cr.g,cr.b);
       RMCoreBase.Palette.SetColor(i,cr);
     end;
   end
   else if isAmigaPaletteMode(pm) then
   begin
     for i:=0 to myColNum-1 do
     begin
      cr.r:=FourToEightBit(EightToFourBit(bmpPal[i].red));
      cr.g:=FourToEightBit(EightToFourBit(bmpPal[i].green));
      cr.b:=FourToEightBit(EightToFourBit(bmpPal[i].blue));
      RMCoreBase.Palette.SetColor(i,cr);
     end;
   end
   else if (pm=PaletteModeVGA) or (pm=PaletteModeVGA256) then
   begin
     for i:=0 to myColNum-1 do
     begin
       cr.r:=SixToEightBit(EightToSixBit(bmpPal[i].red));   //we bitshift because if palette was saved when PaletteModeXga or PaletteModeXga256
       cr.g:=SixToEightBit(EightToSixBit(bmpPal[i].green));   //we will have invalid values
       cr.b:=SixToEightBit(EightToSixBit(bmpPal[i].blue));
       RMCoreBase.Palette.SetColor(i,cr);
//       SetColor(i,cr);
      end;
   end
   else if (pm=PaletteModeXGA) or (pm=PaletteModeXGA256) then
   begin
     for i:=0 to myColNum-1 do
     begin
       cr.r:=bmpPal[i].red;
       cr.g:=bmpPal[i].green;
       cr.b:=bmpPal[i].blue;
       RMCoreBase.Palette.SetColor(i,cr);
//       SetColor(i,cr);
     end;
   end;
 end;

Error:=IORESULT;
ReadBMP:=Error;
{$I+}
end;


Function WriteBMP(x,y,x2,y2 : Word;Filename : String) : Word;
Var
 mybmp    : bmpRec;
 myWidth  : Word;
 myHeight : Word;
 myNumCol : Word;
 BPL      : Word;
 F        : File;
 uline,
 imgline  : lineBufType;
 bmpPal   : Array[0..255] of bmpRGB;
 //stdPal   : PaletteT;
 i,j      : Word;
 Error    : Word;
 padcount : word;
begin
 myHeight:=y2-y+1;
 myWidth:=x2-x+1;
 myNumCol:=GetMAxColor+1;


  if MyNumCol =8 then
  begin
    MyNumCol:=16;
  end
  else if MyNumCol =32 then
  begin
    MyNumCol:=256;
  end;




  If MyNumCol=16 then
 begin
  // ShowMessage('NumCol is 16');
     BPL:=(myWidth+7) Div 8;
     BPL:=(BPL*8) DIV 2;
 end
  else If MyNumCol=2 then
 begin
 //  ShowMessage('NumCol is 2');
    BPL:=(myWidth+7) Div 8;
    BPL:=((BPL+3) Div 4);
    BPL:=BPL*  4;
//    ShowMessage('NumCol is 2 BPL='+IntToStr(BPL));

 end
 else If MyNumCol=4 then
 begin
 //  ShowMessage('NumCol is 4');
    BPL:=(myWidth+7) Div 2;
    BPL:=((BPL+3) Div 4);
    BPL:=BPL*  4;
   // BPL:=1;
//    PadCount:=(4-(BPL mod 4)) mod 4;
 //   BPL:=BPL+PadCount;
 end
 else
 begin
     BPL:=(myWidth+3) div 4;
     BPL:=BPL*4;
 end;
 FillChar(myBmp,SizeOf(myBMP),0);
 mybmp.ID:='BM';
 mybmp.offbits :=SizeOf(myBMP)+(mynumCol*4);
 mybmp.Fsize   :=longint(mybmp.offbits+(BPL*myHeight));
 mybmp.biSize  :=40;
 mybmp.biWidth :=myWidth;
 mybmp.biHeight:=myHeight;
 mybmp.biPlanes:=1;
 mybmp.bisizeImage:=mybmp.fsize-mybmp.offbits;
 if myNumCol=16 then
 begin
   mybmp.bits:=4;
 end
 else if myNumCol=4 then
 begin
   mybmp.bits:=2;
 end
 else if myNumCol=2 then
 begin
   mybmp.bits:=1;
 end
 else
 begin
   mybmp.bits:=8;
 end;

 //GrabPaletteList(StdPal,myNumCol);
 For i:=0 to myNumCol-1 do
 begin
  bmpPal[i].red:=RMCoreBase.palette.GetRed(i);
  bmpPal[i].green:=RMCoreBase.palette.GetGreen(i);
  bmpPal[i].blue:=RMCoreBase.palette.GetBlue(i);
  bmpPal[i].filler:=0;
 end;

{$I-}
 assign(F,filename);
 rewrite(F,1);

 BlockWrite(F,mybmp,sizeof(mybmp));
 error:=IORESULT;
 if Error<>0 then
 begin
   WriteBMP:=Error;
   Close(F);
   Error:=IORESULT;
   exit;
 end;


 BlockWrite(F,bmpPal,myNumCol*4);

 if myNumCol=16 then
 begin
   For j:=y2 downto y do
   begin
     For i:=1 to myWidth do
     begin
//       uline[i-1]:=IconImage[x+i-1,j];
         uline[i-1]:=RMCoreBase.GetPixel(x+i-1,j);
     end;
     SingleToPacked16(uline,imgline,BPL);
     BlockWrite(F,imgLine,BPL);
    error:=IORESULT;
    if Error<>0 then
    begin
      WriteBMP:=Error;
      Close(F);
      Error:=IORESULT;
      exit;
    end;
   end;
 end
else if myNumCol=4 then
 begin
   For j:=y2 downto y do
   begin
     For i:=1 to myWidth do
     begin
//       uline[i-1]:=IconImage[x+i-1,j];
         uline[i-1]:=RMCoreBase.GetPixel(x+i-1,j);
     end;
    SingleToPacked4(uline,imgline,BPL);
    BlockWrite(F,imgLine,BPL);
    error:=IORESULT;
    if Error<>0 then
    begin
      WriteBMP:=Error;
      Close(F);
      Error:=IORESULT;
      exit;
    end;
   end;
 end
else if myNumCol=2 then
 begin
   For j:=y2 downto y do
   begin
     For i:=1 to myWidth do
     begin
//       uline[i-1]:=IconImage[x+i-1,j];
         uline[i-1]:=RMCoreBase.GetPixel(x+i-1,j);
     end;
    SingleToPacked8(uline,imgline,BPL);
    BlockWrite(F,imgLine,BPL);
    error:=IORESULT;
    if Error<>0 then
    begin
      WriteBMP:=Error;
      Close(F);
      Error:=IORESULT;
      exit;
    end;
   end;
 end
 else
 begin
   For j:=y2 downto y do
   begin
     For i:=1 to myWidth do
     begin
//       uline[i-1]:=IconImage[x+i-1,j];
         uline[i-1]:=RMCoreBase.GetPixel(x+i-1,j);
     end;
     BlockWrite(F,uLine,BPL);
     error:=IORESULT;
     if Error<>0 then
     begin
      WriteBMP:=Error;
      Close(F);
      Error:=IORESULT;
      exit;
     end;
   end;
 end;
 Close(F);
 Error:=IORESULT;
 WriteBMP:=Error;
{$I+}
end;

begin
end.
