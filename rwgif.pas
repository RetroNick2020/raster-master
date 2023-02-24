unit rwgif;

{$mode TP}
{$PACKRECORDS 1}

interface
uses
  rwgifcore,rmcore;

function WGif(x,y,x2,y2 : integer;filename : string) : integer;
function RGif(x,y,x2,y2,Lp,Pm : integer;filename : string) : integer;

implementation
type
  LineBufType = Array[0..2047] of Byte;
var
  GifXOffset : integer;
  GifYOffset : integer;
  GifX       : integer;
  GifY       : integer;
  GifWidth   : integer;
  GifHeight  : integer;

function GetMaxColor : integer;
begin
  GetMaxColor:=RMCoreBase.Palette.GetColorCount-1;
end;

function GetGifPixel : integer;
begin
 if GifY = GifHeight then
 begin
   GetGifPixel:=-1;
   exit;
 end;
 GetGifPixel:=RMCoreBase.GetPixel(GifX+GifXOffset,GifY+GifYoffset);
 inc(GifX);
 if GifX = GifWidth then
 begin
   Gifx:=0;
   inc(GifY);
 end;
end;

procedure GetGifLine(Var pixels; line, width : integer );
var
  rmlinebuf : LineBufType;
  i : integer;
  mywidth : integer;
begin
  if line > GifHeight then exit;
  if GifWidth < width  then myWidth:=GifWidth else myWidth:=width;
  move(pixels,rmlinebuf,mywidth);

  for i:=0 to mywidth-1 do
  begin
    RMCoreBase.PutPixel(GifXoffset+i,GifYOffset+line,rmlinebuf[i]);
  end;
end;

function GetGifDepth : integer;
var
  myNumCols : integer;
begin
 myNumCols:=GetMaxColor+1;
 case myNumCols of 2 : GetGifDepth:=1;
                   4 : GetGifDepth:=2;
                   8 : GetGifDepth:=3;
                  16 : GetGifDepth:=4;
                  32 : GetGifDepth:=5;
                  64 : GetGifDepth:=6;
                 128 : GetGifDepth:=7;
                 256 : GetGifDepth:=8;
 end;
end;

function WGif(x,y,x2,y2 : integer;filename : string) : integer;
var
  width,height : integer;
  Gifpal :  array[0..767] of byte;
  i : integer;
  myNumCols : integer;
begin
 GifXOffset:=x;
 GifYOffset:=y;
 GifX:=0;
 GifY:=0;
 width:=x2-x+1;
 height:=y2-y+1;
 GifWidth:=width;
 GifHeight:=height;

 myNumCols:=GetMaxColor+1;

 For i:=0 to myNumCols-1 do
 begin
  gifPal[i*3]:=RMCoreBase.palette.GetRed(i);
  gifPal[i*3+1]:=RMCoreBase.palette.GetGreen(i);
  gifPal[i*3+2]:=RMCoreBase.palette.GetBlue(i);
 end;

 WGif:=SaveGif(filename, width, height,GetGifDepth,Gifpal );
end;

function RGif(x,y,x2,y2,Lp,Pm : integer;filename : string) : integer;
var
  width,height : integer;
  i : integer;
  myNumCols : integer;
  error : integer;
  cr  : TRMColorRec;
begin
 GifXOffset:=x;
 GifYOffset:=y;
 width:=x2-x+1;
 height:=y2-y+1;
 GifWidth:=width;
 GifHeight:=height;

 myNumCols:=GetMaxColor+1;
 error:=LoadGif(filename);
 if (error = 0) and (Lp = 1) and (pm <>PaletteModeMono ) and (pm<>PaletteModeCGA0) and (pm<>PaletteModeCGA1) and (pm<> PaletteModeEGA) then
 begin
  // For i:=0 to myNumCols-1 do
  // begin
  //     cr.r:=GifPalette[i*3];
  //     cr.g:=GifPalette[i*3+1];
  //     cr.b:=GifPalette[i*3+2];
  //     RMCoreBase.Palette.SetColor(i,cr);
  // end;

   if pm=PaletteModeEGA then       //if we are in ega palette mode we need to be able to remap rgb color ega64 palette
      begin                           //if not we skip setting that color
        for i:=0 to myNumCols-1 do
        begin
          cr.r:=GifPalette[i*3];
          cr.g:=GifPalette[i*3+1];
          cr.b:=GifPalette[i*3+2];
          MakeRGBToEGACompatible(cr.r,cr.g,cr.b,cr.r,cr.g,cr.b);
          RMCoreBase.Palette.SetColor(i,cr);
        end;
      end
      else if isAmigaPaletteMode(pm) then
      begin
        for i:=0 to myNumCols-1 do
        begin
         cr.r:=FourToEightBit(EightToFourBit(GifPalette[i*3]));
         cr.g:=FourToEightBit(EightToFourBit(GifPalette[i*3+1]));
         cr.b:=FourToEightBit(EightToFourBit(GifPalette[i*3+2]));
         RMCoreBase.Palette.SetColor(i,cr);
        end;
      end
      else if (pm=PaletteModeVGA) or (pm=PaletteModeVGA256) then
      begin
        for i:=0 to myNumCols-1 do
        begin
          cr.r:=SixToEightBit(EightToSixBit(GifPalette[i*3]));   //we bitshift because if palette was saved when PaletteModeXga or PaletteModeXga256
          cr.g:=SixToEightBit(EightToSixBit(GifPalette[i*3+1]));   //we will have invalid values
          cr.b:=SixToEightBit(EightToSixBit(GifPalette[i*3+2]));
          RMCoreBase.Palette.SetColor(i,cr);
       //   SetColor(i,cr);
         end;
      end
      else if (pm=PaletteModeXGA) or (pm=PaletteModeXGA256) then
      begin
        for i:=0 to myNumCols-1 do
        begin
          cr.r:=GifPalette[i*3];
          cr.g:=GifPalette[i*3+1];
          cr.b:=GifPalette[i*3+2];
          RMCoreBase.Palette.SetColor(i,cr);
   //       SetColor(i,cr);
        end;
      end;
 end;
 RGif:=error;
end;


procedure InitProcs;
begin
 GifOutLineProc := GetGifLine;
 GifInPixelProc := GetGifPixel;
end;

begin
  InitProcs;
end.

