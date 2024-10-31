unit spriteimport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, ExtDlgs,Clipbrd,LCLIntf,LCLType, SpinEx,rwpng,rmcore,rmthumb;

type

  { TSpriteImportForm }

  TSpriteImportForm = class(TForm)
    CheckBoxDisplayGrid: TCheckBox;
    CheckBoxSnapToGrid: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    ImportFromClipboard: TButton;
    SpinEditWidth: TSpinEditEx;
    SpinEditHeight: TSpinEditEx;
    SpriteSheetPaintBox: TPaintBox;
    SpriteSizeComboBox: TComboBox;
    NewPaletteComboBox: TComboBox;
    PaletteComboBox: TComboBox;
    SpriteSizeLabel: TLabel;
    OpenSpriteSheet: TButton;
    SpriteImage: TImage;
    StatusBar1: TStatusBar;
    TopPanel: TPanel;
    SpriteSheetScrollBox: TScrollBox;
    ZoomTrackBar: TTrackBar;
    procedure CheckBoxDisplayGridChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImportFromClipboardClick(Sender: TObject);
    procedure NewPaletteComboBoxChange(Sender: TObject);
    procedure OpenSpriteSheetClick(Sender: TObject);
    procedure SpinEditWidthHeightChange(Sender: TObject);
    procedure SpriteSheetPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpriteSheetPaintBoxPaint(Sender: TObject);
    procedure PaletteComboBoxChange(Sender: TObject);
    procedure SpriteSheetPaintBoxClick(Sender: TObject);
    procedure SpriteSizeComboBoxChange(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);
  private

  public
       SourceImage : TBitMap;
       BoxX,BoxY,BoxX2,BoxY2 : integer;
       LastX,LastY : integer;
       ClipX : integer;
       ClipY : integer;
       ClipWidth : integer;
       ClipHeight : integer;
       SpriteSize  : integer;
       SpriteWidth : integer;
       SpriteHeight: integer;
       ZoomSize    : integer;

       TopColorCount : integer;
       TopColors : TRMPaletteBuf;

       NewPaletteFrom : integer;
       NewPaletteMode    : integer;

       EasyPNG : TEasyPNG;

       procedure DrawSpriteSelectBox;
       procedure DrawGrid;
       procedure UpdateSpriteValues;
       procedure UpdateInfo;
       function ZoomXToReal(zx : integer) : integer;
       function ZoomYToReal(zy : integer) : integer;

  end;

var
  SpriteImportForm: TSpriteImportForm;

implementation
  uses rmmain,mapeditor;  //avoid circular refernce by importing in implmentation section
{$R *.lfm}

{ TSpriteImportForm }

procedure TSpriteImportForm.OpenSpriteSheetClick(Sender: TObject);
var
  SourceImageWidth,SourceImageHeight : integer;
begin
  OpenDialog1.Filter := 'PNG|*.png|BMP|*.bmp|JPG|*.jpg|ICO|*.ico|All Files|*.*' ;
  if OpenDialog1.Execute then
  begin
      EasyPNG.LoadFromFile(OpenDialog1.FileName);
      lastx:=-1;
      lasty:=-1;
      SourceImageWidth:=EasyPNG.Picture1.Width;
      SourceImageHeight:=EasyPNG.Picture1.Height;
//      SourceImage.AutoSize:=true;
//      SourceImage.Picture.Bitmap.SetSize(1,1);
        SourceImage.Clear;
        SourceImage.SetSize(SourceImageWidth*ZoomSize,SourceImageHeight*ZoomSize);
//      SourceImage.Canvas.CopyRect(Rect(0,0,SourceImageWidth*ZoomSize,pheight*ZoomSize),EasyPNG.Picture1.Bitmap.Canvas,Rect(0,0,SourceImageWidth,pheight));
      SourceImage.Canvas.CopyRect(Rect(0,0,SourceImageWidth,SourceImageHeight),EasyPNG.Picture1.Bitmap.Canvas,Rect(0,0,SourceImageWidth,SourceImageHeight));
//      SourceImage.AutoSize:=false;
      SpriteSheetPaintBox.Width:=SourceImageWidth*ZoomSize;
      SpriteSheetPaintBox.Height:=SourceImageHeight*ZoomSize;
      SpriteSheetPaintBox.Invalidate;
      EasyPNG.BuildHashes(0,0,SourceImageWidth-1,SourceImageHeight-1);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
      TopColorCount:=EasyPNG.BuildTopColors(TopColors);
  end;
end;

procedure TSpriteImportForm.SpinEditWidthHeightChange(Sender: TObject);
begin
  if SpriteSize = 6 then SpriteSizeComboBoxChange(Sender);
end;

procedure TSpriteImportForm.SpriteSheetPaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin

  if CheckBoxSnapToGrid.Checked then
  begin
    BoxX:=(X div (spritewidth*zoomsize)) * (spritewidth*zoomsize);
    BoxY:=(Y div (spriteheight*zoomsize)) * (spriteheight*zoomsize);
    BoxX2:=BoxX+(spritewidth*zoomsize);
    BoxY2:=BoxY+(spriteheight*zoomsize);
  end
  else
  begin
(*    BoxX:=(X Div ZoomSize) * ZoomSize-ClipWidth div 2;
    BoxY:=(Y Div ZoomSize) * ZoomSize-ClipHeight div 2;
    BoxX2:=(X Div ZoomSize) * ZoomSize+ClipWidth div 2-1;
    BoxY2:=(Y Div ZoomSize) * ZoomSize+ClipHeight div 2-1;*)
    BoxX:=(X div zoomsize)*zoomsize;
    BoxY:=(Y div zoomsize)*zoomsize;
    BoxX2:=BoxX+spritewidth*zoomsize;
    BoxY2:=BoxY+spriteheight*zoomsize;

  end;
 UpdateInfo;
 SpriteSheetPaintBox.Invalidate;
end;

procedure TSpriteImportForm.SpriteSheetPaintBoxPaint(Sender: TObject);
begin
  SpriteSheetPaintBox.Canvas.CopyRect(Rect(0,0,SourceImage.width*ZoomSize,SourceImage.Height*ZoomSize),SourceImage.Canvas,Rect(0,0,SourceImage.Width,SourceImage.Height));
  if CheckBoxDisplayGrid.Checked then DrawGrid;
  DrawSpriteSelectBox;
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
   pWidth:=EasyPNG.Picture1.Width;
   pheight:=EasyPNG.Picture1.Height;
//   SourceImage.AutoSize:=true;
//   SourceImage.SetSize(1,1);
   SourceImage.Clear;
   SourceImage.SetSize(pWidth*zoomsize,pheight*zoomsize);
   SpriteSheetPaintBox.Width:=pWidth*ZoomSize;
   SpriteSheetPaintBox.Height:=pHeight*ZoomSize;
   SourceImage.Canvas.CopyRect(Rect(0,0,pWidth,pheight),EasyPNG.Picture1.Bitmap.Canvas,Rect(0,0,pWidth,pheight));
//   SourceImage.AutoSize:=false;
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
     pWidth:=EasyPNG.Picture1.Width;
     pheight:=EasyPNG.Picture1.Height;

     EasyPNG.BuildHashes(0,0,pWidth-1,pheight-1);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
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
     pWidth:=EasyPNG.Picture1.Width;
     pheight:=EasyPNG.Picture1.Height;

     EasyPNG.BuildHashes(0,0,pwidth-1,pheight-1);        //we only need the palette colors from the area we are loading - image can have more colors somewhere else
     TopColorCount:=EasyPNG.BuildTopColors(TopColors);
  end;
end;


procedure TSpriteImportForm.SpriteSheetPaintBoxClick(Sender: TObject);
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
  ClipX:=ZoomXToReal(BoxX);
  ClipY:=ZoomYToReal(BoxY);

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

 //inject into Sprite editor and Map Editor
 SpriteImage.Canvas.CopyRect(Rect(0,0,128,128),TempSprite.Canvas,Rect(0,0,TempSprite.Width,TempSprite.Height));
 TempSprite.Free;
 RMMainForm.UpdateImportedImage;
 MapEdit.UpdateTileView;
end;

procedure TSpriteImportForm.DrawSpriteSelectBox;
begin
  SpriteSheetPaintBox.Canvas.Brush.Style:=bsClear;
  SpriteSheetPaintBox.Canvas.Pen.Style := psSolid;
  SpriteSheetPaintBox.Canvas.Pen.Color := clYellow;
  SpriteSheetPaintBox.Canvas.Pen.Mode :=pmCopy;
  SpriteSheetPaintBox.Canvas.Pen.Width :=3;
  SpriteSheetPaintBox.Canvas.Rectangle(BoxX,BoXY,BoxX2,BoxY2);
end;

Procedure TSpriteImportForm.DrawGrid;
var
  x,y : integer;
begin
  SpriteSheetPaintBox.Canvas.Brush.Style:=bsClear;
  SpriteSheetPaintBox.Canvas.Pen.Style := psSolid;
  SpriteSheetPaintBox.Canvas.Pen.Mode :=pmXor;
  SpriteSheetPaintBox.Canvas.Pen.Width :=1;
  SpriteSheetPaintBox.Canvas.Pen.Color := clWhite;

  x:=0;
  While x < SpriteSheetPaintBox.Width do
  begin
    SpriteSheetPaintBox.Canvas.Line(x,0,x,SpriteSheetPaintBox.Height-1);
    inc(x,ClipWidth);
  end;
  y:=0;
  While y < SpriteSheetPaintBox.Height do
  begin
    SpriteSheetPaintBox.Canvas.Line(0,y,SpriteSheetPaintBox.Width-1,y);
    inc(y,ClipHeight);
  end;

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
                     6:begin
                        SpriteWidth:=SpinEditWidth.Value;
                        SpriteHeight:=SpinEditHeight.Value;
                       end;

  end;
  ClipWidth:=ZoomSize*SpriteWidth;
  ClipHeight:=ZoomSize*SpriteHeight;
end;

procedure TSpriteImportForm.SpriteSizeComboBoxChange(Sender: TObject);
begin
  SpriteSize:=SpriteSizeComboBox.ItemIndex;
  UpdateSpriteValues;
  SpriteSheetPaintBox.Invalidate;
end;

procedure TSpriteImportForm.ZoomTrackBarChange(Sender: TObject);
var
  pwidth,pheight : integer;
begin
  ZoomSize:=ZoomtrackBar.Position;
  UpdateSpriteValues;

  lastx:=-1;
  lasty:=-1;
  pWidth:=EasyPNG.Picture1.Width;
  pheight:=EasyPNG.Picture1.Height;
//  SourceImage.AutoSize:=true;
//  SourceImage.Picture.Bitmap.SetSize(1,1);
//  SourceImage.Picture.Bitmap.SetSize(pwidth*ZoomSize,pheight*ZoomSize);
//  SourceImage.Canvas.CopyRect(Rect(0,0,pwidth*ZoomSize,pheight*ZoomSize),EasyPNG.Picture1.Bitmap.Canvas,Rect(0,0,pwidth,pheight));
//  SourceImage.AutoSize:=false;
//SpriteSheetPaintBox.Width:=0;
//SpriteSheetPaintBox.Height:=0;
//SpriteSheetPaintBox.Invalidate;
SpriteSheetPaintBox.Width:=pWidth*ZoomSize;
SpriteSheetPaintBox.Height:=pHeight*ZoomSize;

SpriteSheetPaintBox.Invalidate;
end;

procedure TSpriteImportForm.FormCreate(Sender: TObject);
begin
  SourceImage:=TBitMap.Create;
  EasyPng:=TEasyPNG.Create;
  lastx:=-1;
  lasty:=-1;

  SpriteSize:=2;
  SpriteWidth:=32;
  SpriteHeight:=32;

  ZoomSize:=5;
  ClipWidth:=ZoomSize*SpriteWidth;
  ClipHeight:=ZoomSize*SpriteHeight;

  NewPaletteFrom:=0;   //new palette from clip area
  NewPaletteMode:=7;   //xga 256
  PaletteComboBox.ItemIndex:=NewPaletteMode;
  NewPaletteComboBox.ItemIndex:=NewPaletteFrom;
end;

procedure TSpriteImportForm.CheckBoxDisplayGridChange(Sender: TObject);
begin
  SpriteSheetPaintBox.Invalidate;
end;


function TSpriteImportForm.ZoomXToReal(zx : integer) : integer;
begin
      result:=zx Div ZoomSize;
(*
  if CheckBoxSnapToGrid.Checked then
  begin
    result:=zx Div ZoomSize;
 end
  else
  begin
    result:=(zx Div ZoomSize) - (SpriteWidth div 2);
  end;
  *)
end;

function TSpriteImportForm.ZoomYToReal(zy : integer) : integer;
begin
 result:=zy Div ZoomSize;
(*
 if CheckBoxSnapToGrid.Checked then
  begin
    result:=zy Div ZoomSize;
 end
  else
  begin
    result:=(zy Div ZoomSize) - (SpriteHeight div 2);
  end;
  *)
end;

procedure TSpriteImportForm.UpdateInfo;
var
   TempX,TempY : integer;
   TempX2,TempY2 : integer;
begin
  TempX:=ZoomXToReal(BoxX);
  TempY:=ZoomYToReal(BoxY);

  TempX2:=TempX+SpriteWidth-1;
  TempY2:=TempY+SpriteHeight-1;

  StatusBar1.SimpleText:='X = '+IntToStr(TempX)+' Y = '+IntToStr(TempY)+' X2 = '+IntToStr(TempX2)+' Y2 = '+IntToStr(TempY2);
end;

end.

