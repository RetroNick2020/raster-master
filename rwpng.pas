unit rwpng;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, graphics,fgl,StrUtils,rmcore,dialogs;



type

  { TForm1 }

  TEasyPNG = class

  public
    Picture1 : TPicture;
    Palette : TRMPaletteBuf;
    GlobalPalette : TRMPaletteBuf; //palette created after scanning entire image
    LocalPalette  : TRMPaletteBuf; //palette created after scanning location area of sprite image

    Dictionary: specialize TFPGMap<string, longint>;

    constructor Create;
    destructor destroy; override;
    procedure BuildHashes(x,y,x2,y2 : integer);
    function BuildTopColors(var  TopPalette : TRMPaletteBuf) : integer;

    Function FindMostColorIndex : integer;
    procedure CreatePaletteUsingBasePalette(var BasePalette : TRMPaletteBuf;PaletteMode,ColorCount : integer;
                             var TopPalette : TRMPaletteBuf;topncolors : integer);
//    function FindPaletteIndexInCurrentSpritePalette(r,g,b : integer;var BasePalette : TRMPaletteBuf;pm,nColors : integer) : integer;
    procedure CopyImageToCore(var BasePalette : TRMPaletteBuf;PaletteMode,ColorCount : integer; x,y,x2,y2 : integer);
    procedure CopyPaletteToCore(NewPalette : TRMPaletteBuf;PaletteMode : integer);

    Procedure LoadFromFile(filename : string);
    procedure CopyPictureToCanvas(canvas : TCanvas;x,y,x2,y2 : integer);
    procedure CopyCoreToImage(x,y,x2,y2 : integer);
    Procedure SaveToFile(filename : string);

    procedure GetPalette(var Pal : TRMPaletteBuf);

    function GetWidth : integer;
    function GetHeight : integer;

  end;

function ReadPNG(x,y,x2,y2 : integer;filename : string; LoadPalette : Boolean) : integer;
function SavePNG(x,y,x2,y2 : integer;filename : string) : integer;
function FindPaletteIndex(r,g,b : integer;var BasePalette : TRMPaletteBuf;pm,nColors : integer) : integer;


implementation

function TColorToStr(Color : TColor) : string;
(*
var
 r,g,b : integer;*)
begin
   (*
   r:=SixToEightBit(EightToSixBit(Red(Color)));
   g:=SixToEightBit(EightToSixBit(Green(Color)));
   b:=SixToEightBit(EightToSixBit(Blue(Color)));

   TColorToStr := AddChar('0',IntToStr(r),3)+
   AddChar('0',IntToStr(g),3)+
   AddChar('0',IntToStr(b), 3);
  *)


   TColorToStr := AddChar('0',IntToStr(Red(Color)),3)+
   AddChar('0',IntToStr(Green(Color)),3)+
   AddChar('0',IntToStr(Blue(Color)), 3);

end;


procedure ColorStrToRGB(colorstr : string;var r,g,b : integer);
begin
   r:=StrToInt(copy(colorStr,1,3));
   g:=StrToInt(copy(colorStr,4,3));
   b:=StrToInt(copy(colorStr,7,3));
end;

function FindColorInPalette(Var Palette : TRMPaletteBuf;nColors,r,g,b : integer) : integer;
var
  i: integer;
begin
  FindColorInPalette:=-1;
  for i:=0 to (nColors-1) do
  begin
     if (r=Palette[i].r) AND (g=Palette[i].g) AND (b=Palette[i].b) then
     begin
        FindColorInPalette:=i;
        exit;
     end;
  end;
end;

function FindExactColorMatch(Var Palette : TRMPaletteBuf;nColors,r,g,b : integer) : integer;
var
  i: integer;
begin
  FindExactColorMatch:=-1;
  for i:=0 to nColors-1 do
  begin
     if (r=Palette[i].r) AND (g=Palette[i].g) AND (b=Palette[i].b) then
     begin
        FindExactColorMatch:=i;
        exit;
     end;
  end;
end;

function FindNearColorMatch(Var Palette : TRMPaletteBuf;nColors,r,g,b : integer) : integer;
var
  c1,c2 : TColor;
  gap,tgap : double;
  i,fcm,ec : integer;
begin
  ec:=FindExactColorMatch(Palette,nColors,r,g,b);
  if ec > -1 then
  begin
    FindNearColorMatch:=ec;
    exit;
  end;

  c1:=RGBToColor(r,g,b);
  gap:=10000;
  fcm:=0;
  for i:=0 to nColors-1 do
  begin
     c2:=RGBToColor(Palette[i].r,Palette[i].g,Palette[i].b);
     tgap:=ColorDistance(c1,c2);
     if tgap < gap then
     begin
        gap:=tgap;
        fcm:=i;
     end;
  end;
  FindNearColorMatch:=fcm;
end;

constructor TEasyPNG.Create;
begin
  Picture1:=TPicture.Create;
  Dictionary := specialize TFPGMap<string, longint>.Create;
end;

Function TEasyPNG.FindMostColorIndex : integer;
var
   i : integer;
   v : longint;
   c  : integer;
begin
  v:=0;
  c:=-1;
  for i:=0 to Dictionary.Count-1 do
  begin
     if Dictionary.Data[i] > v then
     begin
        v:=Dictionary.Data[i];
        c:=i;
     end;
  end;
  FindMostColorIndex:=c;
end;

Procedure TEasyPNG.BuildHashes(x,y,x2,y2 : integer);
var
 i,j : integer;
 color : TColor;
 colorStr : string;
 v  : longint;
 cc  : integer;
width,height : integer;
begin
 width:=x2-x+1;
 height:=y2-y+1;
 if width > Picture1.width then width:=Picture1.width;
 if height > Picture1.height then height:=Picture1.height;

 cc:=0;
 Dictionary.Clear;
 for j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
     color:=Picture1.Bitmap.Canvas.Pixels[x+i,y+j];
     colorstr:=TColorToStr(color);
     if Dictionary.TryGetData(colorstr,v) then
     begin
       inc(v);
       Dictionary.AddOrSetData(colorstr,v);
     end
     else
     begin
       Dictionary.Add(colorstr,1);
       inc(cc);
     end;
   end;
 end;
end;

function TEasyPNG.BuildTopColors(var  TopPalette : TRMPaletteBuf) : integer;
var
 ColorCount : integer;
 MostColors : integer;
 ColorStr   : string;
begin
  ColorCount:=0;
  while (Dictionary.Count > 0) and (ColorCount < 256)  do
  begin
   MostColors:=FindMostColorIndex;
   if MostColors<>-1 then
   begin
     ColorStr:=Dictionary.keys[MostColors];
     Dictionary.Delete(MostColors);
     ColorStrToRGB(ColorStr,TopPalette[ColorCount].r,
                            TopPalette[ColorCount].g,
                            TopPalette[ColorCount].b);
     inc(ColorCount);
   end;
  end;

 BuildTopColors:=ColorCount;
end;

// based on rgb and palette mode find best color index
function FindPaletteIndex(r,g,b : integer;var BasePalette : TRMPaletteBuf;pm,nColors : integer) : integer;
var
 ColorIndex : integer;
begin
 ColorIndex:=0;

 if pm = PaletteModeEGA then
 begin
  // r:=TwoToEightBit(EightToTwoBit(r));
 //  g:=TwoToEightBit(EightToTwoBit(g));
 //  b:=TwoToEightBit(EightToTwoBit(b));

   ColorIndex:=FindNearColorMatch(BasePalette,nColors,r,g,b);
   if ColorIndex > 15 then ColorIndex:=ColorIndex Mod 15; //just picks a color base mod 15 - we need something
 end
 else if (pm=PaletteModeVGA) or (pm=paletteModeVGA256) then
 begin
        (*
    r:=SixToEightBit(EightToSixBit(r));
    g:=SixToEightBit(EightToSixBit(g));
    b:=SixToEightBit(EightToSixBit(b));

          *)
   (*
   r:=TwoToEightBit(EightToTwoBit(r));
   g:=TwoToEightBit(EightToTwoBit(g));
   b:=TwoToEightBit(EightToTwoBit(b));
     *)

    ColorIndex:=FindNearColorMatch(BasePalette,nColors,r,g,b);  //near performas findexact also
    if (pm=PaletteModeVGA) and (ColorIndex > 15) then ColorIndex:=ColorIndex Mod 15;
 end
 else if (pm=PaletteModeXGA) or (pm=paletteModeXGA256) then
 begin
    ColorIndex:=FindNearColorMatch(BasePalette,nColors,r,g,b);  //near performas findexact also
    if (pm=PaletteModeXGA) and (ColorIndex > 15) then ColorIndex:=ColorIndex Mod 15;
 end
 else if isAmigaPaletteMode(pm) then
 begin
 (*  r:=FourToEightBit(EightToFourBit(r));
   g:=FourToEightBit(EightToFourBit(g));
   b:=FourToEightBit(EightToFourBit(b));
   *)

 //  r:=TwoToEightBit(EightToTwoBit(r));
  // g:=TwoToEightBit(EightToTwoBit(g));
  // b:=TwoToEightBit(EightToTwoBit(b));

   ColorIndex:=FindNearColorMatch(BasePalette,nColors,r,g,b);  //near performas findexact also
   if  (ColorIndex > (nColors-1)) then ColorIndex:=ColorIndex Mod (nColors-1);
 end
 else if (pm=PaletteModeCGA0) or (pm=PaletteModeCGA1) then
 begin
   //cga and mono - good luck trying to match anything here
   ColorIndex:=FindNearColorMatch(BasePalette,nColors,r,g,b);  //near performas findexact also
   if  (ColorIndex > 3) then ColorIndex:=ColorIndex Mod 3;
 end
 else if (pm=PaletteModeMono) then
 begin
   //cga and mono - good luck trying to match anything here
   ColorIndex:=FindNearColorMatch(BasePalette,nColors,r,g,b);  //near performas findexact also
   if  (ColorIndex > 1) then ColorIndex:=1;
 end;

 if ColorIndex < 0 then ColorIndex:=1;  //if we can't find a match then it's 1 - not ideal but i need to assign a color that works for all modes
 FindPaletteIndex:=ColorIndex;
end;


// creates up to 256 color entries starting with most popular color
// if vga and amiga palette will try to create a compatible palette
// if EGA, CGA, or Mono mode it will just copy the default palettes for these modes

procedure TEasyPNG.CreatePaletteUsingBasePalette(var BasePalette : TRMPaletteBuf;PaletteMode,ColorCount : integer;
                             var TopPalette : TRMPaletteBuf;topncolors : integer);
var
nColors : integer;
//pm : integer;
r,g,b : integer;
EGAIndex : integer;
FindInPalette : integer;
palCounter    : integer;
 i            : integer;
begin
 //we only need to make palette for certain palette mode. CGA/Mono do not need palettes changes
 //we find nearest color to their palette - hard to get any decent results without dithering, but this is not an imaging program
// pm:=RMCoreBAse.Palette.GetPaletteMode;
// RMCoreBase.Palette.GetPalette(palette);  //get the current sprite palette
                                          //we will overwrite the current palette starting at index 1
                                          //we may end up with less colors than the default palette
                                          //by assigning the default palette first we don't need to com up with the extra colors needed
 palCounter:=1;
// nColors:=RMCoreBase.Palette.GetColorCount;
 nColors:=ColorCount;

 if (PaletteMode = PaletteModeVGA256) or (PaletteMode = PaletteModeVGA) then
 begin
    For i:=0 to TopNColors-1 do
    begin
        r:=TopPalette[i].r;
        g:=TopPalette[i].g;
        b:=TopPalette[i].b;

        FindInPalette:=FindColorInPalette(BasePalette,palCounter,r,g,b);
        if (FindInPalette=-1) then      //not found
        begin
          if palCounter < nColors then   //was nColors-1
          begin
            BasePalette[palCounter].r:=r;
            BasePalette[palCounter].g:=g;
            BasePalette[palCounter].b:=b;
            inc(palCounter);
          end;
        end;
    end;

    For i:=0 to TopNColors-1 do
    begin
      BasePalette[i].r:=SixToEightBit(EightToSixBit(BasePalette[i].r));
      BasePalette[i].g:=SixToEightBit(EightToSixBit(BasePalette[i].g));
      BasePalette[i].b:=SixToEightBit(EightToSixBit(BasePalette[i].b));
    end;
 end
 else if (PaletteMode = PaletteModeXGA256) or (PaletteMode = PaletteModeXGA) then
 begin
    For i:=0 to TopNColors-1 do
    begin
        r:=TopPalette[i].r;
        g:=TopPalette[i].g;
        b:=TopPalette[i].b;

        FindInPalette:=FindColorInPalette(BasePalette,palCounter,r,g,b);
        if (FindInPalette=-1) then      //not found
        begin
          if palCounter < nColors then     //was nColors-1
          begin
            BasePalette[palCounter].r:=r;
            BasePalette[palCounter].g:=g;
            BasePalette[palCounter].b:=b;
            inc(palCounter);
          end;
        end;
    end;
 end
 else if (PaletteMode = PaletteModeEGA) then
 begin
   For i:=0 to TopNColors-1 do
   begin
        r:=TopPalette[i].r;
        g:=TopPalette[i].g;
        b:=TopPalette[i].b;


        FindInPalette:=FindColorInPalette(BasePalette,palCounter,r,g,b);
        if (FindInPalette=-1) then   //not found or found in index higher than 15
        begin
          if palCounter < nColors then
          begin
            BasePalette[palCounter].r:=r;
            BasePalette[palCounter].g:=g;
            BasePalette[palCounter].b:=b;
            inc(palCounter);
          end;
        end;
    end;

    For i:=0 to TopNColors-1 do
    begin
      MakeRGBToEGACompatible(BasePalette[i].r,BasePalette[i].g,BasePalette[i].b,
                             BasePalette[i].r,BasePalette[i].g,BasePalette[i].b);
    end;
 end
 else if isAmigaPaletteMode(PaletteMode) then
 begin
   For i:=0 to TopNColors-1 do
   begin
      r:=TopPalette[i].r;
      g:=TopPalette[i].g;
      b:=TopPalette[i].b;

      FindInPalette:=FindColorInPalette(BasePalette,palCounter,r,g,b);
      if (FindInPalette=-1) then
      begin
          if palCounter < nColors then  //was nColors-1
          begin
            BasePalette[palCounter].r:=r;
            BasePalette[palCounter].g:=g;
            BasePalette[palCounter].b:=b;
            inc(palCounter);
          end;
      end;
    end;
    For i:=0 to TopNColors-1 do
    begin
      BasePalette[i].r:=FourToEightBit(EightToFourBit(BasePalette[i].r));
      BasePalette[i].g:=FourToEightBit(EightToFourBit(BasePalette[i].g));
      BasePalette[i].b:=FourToEightBit(EightToFourBit(BasePalette[i].b));
    end;
  end;
end;

// will map each pixel to the closest color in the built palette
// this should work fine for 256 color vga
// all other modes will have various levels of success depending on amount of colors and if they can be altered
// cga and mono will probably fail really bad when loading colors that do not match up exactly

procedure TEasyPNG.CopyImageToCore(var BasePalette : TRMPaletteBuf;PaletteMode,ColorCount : integer; x,y,x2,y2 : integer);
var
 width,height : integer;
 i,j : integer;
 color : TColor;
 ci    : integer;
 pm : integer;
 nColors : integer;
begin
// nColors:=RMCoreBase.Palette.GetColorCount;
 nColors:=ColorCount;
// pm:=RMCoreBAse.Palette.GetPaletteMode;
 pm:=PaletteMode;
 width:=x2-x+1;
 height:=y2-y+1;
 if width > Picture1.width then width:=Picture1.width;
 if height > Picture1.height then height:=Picture1.height;
 for j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
     color:=Picture1.Bitmap.Canvas.Pixels[i,j];
     ci:=FindPaletteIndex(Red(Color),Green(Color),Blue(Color),BasePalette,pm,nColors);
     RMCoreBase.PutPixel(x+i,y+j,ci);
   end;
 end;
end;

//copy palette to RMCore
procedure TEasyPNG.CopyPaletteToCore(NewPalette : TRMPaletteBuf;PaletteMode : integer);
begin
// pm:=RMCoreBAse.Palette.GetPaletteMode;
 if (PaletteMode in [PaletteModeXGA256,PaletteModeXGA,PaletteModeVGA256,PaletteModeVGA,PaletteModeEGA]) or (isAmigaPaletteMode(PaletteMode)) then
 begin
   RMCoreBase.Palette.SetPalette(NewPalette);
 end;
end;

procedure TEasyPNG.GetPalette(var Pal : TRMPaletteBuf);
begin
 pal:=Palette;
end;

function TEasyPNG.GetWidth : integer;
begin
  GetWidth:=Picture1.Width;
end;

function TEasyPNG.GetHeight : integer;
begin
  GetHeight:=Picture1.Height;
end;

Procedure TEasyPNG.LoadFromFile(filename : string);
begin
// Picture1.Bitmap.PixelFormat:=pf4bit;
 Picture1.LoadFromFile(filename);
end;

destructor TEasyPNG.destroy;
begin
  Picture1.Free;
  Dictionary.Free;
end;

function ReadPNG(x,y,x2,y2 : integer;filename : string; LoadPalette : Boolean) : integer;
var
 EasyPNG : TEasyPNG;
 OurPalette,TopColors : TRMPaletteBuf;
 PaletteMode,ColorCount,TopColorCount : Integer;
begin
 EasyPNG:=TEasyPNG.Create;
 EasyPNG.LoadFromFile(filename);

 RMCoreBase.Palette.GetPalette(OurPalette);
 PaletteMode:=RMCoreBase.Palette.GetPaletteMode;
 ColorCount:=RMCoreBase.Palette.GetColorCount;

 if LoadPalette then
 begin
   EasyPNG.BuildHashes(x,y,x2,y2);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
   TopColorCount:=EasyPNG.BuildTopColors(TopColors);
   EasyPNG.CreatePaletteUsingBasePalette(OurPalette,PaletteMode,ColorCount,TopColors,TopColorCount);
   EasyPNG.CopyPaletteToCore(OurPalette,PaletteMode);
 end;
 EasyPNG.CopyImageToCore(OurPalette,PaletteMode,ColorCount,x,y,x2,y2);
 EasyPNG.Free;
 ReadPNG:=0;
end;
(* no transparent support

procedure TEasyPNG.CopyCoreToImage(x,y,x2,y2 : integer);
var
 width,height : integer;
 i,j   : integer;
 color : TColor;
 ci    : integer;
 cr    : TRMColorRec;
begin
 width:=x2-x+1;
 height:=y2-y+1;

 picture1.Bitmap.Width:=width;
 Picture1.Bitmap.height:=height;
 picture1.Bitmap.PixelFormat:=pf32bit;
 for j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
     ci:=RMCoreBase.GetPixel(x+i,y+j);
     RMCoreBase.Palette.GetColor(ci,cr);
     Color:=RGBToColor(cr.r,cr.g,cr.b);
     Picture1.Bitmap.Canvas.Pixels[i,j]:=Color;
   end;
 end;
end;
 *)

procedure TEasyPNG.CopyCoreToImage(x,y,x2,y2 : integer);
var
 width,height : integer;
 i,j   : integer;
 ci    : integer;
 cr    : TRMColorRec;
 pixeldata  : PByte;
 pixelpos   : longint;
begin
 width:=x2-x+1;
 height:=y2-y+1;

 picture1.Bitmap.Width:=width;
 Picture1.Bitmap.height:=height;
 picture1.Bitmap.PixelFormat:=pf32bit;         //change format to 32 bit/RGBA
 pixeldata:=picture1.Bitmap.RawImage.Data;
 pixelpos:=0;
 for j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
     ci:=RMCoreBase.GetPixel(x+i,y+j);
     RMCoreBase.Palette.GetColor(ci,cr);
     pixeldata[pixelpos]:=cr.b;     // Blue
     pixeldata[pixelpos+1]:=cr.g;   // Green
     pixeldata[pixelpos+2]:=cr.r;   // Red
     if (cr.r = 255) and (cr.b=255) and (cr.g=0) then   //if fuschia
     begin
       pixeldata[pixelpos+3]:=0;  // Alpha     0 = transparent
     end
     else
     begin
      pixeldata[pixelpos+3]:=255; // Alpha     255 = solid
     end;
     inc(pixelpos,4);
   end;
 end;
end;

procedure TEasyPNG.CopyPictureToCanvas(canvas : TCanvas;x,y,x2,y2 : integer);
begin

end;

Procedure TEasyPNG.SaveToFile(filename : string);
begin
 Picture1.SaveToFile(filename);
end;


function SavePNG(x,y,x2,y2 : integer;filename : string) : integer;
var
 EasyPNG : TEasyPNG;
begin
 EasyPNG:=TEasyPNG.Create;
 EasyPNG.CopyCoreToImage(x,y,x2,y2);
 EasyPNG.SaveToFile(filename);
 EasyPNG.Free;
 SavePNG:=0;
end;




end.

