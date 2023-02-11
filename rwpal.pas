{$mode TP}
{$PACKRECORDS 1}
unit rwpal;

interface
uses
  SysUtils,FileUtil,StrUtils,RMCore,rmxgfcore,rwxgf,gwbasic;

Const
  ColorIndexFormat = 1;
  ColorFourBitFormat =2;
  ColorSixBitFormat =3;
  ColorEightBitFormat =4;
  ColorOnePercentFormat = 5;
  ColorTwoBitFormat = 6;


Function ReadPAL(Filename : String;pm : integer) : Word;
Function WritePAL(Filename : String) : Word;


function WritePalData(filename : string; Lan,rgbFormat : integer) : word;
function WritePalConstants(filename : string; Lan,rgbFormat : integer) : word;
function WritePalStatements(filename : string; Lan,rgbFormat : integer) : word;
function WriteRGBPackedPalArray(filename : string; Lan : integer; vsprite : boolean) : word;

procedure WritePalToArrayBuffer(var data : BufferRec;imagename : string; Lan,rgbFormat : integer);
procedure WritePalToBuffer(var data : BufferRec; rgbFormat : integer);

function WritePalToArrayFile(filename : string; Lan,rgbFormat : integer) : word;
function WritePalToFile(filename : string; rgbFormat : integer) : word;


implementation

type
  PalType = Array[0..255,0..2] of Byte;


function GetPalSize(ncolors,rgbFormat : integer) : integer;
begin
  if rgbFormat = ColorIndexFormat then GetPalSize:=nColors else GetPalSize:=nColors*3;
end;

function ColorFormatToStr(rgbFormat: integer) : string;
begin
  ColorFormatToStr:='';
  Case rgbFormat of ColorIndexFormat:ColorFormatToStr:='Color Index';
                    ColorFourBitFormat:ColorFormatToStr:='4 Bit';
                    ColorSixBitFormat:ColorFormatToStr:='6 Bit';
                    ColorEightBitFormat:ColorFormatToStr:='8 Bit';
                    ColorOnePercentFormat:ColorFormatToStr:='1 Percent';
                    ColorTwoBitFormat:ColorFormatToStr:='2 Bit';

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
                   ColorTwoBitFormat:ColorValueToStr:=IntToStr(EightToTwoBit(InValue));
 end;
end;

function LanToStr(Lan: integer) : string;
begin
  LanToStr:='';
  Case Lan of ABLan:LanToStr:='AmigaBASIC';
              APLan:LanToStr:='Amiga Pascal';
              ACLan:LanToStr:='Amiga C';
              PBLan:LanToStr:='Power/Turbo BASIC';
              TPLan:LanToStr:='Turbo Pascal';
              TCLan:LanToStr:='Turbo C';
              GWLan:LanToStr:='GWBASIC/PC-BASIC';
              QBLan:LanToStr:='QuickBASIC';
              AQBLan:LanToStr:='Amiga QuickBasic';
              QCLan:LanToStr:='QuickC';
              QPLan:LanToStr:='QuickPascal';
              FBLan:LanToStr:='FreeBASIC';
              FBinQBModeLan:LanToStr:='FreeBASIC';
              FPLan:LanToStr:='FreePascal';
              OWLan:LanToStr:='Open Watcom C';

  end;
end;

function PaletteCmdToStr(Lan,ColorFormat : integer) : string;
begin
 PaletteCmdToStr:='Palette';
 if ((Lan=TPLan) OR (Lan=FPLan)) and (ColorFormat=ColorIndexFormat) then
 begin
   PaletteCmdToStr:='SetPalette(';
 end
 else if (Lan=TPLan) OR (Lan=FPLan) then
 begin
   PaletteCmdToStr:='SetRGBPalette(';
 end
  else if (Lan=TCLan) and (ColorFormat=ColorIndexFormat) then
 begin
   PaletteCmdToStr:='setpalette(';
 end
 else if (Lan=TCLan) then
 begin
   PaletteCmdToStr:='setrgbpalette(';
 end
 else if (Lan=QCLan) or (Lan=OWLan) then
 begin
  PaletteCmdToStr:='_remappalette(';
 end
 else if (Lan=QPLan) then
 begin
  PaletteCmdToStr:='_RemapPalette(';
 end
 else if (Lan=PBLan)  and (ColorFormat=ColorSixBitFormat) then  //Turbo/PB do not support additional palette information for VGA rgb formula
 begin                                                     //maybe in future will replacement function for PB
  PaletteCmdToStr:='Call PaletteX(';
 end;

end;

function LineTrmToStr(Lan : integer) : string;
begin
 LineTrmToStr:='';
 Case Lan of QPLan,TPLan,FPLan,APLan:LineTrmToStr:=');';
             TCLan,QCLan,ACLan,OWLan:LineTrmToStr:='};';
 end;
end;

function CommentBeginToStr(Lan : integer) : string;
begin
 CommentBeginToStr:=#39;
 Case Lan of QPLan,TPLan,FPLan,APLan:CommentBeginToStr:='(*';
             TCLan,QCLan,ACLan,OWLan:CommentBeginToStr:='/*';
 end;
end;

function CommentEndToStr(Lan : integer) : string;
begin
 CommentEndToStr:='';
 Case Lan of QPLan,TPLan,FPLan,APLan:CommentEndToStr:='*)';
             TCLan,QCLan,ACLan,OWLan:CommentEndToStr:='*/';
 end;
end;

function CommandEndBracketToStr(Lan : integer) : string;
begin
 CommandEndBracketToStr:=');';
 Case Lan of ABLan,FBinQBModeLan,QBlan,PBLan,GWLan:CommandEndBracketToStr:='';
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
 CR : TRMColorRec;
begin
 SetCoreActive;
 SetGWStartLineNumber(1000);
 {$I-}
  Assign(F,filename);
  Rewrite(F);
  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);
  Writeln(F,LineCountToStr(Lan),CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette, ',' Size= ',GetPalSize(nColors,rgbFormat),' Colors= ',NColors, 'Format= ',BFormat);
  For i:=0 to NColors-1 do
  begin
    GetColor(i,CR);
    r:=CR.r;
    g:=CR.g;
    b:=CR.b;
    if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      WriteLn(F,LineCountToStr(Lan),'DATA ',cistr); //linecounttostr is blank unless is GWLan
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      WriteLn(F,LineCountToStr(Lan),'DATA ',rstr,', ',gstr,', ',bstr);    //linecounttostr is blank unless js GWLan
    end;
//    inc(LineCounter,10);
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
 CR : TRMColorRec;

begin
 SetCoreActive;
{$I-}
  Assign(F,filename);
  Rewrite(F);

  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);
  WriteLn(F,CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette, ',' Size= ',GetPalSize(nColors,rgbFormat),' Colors= ',NColors,' Format=',BFormat,' ',CommentEndToStr(Lan));

  palettenamestr:=filenametoPalettename(filename);
  if rgbformat =ColorIndexFormat then
  begin
    arraysize:=NColors-1;
  end
  else
  begin
    arraysize:=Ncolors*3-1;
  end;
  If (Lan=TPlan) OR (Lan =FPLan) OR (Lan=QPlan) OR (Lan = APLan) then
  begin
   Writeln(F,palettenamestr, ' : array[0..',arraysize,'] of byte = (');
  end
  Else if (Lan = QCLan) or (Lan = TCLan) or (Lan = OWLan) then
  begin
    Writeln(F,'char ',palettenamestr,'[',arraysize,'] = {');
  end
  Else if (Lan=ACLan) then
  begin
    Writeln(F,'UBYTE ',palettenamestr,'[',arraysize,'] = {');
  end;

  For i:=0 to NColors-1 do
  begin
    GetColor(i,CR);
    r:=CR.r;
    g:=CR.g;
    b:=CR.b;

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
 PBasicEndBracket : string;
 CR : TRMColorRec;

begin
SetCoreActive;
SetGWStartLineNumber(1000);
{$I-}
  Assign(F,filename);
  Rewrite(F);

  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);
  pcmdstr:=PaletteCmdToStr(Lan,rgbFormat);
  LineTrmStr:=CommandEndBracketToStr(Lan);

  Writeln(F,LineCountToStr(Lan),CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette Commands, ',' Size= ',GetPalSize(nColors,rgbFormat),' Colors= ',NColors,' Format=',BFormat,' ',CommentEndToStr(Lan));
  For i:=0 to NColors-1 do
  begin
    GetColor(i,CR);
    r:=CR.r;
    g:=CR.g;
    b:=CR.b;

    if ((Lan=QBLan) or (Lan=FBinQBModeLan) or (Lan=GWLan) or (Lan=PBLan) or (Lan=QCLan) or (Lan=QPLan) or (Lan=OWLan)) and (rgbFormat = ColorSixBitFormat) then
    begin
      cistr:=IntToStr(EightToSixBit(r)+(EightToSixBit(g)*256)+(EightToSixBit(b)*65536));
      if (Lan=PBlan) then   PBasicEndBracket:=')' else   PBasicEndBracket:='';
      WriteLn(F,LineCountToStr(Lan),pcmdstr,' ',i,', ',cistr,LineTrmStr,PBasicEndBracket);  // only for Call PaletteX(index,color) otherwise normal Palette command structure
    end
    else if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      WriteLn(F,LineCountToStr(Lan),pcmdstr,' ',i,', ',cistr,LineTrmStr);
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      WriteLn(F,LineCountToStr(Lan),pcmdstr,' ',i,', ',rstr,', ',gstr,', ',bstr,LineTrmStr);
    end;
//    inc(LineCounter,10);
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
 CR : TRMColorRec;

begin
SetCoreActive;
{$I-}
 Colors:=GetMaxColor+1;
 //GrabPaletteList(myPal,Colors);

 For i:=0 to 255 do
begin
  GetColor(i,CR);
  myPal[i,0]:=CR.r;;
  myPal[i,1]:=CR.g;
  myPal[i,2]:=CR.g;
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
 SetCoreActive;
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
//        RMCoreBase.Palette.SetColor(i,cr);
          SetColor(i,cr);
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
//      RMCoreBase.Palette.SetColor(i,cr);
      SetColor(i,cr);

     end;
   end
   else    //most liekly vga or vga256 - no modifications needed
   begin
     for i:=0 to Colors-1 do
     begin
       cr.r:=mypal[i,0];
       cr.g:=mypal[i,1];
       cr.b:=mypal[i,2];
//       RMCoreBase.Palette.SetColor(i,cr);
       SetColor(i,cr);

     end;
   end;

end;
end;


function WriteRGBPackedPalArray(filename : string; Lan : integer; vsprite : boolean) : word;
var

 F : Text;
 palettenamestr : string;
 TR : TRMColorRec;
 color : word;
 startcol,endcol : word;
 arsize : word;
 i : word;
begin
SetCoreActive;
{$I-}
  Assign(F,filename);
  Rewrite(F);

  palettenamestr:=filenametoPalettename(filename);

  startcol:=0;
  endcol:=GetMaxColor;
  arsize:=endcol+1;
  if vsprite then
  begin
    startcol:=1;
    endcol:=3;
    arsize:=3;
  end;

  If Lan = APlan then
  begin
    if vsprite then writeln(F,'(* VSprite Colors *)') else writeln(F,'(* LoadRGB4 Colors *)');
    Writeln(F,'  ',palettenamestr, ' : Array[1..',arsize,'] of WORD = (');
  end
  Else if Lan = ACLan then
  begin
    if vsprite then writeln(F,'/* VSprite Colors */') else writeln(F,'/* LoadRGB4 Colors */');
    Writeln(F,'  WORD ',palettenamestr,'[',arsize,'] = {');
  end;

  for i:=startcol to endcol do
  begin
    RMCoreBase.Palette.GetColor(i,TR);
    Color:=(EightToFourBit(TR.r) SHL 8) + (EightToFourBit(TR.g) SHL 4) + EightToFourBit(TR.b);

    if  Lan=APLan then Write(F,'   $',HexStr(Color,4));
    if  Lan=ACLAN then Write(F,'   0x',LowerCase(HexStr(Color,4)));
    if i <> endcol then writeln(F,',')
  end;
  if Lan=APLan then writeln(F,');');
  if Lan=ACLan then writeln(F,'};');

  Close(F);
  WriteRGBPackedPalArray:=IORESULT;
{$I+}
end;


function WritePalCPascalStatementsBuffer(var data : BufferRec; imagename : string; Lan,rgbFormat : integer) : word;
var
 NColors : integer;
 BFormat : string;
// F : Text;
 i : integer;
 r,g,b   : integer;
 cistr,rstr,gstr,bstr :string;
 pcmdstr : string;
 LineTrmStr : string;
// LineCounter : integer;
 CR : TRMColorRec;
begin
  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);
  pcmdstr:=PaletteCmdToStr(Lan,rgbFormat);
  LineTrmStr:=LineTrmToStr(Lan);
//  LineCounter:=1000;
  Writeln(data.fText,CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette Commands, ',' Size= ',GetPalSize(nColors,rgbFormat),' Colors= ',NColors, ' Format=',BFormat,' ',CommentEndToStr(Lan));
  For i:=0 to NColors-1 do
  begin
(*    r:=RMCoreBase.Palette.GetRed(i);
    g:=RMCoreBase.Palette.GetGreen(i);
    b:=RMCoreBase.Palette.GetBlue(i);
*)
    GetColor(i,CR);
    r:=CR.r;
    g:=CR.g;
    b:=CR.b;

    if (Lan=QBLan) and (rgbFormat = ColorSixBitFormat) then
    begin
      cistr:=IntToStr(EightToSixBit(r)+(EightToSixBit(g)*256)+(EightToSixBit(b)*65536));
      WriteLn(data.fText,LineCountToStr(Lan),pcmdstr,' ',i,', ',cistr,LineTrmStr);
    end
    else if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      WriteLn(data.fText,LineCountToStr(Lan),pcmdstr,' ',i,', ',cistr,LineTrmStr);
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      WriteLn(data.fText,LineCountToStr(Lan),pcmdstr,' ',i,', ',rstr,', ',gstr,', ',bstr,LineTrmStr);
    end;
//    inc(LineCounter,10);
  end;

{$I+}
end;

function WritePalBasicBuffer(var data : BufferRec; imagename : string; Lan,rgbFormat : integer) : word;
var
 NColors : integer;
 BFormat : string;
 //F : Text;
 i : integer;
 r,g,b   : integer;
 cistr,rstr,gstr,bstr : string;
 //LineCounter : integer;
 CR : TRMColorRec;
begin

//  LineCounter:=1000;
  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);

  Writeln(data.fText,LineCountToStr(Lan),CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette, ',' Size= ',GetPalSize(nColors,rgbFormat),' Colors= ',NColors,' Format=',BFormat);
  For i:=0 to NColors-1 do
  begin
    (*
    r:=RMCoreBase.Palette.GetRed(i);
    g:=RMCoreBase.Palette.GetGreen(i);
    b:=RMCoreBase.Palette.GetBlue(i);
*)
    GetColor(i,CR);
    r:=CR.r;
    g:=CR.g;
    b:=CR.b;
    if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      WriteLn(data.fText,LineCountToStr(Lan),'DATA ',cistr); //linecounttostr is blank unless is GWLan
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      WriteLn(data.fText,LineCountToStr(Lan),'DATA ',rstr,', ',gstr,', ',bstr);    //linecounttostr is blank unless js GWLan
    end;
//    inc(LineCounter,10);
  end;
end;



//for C/pascal languages
Procedure WritePalCPascalBuffer(var data : BufferRec;imagename : string; Lan,rgbFormat : integer);
var
 NColors : integer;
 BFormat : string;
// F : Text;
 i : integer;
 r,g,b   : integer;
 cistr,rstr,gstr,bstr : string;
 palettenamestr : string;
 arraysize      : integer;
 CR : TRMColorRec;

begin
  NColors:=GetMaxColor+1;
  BFormat:=ColorFormatToStr(rgbFormat);
  WriteLn(data.fText,CommentBeginToStr(Lan),' ',LanToStr(Lan),' Palette, ',' Size= ',GetPalSize(nColors,rgbFormat),' Colors= ',NColors, ' Format= ',BFormat,' ',CommentEndToStr(Lan));

  palettenamestr:=imagename;
  if rgbformat =ColorIndexFormat then
  begin
    arraysize:=NColors-1;
  end
  else
  begin
    arraysize:=Ncolors*3-1;
  end;
  If (Lan = TPlan) OR (Lan = QPlan) OR (Lan =FPLan) OR (Lan = APLan) then
  begin
   Writeln(data.fText,palettenamestr, ' : array[0..',arraysize,'] of byte = (');
  end
  Else if (Lan = QCLan) or (Lan = TCLan) or (Lan = OWLan) then
  begin
    Writeln(data.fText,'char ',palettenamestr,'[',arraysize,'] = {');
  end
  Else if (Lan=ACLan) then
  begin
    Writeln(data.fText,'UBYTE ',palettenamestr,'[',arraysize,'] = {');
  end;

  For i:=0 to NColors-1 do
  begin
(*    r:=RMCoreBase.Palette.GetRed(i);
    g:=RMCoreBase.Palette.GetGreen(i);
    b:=RMCoreBase.Palette.GetBlue(i);
  *)
    GetColor(i,CR);
    r:=CR.r;
    g:=CR.g;
    b:=CR.b;

    if rgbFormat = ColorIndexFormat then
    begin
      cistr:=ColorValueToStr(RGBToEGAIndex(r,g,b),rgbFormat);
      Write(data.fText,cistr);
      if (i<>NColors-1) then Write(data.fText,',')
    end
    else
    begin
      rstr:=ColorValueToStr(r,rgbFormat);
      gstr:=ColorValueToStr(g,rgbFormat);
      bstr:=ColorValueToStr(b,rgbFormat);
      Write(data.fText,'  ',rstr,', ',gstr,', ',bstr);
      if (i<>NColors-1) then           //if its the last color we don't write a comma at end of line
      begin
         Write(data.fText,',');
         Writeln(data.fText);
      end;
    end;
  end;
  writeln(data.fText,LineTrmToStr(Lan));
end;





//write c/pascal constants and basic data statements
procedure WritePalToArrayBuffer(var data : BufferRec;imagename : string; Lan,rgbFormat : integer);
begin
   case Lan of ABLan,AQBLan,QBLan,PBLan,GWLAN,FBinQBModeLan:WritePalBasicBuffer(data,imagename,Lan,rgbFormat);
               TPLan,QPLan,APLan,FPLan,TCLan,QCLan,ACLan,OWLan:WritePalCPascalBuffer(data,imagename,Lan,rgbFormat);
   end;
end;

//write from RES called function
Procedure WritePalToBuffer(var data : BufferRec; rgbFormat : integer);
var
  nColors : integer;
  CR : TRMColorRec;
  i  : integer;
  ColorBuf : array[0..767] of byte;
  ColorBufEGA : array[0..15] of byte;
begin
  nColors:=GetMaxColor+1;
  for i:=0 to nColors-1 do
  begin
    GetColor(i,CR);
    case rgbFormat of  ColorIndexFormat: begin
                                           ColorBufEGA[i]:=RGBToEGAIndex(CR.r,CR.g,CR.b);
                                         end;
        ColorOnePercentFormat,ColorFourBitFormat: begin
                                           ColorBuf[i*3]:= EightToFourBit(cr.r);
                                           ColorBuf[i*3+1]:= EightToFourBit(cr.g);
                                           ColorBuf[i*3+2]:= EightToFourBit(cr.b);
                                         end;
                      ColorSixBitFormat: begin
                                           ColorBuf[i*3]:= EightToSixBit(cr.r);
                                           ColorBuf[i*3+1]:= EightToSixBit(cr.g);
                                           ColorBuf[i*3+2]:= EightToSixBit(cr.b);
                                         end;
                    ColorEightBitFormat: begin
                                           ColorBuf[i*3]:= cr.r;
                                           ColorBuf[i*3+1]:= cr.g;
                                           ColorBuf[i*3+2]:= cr.b;
                                         end;
   end;
 end;
 if rgbFormat = ColorIndexFormat then BlockWrite(data.f,ColorBufEGA,ncolors)
   else Blockwrite(data.f,ColorBuf,nColors*3);

end;

function WritePalToArrayFile(filename : string; Lan,rgbFormat : integer) : word;
var
 data : BufferRec;
 imagename : string;
begin
 SetCoreActive;
 SetGWStartLineNumber(1000);
{$I-}
  Assign(data.fText,filename);
  Rewrite(data.fText);
  WritePalToArrayBuffer(data,imagename,Lan,rgbformat);

  Close(data.fText);
{$I+}
  WritePalToArrayFile:=IORESULT;
end;

function WritePalToFile(filename : string; rgbFormat : integer) : word;
var
 data : BufferRec;
begin
 SetCoreActive;
 Assign(data.f,FileName);
{$I-}
 Rewrite(data.f,1);
 WritePalToBuffer(data,rgbformat);
 Close(data.f);
{$I+}
 WritePalToFile:=IORESULT;
end;

begin
end.

