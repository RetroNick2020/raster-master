unit rmcore;

{$mode objfpc}{$H+}

interface
uses
  Classes, Graphics, SysUtils,GraphUtil,Math;


//const
//  MaxImagePixelWidth = 256;
//  MaxImagePixelHeight = 256;

Type
  TRMColorRec = Record
                   r : integer;
                   g : integer;
                   b : integer;
                end;

  TRMPaletteBuf = array[0..255] of TRMColorRec;

  TRMPalette = class(TObject)
               private
                   PaletteBuf : TRMPaletteBuf;
                   ColorCount : integer;
                  Palettemode : integer;

                  CBPaletteBuf : TRMPaletteBuf;  //clipboard palette - use for copy and paste palette
                  CBColorCount : integer;
                 CBPalettemode : integer;


               public
               Constructor Create;
               procedure AddColor(r,g,b : integer);
               procedure DeleteColor(index : integer);
               procedure ClearColors;
               procedure GetColor(index : integer;var cr : TRMColorRec);
               procedure SetColor(index : integer; cr : TRMColorRec);

               procedure GetPalette(var P : TRMPaletteBuf);
               procedure SetPalette(P : TRMPaletteBuf);
               procedure SetPaletteMode(mode : integer);
               function GetPaletteMode : integer;

               procedure GetCBPalette(var P : TRMPaletteBuf);  //get cliboard palette
               procedure SetCBPalette(P : TRMPaletteBuf);
               procedure SetCBPaletteMode(mode : integer);
               function GetCBPaletteMode : integer;

               procedure GetCBColor(index : integer;var cr : TRMColorRec);
               procedure SetCBColor(index : integer; cr : TRMColorRec);


               function GetColorCount : integer;
               procedure SetColorCount(count : integer);
               function GetRed(index : integer) : integer;
               function GetGreen(index : integer) : integer;
               function GetBlue(index : integer) : integer;
               function FindNearColorMatch(r,g,b : integer) : integer;
               function FindExactColorMatch(r,g,b : integer) : integer;

               procedure CopyPaletteToCB;
               procedure PasteFromCBToPalette;

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
                  UndoImageBuf  : TRMImageBuf;
                  CurColor      : integer; // current color

                  ImgBufWidth         : integer;
                  ImgBufHeight        : integer;

                 public

                 Constructor create;
                 procedure PutPixel(x,y,Color : Integer);
                 procedure PutPixel(x,y : integer);
                 function GetPixel(x,y : Integer) : Integer;
                 function GetPixelTColor(x,y : Integer) : TColor;

                 procedure SetCurColor(Color : integer);
                 function GetCurColor : integer;

                 procedure ClearBuf(Color : integer);
                 procedure CopyToUndoBuf;
                 procedure UnDo;
                 procedure SetWidth(width : integer);
                 procedure SetHeight(height : integer);

                 function GetWidth : integer;
                 function GetHeight : integer;

                 function GetImageBufPtr : pointer;
                 function GetUndoImageBufPtr : pointer;


  end;


  const
     PaletteModeNone = 0;
     PaletteModeMono = 1;
     PaletteModeCGA0 = 2;
     PaletteModeCGA1 = 3;
     PaletteModeEGA  = 4;
     PaletteModeVGA =  5;
     PaletteModeVGA256 = 6;
     PaletteModeAmiga2 = 7;
     PaletteModeAmiga4 = 8;
     PaletteModeAmiga8 = 9;
     PaletteModeAmiga16 = 10;
     PaletteModeAmiga32 = 11;


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
    (r:0;g:0;b:170),
    (r:0;g:170;b:0),
    (r:0;g:170;b:170),
    (r:170;g:0;b:0),
    (r:170;g:0;b:170),
    (r:170;g:85;b:0),
    (r:170;g:170;b:170),
      (r:  85;g:  85;b:  85),
      (r:  85;g:  85;b: 255),
      (r:  85;g: 255;b:  85),
      (r:  85;g: 255;b: 255),
      (r: 255;g:  85;b:  85),
      (r: 255;g:  85;b: 255),
      (r: 255;g: 255;b:  85),
      (r: 255;g: 255;b: 255),
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


    AmigaDefault32 : array[0..31] of TRMColorRec = (
              (r:0;g:85;b:170),
              (r:255;g:255;b:255),
              (r:0;g:0;b:34),
              (r:255;g:136;b:0),
              (r:0;g:0;b:255),
              (r:255;g:0;b:255),
              (r:0;g:255;b:255),
              (r:255;g:255;b:255),
              (r:102;g:34;b:0),
              (r:238;g:85;b:0),
              (r:153;g:255;b:17),
              (r:238;g:187;b:0),
              (r:85;g:85;b:255),
              (r:153;g:34;b:255),
              (r:0;g:255;b:236),
              (r:204;g:204;b:204),
              (r:0;g:0;b:0),
              (r:221;g:34;b:34),
              (r:0;g:0;b:0),
              (r:255;g:204;b:170),
              (r:68;g:68;b:68),
              (r:85;g:85;b:85),
              (r:102;g:102;b:102),
              (r:119;g:119;b:119),
              (r:136;g:136;b:136),
              (r:153;g:153;b:153),
              (r:187;g:187;b:187),
              (r:170;g:170;b:170),
              (r:204;g:204;b:204),
              (r:221;g:221;b:221),
              (r:238;g:238;b:238),
              (r:255;g:255;b:255));



var
  RMCoreBase : TRMCoreBase;

procedure GetDefaultRGBEGA64(index : integer;var cr : TRMColorREc);
procedure GetDefaultRGBVGA(index : integer;var cr : TRMColorREc);
function RGBToEGAIndex(r,g,b : integer) : integer;
function RGBToEGAIndex2(r,g,b : integer) : integer;

function EightToSixBit(EightBitValue : integer) : integer;
function SixToEightBit(SixBitValue : integer) : integer;
function EightToFourBit(EightBitValue : integer) : integer;
function FourToEightBit(FourBitValue : integer) : integer;
function TwoToEightBit(TwoBitValue : integer) : integer;
function EightToTwoBit(EightBitValue : integer) : integer;

function ColorsInPalette(pm : integer) : integer;

function CanLoadPaletteFile(PaletteMode : integer) : boolean;
function isAmigaPaletteMode(pm : integer) : boolean;
function ColIndexToHoverInfo(colIndex : integer; pm : integer) : string;


implementation

function ColorsInPalette(pm : integer) : integer;
begin
  ColorsInPalette:=0;
  Case pm of  PaletteModeMono, PaletteModeAmiga2:ColorsInPalette:=2;
              PaletteModeCGA0,PaletteModeCGA1,PaletteModeAmiga4:ColorsInPalette:=4;
              PaletteModeEGA,PaletteModeVGA,PaletteModeAmiga16:ColorsInPalette:=16;
              PaletteModeVGA256:ColorsInPalette:=256;
              PaletteModeAmiga8:ColorsInPalette:=8;
              PaletteModeAmiga32:ColorsInPalette:=32;
  end;
end;

function EightToSixBit(EightBitValue : integer) : integer;
begin
  EightToSixBit:=round((double(EightBitValue) * 63) / 255)
end;

function SixToEightBit(SixBitValue : integer) : integer;
begin
   SixToEightBit := SixBitValue * 255 div 63
end;

function EightToFourBit(EightBitValue : integer) : integer;
begin
(*  EightToFourBit:=EightBitValue SHR 4;*)   //not precise
  EightToFourBit:=round((double(EightBitValue) * 15) / 255)
end;

function FourToEightBit(FourBitValue : integer) : integer;
begin
(*   FourToEightBit := FourBitValue SHL 4;*)  // not precise
  FourToEightBit := FourBitValue * 255 div 15
end;


function EightToTwoBit(EightBitValue : integer) : integer;
begin
(*  EightToTwoBit:=EightBitValue SHR 6;*)   //not precise
  EightToTwoBit:=round((double(EightBitValue) * 3) / 255)
end;

function TwoToEightBit(TwoBitValue : integer) : integer;
begin
(*   TwoToEightBit := TwoBitValue SHL 6;*)  // not precise
  TwoToEightBit := TwoBitValue * 255 div 3;
end;

function ColIndexToHoverInfo(colIndex : integer; pm : integer) : string;
var
  ColIndexStr : string;
  cr : TRMColorRec;
begin
  ColIndexStr:='Color Index: '+IntToStr(colIndex);
  if pm = PaletteModeEGA then
  begin
//     GetRGBVGA(colIndex,cr);
     RMCoreBase.Palette.GetColor(colindex,cr);
     ColIndexstr:=ColIndexStr+#13#10+'EGA Index: '+IntToStr(RGBToEGAIndex(cr.r,cr.g,cr.b)) + #13#10+'R:'+IntToStr(cr.r)+' G:'+IntToStr(cr.g)+' B:'+IntToStr(cr.b);
  end
  else if (pm=PaletteModeVGA) or (pm=PaletteModeVGA256) then
  begin
     RMCoreBase.Palette.GetColor(colindex,cr);
     ColIndexstr:=ColIndexStr+#13#10+'R:'+IntToStr(EightToSixBit(cr.r))+' G:'+IntToStr(EightToSixBit(cr.g))+' B:'+IntToStr(EightToSixBit(cr.b));
  end
 else if isAmigaPaletteMode(pm) then
  begin
     RMCoreBase.Palette.GetColor(colindex,cr);
     ColIndexstr:=ColIndexStr+#13#10+'R:'+IntToStr(EightToFourBit(cr.r))+' G:'+IntToStr(EightToFourBit(cr.g))+' B:'+IntToStr(EightToFourBit(cr.b));
  end;
  ColIndexToHoverInfo:=ColIndexStr;
end;

function ColorDistance(col1, col2: TColor): Double;
var
  H1,S1,L1 : byte;
  H2,S2,L2 : byte;
 begin
    ColorToHLS(col1, H1, S1, L1);
    ColorToHLS(col2, H2, S2, L2);
    ColorDistance:=sqr(H1-H2) + sqr(S1-S2) + sqr(L1-L2);
end;

function CanLoadPaletteFile(PaletteMode : integer) : boolean;
begin
  CanLoadPaletteFile:=true;  //most mode can load palettes
  Case PaletteMode of PaletteModeMono,
                      PaletteModeCGA0,
                      PaletteModeCGA1: CanLoadPaletteFile:=false;   //fixed hardware
  end;
end;

function isAmigaPaletteMode(pm : integer) : boolean;
begin
  isAmigaPaletteMode:=false;
  Case pm of PaletteModeAmiga2,
             PaletteModeAmiga4,
             PaletteModeAmiga8,
             PaletteModeAmiga16,
             PaletteModeAmiga32:isAmigaPaletteMode:=true;
  end;
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
  RGBToEGAIndex:=RGBToEGAIndex2(r,g,b);     // not precise but we come up with a number
end;

function RGBToEGAIndex2(r,g,b : integer) : integer;
var
 r2,b2,g2 : integer;
 i : integer;
begin
 r2:=EightToTwoBit(r);
 g2:=EightToTwoBit(g);
 b2:=EightToTwoBit(b);

  for i:=0 to 63 do
  begin
    if (EightToTwoBit(EGADefault64[i].r) = r2) AND(EightToTwoBit(EGADefault64[i].g) = g2) AND (EightToTwoBit(EGADefault64[i].b) = b2) then
    begin
       RGBToEGAIndex2:=i;
       exit;
    end;
  end;
 // RGBToEGAIndex2:=2;
  RGBToEGAIndex2:=(r2 shl 4) + (g2 shl 2) + b2;
end;

procedure GetDefaultRGBEGA64(index : integer;var cr : TRMColorREc);
begin
  cr:=EGADefault64[index];
end;

procedure GetDefaultRGBVGA(index : integer;var cr : TRMColorREc);
begin
  cr:=VGADefault256[index];
end;

Constructor TRMPalette.create;
begin
  ColorCount:=0;
  SetPaletteMode(PaletteModeNone);
  SetCBPaletteMode(PaletteModeNone);
end;

procedure TRMPalette.GetPalette(var P : TRMPaletteBuf);
begin
  P:=PaletteBuf;
end;

procedure TRMPalette.SetPalette(P : TRMPaletteBuf);
begin
  PaletteBuf:=P;
end;

procedure TRMPalette.GetCBPalette(var P : TRMPaletteBuf);
begin
  P:=CBPaletteBuf;
end;

procedure TRMPalette.SetCBPalette(P : TRMPaletteBuf);
begin
  CBPaletteBuf:=P;
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
  // add code to remove single color from list
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

procedure TRMPalette.GetCBColor(index : integer;var cr : TRMColorRec);
begin
    if index > ColorCount then
    begin
       cr:=VGADefault256[index];
    end
    else
    begin
      cr:=CBpalettebuf[index];
    end;
end;


function TRMPalette.FindExactColorMatch(r,g,b : integer) : integer;
var
  i: integer;
begin
  FindExactColorMatch:=-1;
  for i:=0 to GetColorCount-1 do
  begin
     if (r=GetRed(i)) AND (g=GetGreen(i)) AND (b=GetBlue(i)) then
     begin
        FindExactColorMatch:=i;
        exit;
     end;
  end;
end;

function TRMPalette.FindNearColorMatch(r,g,b : integer) : integer;
var
  c1,c2 : TColor;
  gap,tgap : double;
  i,fcm,ec : integer;
begin
  ec:=FindExactColorMatch(r,g,b);
  if ec > -1 then
  begin
    FindNearColorMatch:=ec;
    exit;
  end;

  c1:=RGBToColor(r,g,b);
  gap:=10000;
  fcm:=0;
  for i:=0 to GetColorCount-1 do
  begin
     c2:=RGBToColor(GetRed(i),GetGreen(i),GetBlue(i));
     tgap:=ColorDistance(c1,c2);
     if tgap < gap then
     begin
        gap:=tgap;
        fcm:=i;
     end;
  end;
  FindNearColorMatch:=fcm;
end;

procedure TRMPalette.SetColor(index : integer;cr : TRMColorRec);
begin
  palettebuf[index]:=cr;
end;

procedure TRMPalette.SetCBColor(index : integer;cr : TRMColorRec);
begin
  CBpalettebuf[index]:=cr;
end;



procedure TRMPalette.ClearColors;
begin
  ColorCount:=0;
end;
procedure TRMPalette.SetColorCount(count : integer);
begin
  ColorCount:=count;
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

procedure TRMPalette.SetPaletteMode(mode : integer);
begin
  PaletteMode:=mode;
end;

procedure TRMPalette.SetCBPaletteMode(mode : integer);
begin
  CBPaletteMode:=mode;
end;


function TRMPalette.GetPaletteMode : integer;
begin
  GetPaletteMode:=PaletteMode;
end;

function TRMPalette.GetCBPaletteMode : integer;
begin
  GetCBPaletteMode:=CBPaletteMode;
end;


procedure TRMPalette.CopyPaletteToCB;
var
  pm : integer;
  Palette :   TRMPaletteBuf;

begin
  //we can copy all palettes to cliboard including mono and CGA. We Cannot paste to mono and CGA, we can paste mono and CGA to to other modes
  pm:=GetPaletteMode;
  GetPalette(Palette);
  SetCBPalette(Palette);
  SetCBPaletteMode(pm);
end;

procedure TRMPalette.PasteFromCBToPalette;
var
  CBpm,pm : integer;
  cbpmColors,pmColors,convertColors : integer;
  Palette :   TRMPaletteBuf;
  EGAIndex : integer;
   CR :TRMColorRec;
   i : integer;
begin
  CBpm:=GetCBPaletteMode;
  if CBpm = PaletteModeNone then exit;  //nothing in Palette cliboard
  pm:=GetPaletteMode; //get current palette mode
  if (pm=PaletteModeMono) or (pm=PaletteModeCGA0) or (pm=PaletteModeCGA1) then exit; //we can't change the palette in these modes;

  if pm=CBpm then //clipboard and current palette are the same type - this is easy , takes care ega to ega, vga to vga, and vga256 to vga256 and all amiga palettes
  begin
     GetCBPalette(Palette);
     SetPalette(Palette);
     exit;
  end;

  //only convert colors that are required, if our clibaord palette is 256 and current palette is 16 colors than we only need to copy the first 16 colors
  cbpmColors:=ColorsinPalette(CBpm);
  pmColors:=ColorsInPalette(pm);
  if pmColors < cbpmcolors then convertColors:=pmColors else convertColors:=cbpmColors;

  if pm = PaletteModeEGA then  //our current palette mode is EGA but out source is something else - we need to convert
  begin
     for i:=0 to convertColors-1 do
     begin
       GetCBColor(i,cr);
       EGAIndex:=RGBToEGAIndex(cr.r,cr.g,cr.b);  //if we can't find a match than leave current color as is
       if (EGAIndex >=0) and (EGAIndex < 64) then
       begin
         cr:=EGADefault64[EGAIndex];
         SetColor(i,cr);
      end;
    end;
  end
  else if isAmigaPaletteMode(pm) then
  begin
    for i:=0 to convertColors-1 do
    begin
      GetCBColor(i,cr);
      cr.r:=FourToEightBit(EightToFourBit(cr.r));  //we lose some quality converting to amiga palette but we can easily match up
      cr.g:=FourToEightBit(EightToFourBit(cr.g));
      cr.b:=FourToEightBit(EightToFourBit(cr.b));
      SetColor(i,cr);
    end;
  end
  else if (pm=PaletteModeVGA) or (pm=PaletteModeVGA256) then
  begin
    for i:=0 to convertColors-1 do
    begin
      GetCBColor(i,cr);
      cr.r:=SixToEightBit(EightToSixBit(cr.r));   // probably don't need to do this but in the future we might have a real 8 bit color mode
      cr.g:=SixToEightBit(EightToSixBit(cr.g));
      cr.b:=SixToEightBit(EightToSixBit(cr.b));
      SetColor(i,cr);
   end;
  end;

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
    SetWidth(256);
    SetHeight(256);
    SetCurColor(1);
    ClearBuf(0);
    CopyToUndoBuf;
 end;

procedure TRMCoreBase.SetWidth(width : integer);
begin
  ImgBufWidth:=width;
end;

procedure TRMCoreBase.SetHeight(height : integer);
begin
  ImgBufHeight:=height;
end;

function TRMCoreBase.GetWidth : integer;
begin
  GetWidth:=ImgBufWidth;
end;

function TRMCoreBase.GetHeight : integer;
begin
  GetHeight:=ImgBufHeight;
end;


function TRMCoreBase.GetImageBufPtr : pointer;
begin
  GetImageBufPtr:=@ImageBuf;
end;

function TRMCoreBase.GetUndoImageBufPtr : pointer;
begin
    GetUndoImageBufPtr:=@UndoImageBuf;
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
  if (x<0) or (x > (ImgBufWidth-1)) or (y<0) or (y > (ImgBufHeight-1))  then exit;
  ImageBuf.Pixel[x,y]:=Color;
end;

procedure TRMCoreBase.PutPixel(x,y : Integer);
begin
  if (x<0) or (x > (ImgBufWidth-1)) or (y<0) or (y > (ImgBufHeight-1))  then exit;
  ImageBuf.Pixel[x,y]:=CurColor;
end;

function TRMCoreBase.GetPixel(x,y : Integer) : Integer;
begin
  GetPixel:=ImageBuf.Pixel[x,y];
end;

function TRMCoreBase.GetPixelTColor(x,y : integer) : TColor;
var
 r,g,b : integer;
 colindex : integer;
begin
 colindex:=ImageBuf.Pixel[x,y];
 r:=Palette.GetRed(colindex);
 g:=Palette.GetGreen(colindex);
 b:=Palette.GetBlue(colindex);
 GetPixelTColor:=RGBToColor(r,g,b);
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

