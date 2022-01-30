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
    Dictionary: specialize TFPGMap<string, longint>;

    constructor Create;
    destructor destroy; override;
    procedure BuildHashes(x,y,x2,y2 : integer);
    Function FindMostColorIndex : integer;
    procedure CreatePalette;

    function FindPaletteIndex(r,g,b,pm,nColors : integer) : integer;
    procedure CopyImageToCore(x,y,x2,y2 : integer);
    procedure CopyPaletteToCore;
    Procedure LoadFromFile(filename : string);
    procedure CopyCoreToImage(x,y,x2,y2 : integer);
    Procedure SaveToFile(filename : string);

  end;

function ReadPNG(x,y,x2,y2 : integer;filename : string; LoadPalette : Boolean) : integer;
function SavePNG(x,y,x2,y2 : integer;filename : string) : integer;


implementation

function TColorToStr(Color : TColor) : string;
begin
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
 for j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
     color:=Picture1.Bitmap.Canvas.Pixels[i,j];
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



// based on rgb and palette mode find best color index
function TEasyPNG.FindPaletteIndex(r,g,b,pm,nColors : integer) : integer;
var
 ColorIndex : integer;
begin
 ColorIndex:=0;

 if pm = PaletteModeEGA then
 begin
   r:=TwoToEightBit(EightToTwoBit(r));
   g:=TwoToEightBit(EightToTwoBit(g));
   b:=TwoToEightBit(EightToTwoBit(b));

   ColorIndex:=RMCoreBase.Palette.FindNearColorMatch(r,g,b);
   if ColorIndex > 15 then ColorIndex:=ColorIndex Mod 15;
 end
 else if (pm=PaletteModeVGA) or (pm=paletteModeVGA256) then
 begin
  (*  r:=SixToEightBit(EightToSixBit(r));
    g:=SixToEightBit(EightToSixBit(g));
    b:=SixToEightBit(EightToSixBit(b));
    *)

   r:=TwoToEightBit(EightToTwoBit(r));
   g:=TwoToEightBit(EightToTwoBit(g));
   b:=TwoToEightBit(EightToTwoBit(b));


    ColorIndex:=RMCoreBase.Palette.FindNearColorMatch(r,g,b);  //near performas findexact also
    if (pm=PaletteModeVGA) and (ColorIndex > 15) then ColorIndex:=ColorIndex Mod 15;
 end
 else if isAmigaPaletteMode(pm) then
 begin
 (*  r:=FourToEightBit(EightToFourBit(r));
   g:=FourToEightBit(EightToFourBit(g));
   b:=FourToEightBit(EightToFourBit(b));
   *)

   r:=TwoToEightBit(EightToTwoBit(r));
   g:=TwoToEightBit(EightToTwoBit(g));
   b:=TwoToEightBit(EightToTwoBit(b));

   ColorIndex:=RMCoreBase.Palette.FindNearColorMatch(r,g,b);  //near performas findexact also
   if  (ColorIndex > (nColors-1)) then ColorIndex:=ColorIndex Mod (nColors-1);
 end
 else if (pm=PaletteModeCGA0) or (pm=PaletteModeCGA1) then
 begin
   //cga and mono - good luck trying to match anything here
   ColorIndex:=RMCoreBase.Palette.FindNearColorMatch(r,g,b);  //near performas findexact also
   if  (ColorIndex > 3) then ColorIndex:=ColorIndex Mod 3;
 end
 else if (pm=PaletteModeMono) then
 begin
   //cga and mono - good luck trying to match anything here
   ColorIndex:=RMCoreBase.Palette.FindNearColorMatch(r,g,b);  //near performas findexact also
   if  (ColorIndex > 1) then ColorIndex:=1;
 end;

 if ColorIndex < 0 then ColorIndex:=1;  //if we can't find a match then it's 1 - not ideal but i need to assign a color that works for all modes
 FindPaletteIndex:=ColorIndex;
end;


// creates up to 256 color entries starting with most popular color
// if vga and amiga palette will try to create a compatible palette
// if EGA, CGA, or Mono mode it will just copy the default palettes for these modes

procedure TEasyPNG.CreatePalette;
var
 i : integer;
mc : integer;
colorstr : string;
nColors : integer;
pm : integer;
r,g,b : integer;
EGAIndex : integer;
FindInPalette : integer;
palCounter    : integer;
begin
 //we only need to make palette for certain palette mode. CGA/Mono do not need palettes changes
 //we find nearest color to their palette - hard to get any decent results without dithering, but this is not an imaging program
 pm:=RMCoreBAse.Palette.GetPaletteMode;
 RMCoreBase.Palette.GetPalette(palette);
 palCounter:=1;
 nColors:=RMCoreBase.Palette.GetColorCount;

 if (pm = PaletteModeVGA256) or (pm = PaletteModeVGA) then
 begin
    while Dictionary.Count > 0 do   //we skip index 0
    begin
      mc:=FindMostColorIndex;
      if mc<>-1 then
      begin
        colorstr:=Dictionary.keys[mc];
        ColorStrToRGB(colorstr,r,g,b);
          (*
        r:=SixToEightBit(EightToSixBit(r));
        g:=SixToEightBit(EightToSixBit(g));
        b:=SixToEightBit(EightToSixBit(b));
            *)

        r:=TwoToEightBit(EightToTwoBit(r));
        g:=TwoToEightBit(EightToTwoBit(g));
        b:=TwoToEightBit(EightToTwoBit(b));

        FindInPalette:=FindColorInPalette(Palette,palCounter,r,g,b);
        if (FindInPalette=-1) then      //not found
        begin
          if palCounter < (nColors-1) then
          begin
            Palette[palCounter].r:=r;
            Palette[palCounter].g:=g;
            Palette[palCounter].b:=b;
            inc(palCounter);
          end;
        end;
        Dictionary.Delete(mc);
      end;
    end;
 end
 else if (pm = PaletteModeEGA) then
 begin
    while Dictionary.Count > 0 do   //we skip index 0
    begin
      mc:=FindMostColorIndex;
      if mc<>-1 then
      begin
        colorstr:=Dictionary.keys[mc];
        ColorStrToRGB(colorstr,r,g,b);

        r:=TwoToEightBit(EightToTwoBit(r));
        g:=TwoToEightBit(EightToTwoBit(g));
        b:=TwoToEightBit(EightToTwoBit(b));


        FindInPalette:=FindColorInPalette(Palette,palCounter,r,g,b);
        if (FindInPalette=-1) then   //not found or found in index higher than 15
        begin
          EGAIndex:=RGBToEGAIndex(r,g,b);
          if EGAIndex < 64 then
          begin
            Palette[palCounter].r:=EGADefault64[EGAIndex].r;
            Palette[palCounter].g:=EGADefault64[EGAIndex].g;
            Palette[palCounter].b:=EGADefault64[EGAIndex].b;
            inc(palCounter);
          end;
        end;
        Dictionary.Delete(mc);
      end;
    end;
 end
 else if isAmigaPaletteMode(pm) then
 begin
    while Dictionary.Count > 0 do
    begin
      mc:=FindMostColorIndex;
      if mc<>-1 then
      begin
        colorstr:=Dictionary.keys[mc];
        ColorStrToRGB(colorstr,r,g,b);
        (*
        r:=FourToEightBit(EightToFourBit(r));
        g:=FourToEightBit(EightToFourBit(g));
        b:=FourToEightBit(EightToFourBit(b));
          *)

        r:=TwoToEightBit(EightToTwoBit(r));            // this gives better results than the above
        g:=TwoToEightBit(EightToTwoBit(g));
        b:=TwoToEightBit(EightToTwoBit(b));


        FindInPalette:=FindColorInPalette(Palette,palCounter,r,g,b);
        if (FindInPalette=-1) then
        begin
          if palCounter < (nColors-1) then
          begin
            Palette[palCounter].r:=r;
            Palette[palCounter].g:=g;
            Palette[palCounter].b:=b;
            inc(palCounter);
          end;
        end;
        Dictionary.Delete(mc);
      end;
    end;
 end;
end;

// will map each pixel to the closest color in the built palette
// this should work fine for 256 color vga
// all other modes will have various levels of success depending on amount of colors and if they can be altered
// cga and mono will probably fail really bad when loading colors that do not match up exactly

procedure TEasyPNG.CopyImageToCore(x,y,x2,y2 : integer);
var
 width,height : integer;
 i,j : integer;
 color : TColor;
 ci    : integer;
 pm : integer;
 nColors : integer;
begin
 nColors:=RMCoreBase.Palette.GetColorCount;
 pm:=RMCoreBAse.Palette.GetPaletteMode;
 width:=x2-x+1;
 height:=y2-y+1;
 if width > Picture1.width then width:=Picture1.width;
 if height > Picture1.height then height:=Picture1.height;
 for j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
     color:=Picture1.Bitmap.Canvas.Pixels[i,j];
     ci:=FindPaletteIndex(Red(Color),Green(Color),Blue(Color),pm,nColors);
     RMCoreBase.PutPixel(x+i,y+j,ci);
   end;
 end;
end;

//copy palette to RMCore
procedure TEasyPNG.CopyPaletteToCore;
var
 pm : integer;
begin
 pm:=RMCoreBAse.Palette.GetPaletteMode;
 if (pm = PaletteModeVGA256) or (pm = PaletteModeVGA) or (pm = PaletteModeEGA) or (isAmigaPaletteMode(pm)) then
 begin
   RMCoreBase.Palette.SetPalette(Palette);
 end;
end;

Procedure TEasyPNG.LoadFromFile(filename : string);
begin
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
begin
 EasyPNG:=TEasyPNG.Create;
 EasyPNG.LoadFromFile(filename);
 if LoadPalette then
 begin
   EasyPNG.BuildHashes(x,y,x2,y2);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
   EasyPNG.CreatePalette;
   EasyPNG.CopyPaletteToCore;
 end;
 EasyPNG.CopyImageToCore(x,y,x2,y2);
 EasyPNG.Free;
 ReadPNG:=0;
end;


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

