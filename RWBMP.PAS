Unit rwbmp;
 Interface
Function ReadBMP(x,y,x2,y2,lp : Word;Filename : String) : Word;
Function WriteBMP(x,y,x2,y2 : Word;Filename : String) : Word;
Implementation
  uses vars,core,dos,graph,bgiPal;

type
 bmpRec = Record
             ID              : Array[1..2] of CHAR;
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

Procedure PackedToSingle(Var imgLine,uline : lineBufType;bpl,width : Word);
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

Procedure SingleToPacked(Var uline,imgline : lineBufType;bpl : Word);
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

Function ReadBMP(x,y,x2,y2,lp : Word;Filename : String) : Word;
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
 stdPal   : PaletteT;
 i,j      : Word;
 Error    : Word;
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

 if NOT ((mybmp.biCompression=0) AND (mybmp.ID='BM') AND ((mybmp.bits=4) OR (mybmp.bits=8))) then
 begin
  ReadBMP:=1000;
  Close(F);
  Error:=IORESULT;
  exit;
 end;

 if myHeight>mybmp.biHeight then
 begin
   myHeight:=myBmp.biHeight;
 end;

 if myWidth>mybmp.biWidth then
 begin
   myWidth:=myBmp.biWidth;
 end;

 myColNum:=1 SHL myBmp.bits;
 if myBmp.Bits=4 then
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
    PackedToSingle(imgLine,Uline,BPL,myWidth);
    For i:=1 to myWidth do
    begin
      IconImage[x+i-1,y+j-1]:=Uline[i-1];
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
      IconImage[x+i-1,y+j-1]:=Uline[i-1];
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
   ReduceTo16;
 end;

 if lp=1 then
 begin
   For i:=0 to myColNum-1 do
   begin
    StdPal[i,0]:=bmpPal[i].red SHR 2;
    StdPal[i,1]:=bmpPal[i].green SHR 2;
    StdPal[i,2]:=bmpPal[i].blue SHR 2;
   end;
   SetPaletteList(StdPal,myColNum);
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
 stdPal   : PaletteT;
 i,j      : Word;
 Error    : Word;
begin
 myHeight:=y2-y+1;
 myWidth:=x2-x+1;
 myNumCol:=GetMAxColor+1;
 If MyNumCol=16 then
 begin
     BPL:=(myWidth+7) Div 8;
     BPL:=(BPL*8) DIV 2;
 end
 else
 begin
     BPL:=(myWidth+3) div 4;
     BPL:=BPL*4;
 end;
 FillChar(myBmp,SizeOf(myBMP),0);
 mybmp.ID:='BM';
 mybmp.offbits :=SizeOf(myBMP)+(mynumCol*4);
 mybmp.Fsize   :=mybmp.offbits+(BPL*myHeight);
 mybmp.biSize  :=40;
 mybmp.biWidth :=myWidth;
 mybmp.biHeight:=myHeight;
 mybmp.biPlanes:=1;
 mybmp.bisizeImage:=mybmp.fsize-mybmp.offbits;
 if myNumCol=16 then
 begin
   mybmp.bits:=4;
 end
 else
 begin
   mybmp.bits:=8;
 end;

 GrabPaletteList(StdPal,myNumCol);
 For i:=0 to myNumCol-1 do
 begin
  bmpPal[i].red:=StdPal[i,0] SHL 2;
  bmpPal[i].green:=StdPal[i,1] SHL 2;
  bmpPal[i].blue:=StdPal[i,2] SHL 2;
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
       uline[i-1]:=IconImage[x+i-1,j];
     end;
     SingleToPacked(uline,imgline,BPL);
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
       uline[i-1]:=IconImage[x+i-1,j];
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