unit spriteimport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, ExtDlgs,Clipbrd,LCLIntf,LCLType,rwpng,rmcore,rmthumb;

type

  { TSpriteImportForm }

  TSpriteImportForm = class(TForm)
    InfoLabel: TLabel;
    OpenDialog1: TOpenDialog;
    ImportFromClipboard: TButton;
    SpriteSizeComboBox: TComboBox;
    NewPaletteComboBox: TComboBox;
    PaletteComboBox: TComboBox;
    SpriteSizeLabel: TLabel;
    OpenSpriteSheet: TButton;
    SpriteImage: TImage;
    SourceImage: TImage;
    TopPanel: TPanel;
    ScrollBox1: TScrollBox;
    ZoomTrackBar: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure ImportFromClipboardClick(Sender: TObject);
    procedure NewPaletteComboBoxChange(Sender: TObject);
    procedure OpenSpriteSheetClick(Sender: TObject);
    procedure PaletteComboBoxChange(Sender: TObject);
    procedure SourceImageClick(Sender: TObject);
    procedure SourceImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpriteSizeComboBoxChange(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);
  private

  public
       LastX,LastY : integer;
       ClipX : integer;
       ClipY : integer;
       ClipWidth : integer;
       ClipHeight : integer;
       SpriteSize  : integer;
       SpriteWidth : integer;
       SpriteHeight: integer;
       ZoomSize    : integer;
//       RX,RY       : integer;
       TopColorCount : integer;
       TopColors : TRMPaletteBuf;

       NewPaletteFrom : integer;
       NewPaletteMode    : integer;

       EasyPNG : TEasyPNG;

       procedure DrawXorBox(x,y : integer);
       procedure UpdateSpriteValues;
       procedure UpdateInfo;
       procedure ZoomToReal(zx,zy : integer;var rx,ry : integer);
  end;

var
  SpriteImportForm: TSpriteImportForm;

implementation

{$R *.lfm}

{ TSpriteImportForm }

procedure TSpriteImportForm.OpenSpriteSheetClick(Sender: TObject);
var
  pwidth,pheight : integer;
begin
  OpenDialog1.Filter := 'PNG|*.png|BMP|*.bmp|JPG|*.jpg|ICO|*.ico|All Files|*.*' ;
  if OpenDialog1.Execute then
  begin
      EasyPNG.LoadFromFile(OpenDialog1.FileName);
      lastx:=-1;
      lasty:=-1;
      pwidth:=EasyPNG.Picture1.Width;
      pheight:=EasyPNG.Picture1.Height;
      SourceImage.AutoSize:=true;
      SourceImage.Picture.Bitmap.SetSize(1,1);
      SourceImage.Picture.Bitmap.SetSize(pwidth*ZoomSize,pheight*ZoomSize);
      SourceImage.Canvas.CopyRect(Rect(0,0,pwidth*ZoomSize,pheight*ZoomSize),EasyPNG.Picture1.Bitmap.Canvas,Rect(0,0,pwidth,pheight));
      SourceImage.AutoSize:=false;

      EasyPNG.BuildHashes(0,0,pwidth-1,pheight-1);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
      TopColorCount:=EasyPNG.BuildTopColors(TopColors);
  end;
end;

procedure TSpriteImportForm.ImportFromClipboardClick(Sender: TObject);
var
  pwidth,pheight : integer;
begin
  if Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
  begin
   lastx:=-1;
   lasty:=-1;

   EasyPNG.Picture1.Bitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));
   pwidth:=EasyPNG.Picture1.Width;
   pheight:=EasyPNG.Picture1.Height;
   SourceImage.AutoSize:=true;
   SourceImage.Picture.Bitmap.SetSize(1,1);
   SourceImage.Picture.Bitmap.SetSize(pwidth*ZoomSize,pheight*ZoomSize);
   SourceImage.Canvas.CopyRect(Rect(0,0,pwidth*ZoomSize,pheight*ZoomSize),EasyPNG.Picture1.Bitmap.Canvas,Rect(0,0,pwidth,pheight));
   SourceImage.AutoSize:=false;
   EasyPNG.BuildHashes(0,0,pwidth-1,pheight-1);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
   TopColorCount:=EasyPNG.BuildTopColors(TopColors);
  end;
end;

procedure TSpriteImportForm.PaletteComboBoxChange(Sender: TObject);
var
  pwidth,pheight : integer;
begin
  NewPaletteMode:=PaletteComboBox.ItemIndex;
  if NewPaletteFrom = 1 then
  begin
     pwidth:=EasyPNG.Picture1.Width;
     pheight:=EasyPNG.Picture1.Height;

     EasyPNG.BuildHashes(0,0,pwidth-1,pheight-1);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
     TopColorCount:=EasyPNG.BuildTopColors(TopColors);
  end;
end;

procedure TSpriteImportForm.NewPaletteComboBoxChange(Sender: TObject);
var
  pwidth,pheight : integer;
begin
  NewPaletteFrom:=NewPaletteComboBox.ItemIndex;
  if NewPaletteFrom = 1 then
  begin
     pwidth:=EasyPNG.Picture1.Width;
     pheight:=EasyPNG.Picture1.Height;

     EasyPNG.BuildHashes(0,0,pwidth-1,pheight-1);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
     TopColorCount:=EasyPNG.BuildTopColors(TopColors);
  end;
end;


procedure TSpriteImportForm.SourceImageClick(Sender: TObject);
var
  OurPalette    : TRMPaletteBuf;
  ClipTopColors : TRMPaletteBuf;
  ColorCount  : integer;
  PaletteMode : integer;
  ImageCount  : integer;
  PixelColor  : TColor;
  ci          : integer;
  i,j         : integer;
  ClipColorCount : integer;
  TempSprite     : TBitMap;
begin
  TempSprite:=TBitMap.Create;
  TempSprite.SetSize(SpriteWidth,SpriteHeight);
  ZoomToReal(LastX,LastY,ClipX,ClipY);

  ColorCount:=16;

  if NewPaletteMode = 0 then
  begin
     PaletteMode:=PaletteModeMono;
     ColorCount:=2;
  end
  else if NewPaletteMode = 1 then
  begin
    PaletteMode:=PaletteModeCGA0;
    ColorCount:=4;
  end
  else if NewPaletteMode = 2 then
  begin
    PaletteMode:=PaletteModeCGA1;
    ColorCount:=4;
  end
  else if NewPaletteMode = 3 then
  begin
     PaletteMode:=PaletteModeEGA;
  end
  else if NewPaletteMode = 4 then
  begin
    PaletteMode:=PaletteModeVGA;
  end
  else if NewPaletteMode = 5 then
  begin
    PaletteMode:=PaletteModeVGA256;
    ColorCount:=256;
  end
  else if NewPaletteMode = 6 then
  begin
    PaletteMode:=PaletteModeXGA;
  end
  else if NewPaletteMode = 7 then
  begin
    PaletteMode:=PaletteModeXGA256;
    ColorCount:=256;
  end
  else if NewPaletteMode = 8 then
  begin
     PaletteMode:=PaletteModeAmiga32;
     ColorCount:=32;
   end
  else if NewPaletteMode = 9 then
  begin
    PaletteMode:=PaletteModeAmiga16;
    ColorCount:=16;
  end
  else if NewPaletteMode = 10 then
  begin
    PaletteMode:=PaletteModeAmiga8;
    ColorCount:=8;
  end
  else if NewPaletteMode = 11 then
  begin
    PaletteMode:=PaletteModeAmiga4;
    ColorCount:=4;
  end
  else if NewPaletteMode = 12 then
  begin
    PaletteMode:=PaletteModeAmiga2;
    ColorCount:=2;
  end;

  LoadPaletteBuf(OurPalette,PaletteMode);

  ImageThumbBase.AddImportImage(SpriteWidth,SpriteHeight);
  ImageCount:=ImageThumbBase.GetCount;


  if NewPaletteFrom = 0 then  //clip area
  begin
    EasyPNG.BuildHashes(ClipX,ClipY,ClipX+SpriteWidth-1,ClipY+SpriteHeight-1);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
    ClipColorCount:=EasyPNG.BuildTopColors(ClipTopColors);
    EasyPNG.CreatePaletteUsingBasePalette(OurPalette,PaletteMode,ColorCount,ClipTopColors,ClipColorCount);
  end
  else if NewPaletteFrom = 1 then  //from entire image
  begin
     EasyPNG.CreatePaletteUsingBasePalette(OurPalette,PaletteMode,ColorCount,TopColors,TopColorCount);
  end
  else if NewPaletteFrom = 2 then  //get current sprite palette
  begin
     RMCoreBase.Palette.GetPalette(OurPalette);
     PaletteMode:=RMCoreBase.Palette.GetPaletteMode;
     ColorCount:=RMCoreBase.Palette.GetColorCount;
  end;

  ImageThumbBase.SetPalette(ImageCount-1,OurPalette);
  ImageThumbBase.SetPaletteMode(ImageCount-1,PaletteMode);
  ImageThumbBase.SetColorCount(ImageCount-1,ColorCount);

  //SpriteImage.Picture.Bitmap.SetSize(SpriteWidth,SpriteHeight);

  for j:=0 to SpriteHeight-1 do
  begin
   for i:=0 to Spritewidth-1 do
   begin
     PixelColor:=EasyPNG.Picture1.Bitmap.Canvas.Pixels[ClipX+i,ClipY+j];
     ci:=FindPaletteIndex(Red(PixelColor),Green(PixelColor),Blue(PixelColor),OurPalette,PaletteMode,ColorCount);
     ImageThumbBase.PutPixel(ImageCount-1,i,j,ci);
     TempSprite.Canvas.Pixels[i,j]:=RGBToColor(OurPalette[ci].r,OurPalette[ci].g,OurPalette[ci].b);
   end;
 end;

 SpriteImage.Canvas.CopyRect(Rect(0,0,128,128),TempSprite.Canvas,Rect(0,0,TempSprite.Width,TempSprite.Height));
 TempSprite.Free;
end;

procedure TSpriteImportForm.DrawXorBox(x,y : integer);
var
  TempX,TempY : integer;
  TempX2,TempY2 : integer;

begin
  if (lastx<>x) or (lasty<>y) then
  begin
      if (lastx<>-1) and (lasty<>-1) then
      begin
          //clear last draw
          //SourceImage.Canvas.Brush.Style := bsClear;
          SourceImage.Canvas.Brush.Style:=bsClear;
          SourceImage.Canvas.Pen.Style := psSolid;
          SourceImage.Canvas.Pen.Color := clYellow;
          SourceImage.Canvas.Pen.Mode := pmXor;
          TempX:=(LastX Div ZoomSize) * ZoomSize-ClipWidth div 2;
          TempY:=(LastY Div ZoomSize) * ZoomSize-ClipHeight div 2;

          TempX2:=(LastX Div ZoomSize) * ZoomSize+ClipWidth div 2-1;
          TempY2:=(LastY Div ZoomSize) * ZoomSize+ClipHeight div 2-1;

          SourceImage.Canvas.Rectangle(TempX,TempY,TempX2,TempY2);
          SourceImage.Canvas.Rectangle(TempX+1,TempY+1,TempX2-1,TempY2-1);

      end;
  end;
  lastx:=x;
  lasty:=y;

  //SourceImage.Canvas.Brush.Style := bsClear;
  SourceImage.Canvas.Brush.Style:=bsClear;
  SourceImage.Canvas.Pen.Style := psSolid;
  SourceImage.Canvas.Pen.Color := clYellow;
  SourceImage.Canvas.Pen.Mode := pmXor;
//  SourceImage.picture.bitmap.Canvas.Rectangle(x-32,y-32,lastx+31,lasty+31);
  TempX:=(LastX Div ZoomSize) * ZoomSize-ClipWidth div 2;
  TempY:=(LastY Div ZoomSize) * ZoomSize-ClipHeight div 2;

  TempX2:=(LastX Div ZoomSize) * ZoomSize+ClipWidth div 2-1;
  TempY2:=(LastY Div ZoomSize) * ZoomSize+ClipHeight div 2-1;

  SourceImage.Canvas.Rectangle(TempX,TempY,TempX2,TempY2);
  SourceImage.Canvas.Rectangle(TempX+1,TempY+1,TempX2-1,TempY2-1);

end;

procedure TSpriteImportForm.SourceImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  DrawXorBox(x,y);
  UpdateInfo;
end;

procedure TSpriteImportForm.UpdateSpriteValues;
begin
  Case SpriteSize of 0:begin
                        SpriteWidth:=8;
                        SpriteHeight:=8;
                       end;
                     1:begin
                        SpriteWidth:=16;
                        SpriteHeight:=16;
                       end;
                     2:begin
                        SpriteWidth:=32;
                        SpriteHeight:=32;
                       end;
                     3:begin
                        SpriteWidth:=64;
                        SpriteHeight:=64;
                       end;
                     4:begin
                        SpriteWidth:=128;
                        SpriteHeight:=128;
                       end;
                     5:begin
                        SpriteWidth:=256;
                        SpriteHeight:=256;
                       end;

  end;
  ClipWidth:=ZoomSize*SpriteWidth;
  ClipHeight:=ZoomSize*SpriteHeight;
end;

procedure TSpriteImportForm.SpriteSizeComboBoxChange(Sender: TObject);
begin
  DrawXorBox(LastX,LastY); //erase it
  SpriteSize:=SpriteSizeComboBox.ItemIndex;
  UpdateSpriteValues;
  DrawXorBox(LastX,LastY); //draw with new size
end;

procedure TSpriteImportForm.ZoomTrackBarChange(Sender: TObject);
var
  pwidth,pheight : integer;
begin
  ZoomSize:=ZoomtrackBar.Position;
  UpdateSpriteValues;

  lastx:=-1;
  lasty:=-1;
  pwidth:=EasyPNG.Picture1.Width;
  pheight:=EasyPNG.Picture1.Height;
  SourceImage.AutoSize:=true;
  SourceImage.Picture.Bitmap.SetSize(1,1);
  SourceImage.Picture.Bitmap.SetSize(pwidth*ZoomSize,pheight*ZoomSize);
  SourceImage.Canvas.CopyRect(Rect(0,0,pwidth*ZoomSize,pheight*ZoomSize),EasyPNG.Picture1.Bitmap.Canvas,Rect(0,0,pwidth,pheight));
  SourceImage.AutoSize:=false;
end;

procedure TSpriteImportForm.FormCreate(Sender: TObject);
begin
  EasyPng:=TEasyPNG.Create;
  lastx:=-1;
  lasty:=-1;

  SpriteSize:=2;
  SpriteWidth:=32;
  SpriteHeight:=32;

  ZoomSize:=5;
  ClipWidth:=ZoomSize*SpriteWidth;
  ClipHeight:=ZoomSize*SpriteHeight;

  NewPaletteFrom:=1;   //new palette from entire image
  NewPaletteMode:=4;   //vga
end;





procedure TSpriteImportForm.ZoomToReal(zx,zy : integer;var rx,ry : integer);
begin
  rx:=(zx Div ZoomSize) - (SpriteWidth div 2);
  ry:=(zy Div ZoomSize) - (SpriteHeight div 2);
end;

procedure TSpriteImportForm.UpdateInfo;
var
   TempX,TempY : integer;
   TempX2,TempY2 : integer;

begin
//  TempX:=(LastX Div ZoomSize) - (SpriteWidth div 2);
//  TempY:=(LastY Div ZoomSize) - (SpriteHeight div 2);


  ZoomToReal(LastX,LastY,TempX,TempY);
  TempX2:=TempX+SpriteWidth-1;
  TempY2:=TempY+SpriteHeight-1;

  infolabel.Caption:='X = '+IntToStr(TempX)+' Y = '+IntToStr(TempY)+' X2 = '+IntToStr(TempX2)+' Y2 = '+IntToStr(TempY2);
end;

end.

