{$mode TP}
{$PACKRECORDS 1}

unit rwraw;

interface
     uses RMCore,Dialogs,SysUtils;
Function ReadRaw(x,y,x2,y2,pal,pm : Word;FileName : String) : Word;
Function WriteRaw(x,y,x2,y2 : Word;FileName : String) : Word;



implementation

type
 linebuftype = array[0..1023] of byte;

function GetMaxColor : integer;
begin
  GetMaxColor:=RMCoreBase.Palette.GetColorCount -1;
end;


Function WriteRaw(x,y,x2,y2 : Word;FileName : String) : Word;
Var
 Error,i ,j : Word;
    F : File;
 Width,Height,Colors : Word;
 Tbuf : linebuftype;
  myPal : Array[0..255,0..2] of Byte;
begin
 Width:=x2-x+1;
 Height:=y2-y+1;
 Colors:=GetMaxColor+1;

// GrabPaletteList(myPal,Colors);
For i:=0 to 255 do
begin
  myPal[i,0]:=RMCoreBase.Palette.GetRed(i);
  myPal[i,1]:=RMCoreBase.Palette.GetGreen(i);
  myPal[i,2]:=RMCoreBase.Palette.GetBlue(i);
end;


{$I-}
 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,Width,2);
 BlockWrite(F,Height,2);
 BlockWrite(F,Colors,2);

 BlockWrite(F,myPal,Colors*3);

 For j:=y to y2 do
 begin
   For i:=1 to Width do
   begin
  //   Tbuf[i]:=IconImage[x+i-1,j];
       Tbuf[i-1]:=RMCoreBase.GetPixel(x+i-1,j);
   end;
   BlockWrite(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     WriteRaw:=Error;
     Exit;
   end;
 end;

 Close(F);
 Error:=IORESULT;
 WriteRaw:=Error;
{$I+}
end;

Function ReadRaw(x,y,x2,y2,pal,pm : Word;FileName : String) : Word;
Var
 Error,i ,j : Word;
    F : File;
 Width,Height,Colors : Word;
 myWidth,myHeight : Word;
 Fcol : Byte;
 Tbuf : LineBufType;
  myPal :  Array[0..255,0..2] of Byte;
 size,fsize  : LongInt;
 cr : TRMColorRec;
begin
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
{$I-}
 Assign(F,FileName);
 Reset(F,1);
 Error:=IORESULT;
 if Error <>0 then
 begin
   ReadRaw:=Error;
   Exit;
 end;

 fsize:=FileSize(F);

 BlockRead(F,Width,2);
 BlockRead(F,Height,2);
 BlockRead(F,Colors,2);

 size:=Width*Height+(Colors*3)+6;  //make sure everything is valid RM RAW file and not something else with RAW extension
 if size<>fsize then
 begin
  Close(f);
  ReadRaw:=1000;
  Error:=IORESULT;
  Exit;
 end;
 If Colors > 0 Then
 begin
   BlockRead(F,myPal,Colors*3);
 end;
 If myHeight > Height then myHeight:=Height;
 if myWidth >  Width then myWidth:=Width;
 For j:=1 to myHeight do
 begin
   BlockRead(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     ReadRaw:=Error;
     Exit;
   end;
   For i:=1 to myWidth do
   begin
       //IconImage[x+i-1,y+j-1]:=Tbuf[i-1];
       RMCoreBase.PutPixel(x+i-1,y+j-1,Tbuf[i-1]);
   end;
 end;
 Close(F);
 If (GetMaxColor=15) AND (Colors>16) then
 begin
   //ReduceTo16;
 end;
 if Colors > (GetMaxColor+1) then Colors:=GetMaxColor+1;


 If (Pal=1) and (CanLoadPaletteFile(pm)) and (Colors > 0) then     //we do not load palette for mono and cga or if we are select/clip open mode pal=0
 begin
   if pm=PaletteModeEGA then       //if we are in ega palette mode we need to be able to remap rgb color ega64 palette
   begin                           //if not we skip setting that color
     for i:=0 to Colors-1 do
     begin
       cr.r:=mypal[i,0];
       cr.g:=mypal[i,1];
       cr.b:=mypal[i,2];
       if RGBToEGAIndex(cr.r,cr.g,cr.b) > -1 then    //if this returns an index to EGA color we can accept it
       begin
        RMCoreBase.Palette.SetColor(i,cr);
       end;
     end;
   end
   else if isAmigaPaletteMode(pm) then
   begin
     for i:=0 to Colors-1 do
     begin
      cr.r:=FourToEightBit(EightToFourBit(mypal[i,0]));
      cr.g:=FourToEightBit(EightToFourBit(mypal[i,1]));
      cr.b:=FourToEightBit(EightToFourBit(mypal[i,2]));
      RMCoreBase.Palette.SetColor(i,cr);
     end;
   end
   else    //most liekly vga or vga256 - no modifications needed
   begin
     for i:=0 to Colors-1 do
     begin
       cr.r:=mypal[i,0];
       cr.g:=mypal[i,1];
       cr.b:=mypal[i,2];
       RMCoreBase.Palette.SetColor(i,cr);
     end;
   end;
 Error:=IORESULT;
 ReadRaw:=Error;
{$I+}
end;
end;


end.

