{$mode TP}
{$PACKRECORDS 1}
unit rwpal;

interface
uses
  SysUtils,RMCore,rwXGF;

Const
  ColorIndexFormat = 1;
  ColorFourBitFormat =2;
  ColorSixBitFormat =3;
  ColorEightBitFormat =4;
  ColorOnePercentFormat = 5;


Function ReadPAL(Filename : String;pm : integer) : Word;
Function WritePAL(Filename : String) : Word;
function WritePalData(filename : string; Lan,rgbFormat : integer) : word;
function WritePalStatements(filename : string; Lan,rgbFormat : integer) : word;

implementation

type
  PalType = Array[0..255,0..2] of Byte;

function GetMaxColor : integer;

begin
  GetMaxColor:=RMCoreBase.Palette.GetColorCount -1;
end;

function ColorFormatToStr(rgbFormat: integer) : string;
begin
  ColorFormatToStr:='';
  Case rgbFormat of ColorIndexFormat:ColorFormatToStr:='Color Index';
                    ColorFourBitFormat:ColorFormatToStr:='4 Bit';
                    ColorSixBitFormat:ColorFormatToStr:='6 Bit';
                    ColorEightBitFormat:ColorFormatToStr:='8 Bit';
                    ColorOnePercentFormat:ColorFormatToStr:='1 Percent';
  end;
end;

function ColorValueToStr(Invalue,OutFormat : integer) : string;
begin

 ColorValueToStr:='';
 Case OutFormat of ColorIndexFormat:ColorValueToStr:=IntToStr(InValue);
                   ColorFourBitFormat:ColorValueToStr:=IntToStr(EightToFourBit(InValue));
                   ColorSixBitFormat:ColorValueToStr:=IntToStr(EightToSixBit(InValue));
                   ColorEightBitFormat:ColorValueToStr:=IntToStr(InValue);
                   ColorOnePercentFormat:ColorValueToStr:=FormatFloat('0.00',EightToFourBit(InValue)*0.0669);
 end;
end;

function LanToStr(Lan: integer) : string;
begin
  LanToStr:='';
  Case Lan of ABLan:LanToStr:='AmigaBASIC';
              QBLan:LanToStr:='QuickBASIC';
  end;
end;


// write basic data statements just for basic compilers
function WritePalData(filename : string; Lan,rgbFormat : integer) : word;
var
 Error : word;
 NColors : integer;
 BFormat : string;
 F : Text;
 i : integer;
 r,g,b   : integer;
 cistr,rstr,gstr,bstr : string;
begin
{$I-}
  Assign(F,filename);
  Rewrite(F);

  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);

  Writeln(F,#39,' ',LanToStr(Lan),' Palette Data, ',NColors,' Colors, Format=',BFormat);
  For i:=0 to NColors-1 do
  begin
    r:=RMCoreBase.Palette.GetRed(i);
    g:=RMCoreBase.Palette.GetGreen(i);
    b:=RMCoreBase.Palette.GetBlue(i);

    if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      WriteLn(F,'DATA ',cistr);
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      WriteLn(F,'DATA ',rstr,', ',gstr,', ',bstr);
    end;
  end;
  Close(F);
  WritePalData:=IORESULT;
{$I+}
end;
// palette command statement all languages
function WritePalStatements(filename : string; Lan,rgbFormat : integer) : word;
var
 Error : word;
 NColors : integer;
 BFormat : string;
 F : Text;
 i : integer;
 r,g,b   : integer;
 cistr,rstr,gstr,bstr : string;
begin
{$I-}
  Assign(F,filename);
  Rewrite(F);

  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);

  Writeln(F,#39,' ',LanToStr(Lan),' Palette Commands, ',NColors,' Colors, Format=',BFormat);
  For i:=0 to NColors-1 do
  begin
    r:=RMCoreBase.Palette.GetRed(i);
    g:=RMCoreBase.Palette.GetGreen(i);
    b:=RMCoreBase.Palette.GetBlue(i);

    if (Lan=QBLan) and (rgbFormat = ColorSixBitFormat) then
    begin
      cistr:=IntToStr(EightToSixBit(r)+(EightToSixBit(g)*256)+(EightToSixBit(b)*65536));
      WriteLn(F,'PALETTE ',i,', ',cistr);
    end
    else if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      WriteLn(F,'PALETTE ',i,', ',cistr);
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      WriteLn(F,'PALETTE ',i,', ',rstr,', ',gstr,', ',bstr);
    end;
  end;
  Close(F);
  WritePalStatements:=IORESULT;
{$I+}
end;

Function WritePAL(FileName : String): Word;
Var
 F : File;
 myPal :  Array[0..255,0..2] of Byte;
 Colors : Word;
 Error : Word;
 i : integer;

begin
{$I-}
 Colors:=GetMaxColor+1;
 //GrabPaletteList(myPal,Colors);

 For i:=0 to 255 do
begin
  myPal[i,0]:=RMCoreBase.Palette.GetRed(i);
  myPal[i,1]:=RMCoreBase.Palette.GetGreen(i);
  myPal[i,2]:=RMCoreBase.Palette.GetBlue(i);
end;

 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,myPAL,Colors*3);
 Close(F);
 Error:=IORESULT;
 WritePAL:=Error;
{$I+}
end;

Function ReadPAL(Filename : String; pm : integer) : Word;
Var
 F      : File;
 Fsize  : LongInt;
 Colors : word;
 Error  : Word;
  myPal :  Array[0..255,0..2] of Byte;
  cr : TRMColorRec;
  i : integer;
begin
 Colors:=GetMaxCOlor+1;
 Assign(F,FileName);
 Reset(F,1);
 Fsize:=FIleSize(F);
 If (Fsize<>6) AND  (Fsize<>12) AND  (Fsize<>24) AND  (Fsize<>48)   AND  (Fsize<>96) AND (Fsize<>768) then
 begin
  ReadPAL:=1000;
  Exit;
 end;

 Colors :=Fsize div 3;
 if Colors > 256 then Colors:=256;

 BlockRead(F,myPAL,Colors*3);
 Close(F);
 Error:=IORESULT;
 ReadPAl:=Error;

 If (CanLoadPaletteFile(pm)) and (Colors > 0) then     //we do not load palette for mono and cga
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

end;
end;

begin
end.

