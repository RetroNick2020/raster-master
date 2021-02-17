unit RMCore;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;



Type
  TRMColorRec = Record
                   r : integer;
                   g : integer;
                   b : integer;
                end;

  TRMPaletteBuf = array[0..255] of TRMColorRec;

  TRMPalette = class(TObject)
               private
                   paletteBuf : TRMPaletteBuf;
                   ColorCount : integer;
               public
               Constructor Create;
               procedure AddColor(r,g,b : integer);
               procedure DeleteColor(index : integer);
               procedure ClearColors;
               procedure GetColor(index : integer;var cr : TRMColorRec);
               procedure SetColor(index : integer; cr : TRMColorRec);
               function GetColorCount : integer;
               function GetRed(index : integer) : integer;
               function GetGreen(index : integer) : integer;
               function GetBlue(index : integer) : integer;

               procedure DownToVGA;
               procedure DownToEGA;
               procedure DownToCGA;
               procedure DownToMono;
               procedure UpToVGA256;
               procedure UpToVGA;
               procedure UpToEGA;
               procedure UpToCGA;


  end;



  TRMImageBuf = Record
                  Pixel : array[0..255,0..255] of Integer;
       //
  end;

  TRMCoreBase = class(TObject)
                 // Draw Pixel to internal structure
                 // Get Pixel  from internal structure
                 // Save(fname,x1,y1,x2,y2, formwat writer : TObject)

                  Palette  : TRMPalette;
                 private

                  ImageBuf      : TRMImageBuf;
                  TempImageBuf  : TRMImageBuf;
                  UndoImageBuf : TRMImageBuf;

                  CurColor    : integer; // current color

                 public

                 Constructor create;
                 procedure PutPixel(x,y,Color : Integer);
                 procedure PutPixel(x,y : integer);
                 function GetPixel(x,y : Integer) : Integer;
                 procedure SetCurColor(Color : integer);
                 function GetCurColor : integer;
                 procedure ClearBuf(Color : integer);
                 procedure CopyToUndoBuf;
                 procedure UnDo;

  end;


  const
    MonoDefault : array[0..1] of TRMColorRec = ((r:0;g:0;b:0),
                                                (r:255;g:255;b:255));


    CGADefault0 : array[0..3] of TRMColorRec = ((r:0;g:0;b:0),
                                                (r:85;g:250;b:250),
                                                (r:250;g:85;b:250),
                                                (r:255;g:255;b:255));

    CGADefault1 : array[0..3] of TRMColorRec = ((r:0;g:0;b:0),
                                                (r:85;g:250;b:85),
                                                (r:250;g:85;b:85),
                                                (r:250;g:250;b:85));


    EGADefault16 : array[0..15] of TRMColorRec = ((r:0;g:0;b:0),
                                                  (r:0;g:0;b:170),
                                                  (r:0;g:170;b:0),
                                                  (r:0;g:170;b:170),
                                                  (r:170;g:0;b:0),
                                                  (r:170;g:0;b:0),
                                                  (r:170;g:85;b:0),
                                                  (r:170;g:170;b:170),
                                                  (r:85;g:85;b:85),
                                                  (r:85;g:85;b:255),
                                                  (r:85;g:255;b:85),
                                                  (r:85;g:255;b:255),
                                                  (r:255;g:85;b:85),
                                                  (r:255;g:85;b:255),
                                                  (r:255;g:255;b:85),
                                                  (r:255;g:255;b:255));


    EGADefault64 : array[0..63] of TRMColorRec = ((r:0;g:0;b:0),

                                                  (r:0;g:0;b:170),
                                                  (r:0;g:170;b:0),
                                                  (r:0;g:170;b:170),
                                                  (r:170;g:0;b:0),
                                                  (r:170;g:0;b:170),
                                                  (r:170;g:85;b:0),
                                                  (r:170;g:170;b:170),
                                                  (r:0;g:0;b:85),
                                                  (r:0;g:0;b:255),
                                                  (r:0;g:170;b:85),
                                                  (r:0;g:170;b:255),
                                                  (r:170;g:0;b:85),
                                                  (r:170;g:0;b:255),
                                                  (r:170;g:170;b:85),
                                                  (r:170;g:170;b:255),



                                                  (r:0;g:85;b:0),
                                                  (r:0;g:85;b:170),
                                                  (r:0;g:255;b:0),
                                                  (r:0;g:255;b:170),
                                                  (r:170;g:85;b:0),
                                                  (r:170;g:85;b:170),
                                                  (r:170;g:255;b:0),
                                                  (r:170;g:255;b:170),
                                                  (r:0;g:85;b:85),
                                                  (r:0;g:85;b:255),
                                                  (r:0;g:255;b:85),
                                                  (r:0;g:255;b:255),
                                                  (r:170;g:85;b:85),
                                                  (r:170;g:85;b:255),
                                                  (r:170;g:255;b:85),
                                                  (r:170;g:255;b:255),

                                                  (r:85;g:0;b:0),
                                                  (r:85;g:0;b:170),
                                                  (r:85;g:170;b:0),
                                                  (r:85;g:170;b:170),
                                                  (r:255;g:0;b:0),
                                                  (r:255;g:0;b:170),
                                                  (r:255;g:170;b:0),
                                                  (r:255;g:170;b:170),
                                                  (r:85;g:0;b:85),
                                                  (r:95;g:0;b:255),
                                                  (r:85;g:170;b:85),
                                                  (r:85;g:170;b:255),
                                                  (r:255;g:0;b:85),
                                                  (r:255;g:0;b:255),
                                                  (r:255;g:170;b:85),
                                                  (r:255;g:170;b:255),



                                                  (r:85;g:85;b:0),
                                                  (r:85;g:85;b:170),
                                                  (r:85;g:255;b:0),
                                                  (r:85;g:255;b:170),
                                                  (r:255;g:85;b:0),
                                                  (r:255;g:85;b:170),

                                                  (r:255;g:255;b:0),
                                                  (r:255;g:255;b:170),
                                                  (r:85;g:85;b:85),
                                                  (r:85;g:85;b:255),
                                                  (r:85;g:255;b:85),
                                                  (r:85;g:255;b:255),
                                                  (r:255;g:85;b:85),
                                                  (r:255;g:85;b:255),
                                                  (r:255;g:255;b:85),
                                                  (r:255;g:255;b:255));


    VGADefault256 : array[0..255] of TRMColorRec =(
    (r:   0;g:   0;b:   0),
      (r:   0;g:   0;b: 168),
      (r:   0;g: 168;b:   0),
      (r:   0;g: 168;b: 168),
      (r: 168;g:   0;b:   0),
      (r: 168;g:   0;b: 168),
      (r: 168;g:  84;b:   0),
      (r: 168;g: 168;b: 168),
      (r:  84;g:  84;b:  84),
      (r:  84;g:  84;b: 252),
      (r:  84;g: 252;b:  84),
      (r:  84;g: 252;b: 252),
      (r: 252;g:  84;b:  84),
      (r: 252;g:  84;b: 252),
      (r: 252;g: 252;b:  84),
      (r: 252;g: 252;b: 252),
      (r:   0;g:   0;b:   0),
      (r:  20;g:  20;b:  20),
      (r:  32;g:  32;b:  32),
      (r:  44;g:  44;b:  44),
      (r:  56;g:  56;b:  56),
      (r:  68;g:  68;b:  68),
      (r:  80;g:  80;b:  80),
      (r:  96;g:  96;b:  96),
      (r: 112;g: 112;b: 112),
      (r: 128;g: 128;b: 128),
      (r: 144;g: 144;b: 144),
      (r: 160;g: 160;b: 160),
      (r: 180;g: 180;b: 180),
      (r: 200;g: 200;b: 200),
      (r: 224;g: 224;b: 224),
      (r: 252;g: 252;b: 252),
      (r:   0;g:   0;b: 252),
      (r:  64;g:   0;b: 252),
      (r: 124;g:   0;b: 252),
      (r: 188;g:   0;b: 252),
      (r: 252;g:   0;b: 252),
      (r: 252;g:   0;b: 188),
      (r: 252;g:   0;b: 124),
      (r: 252;g:   0;b:  64),
      (r: 252;g:   0;b:   0),
      (r: 252;g:  64;b:   0),
      (r: 252;g: 124;b:   0),
      (r: 252;g: 188;b:   0),
      (r: 252;g: 252;b:   0),
      (r: 188;g: 252;b:   0),
      (r: 124;g: 252;b:   0),
      (r:  64;g: 252;b:   0),
      (r:   0;g: 252;b:   0),
      (r:   0;g: 252;b:  64),
      (r:   0;g: 252;b: 124),
      (r:   0;g: 252;b: 188),
      (r:   0;g: 252;b: 252),
      (r:   0;g: 188;b: 252),
      (r:   0;g: 124;b: 252),
      (r:   0;g:  64;b: 252),
      (r: 124;g: 124;b: 252),
      (r: 156;g: 124;b: 252),
      (r: 188;g: 124;b: 252),
      (r: 220;g: 124;b: 252),
      (r: 252;g: 124;b: 252),
      (r: 252;g: 124;b: 220),
      (r: 252;g: 124;b: 188),
      (r: 252;g: 124;b: 156),
      (r: 252;g: 124;b: 124),
      (r: 252;g: 156;b: 124),
      (r: 252;g: 188;b: 124),
      (r: 252;g: 220;b: 124),
      (r: 252;g: 252;b: 124),
      (r: 220;g: 252;b: 124),
      (r: 188;g: 252;b: 124),
      (r: 156;g: 252;b: 124),
      (r: 124;g: 252;b: 124),
      (r: 124;g: 252;b: 156),
      (r: 124;g: 252;b: 188),
      (r: 124;g: 252;b: 220),
      (r: 124;g: 252;b: 252),
      (r: 124;g: 220;b: 252),
      (r: 124;g: 188;b: 252),
      (r: 124;g: 156;b: 252),
      (r: 180;g: 180;b: 252),
      (r: 196;g: 180;b: 252),
      (r: 216;g: 180;b: 252),
      (r: 232;g: 180;b: 252),
      (r: 252;g: 180;b: 252),
      (r: 252;g: 180;b: 232),
      (r: 252;g: 180;b: 216),
      (r: 252;g: 180;b: 196),
      (r: 252;g: 180;b: 180),
      (r: 252;g: 196;b: 180),
      (r: 252;g: 216;b: 180),
      (r: 252;g: 232;b: 180),
      (r: 252;g: 252;b: 180),
      (r: 232;g: 252;b: 180),
      (r: 216;g: 252;b: 180),
      (r: 196;g: 252;b: 180),
      (r: 180;g: 252;b: 180),
      (r: 180;g: 252;b: 196),
      (r: 180;g: 252;b: 216),
      (r: 180;g: 252;b: 232),
      (r: 180;g: 252;b: 252),
      (r: 180;g: 232;b: 252),
      (r: 180;g: 216;b: 252),
      (r: 180;g: 196;b: 252),
      (r:   0;g:   0;b: 112),
      (r:  28;g:   0;b: 112),
      (r:  56;g:   0;b: 112),
      (r:  84;g:   0;b: 112),
      (r: 112;g:   0;b: 112),
      (r: 112;g:   0;b:  84),
      (r: 112;g:   0;b:  56),
      (r: 112;g:   0;b:  28),
      (r: 112;g:   0;b:   0),
      (r: 112;g:  28;b:   0),
      (r: 112;g:  56;b:   0),
      (r: 112;g:  84;b:   0),
      (r: 112;g: 112;b:   0),
      (r:  84;g: 112;b:   0),
      (r:  56;g: 112;b:   0),
      (r:  28;g: 112;b:   0),
      (r:   0;g: 112;b:   0),
      (r:   0;g: 112;b:  28),
      (r:   0;g: 112;b:  56),
      (r:   0;g: 112;b:  84),
      (r:   0;g: 112;b: 112),
      (r:   0;g:  84;b: 112),
      (r:   0;g:  56;b: 112),
      (r:   0;g:  28;b: 112),
      (r:  56;g:  56;b: 112),
      (r:  68;g:  56;b: 112),
      (r:  84;g:  56;b: 112),
      (r:  96;g:  56;b: 112),
      (r: 112;g:  56;b: 112),
      (r: 112;g:  56;b:  96),
      (r: 112;g:  56;b:  84),
      (r: 112;g:  56;b:  68),
      (r: 112;g:  56;b:  56),
      (r: 112;g:  68;b:  56),
      (r: 112;g:  84;b:  56),
      (r: 112;g:  96;b:  56),
      (r: 112;g: 112;b:  56),
      (r:  96;g: 112;b:  56),
      (r:  84;g: 112;b:  56),
      (r:  68;g: 112;b:  56),
      (r:  56;g: 112;b:  56),
      (r:  56;g: 112;b:  68),
      (r:  56;g: 112;b:  84),
      (r:  56;g: 112;b:  96),
      (r:  56;g: 112;b: 112),
      (r:  56;g:  96;b: 112),
      (r:  56;g:  84;b: 112),
      (r:  56;g:  68;b: 112),
      (r:  80;g:  80;b: 112),
      (r:  88;g:  80;b: 112),
      (r:  96;g:  80;b: 112),
      (r: 104;g:  80;b: 112),
      (r: 112;g:  80;b: 112),
      (r: 112;g:  80;b: 104),
      (r: 112;g:  80;b:  96),
      (r: 112;g:  80;b:  88),
      (r: 112;g:  80;b:  80),
      (r: 112;g:  88;b:  80),
      (r: 112;g:  96;b:  80),
      (r: 112;g: 104;b:  80),
      (r: 112;g: 112;b:  80),
      (r: 104;g: 112;b:  80),
      (r:  96;g: 112;b:  80),
      (r:  88;g: 112;b:  80),
      (r:  80;g: 112;b:  80),
      (r:  80;g: 112;b:  88),
      (r:  80;g: 112;b:  96),
      (r:  80;g: 112;b: 104),
      (r:  80;g: 112;b: 112),
      (r:  80;g: 104;b: 112),
      (r:  80;g:  96;b: 112),
      (r:  80;g:  88;b: 112),
      (r:   0;g:   0;b:  64),
      (r:  16;g:   0;b:  64),
      (r:  32;g:   0;b:  64),
      (r:  48;g:   0;b:  64),
      (r:  64;g:   0;b:  64),
      (r:  64;g:   0;b:  48),
      (r:  64;g:   0;b:  32),
      (r:  64;g:   0;b:  16),
      (r:  64;g:   0;b:   0),
      (r:  64;g:  16;b:   0),
      (r:  64;g:  32;b:   0),
      (r:  64;g:  48;b:   0),
      (r:  64;g:  64;b:   0),
      (r:  48;g:  64;b:   0),
      (r:  32;g:  64;b:   0),
      (r:  16;g:  64;b:   0),
      (r:   0;g:  64;b:   0),
      (r:   0;g:  64;b:  16),
      (r:   0;g:  64;b:  32),
      (r:   0;g:  64;b:  48),
      (r:   0;g:  64;b:  64),
      (r:   0;g:  48;b:  64),
      (r:   0;g:  32;b:  64),
      (r:   0;g:  16;b:  64),
      (r:  32;g:  32;b:  64),
      (r:  40;g:  32;b:  64),
      (r:  48;g:  32;b:  64),
      (r:  56;g:  32;b:  64),
      (r:  64;g:  32;b:  64),
      (r:  64;g:  32;b:  56),
      (r:  64;g:  32;b:  48),
      (r:  64;g:  32;b:  40),
      (r:  64;g:  32;b:  32),
      (r:  64;g:  40;b:  32),
      (r:  64;g:  48;b:  32),
      (r:  64;g:  56;b:  32),
      (r:  64;g:  64;b:  32),
      (r:  56;g:  64;b:  32),
      (r:  48;g:  64;b:  32),
      (r:  40;g:  64;b:  32),
      (r:  32;g:  64;b:  32),
      (r:  32;g:  64;b:  40),
      (r:  32;g:  64;b:  48),
      (r:  32;g:  64;b:  56),
      (r:  32;g:  64;b:  64),
      (r:  32;g:  56;b:  64),
      (r:  32;g:  48;b:  64),
      (r:  32;g:  40;b:  64),
      (r:  44;g:  44;b:  64),
      (r:  48;g:  44;b:  64),
      (r:  52;g:  44;b:  64),
      (r:  60;g:  44;b:  64),
      (r:  64;g:  44;b:  64),
      (r:  64;g:  44;b:  60),
      (r:  64;g:  44;b:  52),
      (r:  64;g:  44;b:  48),
      (r:  64;g:  44;b:  44),
      (r:  64;g:  48;b:  44),
      (r:  64;g:  52;b:  44),
      (r:  64;g:  60;b:  44),
      (r:  64;g:  64;b:  44),
      (r:  60;g:  64;b:  44),
      (r:  52;g:  64;b:  44),
      (r:  48;g:  64;b:  44),
      (r:  44;g:  64;b:  44),
      (r:  44;g:  64;b:  48),
      (r:  44;g:  64;b:  52),
      (r:  44;g:  64;b:  60),
      (r:  44;g:  64;b:  64),
      (r:  44;g:  60;b:  64),
      (r:  44;g:  52;b:  64),
      (r:  44;g:  48;b:  64),
      (r:   0;g:   0;b:   0),
      (r:   0;g:   0;b:   0),
      (r:   0;g:   0;b:   0),
      (r:   0;g:   0;b:   0),
      (r:   0;g:   0;b:   0),
      (r:   0;g:   0;b:   0),
      (r:   0;g:   0;b:   0),
      (r:   0;g:   0;b:   0));




  var
    RMCoreBase : TRMCoreBase;

procedure GetRGBEGA64(index : integer;var cr : TRMColorREc);
procedure GetRGBVGA(index : integer;var cr : TRMColorREc);
function RGBToEGAIndex(r,g,b : integer) : integer;
function ToSixBit(EightBitValue : integer) : integer;
function ToEightBit(SixBitValue : integer) : integer;

implementation

function ToSixBit(EightBitValue : integer) : integer;
begin
  ToSixBit:=round((double(EightBitValue) * 63) / 255)
end;

function ToEightBit(SixBitValue : integer) : integer;
begin
   ToEightBit := SixBitValue * 255 div 63
end;

function RGBToEGAIndex(r,g,b : integer) : integer;
var
  i : integer;
begin
  for i:=0 to 63 do
  begin
    if (EGADefault64[i].r = r) AND(EGADefault64[i].g = g) AND (EGADefault64[i].b = b) then
    begin
       RGBToEGAIndex:=i;
       exit;
    end;
  end;
  RGBToEGAIndex:=-1;
end;

procedure GetRGBEGA64(index : integer;var cr : TRMColorREc);
begin
  cr:=EGADefault64[index];
end;

procedure GetRGBVGA(index : integer;var cr : TRMColorREc);
begin
  cr:=VGADefault256[index];
end;

Constructor TRMPalette.create;
begin
  ColorCount:=0;
end;

procedure TRMPalette.AddColor(r,g,b : integer);
begin
  if (ColorCount > -1) AND (ColorCount < 256) then
  begin
     paletteBuf[ColorCount].r:=r;
     paletteBuf[ColorCount].g:=g;
     paletteBuf[ColorCount].b:=b;
     inc(Colorcount);
  end;
end;

procedure TRMPalette.DeleteColor(index : integer);
begin
end;

procedure TRMPalette.GetColor(index : integer;var cr : TRMColorRec);
begin
    if index > ColorCount then
    begin
       cr:=VGADefault256[index];
    end
    else
    begin
      cr:=palettebuf[index];
    end;
end;

procedure TRMPalette.SetColor(index : integer;cr : TRMColorRec);
begin
  palettebuf[index]:=cr;
end;

procedure TRMPalette.ClearColors;
begin
ColorCount:=0;
end;

function TRMPalette.GetColorCount : integer;
begin
  GetColorCount:=ColorCount;
end;

function TRMPalette.GetRed(index : integer) : integer;
var
  cr : TRMColorRec;
begin
   GetColor(index,cr);
   GetRed:=cr.r;
end;

function TRMPalette.GetGreen(index : integer) : integer;
var
  cr : TRMColorRec;
begin
   GetColor(index,cr);
   getgreen:=cr.g;
end;

function TRMPalette.GetBlue(index : integer) : integer;
var
  cr : TRMColorRec;
begin
   GetColor(index,cr);
   getblue:=cr.b;
end;

procedure TRMPalette.DownToVGA;
begin

end;

procedure TRMPalette.DownToEGA;
begin

end;

procedure TRMPalette.DownToCGA;
begin

end;

procedure TRMPalette.DownToMono;
begin

end;

procedure TRMPalette.UpToVGA256;
begin

end;

procedure TRMPalette.UpToVGA;
begin

end;

procedure TRMPalette.UpToEGA;
begin

end;

procedure TRMPalette.UpToCGA;
begin

end;


Constructor TRMCoreBase.create;
begin
    Palette:=TRMPalette.Create;
    SetCurColor(1);
    ClearBuf(0);
    CopyToUndoBuf;
 end;

procedure TRMCoreBase.SetCurColor(Color : integer);
begin
    CurColor:=Color;
end;

function TRMCoreBase.GetCurColor : integer;
begin
    GetCurColor:=CurColor;
end;

procedure TRMCoreBase.ClearBuf(Color : Integer);
var
  i,j : integer;
begin
    for i:=0 to 255 do
    begin
      for j:=0 to 255 do
      begin
        ImageBuf.Pixel[i,j]:=Color;
      end;
    end;
end;

procedure TRMCoreBase.PutPixel(x,y,Color : Integer);
begin
    if (x > 255) or (y > 255)  then exit;
    ImageBuf.Pixel[x,y]:=Color;
end;

procedure TRMCoreBase.PutPixel(x,y : Integer);
begin
    if (x<0) or (x > 255) or (y<0) or (y > 255)  then exit;
    ImageBuf.Pixel[x,y]:=CurColor;
end;


function TRMCoreBase.GetPixel(x,y : Integer) : Integer;
begin
    GetPixel:=ImageBuf.Pixel[x,y];
end;


procedure TRMCoreBase.CopyToUndoBuf;
begin
  UndoImageBuf:=ImageBuf;
end;

procedure TRMCoreBase.UnDo;
begin
  TempImageBuf:=ImageBuf;
  ImageBuf:=UndoImageBuf;
  UndoImageBuf:=tempImageBuf;
end;

initialization
    RMCoreBase:=TRMCoreBase.Create;
end.

