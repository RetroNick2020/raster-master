unit spriteimport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, ExtDlgs, Menus, Clipbrd, LCLIntf, LCLType, SpinEx, rwpng, rmcore, rmthumb;

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
    PalettePaintBox: TPaintBox;
    StatusBar1: TStatusBar;
    TopPanel: TPanel;
    SpriteSheetScrollBox: TScrollBox;
    ZoomTrackBar: TTrackBar;

    MainMenu1: TMainMenu;
    MenuFile: TMenuItem;
    MnuOpenSheet: TMenuItem;
    MnuImportClip: TMenuItem;
    MnuSep1: TMenuItem;
    MnuClose: TMenuItem;
    MenuView: TMenuItem;
    MnuDisplayGrid: TMenuItem;
    MnuSnapGrid: TMenuItem;
    MnuSep2: TMenuItem;
    MnuZoomIn: TMenuItem;
    MnuZoomOut: TMenuItem;
    MenuImport: TMenuItem;
    MnuImportSprite: TMenuItem;

    procedure CheckBoxDisplayGridChange(Sender: TObject);
    procedure CheckBoxSnapToGridChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImportFromClipboardClick(Sender: TObject);
    procedure MnuCloseClick(Sender: TObject);
    procedure MnuDisplayGridClick(Sender: TObject);
    procedure MnuSnapGridClick(Sender: TObject);
    procedure MnuZoomInClick(Sender: TObject);
    procedure MnuZoomOutClick(Sender: TObject);
    procedure NewPaletteComboBoxChange(Sender: TObject);
    procedure OpenSpriteSheetClick(Sender: TObject);
    procedure SpinEditWidthHeightChange(Sender: TObject);
    procedure SpriteSheetPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpriteSheetPaintBoxPaint(Sender: TObject);
    procedure PaletteComboBoxChange(Sender: TObject);
    procedure PalettePaintBoxPaint(Sender: TObject);
    procedure SpriteSheetPaintBoxClick(Sender: TObject);
    procedure SpriteSizeComboBoxChange(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);
    procedure SpriteSheetScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
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

       DisplayPalette : TRMPaletteBuf;
       DisplayPaletteCount : integer;
       procedure DrawSpriteSelectBox;
       procedure DrawGrid;
       procedure UpdateSpriteValues;
       procedure UpdateInfo;
       procedure UpdateStatusBar;
       procedure BuildDisplayPalette;
       procedure ApplyZoom(newZoom : integer; useAnchor : boolean; anchorX : integer = 0; anchorY : integer = 0);
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
      BuildDisplayPalette;
      UpdateStatusBar;
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
    //free mode - center the selection box on the mouse pointer,
    //snapped to whole image pixels
    BoxX:=((X - (spritewidth*zoomsize) div 2) div zoomsize) * zoomsize;
    BoxY:=((Y - (spriteheight*zoomsize) div 2) div zoomsize) * zoomsize;
    if BoxX < 0 then BoxX:=0;
    if BoxY < 0 then BoxY:=0;
    //keep the box inside the sheet on the right/bottom edges
    if BoxX + spritewidth*zoomsize > SpriteSheetPaintBox.Width then
      BoxX:=((SpriteSheetPaintBox.Width - spritewidth*zoomsize) div zoomsize) * zoomsize;
    if BoxY + spriteheight*zoomsize > SpriteSheetPaintBox.Height then
      BoxY:=((SpriteSheetPaintBox.Height - spriteheight*zoomsize) div zoomsize) * zoomsize;
    if BoxX < 0 then BoxX:=0;
    if BoxY < 0 then BoxY:=0;
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
   BuildDisplayPalette;
   UpdateStatusBar;
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
     BuildDisplayPalette;
  end;
  UpdateStatusBar;
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
     BuildDisplayPalette;
  end;
  UpdateStatusBar;
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

procedure TSpriteImportForm.PalettePaintBoxPaint(Sender: TObject);
var
  i, x, cellW, count : integer;
begin
  PalettePaintBox.Canvas.Brush.Color:=clBtnFace;
  PalettePaintBox.Canvas.FillRect(0, 0, PalettePaintBox.Width, PalettePaintBox.Height);

  count:=DisplayPaletteCount;
  if count <= 0 then exit;
  if count > 256 then count:=256;

  cellW:=PalettePaintBox.Width div count;
  if cellW < 2 then cellW:=2;

  for i:=0 to count-1 do
  begin
    x:=i * cellW;
    if x >= PalettePaintBox.Width then break;
    PalettePaintBox.Canvas.Brush.Color:=RGBToColor(
      DisplayPalette[i].r, DisplayPalette[i].g, DisplayPalette[i].b);
    PalettePaintBox.Canvas.FillRect(x, 0, x + cellW, PalettePaintBox.Height);
  end;
end;

//builds the palette preview that matches what the import will actually use
//mirrors the palette construction logic in SpriteSheetPaintBoxClick
procedure TSpriteImportForm.BuildDisplayPalette;
var
  PaletteMode, ColorCount : integer;
begin
  ColorCount:=16;
  case NewPaletteMode of
    0: begin PaletteMode:=PaletteModeMono;     ColorCount:=2;   end;
    1: begin PaletteMode:=PaletteModeCGA0;     ColorCount:=4;   end;
    2: begin PaletteMode:=PaletteModeCGA1;     ColorCount:=4;   end;
    3: begin PaletteMode:=PaletteModeEGA;      ColorCount:=16;  end;
    4: begin PaletteMode:=PaletteModeVGA;      ColorCount:=16;  end;
    5: begin PaletteMode:=PaletteModeVGA256;   ColorCount:=256; end;
    6: begin PaletteMode:=PaletteModeXGA;      ColorCount:=16;  end;
    7: begin PaletteMode:=PaletteModeXGA256;   ColorCount:=256; end;
    8: begin PaletteMode:=PaletteModeAmiga32;  ColorCount:=32;  end;
    9: begin PaletteMode:=PaletteModeAmiga16;  ColorCount:=16;  end;
   10: begin PaletteMode:=PaletteModeAmiga8;   ColorCount:=8;   end;
   11: begin PaletteMode:=PaletteModeAmiga4;   ColorCount:=4;   end;
   12: begin PaletteMode:=PaletteModeAmiga2;   ColorCount:=2;   end;
  else
    PaletteMode:=PaletteModeVGA;
    ColorCount:=16;
  end;

  //start with the base palette for the selected mode
  LoadPaletteBuf(DisplayPalette, PaletteMode);
  DisplayPaletteCount:=ColorCount;

  case NewPaletteFrom of
    0: //from clip area - can only show the result after a clip area is known
       //for preview, use the full image top colors if available
       begin
         if TopColorCount > 0 then
           EasyPNG.CreatePaletteUsingBasePalette(
             DisplayPalette, PaletteMode, ColorCount, TopColors, TopColorCount);
       end;
    1: //from entire image
       begin
         if TopColorCount > 0 then
           EasyPNG.CreatePaletteUsingBasePalette(
             DisplayPalette, PaletteMode, ColorCount, TopColors, TopColorCount);
       end;
    2: //use current sprite palette
       begin
         RMCoreBase.Palette.GetPalette(DisplayPalette);
         DisplayPaletteCount:=RMCoreBase.Palette.GetColorCount;
       end;
  end;

  PalettePaintBox.Invalidate;
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
  UpdateStatusBar;
  SpriteSheetPaintBox.Invalidate;
end;

procedure TSpriteImportForm.ZoomTrackBarChange(Sender: TObject);
begin
  ApplyZoom(ZoomTrackBar.Position, False);
end;

procedure TSpriteImportForm.ApplyZoom(newZoom : integer; useAnchor : boolean; anchorX : integer; anchorY : integer);
var
  oldZoom : integer;
  pixX, pixY : double;
  newScrollX, newScrollY : integer;
  pWidth, pHeight : integer;
begin
  if newZoom < ZoomTrackBar.Min then newZoom:=ZoomTrackBar.Min;
  if newZoom > ZoomTrackBar.Max then newZoom:=ZoomTrackBar.Max;

  oldZoom:=ZoomSize;

  //remember which image pixel sits under the anchor point
  pixX:=0; pixY:=0;
  if useAnchor and (oldZoom > 0) then
  begin
    pixX:=(SpriteSheetScrollBox.HorzScrollBar.Position + anchorX) / oldZoom;
    pixY:=(SpriteSheetScrollBox.VertScrollBar.Position + anchorY) / oldZoom;
  end;

  //apply the new zoom through the trackbar (fires ZoomTrackBarChange)
  ZoomTrackBar.OnChange:=nil;
  ZoomTrackBar.Position:=newZoom;
  ZoomTrackBar.OnChange:=@ZoomTrackBarChange;

  ZoomSize:=newZoom;
  UpdateSpriteValues;
  lastx:=-1;
  lasty:=-1;
  pWidth:=EasyPNG.Picture1.Width;
  pHeight:=EasyPNG.Picture1.Height;
  SpriteSheetPaintBox.Width:=pWidth*ZoomSize;
  SpriteSheetPaintBox.Height:=pHeight*ZoomSize;

  //keep the anchored pixel under the cursor
  if useAnchor then
  begin
    newScrollX:=Round(pixX * ZoomSize) - anchorX;
    newScrollY:=Round(pixY * ZoomSize) - anchorY;
    if newScrollX < 0 then newScrollX:=0;
    if newScrollY < 0 then newScrollY:=0;
    SpriteSheetScrollBox.HorzScrollBar.Position:=newScrollX;
    SpriteSheetScrollBox.VertScrollBar.Position:=newScrollY;
  end;

  UpdateStatusBar;
  SpriteSheetPaintBox.Invalidate;
end;

procedure TSpriteImportForm.SpriteSheetScrollBoxMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint;
begin
  pt:=SpriteSheetScrollBox.ScreenToClient(MousePos);
  if WheelDelta > 0 then
    ApplyZoom(ZoomSize + 1, True, pt.X, pt.Y)
  else
    ApplyZoom(ZoomSize - 1, True, pt.X, pt.Y);
  Handled:=True;
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
  DisplayPaletteCount:=0;
  BuildDisplayPalette;
  UpdateStatusBar;
end;

procedure TSpriteImportForm.CheckBoxDisplayGridChange(Sender: TObject);
begin
  MnuDisplayGrid.Checked:=CheckBoxDisplayGrid.Checked;
  SpriteSheetPaintBox.Invalidate;
end;

procedure TSpriteImportForm.CheckBoxSnapToGridChange(Sender: TObject);
begin
  MnuSnapGrid.Checked:=CheckBoxSnapToGrid.Checked;
end;

procedure TSpriteImportForm.MnuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TSpriteImportForm.MnuDisplayGridClick(Sender: TObject);
begin
  //toggling the checkbox fires its OnChange which syncs the menu check
  CheckBoxDisplayGrid.Checked:=not CheckBoxDisplayGrid.Checked;
end;

procedure TSpriteImportForm.MnuSnapGridClick(Sender: TObject);
begin
  CheckBoxSnapToGrid.Checked:=not CheckBoxSnapToGrid.Checked;
end;

procedure TSpriteImportForm.MnuZoomInClick(Sender: TObject);
begin
  ApplyZoom(ZoomSize + 1, False);
end;

procedure TSpriteImportForm.MnuZoomOutClick(Sender: TObject);
begin
  ApplyZoom(ZoomSize - 1, False);
end;

function TSpriteImportForm.ZoomXToReal(zx : integer) : integer;
begin
  result:=zx Div ZoomSize;
end;

function TSpriteImportForm.ZoomYToReal(zy : integer) : integer;
begin
  result:=zy Div ZoomSize;
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

  if StatusBar1.Panels.Count >= 1 then
    StatusBar1.Panels[0].Text:='X='+IntToStr(TempX)+' Y='+IntToStr(TempY)+
                               '  X2='+IntToStr(TempX2)+' Y2='+IntToStr(TempY2);
  UpdateStatusBar;
end;

procedure TSpriteImportForm.UpdateStatusBar;
begin
  if StatusBar1.Panels.Count < 5 then exit;

  StatusBar1.Panels[1].Text:='Sprite: '+IntToStr(SpriteWidth)+'x'+IntToStr(SpriteHeight);
  StatusBar1.Panels[2].Text:='Zoom: '+IntToStr(ZoomSize)+'x';

  if (EasyPNG.Picture1.Width > 0) and (EasyPNG.Picture1.Height > 0) then
    StatusBar1.Panels[3].Text:='Sheet: '+IntToStr(EasyPNG.Picture1.Width)+'x'+IntToStr(EasyPNG.Picture1.Height)
  else
    StatusBar1.Panels[3].Text:='Sheet: -';

  StatusBar1.Panels[4].Text:='Palette: '+PaletteComboBox.Text+' ('+NewPaletteComboBox.Text+')';
end;

end.

