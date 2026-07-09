unit rwpng;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, graphics,fgl,StrUtils,rmcore,dialogs,rmthumb,GraphType;

type
  PngRGBASettingsRec = Record
    ColorIndex    : integer;
    UseColorIndex : boolean;
    UseFuschia    : boolean;
    UseCustom     : boolean;
    R,G,B,A       : integer;
  end;

  TTColorLongMap = specialize TFPGMap<TColor, longint>;

  //15-bit color histogram: O(1) per pixel, replaces TFPGMap for speed
  TColorHistEntry = record
    Count : longint;   //how many pixels mapped to this bucket
    R, G, B : byte;    //first exact color seen (preserves full 8-bit precision)
    Used : boolean;    //true if this bucket has any pixels
  end;

  { TForm1 }

  TEasyPNG = class

  public
    Picture1 : TPicture;
    Palette : TRMPaletteBuf;
    GlobalPalette : TRMPaletteBuf; //palette created after scanning entire image
    LocalPalette  : TRMPaletteBuf; //palette created after scanning location area of sprite image

    ColorHashMap :  TTColorLongMap;  //kept for any external code that reads it
    ColorHist : array[0..32767] of TColorHistEntry;
    HistReady : boolean;

    //pf32bit cache of Picture1 for fast RawImage pointer access
    FBmp32 : TBitmap;
    FBmp32Valid : boolean;

    constructor Create;
    destructor destroy; override;
    procedure EnsureBmp32;
    procedure BuildHashes(x,y,x2,y2 : integer);
    function BuildTopColors(var  TopPalette : TRMPaletteBuf) : integer;

    Function FindMostColorIndex : integer;  //legacy - uses ColorHashMap
    procedure CreatePaletteUsingBasePalette(var BasePalette : TRMPaletteBuf;PaletteMode,ColorCount : integer;
                             var TopPalette : TRMPaletteBuf;topncolors : integer);
    procedure CopyImageToCore(var BasePalette : TRMPaletteBuf;PaletteMode,ColorCount : integer; x,y,x2,y2 : integer);
    procedure CopyThumbToImage(index : integer;PngRGBA : PngRGBASettingsRec); // 0=none,1=transparent color=0, 2=transparent color=fuschia,

    procedure CopyPaletteToCore(NewPalette : TRMPaletteBuf;PaletteMode : integer);

    Procedure LoadFromFile(filename : string);
    procedure CopyPictureToCanvas(canvas : TCanvas;x,y,x2,y2 : integer);
    procedure CopyCoreToImage(x,y,x2,y2 : integer;PngRGBA : PngRGBASettingsRec);
    Procedure SaveToFile(filename : string);

    procedure GetPalette(var Pal : TRMPaletteBuf);

    function GetWidth : integer;
    function GetHeight : integer;

  end;

function ReadPNG(x,y,x2,y2 : integer;filename : string; LoadPalette : Boolean) : integer;
function SavePNG(x,y,x2,y2 : integer;filename : string; PngRGBA : PngRGBASettingsRec) : integer;
function SaveFromThumbAsPNG(index : integer;filename : string; PngRGBA : PngRGBASettingsRec) : integer;

function FindPaletteIndex(r,g,b : integer;var BasePalette : TRMPaletteBuf;pm,nColors : integer) : integer;


implementation

procedure ColorToRGB(color : TColor;var r,g,b : integer);
begin
   r:=RED(color);
   g:=GREEN(color);
   b:=BLUE(color);
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
  ColorHashMap := TTColorLongMap.Create;
  HistReady:=false;
  FBmp32:=nil;
  FBmp32Valid:=false;
end;

Function TEasyPNG.FindMostColorIndex : integer;
var
   i : integer;
   v : longint;
   c  : integer;
begin
  v:=0;
  c:=-1;
  for i:=0 to ColorHashMap.Count-1 do
  begin
     if ColorHashMap.Data[i] > v then
     begin
        v:=ColorHashMap.Data[i];
        c:=i;
     end;
  end;
  FindMostColorIndex:=c;
end;

Procedure TEasyPNG.BuildHashes(x,y,x2,y2 : integer);
var
 i,j : integer;
 width,height : integer;
 key : integer;
 cr,cg,cb : byte;
 P : PByte;
 RowStride, BytesPerPixel : integer;
begin
 width:=x2-x+1;
 height:=y2-y+1;
 if width > Picture1.width then width:=Picture1.width;
 if height > Picture1.height then height:=Picture1.height;

 //clear the 15-bit histogram
 FillChar(ColorHist, SizeOf(ColorHist), 0);
 HistReady:=true;

 //build a pf32bit copy for fast raw pointer access (cached across calls)
 EnsureBmp32;
 if (FBmp32 = nil) or (not FBmp32Valid) then exit;

 BytesPerPixel:=FBmp32.RawImage.Description.BitsPerPixel div 8;
 RowStride:=FBmp32.RawImage.Description.BytesPerLine;

 for j:=0 to height-1 do
 begin
   if (y+j) >= FBmp32.Height then break;
   P:=FBmp32.RawImage.Data + (y+j) * RowStride + x * BytesPerPixel;
   for i:=0 to width-1 do
   begin
     //pf32bit = BGRA byte order
     cb:=P^; Inc(P);
     cg:=P^; Inc(P);
     cr:=P^; Inc(P);
     if BytesPerPixel = 4 then Inc(P);

     //15-bit key: 5 bits per channel
     key:=((cr shr 3) shl 10) or ((cg shr 3) shl 5) or (cb shr 3);

     inc(ColorHist[key].Count);
     if not ColorHist[key].Used then
     begin
       ColorHist[key].R:=cr;
       ColorHist[key].G:=cg;
       ColorHist[key].B:=cb;
       ColorHist[key].Used:=true;
     end;
   end;
 end;
end;

function TEasyPNG.BuildTopColors(var  TopPalette : TRMPaletteBuf) : integer;
var
 ColorCount : integer;
 i, bestIdx : integer;
 bestCount : longint;
begin
  //extract up to 256 most popular colors from the 15-bit histogram
  //each pass finds the highest count, records it, zeros it out
  ColorCount:=0;
  while ColorCount < 256 do
  begin
    bestIdx:=-1;
    bestCount:=0;
    for i:=0 to 32767 do
    begin
      if ColorHist[i].Count > bestCount then
      begin
        bestCount:=ColorHist[i].Count;
        bestIdx:=i;
      end;
    end;
    if bestIdx < 0 then break;  //no more colors

    TopPalette[ColorCount].r:=ColorHist[bestIdx].R;
    TopPalette[ColorCount].g:=ColorHist[bestIdx].G;
    TopPalette[ColorCount].b:=ColorHist[bestIdx].B;
    ColorHist[bestIdx].Count:=0;  //mark consumed so next pass skips it
    inc(ColorCount);
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
   ColorIndex:=FindNearColorMatch(BasePalette,nColors,r,g,b);
   if ColorIndex > 15 then ColorIndex:=ColorIndex Mod 15; //just picks a color base mod 15 - we need something
 end
 else if (pm=PaletteModeVGA) or (pm=paletteModeVGA256) then
 begin
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
FindInPalette : integer;
palCounter    : integer;
 i            : integer;
begin
// we only need to make palette for certain palette mode. CGA/Mono do not need palettes changes
// we find nearest color to their palette - hard to get any decent results without dithering, but this is not an imaging program
// pm:=RMCoreBAse.Palette.GetPaletteMode;
// RMCoreBase.Palette.GetPalette(palette);  //get the current sprite palette
                                          //we will overwrite the current palette starting at index 1
                                          //we may end up with less colors than the default palette
                                          //by assigning the default palette first we don't need to come up with the extra colors needed
 palCounter:=1;
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
 nColors:=ColorCount;
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
 Picture1.LoadFromFile(filename);
 FBmp32Valid:=false;
end;

destructor TEasyPNG.destroy;
begin
  FreeAndNil(FBmp32);
  Picture1.Free;
  ColorHashMap.Free;
end;

//renders Picture1 into a pf32bit TBitmap for direct RawImage.Data access
//only rebuilds when FBmp32Valid is false (after load/clipboard import)
procedure TEasyPNG.EnsureBmp32;
var
  W, H : integer;
begin
  if FBmp32Valid and (FBmp32 <> nil) then exit;
  W:=Picture1.Width;
  H:=Picture1.Height;
  if (W <= 0) or (H <= 0) then exit;
  if FBmp32 = nil then
    FBmp32:=TBitmap.Create;
  FBmp32.PixelFormat:=pf32bit;
  FBmp32.SetSize(W, H);
  FBmp32.Canvas.Brush.Color:=clBlack;
  FBmp32.Canvas.FillRect(0, 0, W, H);
  FBmp32.Canvas.Draw(0, 0, Picture1.Graphic);
  FBmp32Valid:=true;
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

procedure TEasyPNG.CopyCoreToImage(x,y,x2,y2 : integer;PngRGBA : PngRGBASettingsRec); // 0=none,1=transparent color=0, 2=transparent color=fuschia,
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
     pixeldata[pixelpos+3]:=255;    // Alpha     255 = solid

     if (PngRGBA.UseColorIndex) and (PngRGBA.ColorIndex=ci) then
     begin
       pixeldata[pixelpos+3]:=0;  // Alpha     0 = transparent
     end;

     if (PngRGBA.UseFuschia) and (cr.r = 255) and (cr.g=0) and (cr.b=255) then   //use fuschia
     begin
       pixeldata[pixelpos+3]:=0;  // Alpha     0 = transparent
     end;

     if (PngRGBA.UseCustom) and (cr.r = PngRGBA.R) and (cr.b=PngRGBA.B) and (cr.g=PngRGBA.G) then   //use fuschia
     begin
       pixeldata[pixelpos+3]:=PngRGBA.A;  // use Custom Alpha level for transperancy
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


function SavePNG(x,y,x2,y2 : integer;filename : string; PngRGBA : PngRGBASettingsRec) : integer;
var
 EasyPNG : TEasyPNG;
begin
 EasyPNG:=TEasyPNG.Create;
 EasyPNG.CopyCoreToImage(x,y,x2,y2,PngRGBA);
 EasyPNG.SaveToFile(filename);
 EasyPNG.Free;
 SavePNG:=0;
end;


procedure TEasyPNG.CopyThumbToImage(index : integer;PngRGBA : PngRGBASettingsRec); // 0=none,1=transparent color=0, 2=transparent color=fuschia,
var
 width,height : integer;
 i,j   : integer;
 ci    : integer;
 cr    : TRMColorRec;
 pixeldata  : PByte;
 pixelpos   : longint;
begin
 width:=ImageThumbBase.GetExportWidth(index);
 height:=ImageThumbBase.GetExportHeight(index);;

 picture1.Bitmap.Width:=width;
 Picture1.Bitmap.height:=height;
 picture1.Bitmap.PixelFormat:=pf32bit;         //change format to 32 bit/RGBA
 pixeldata:=picture1.Bitmap.RawImage.Data;
 pixelpos:=0;
 for j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
     ci:=ImageThumbBase.GetPixel(index,i,j);
     ImageThumbBase.GetColor(index,ci,cr);

     pixeldata[pixelpos]:=cr.b;     // Blue
     pixeldata[pixelpos+1]:=cr.g;   // Green
     pixeldata[pixelpos+2]:=cr.r;   // Red
     pixeldata[pixelpos+3]:=255;    // Alpha     255 = solid

     if (PngRGBA.UseColorIndex) and (PngRGBA.ColorIndex=ci) then
     begin
       pixeldata[pixelpos+3]:=0;  // Alpha     0 = transparent
     end;

     if (PngRGBA.UseFuschia) and (cr.r = 255) and (cr.g=0) and (cr.b=255) then   //use fuschia
     begin
       pixeldata[pixelpos+3]:=0;  // Alpha     0 = transparent
     end;

     if (PngRGBA.UseCustom) and (cr.r = PngRGBA.R) and (cr.b=PngRGBA.B) and (cr.g=PngRGBA.G) then   //use fuschia
     begin
       pixeldata[pixelpos+3]:=PngRGBA.A;  // use Custom Alpha level for transperancy
     end;

     inc(pixelpos,4);
   end;
 end;
end;


function SaveFromThumbAsPNG(index : integer;filename : string; PngRGBA : PngRGBASettingsRec) : integer;
var
 EasyPNG : TEasyPNG;
begin
 EasyPNG:=TEasyPNG.Create;
 EasyPNG.CopyThumbToImage(index,PngRGBA);
 EasyPNG.SaveToFile(filename);
 EasyPNG.Free;
 SaveFromThumbAsPNG:=0;
end;



end.

