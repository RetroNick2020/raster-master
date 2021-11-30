{$mode TP}
{$PACKRECORDS 1}
unit rwpal;

interface
uses
  SysUtils,FileUtil,StrUtils,RMCore,rwXGF;

Const
  ColorIndexFormat = 1;
  ColorFourBitFormat =2;
  ColorSixBitFormat =3;
  ColorEightBitFormat =4;
  ColorOnePercentFormat = 5;


Function ReadPAL(Filename : String;pm : integer) : Word;
Function WritePAL(Filename : String) : Word;
function WritePalData(filename : string; Lan,rgbFormat : integer) : word;
function WritePalConstants(filename : string; Lan,rgbFormat : integer) : word;
function WritePalStatements(filename : string; Lan,rgbFormat : integer) : word;
function WriteVSpritePalArray(filename : string; Lan : integer) : word;

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
              APLan:LanToStr:='Amiga Pascal';
              ACLan:LanToStr:='Amiga C';
              PBLan:LanToStr:='TurboBASIC';
              TPLan:LanToStr:='Turbo Pascal';
              TCLan:LanToStr:='Turbo C';
              GWLan:LanToStr:='GWBASIC';
              QBLan:LanToStr:='QuickBASIC';
              QCLan:LanToStr:='QuickC';

  end;
end;

function PaletteCmdToStr(Lan,ColorFormat : integer) : string;
begin
 PaletteCmdToStr:='Palette';
 if (Lan=TPLan) and (ColorFormat=ColorIndexFormat) then
 begin
   PaletteCmdToStr:='SetPalette(';
 end
 else if (Lan=TPLan) then
 begin
   PaletteCmdToStr:='SetRGBPalette(';
 end
  else if (Lan=TCLan) and (ColorFormat=ColorIndexFormat) then
 begin
   PaletteCmdToStr:='SetPalette(';
 end
 else if (Lan=TCLan) then
 begin
   PaletteCmdToStr:='SetRGBPalette(';
 end
 else if (Lan=QCLan) then
 begin
  PaletteCmdToStr:='_remappalette(';
 end;
end;

function LineTrmToStr(Lan : integer) : string;
begin
 LineTrmToStr:='';
 Case Lan of TPLan,FPLan,APLan:LineTrmToStr:=');';
             TCLan,QCLan,ACLan:LineTrmToStr:='};';
 end;
end;

function CommentBeginToStr(Lan : integer) : string;
begin
 CommentBeginToStr:=#39;
 Case Lan of TPLan,FPLan,APLan:CommentBeginToStr:='(*';
             TCLan,QCLan,ACLan:CommentBeginToStr:='/*';
 end;
end;

function CommentEndToStr(Lan : integer) : string;
begin
 CommentEndToStr:='';
 Case Lan of TPLan,FPLan,APLan:CommentEndToStr:='*)';
             TCLan,QCLan,ACLan:CommentEndToStr:='*/';
 end;
end;

function LineCountToStr(linenum,Lan : integer) : string;
begin
 LineCountToStr:='';
 if (lan=GWLan) then
 begin
   LineCountToStr:=IntToStr(linenum)+' ';
 end;
end;

function FileNameToPaletteName(filename : string) : string;
begin
  FileNameToPaletteName:=ExtractFileName(ExtractFileNameWithoutExt(filename));
end;

// write basic data statements just for basic compilers
function WritePalData(filename : string; Lan,rgbFormat : integer) : word;
var
 NColors : integer;
 BFormat : string;
 F : Text;
 i : integer;
 r,g,b   : integer;
 cistr,rstr,gstr,bstr : string;
 LineCounter : integer;
begin
{$I-}
  Assign(F,filename);
  Rewrite(F);
  LineCounter:=1000;
  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);
  Writeln(F,CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette, ',NColors,' Colors, Format=',BFormat);
  For i:=0 to NColors-1 do
  begin
    r:=RMCoreBase.Palette.GetRed(i);
    g:=RMCoreBase.Palette.GetGreen(i);
    b:=RMCoreBase.Palette.GetBlue(i);

    if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      WriteLn(F,LineCountToStr(LineCounter,Lan),'DATA ',cistr); //linecounttostr is blank unless js GWLan
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      WriteLn(F,LineCountToStr(LineCounter,Lan),'DATA ',rstr,', ',gstr,', ',bstr);    //linecounttostr is blank unless js GWLan
    end;
    inc(LineCounter,10);
  end;
  Close(F);
  WritePalData:=IORESULT;
{$I+}
end;

//for C/pascal languages
function WritePalConstants(filename : string; Lan,rgbFormat : integer) : word;
var
 NColors : integer;
 BFormat : string;
 F : Text;
 i : integer;
 r,g,b   : integer;
 cistr,rstr,gstr,bstr : string;
 palettenamestr : string;
 arraysize      : integer;
begin
{$I-}
  Assign(F,filename);
  Rewrite(F);

  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);
  WriteLn(F,CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette, ',NColors,' Colors, Format=',BFormat,' ',CommentEndToStr(Lan));

  palettenamestr:=filenametoPalettename(filename);
  if rgbformat =ColorIndexFormat then
  begin
    arraysize:=NColors-1;
  end
  else
  begin
    arraysize:=Ncolors*3-1;
  end;
  If (Lan = TPlan) OR (Lan =FPLan) OR (Lan = APLan) then
  begin
   Writeln(F,palettenamestr, ' : Array[0..',arraysize,'] of Byte = (');
  end
  Else if (Lan = QCLan) or (Lan = TCLan)  then
  begin
    Writeln(F,'char ',palettenamestr,'[',arraysize,'] = {');
  end
  Else if (Lan=ACLan) then
  begin
    Writeln(F,'UBYTE ',palettenamestr,'[',arraysize,'] = {');
  end;

  For i:=0 to NColors-1 do
  begin
    r:=RMCoreBase.Palette.GetRed(i);
    g:=RMCoreBase.Palette.GetGreen(i);
    b:=RMCoreBase.Palette.GetBlue(i);

    if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      Write(F,cistr);
      if (i<>NColors-1) then Write(F,',')
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      Write(F,'  ',rstr,', ',gstr,', ',bstr);
      if (i<>NColors-1) then           //if its the last color we don't write a comma at end of line
      begin
         Write(F,',');
         Writeln(F);
      end;
    end;
  end;
  writeln(F,LineTrmToStr(Lan));
  Close(F);
  WritePalConstants:=IORESULT;
{$I+}
end;





// palette command statement all languages
function WritePalStatements(filename : string; Lan,rgbFormat : integer) : word;
var
 NColors : integer;
 BFormat : string;
 F : Text;
 i : integer;
 r,g,b   : integer;
 cistr,rstr,gstr,bstr :string;
 pcmdstr : string;
 LineTrmStr : string;
 LineCounter : integer;
begin
{$I-}
  Assign(F,filename);
  Rewrite(F);

  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);
  pcmdstr:=PaletteCmdToStr(Lan,rgbFormat);
  LineTrmStr:=LineTrmToStr(Lan);
  LineCounter:=1000;
  Writeln(F,CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette Commands, ',NColors,' Colors, Format=',BFormat,' ',CommentEndToStr(Lan));
  For i:=0 to NColors-1 do
  begin
    r:=RMCoreBase.Palette.GetRed(i);
    g:=RMCoreBase.Palette.GetGreen(i);
    b:=RMCoreBase.Palette.GetBlue(i);

    if (Lan=QBLan) and (rgbFormat = ColorSixBitFormat) then
    begin
      cistr:=IntToStr(EightToSixBit(r)+(EightToSixBit(g)*256)+(EightToSixBit(b)*65536));
      WriteLn(F,LineCountToStr(LineCounter,Lan),pcmdstr,' ',i,', ',cistr,LineTrmStr);
    end
    else if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      WriteLn(F,LineCountToStr(LineCounter,Lan),pcmdstr,' ',i,', ',cistr,LineTrmStr);
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      WriteLn(F,LineCountToStr(LineCounter,Lan),pcmdstr,' ',i,', ',rstr,', ',gstr,', ',bstr,LineTrmStr);
    end;
    inc(LineCounter,10);
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


function WriteVSpritePalArray(filename : string; Lan : integer) : word;
var
 Error : word;
 F : Text;
 palettenamestr : string;
 TR1,TR2,TR3 : TRMColorRec;
 color1,color2,color3 : word;
begin
{$I-}
  Assign(F,filename);
  Rewrite(F);

  palettenamestr:=filenametoPalettename(filename);
  RMCoreBase.Palette.GetColor(1,TR1);
  RMCoreBase.Palette.GetColor(2,TR2);
  RMCoreBase.Palette.GetColor(3,TR3);
  Color1:=(EightToFourBit(TR1.r) SHL 8) + (EightToFourBit(TR1.g) SHL 4) + EightToFourBit(TR1.b);
  Color2:=(EightToFourBit(TR2.r) SHL 8) + (EightToFourBit(TR2.g) SHL 4) + EightToFourBit(TR2.b);
  Color3:=(EightToFourBit(TR3.r) SHL 8) + (EightToFourBit(TR3.g) SHL 4) + EightToFourBit(TR3.b);

  If Lan = APlan then
  begin
    writeln(F,'(* VSprite Colors *)');
    Writeln(F,'  ',palettenamestr, ' : Array[1..3] of WORD = ($',HexStr(Color1,4),',$',HexStr(Color2,4),',$',HexStr(Color3,4),');');
  end
  Else if Lan = ACLan then
  begin
    writeln(F,'/* VSprite Colors */');
    Writeln(F,'  WORD ',palettenamestr,'[3] = {0x',LowerCase(HexStr(Color1,4)),',0x',lowerCase(HexStr(Color2,4)),',0x',LowerCase(HexStr(Color3,4)),'};');
  end;

  Close(F);
  WriteVSpritePalArray:=IORESULT;
{$I+}
end;



begin
end.

